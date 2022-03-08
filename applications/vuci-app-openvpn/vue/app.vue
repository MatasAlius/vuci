<template>
  <div class="openvpn">

    <!-- <a-button type="primary" @click="tempCommand()">.--.</a-button><br><br> -->

    <a-button type="primary" @click="showAddInstance"><a-icon type="plus" />New</a-button>
    <a-form v-if="addModal" :label-col="labelCol" :wrapper-col="wrapperCol" @submit.prevent="addInstance">
      <a-form-item label="Name of the instance" required >
        <a-input placeholder="Name of the instance" v-model="inputName" />
      </a-form-item>
      <a-form-item label="Role" required >
        <a-select placeholder="Select a role" @change="inputRoleChange" v-model="inputRole" >
          <a-select-option value="client">
            client
          </a-select-option>
          <a-select-option value="server" :disabled="disableServer">
            server
          </a-select-option>
        </a-select>
      </a-form-item>
      <a-form-item :wrapper-col="{ span: 10, offset: 6 }">
        <a-button type="primary" html-type="submit">
          Add
        </a-button>
      </a-form-item>
    </a-form>

    <a-divider />

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

    <a-modal v-model="editModal" :width="800" @cancel="cancelModal()">
      <template v-if="modalType === 'server'">
        <configuration :type=true :name="instanceName" :instanceData="instanceData" :key="instanceName + tempNumber" @close="closeModal" />
      </template>
      <template v-else>
        <configuration :type=false :name="instanceName" :instanceData="instanceData" :key="instanceName + tempNumber" @close="closeModal" />
      </template>
      <template #footer><div/></template>
    </a-modal>

    <a-divider />
  </div>
</template>

<script>
import Configuration from './components/Configuration'

const columns = [
  {
    dataIndex: 'name',
    key: 'name',
    title: 'Name',
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
    title: '',
    scopedSlots: { customRender: 'button' }
  }
]

export default {
  components: {
    Configuration
  },
  data () {
    return {
      labelCol: { span: 6 },
      wrapperCol: { span: 4 },
      columns,
      editModal: false,
      addModal: false,
      inputName: '',
      inputRole: 'client',
      disableServer: false,
      modalType: '',
      instances: [],
      instancesData: [],
      instanceData: [],
      instanceName: '',
      tempNumber: 0,
      router_lan: '',
      router_mask: ''
    }
  },
  created () {
    this.$rpc.call('openvpnapp', 'getOpenvpn', { }).then(r => {
      this.addData(r)
    })
  },
  timers: {
    getOpenvpnStatus: { time: 5000, autostart: true, immediate: false, repeat: true }
  },
  methods: {
    cancelModal () {
      this.getNewData()
    },
    closeModal () {
      this.getNewData()
      this.tempNumber += 1
      this.editModal = false
    },
    getNewData () {
      this.instances = []
      this.instancesData = []
      this.$rpc.call('openvpnapp', 'getOpenvpn', { }).then(r => {
        this.addData(r)
      })
      this.getOpenvpnStatus()
    },
    addData (data) {
      for (let i = 0; i < Object.keys(data).length; i++) {
        this.instances.push(data[i])
        var instanceStatus = 'Disabled'
        if (data[i].enable === '1') {
          instanceStatus = 'Inactive'
        }
        this.instancesData.push({ key: data[i]['.index'], name: data[i]['.name'], role: data[i].type, status: instanceStatus, switch: data[i].enable })
        this.getOpenvpnStatus()
      }
    },
    getOpenvpnStatus () {
      this.$rpc.call('ubus', 'call', { object: 'service', method: 'list' }).then(r => {
        for (let i = 0; i < Object.keys(this.instancesData).length; i++) {
          var temp = this.instancesData[i].name
          if (this.instancesData[i].role === 'server') {
            if (r.openvpn.length > 0) {
              if (Object.prototype.hasOwnProperty.call(r.openvpn.instances, this.instancesData[i].name)) {
                if (r.openvpn.instances[temp].running && this.instancesData[i].switch === '1') {
                  this.instancesData[i].status = 'Active'
                }
                if (!r.openvpn.instances[temp].running && this.instancesData[i].switch === '1') {
                  this.instancesData[i].status = 'Inactive'
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
    showAddInstance () {
      this.addModal = !this.addModal
      if (this.instancesData.some(e => e.role === 'server')) {
        this.disableServer = true
      } else {
        this.disableServer = false
      }
    },
    addInstance () {
      if (this.inputName.length > 0 && this.inputRole.length > 0) {
        this.addModal = false
        this.$message.success('Configuration added')
        this.$rpc.call('openvpnapp', 'setOne', { name: this.inputName, type: 'openvpn', role: this.inputRole }).then(r => { })
        this.inputName = ''
        this.inputRole = ''
        this.instances = []
        this.instancesData = []
        this.$rpc.call('openvpnapp', 'getOpenvpn', { }).then(r => {
          this.addData(r)
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
          break
        }
      }
      this.$rpc.call('openvpnapp', 'remove', { name: value2 }).then(r => { })
      this.$message.success('Configuration deleted')
    },
    deleteKey (type, value, name, keyType) {
      if (value !== '' && value !== undefined) {
        this.$rpc.call('openvpnapp', 'delete_keys', { path: value, name: name, key_type: keyType }).then(r => { })
      }
    },
    inputRoleChange (value) {
      this.inputRole = value
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
          this.$rpc.call('openvpnapp', 'deleteFile', { path: this.instances[index].status }).then(r => { })
        }
      } else {
        this.instancesData[index].switch = '1'
        this.instances[index].enable = '1'
        this.instancesData[index].status = 'Inactive'
        this.changeEnable(this.instancesData[index].switch, index)
        if (this.instancesData[index].role === 'client') {
          this.$rpc.call('openvpnapp', 'restartOpenVpn', { }).then(r => { })
        }
      }
      this.getOpenvpnStatus()
    },
    changeEnable (enableValue, id) {
      this.$rpc.call('openvpnapp', 'set', { section: this.instances[id]['.name'], option: 'enable', value: enableValue }).then(r => { })
    },
    clickEdit (role, name) {
      this.modalType = role
      this.instanceName = name
      this.instanceData = ''
      this.tempNumber += 1
      for (let i = 0; i < Object.keys(this.instances).length; i++) {
        if (this.instances[i]['.name'] === name) {
          this.instanceData = this.instances[i]
          break
        }
      }
      this.editModal = true
    },
    tempCommand () {
      // istrinti istestavus
      this.$network.load().then(() => {
        console.log('------- ip address -------')
        const iface = this.$network.getInterface('lan')
        if (!iface) {
          this.waninfo = []
          this.wanIsUp = false
          return
        }
        console.log('Lan name: ' + iface.name)
        this.router_mask = this.$uci.get('network', 'lan', 'netmask')
        this.router_lan = iface.getIPv4Addrs()
        console.log('Lan: ', this.router_lan[0])
        console.log('Mask: ', this.router_mask)

        this.$rpc.call('openvpnapp', 'getNetwork', { section: iface.name, option: 'netmask' }).then(r => {
          console.log('------ getNetwork -------')
          console.log(r)
          if (r) {
            if (r.length > 0) {
              this.router_mask = r[0]
              var inputIp = '192.168.1.64'
              var inputMask = '255.255.255.192'
              this.router_mask = '255.255.255.128'
              console.log(this.inSubNet(inputIp, inputMask, this.router_lan[0], this.router_mask))
            }
          }
        })
      })
    },
    ip2long (ip) {
      // istrinti istestavus
      var components = ip.match(/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/)
      if (components) {
        var iplong = 0
        var power = 1
        for (var i = 4; i >= 1; i -= 1) {
          iplong += power * parseInt(components[i])
          power *= 256
        }
        return iplong
      } else return -1
    },
    inSubNet (inputIp, inputMask, routerLan, routerMask) {
      // istrinti istestavus
      var baseIp
      var longIp
      longIp = this.ip2long(inputIp)
      console.log('--------------')
      console.log(inputIp)
      console.log(longIp)
      if (routerMask && ((baseIp = this.ip2long(routerLan)) >= 0)) {
        console.log('Router ip: ' + routerLan)
        console.log('Base ip: ' + baseIp)
        console.log('Router mask: ' + routerMask)
        var range = -this.maskSize(routerMask)
        var longMask = -this.maskSize(inputMask)
        console.log('Router mask size: ' + range)
        console.log('Input mask size: ' + longMask)
        // console.log('Input last ip: ' + rout)
        // return (longIp > baseIp) && (longIp < baseIp + range - 1)
        // return (longIp > baseIp || longIp === baseIp) && ((longIp < baseIp + range - 1) || (longIp === baseIp + range - 1))
        var ipArray = inputIp.match(/^(\d+)\.(\d+)\.(\d+)\.(\d+)$/)
        console.log(ipArray[4])
        var suma = +ipArray[4] + +longMask
        console.log(suma)
        if (+ipArray[4] > 1 && suma > 255) {
          console.log('Checkas: true')
        }
        console.log('Checkas2: ')
        console.log(ipArray[4])
        console.log(longMask)
        console.log(+ipArray[4] === +longMask)
        console.log('-------')
        if (+ipArray[4] === +longMask) {
          return true
        }
        console.log(baseIp + range - 2)
        if ((longIp > baseIp - 1 || longIp === baseIp) && ((longIp < baseIp + range - 1) || (longIp === baseIp + range - 1))) {
          return true
        } else {
          return false
        }
      } else return false
    },
    maskSize (IPaddress) {
      // istrinti istestavus
      var ip = IPaddress.match(/^(\d+)\.(\d+)\.(\d+)\.(\d+)$/)
      if (ip) {
        return (+ip[1] << 24) + (+ip[2] << 16) + (+ip[3] << 8) + (+ip[4])
      }
      return null
    }
  }
}
</script>
