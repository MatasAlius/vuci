<template>
  <div class="openvpn">
    <a-table :columns="columns" :data-source="instancesData">
      <a slot="name" slot-scope="text, record">
        <template v-if="record.role === 'server'">
        {{ text }}_server
        </template>
        <template v-else>
        {{ text }}_client
        </template>
        </a>
      <span slot="status" slot-scope="text">
        <template> {{ text }}</template>
      </span>
      <span slot="switch" slot-scope="text, record">
        <a-switch :checked="record.switch === '1'" @change="switchClick(record.name)" />
      </span>
      <span slot="button" slot-scope="text, record">
        <a-button type="primary" ghost @click="clickEdit(record.role, record.name)">{{ $t('Edit') }}</a-button>
        <a-divider type="vertical" />
        <a-popconfirm
          title="Delete this configuration?"
          ok-text="Yes"
          cancel-text="No"
          @confirm="onRemove(record.key, record.name)"
        >
          <a-button type="danger" ghost>{{ $t('Delete') }}</a-button>
        </a-popconfirm>
      </span>
    </a-table>
    <a-divider />
    <a-form layout="inline" @submit.prevent="addInstance">
      <a-form-item label="Name of the instance" required >
        <a-input placeholder="Name of the instance" v-model="inputName" />
      </a-form-item>
      <a-form-item label="Role" required>
        <a-select placeholder="Select a role" v-model="inputRole">
          <a-select-option value="client">
            client
          </a-select-option>
          <a-select-option value="server" :disabled="disableServer">
            server
          </a-select-option>
        </a-select>
      </a-form-item>
      <a-form-item>
        <a-button type="primary" html-type="submit">
          <a-icon type="plus" />Add instance
        </a-button>
      </a-form-item>
    </a-form>
    <a-modal v-model="editModal" :width="800" @cancel="closeModal()">
      <template v-if="modalType === 'server'">
        <configuration :type=true :name="instanceName" :instanceData="instanceData" :key="instanceName + tempNumber" @close="closeModal" />
      </template>
      <template v-else>
        <configuration :type=false :name="instanceName" :instanceData="instanceData" :key="instanceName + tempNumber" @close="closeModal" />
      </template>
      <template #footer><div/></template>
    </a-modal>
  </div>
</template>

<script>
import Configuration from './components/Configuration'

const columns = [
  {
    title: 'Name',
    dataIndex: 'name',
    key: 'name',
    scopedSlots: { customRender: 'name' }
  },
  {
    title: 'Role',
    dataIndex: 'role',
    key: 'role'
  },
  {
    title: 'Status',
    dataIndex: 'status',
    key: 'status',
    scopedSlots: { customRender: 'status' }
  },
  {
    title: 'Enable/disable',
    dataIndex: 'switch',
    key: 'switch',
    scopedSlots: { customRender: 'switch' }
  },
  {
    scopedSlots: { customRender: 'button' }
  }
]

export default {
  components: {
    Configuration
  },
  data () {
    return {
      columns,
      editModal: false,
      inputName: '',
      inputRole: 'client',
      disableServer: false,
      modalType: '',
      instances: [],
      instancesData: [],
      instanceData: [],
      instanceName: '',
      tempNumber: 0,
      firsttime: false
    }
  },
  created () {
    this.addData()
    this.firsttime = false
  },
  timers: {
    getOpenvpnStatus: { time: 5000, autostart: true, immediate: false, repeat: true }
  },
  methods: {
    closeModal () {
      this.getNewData()
      this.tempNumber += 1
      this.editModal = false
      this.firsttime = false
    },
    getNewData () {
      this.instances = []
      this.instancesData = []
      this.addData()
    },
    addData () {
      var tempRole = this.inputRole
      var tempName = this.inputName
      this.$rpc.call('openvpnapp', 'getOpenvpn', { }).then(data => {
        for (let i = 0; i < Object.keys(data).length; i++) {
          this.instances.push(data[i])
          var instanceStatus = 'Disabled'
          if (data[i].enable === '1') {
            instanceStatus = 'Inactive'
          }
          this.instancesData.push({ key: data[i]['.index'], name: data[i]['.name'], role: data[i].type, status: instanceStatus, switch: data[i].enable })
        }
        if (this.firsttime) {
          this.clickEdit(tempRole, tempName)
        }
        this.getOpenvpnStatus()
        this.serverRoleDisable()
      })
    },
    getOpenvpnStatus () {
      this.$rpc.call('ubus', 'call', { object: 'service', method: 'list' }).then(r => {
        for (let i = 0; i < Object.keys(this.instancesData).length; i++) {
          if (this.instancesData[i].role === 'server') {
            if (r) {
              if (Object.keys(r.openvpn.instances).length > 0) {
                if (Object.prototype.hasOwnProperty.call(r.openvpn.instances, this.instancesData[i].name)) {
                  if (r.openvpn.instances[this.instancesData[i].name].running && this.instancesData[i].switch === '1') {
                    this.instancesData[i].status = 'Active'
                  } else if (!r.openvpn.instances[this.instancesData[i].name].running && this.instancesData[i].switch === '1') {
                    this.instancesData[i].status = 'Inactive'
                  }
                }
              }
            }
          } else if (this.instances[i].status) {
            this.$rpc.call('openvpnapp', 'readFile', { path: this.instances[i].status }).then(r => {
              if (r && r[4] !== undefined) {
                var line = r[4].split(',')
                if (line[1] > 0 && this.instancesData[i].switch === '1') {
                  this.instancesData[i].status = 'Connected'
                } else if (line[1] <= 0 && this.instancesData[i].switch === '1') {
                  this.instancesData[i].status = 'Disconnected'
                }
              }
            })
          }
        }
      })
    },
    addInstance () {
      if (this.inputName.length > 0 && this.inputRole.length > 0) {
        this.$rpc.call('openvpnapp', 'setOne', { name: this.inputName, type: 'openvpn', role: this.inputRole }).then(r => {
          this.$message.success('Configuration added')
          this.firsttime = true
          this.getNewData()
          this.inputName = ''
          this.inputRole = 'client'
        })
      } else {
        this.$message.error('Not all fields are filled')
      }
    },
    onRemove (value, value2) {
      for (var i = 0; i < this.instancesData.length; i++) {
        if (this.instancesData[i].key === value) {
          if (this.instances[i].type === 'server') {
            if (this.instances[i]._auth === 'tls') {
              this.deleteKey('Server', this.instances[i].ca, this.instancesData[i].name, 'ca')
              this.deleteKey('Server', this.instances[i].cert, this.instancesData[i].name, 'cert')
              this.deleteKey('Server', this.instances[i].key, this.instancesData[i].name, 'key')
              this.deleteKey('Server', this.instances[i].dh, this.instancesData[i].name, 'dh')
            } else {
              this.deleteKey('Server', this.instances[i].secret, this.instancesData[i].name, 'secret')
            }
          } else {
            if (this.instances[i]._auth === 'tls') {
              this.deleteKey('Client', this.instances[i].ca, this.instancesData[i].name, 'ca')
              this.deleteKey('Client', this.instances[i].cert, this.instancesData[i].name, 'cert')
              this.deleteKey('Client', this.instances[i].key, this.instancesData[i].name, 'key')
            } else {
              this.deleteKey('Client', this.instances[i].secret, this.instancesData[i].name, 'secret')
            }
          }
          if (Object.prototype.hasOwnProperty.call(this.instances[i], 'status')) {
            if (this.instances[i].status !== '') {
              this.$rpc.call('openvpnapp', 'deleteFile', { path: this.instances[i].status }).then(r => { })
            }
          }
          this.instancesData.splice(i, 1)
          this.instances.splice(i, 1)
          this.serverRoleDisable()
          break
        }
      }
      this.$rpc.call('openvpnapp', 'remove', { name: value2 }).then(r => { this.$uci.apply().then(() => { this.$rpc.call('openvpnapp', 'restartOpenVpn', { }).then(r => { this.$message.success('Configuration deleted') }) }) })
    },
    deleteKey (type, value, name, keyType) {
      if (value !== '' && value !== undefined) {
        this.$rpc.call('openvpnapp', 'delete_keys', { path: value, name: name, key_type: keyType }).then(r => { })
      }
    },
    switchClick (value) {
      var index = 0
      for (let i = 0; i < Object.keys(this.instancesData).length; i++) {
        if (this.instancesData[i].name === value) {
          index = i
          break
        }
      }
      if (this.instancesData[index].switch === '1') {
        this.instancesData[index].switch = '0'
        this.instances[index].enable = '0'
        this.instancesData[index].status = 'Disabled'
        this.changeEnable(this.instancesData[index].switch, index)
        if (this.instancesData[index].role === 'client') {
          if (this.instances[index].status) {
            this.$rpc.call('openvpnapp', 'deleteFile', { path: this.instances[index].status }).then(r => { })
          }
        }
      } else {
        this.instancesData[index].switch = '1'
        this.instances[index].enable = '1'
        this.instancesData[index].status = 'Inactive'
        this.changeEnable(this.instancesData[index].switch, index)
        if (this.instancesData[index].role === 'client') {
          this.$uci.apply().then(() => { this.$rpc.call('openvpnapp', 'restartOpenVpn', { }).then(r => { }) })
        }
      }
      this.getOpenvpnStatus()
    },
    changeEnable (enableValue, id) {
      this.$rpc.call('openvpnapp', 'set', { section: this.instances[id]['.name'], option: 'enable', value: enableValue }).then(r => { this.$uci.apply().then(() => { }) })
    },
    clickEdit (role, name) {
      this.modalType = role
      this.instanceName = name
      this.tempNumber += 1
      this.instanceData = []
      for (let i = 0; i < Object.keys(this.instances).length; i++) {
        if (this.instances[i]['.name'] === name) {
          this.instanceData = this.instances[i]
          break
        }
      }
      this.editModal = true
    },
    serverRoleDisable () {
      if (this.instancesData.some(e => e.role === 'server')) {
        this.disableServer = true
      } else {
        this.disableServer = false
      }
    }
  }
}
</script>
