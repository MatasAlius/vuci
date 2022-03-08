<template>
  <div class="configuration">
    <template v-if="type">
      <a-form>
        <h2><a-icon type="cloud-server" /> {{ name }} configuration (server)</h2>
        <a-divider />
        <a-form-item label="Enable/disable" name="enable" required :label-col="labelCol" :wrapper-col="wrapperCol" >
          <a-switch name="enable" :checked="server.enable" @change="enableServerSwitch" />
        </a-form-item>
        <a-form-item label="Select authentication mode" required :label-col="labelCol" :wrapper-col="wrapperCol" >
          <a-select default-value="static" v-model="authenticationType" @change="handleServerChange">
            <a-select-option value="static">
              Static key
            </a-select-option>
            <a-select-option value="tls">
              TLS
            </a-select-option>
          </a-select>
        </a-form-item>
        <template v-if="authenticationType === 'static'">
          <a-form-item label="Local tunnel endpoint IP" name="local_ip" required :label-col="labelCol" :wrapper-col="wrapperCol">
            <a-input placeholder="Please input local tunnel endpoint IP" v-model="server.local_ip" />
            <p v-if="error.server_local_ip" class="error">Please input local tunnel endpoint IP</p>
          </a-form-item>
          <a-form-item label="Remote tunnel endpoint IP" name="network_ip" required :label-col="labelCol" :wrapper-col="wrapperCol" >
            <a-input placeholder="Please input remote tunnel endpoint IP" v-model="server.network_ip" />
            <p v-if="error.server_network_ip" class="error">Please input remote tunnel endpoint IP</p>
          </a-form-item>
          <a-form-item label="Remote network IP address" name="remote_ip" required :label-col="labelCol" :wrapper-col="wrapperCol" >
            <a-input placeholder="Please input remote network IP address" v-model="server.remote_ip" />
            <p v-if="error.server_remote_ip" class="error">Please input remote network IP address</p>
          </a-form-item>
          <a-form-item label="Remote network netmask" name="network_mask" required :label-col="labelCol" :wrapper-col="wrapperCol" >
            <a-input placeholder="Please input remote network netmask" v-model="server.network_mask" />
            <p v-if="error.server_network_mask" class="error">Please input remote network netmask</p>
          </a-form-item>
          <a-form-item label="Port" name="server_port" :label-col="labelCol" :wrapper-col="wrapperCol" >
            <a-input placeholder="Please input port" v-model="server.port" />
            <p v-if="error.server_port" class="error">Please input port</p>
          </a-form-item>
          <a-form-item label="Static key upload" required :label-col="labelCol" :wrapper-col="wrapperCol" >
            <a-upload action="/upload" @change="onUploadServerStatic" :data="{path: '/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.secretstatic.key'}">
              <a-button size="small" type="primary" icon="upload" @click="temp='/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.secretstatic.key';" :disabled="disableUpload">{{ $t('upgrade.Select File') }}</a-button>
            </a-upload>
            <template v-if="server.secret">
              Uploaded
            </template>
          </a-form-item>
        </template>
        <template v-else>
          <a-form-item label="Virtual network IP address" name="server_ip" required :label-col="labelCol" :wrapper-col="wrapperCol" >
            <a-input placeholder="Please input virtual network IP address" v-model="server.server_ip" />
            <p v-if="error.server_ip" class="error">Please input virtual network IP address</p>
          </a-form-item>
          <a-form-item label="Virtual network netmask" name="server_netmask" required :label-col="labelCol" :wrapper-col="wrapperCol" >
            <a-input placeholder="Please input virtual network netmask" v-model="server.server_netmask" />
            <p v-if="error.server_netmask" class="error">Please input virtual network netmask</p>
          </a-form-item>
          <a-form-item label="Port" name="server_port" :label-col="labelCol" :wrapper-col="wrapperCol" >
            <a-input placeholder="Please input port" v-model="server.port" />
            <p v-if="error.server_port" class="error">Please input port</p>
          </a-form-item>
          <a-form-item label="Certificate authority certificate upload" required :label-col="labelCol" :wrapper-col="wrapperCol">
            <a-upload action="/upload" @change="onUploadServerCaca" :data="{path: '/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.caca.cert.pem'}">
              <a-button size="small" type="primary" icon="upload" @click="temp='/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.caca.cert.pem';" :disabled="disableUpload">{{ $t('upgrade.Select File') }}</a-button>
            </a-upload>
            <template v-if="server.ca">
              Uploaded
            </template>
          </a-form-item>
          <a-form-item label="Server certificate upload" required :label-col="labelCol" :wrapper-col="wrapperCol">
            <a-upload action="/upload" @change="onUploadServerCert" :data="{path: '/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.certserver.cert.pem'}">
              <a-button size="small" type="primary" icon="upload" @click="temp='/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.certserver.cert.pem';" :disabled="disableUpload">{{ $t('upgrade.Select File') }}</a-button>
            </a-upload>
            <template v-if="server.cert">
              Uploaded
            </template>
          </a-form-item>
          <a-form-item label="Server key upload" required :label-col="labelCol" :wrapper-col="wrapperCol">
            <a-upload action="/upload" @change="onUploadServerKey" :data="{path: '/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.keyserver.key.pem'}">
              <a-button size="small" type="primary" icon="upload" @click="temp='/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.keyserver.key.pem';" :disabled="disableUpload">{{ $t('upgrade.Select File') }}</a-button>
            </a-upload>
            <template v-if="server.key">
              Uploaded
            </template>
          </a-form-item>
          <a-form-item label="Diffie Hellman parameters upload" required :label-col="labelCol" :wrapper-col="wrapperCol">
            <a-upload action="/upload" @change="onUploadServerDh" :data="{path: '/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.dhdh.pem'}">
              <a-button size="small" type="primary" icon="upload" @click="temp='/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.dhdh.pem';" :disabled="disableUpload">{{ $t('upgrade.Select File') }}</a-button>
            </a-upload>
            <template v-if="server.dh">
              Uploaded
            </template>
          </a-form-item>
        </template>
        <a-form-item :label-col="labelCol" :wrapper-col="wrapperCol">
          <a-button type="primary" key="submit" @click="applyServerConfig">
            Submit
          </a-button>
        </a-form-item>
      </a-form>
    </template>

    <template v-else>
      <a-form >
        <h2><a-icon type="user" /> {{ name }} configuration (client)</h2>
        <a-divider />
        <a-form-item label="Enable/disable" name="enable" required :label-col="labelCol" :wrapper-col="wrapperCol" >
          <a-switch name="enable" :checked="client.enable" @change="enableClientSwitch" />
        </a-form-item>
        <a-form-item label="Select authentication mode" required :label-col="labelCol" :wrapper-col="wrapperCol" >
          <a-select default-value="static" v-model="authenticationType" @change="handleClientChange">
            <a-select-option value="static">
              Static key
            </a-select-option>
            <a-select-option value="tls">
              TLS
            </a-select-option>
          </a-select>
        </a-form-item>
        <template v-if="authenticationType === 'static'">
          <a-form-item label="Remote host/IP address" name="client_remote" required :label-col="labelCol" :wrapper-col="wrapperCol" >
            <a-input placeholder="Please input remote host/IP address" v-model="client.remote" />
            <p v-if="error.client_remote" class="error">Please input remote host/IP address</p>
          </a-form-item>
          <a-form-item label="Port" name="client_port" :label-col="labelCol" :wrapper-col="wrapperCol" >
            <a-input placeholder="Please input port" v-model="client.port" />
            <p v-if="error.client_port" class="error">Please input port</p>
          </a-form-item>
          <a-form-item label="Local tunnel endpoint IP" name="client_local_ip" required :label-col="labelCol" :wrapper-col="wrapperCol" >
            <a-input placeholder="Please input local tunnel endpoint IP" v-model="client.local_ip" />
            <p v-if="error.client_local_ip" class="error">Please input local tunnel endpoint IP</p>
          </a-form-item>
          <a-form-item label="Remote tunnel endpoint IP" name="client_remote_ip" required :label-col="labelCol" :wrapper-col="wrapperCol" >
            <a-input placeholder="Please input remote tunnel endpoint IP" v-model="client.remote_ip" />
            <p v-if="error.client_remote_ip" class="error">Please input remote tunnel endpoint IP</p>
          </a-form-item>
          <a-form-item label="Remote network IP address" name="client_network_ip" required :label-col="labelCol" :wrapper-col="wrapperCol" >
            <a-input placeholder="Please input remote network IP address" v-model="client.network_ip" />
            <p v-if="error.client_network_ip" class="error">Please input remote network IP address</p>
          </a-form-item>
          <a-form-item label="Remote network netmask" name="client_network_mask" required :label-col="labelCol" :wrapper-col="wrapperCol" >
            <a-input placeholder="Please input remote network netmask" v-model="client.network_mask" />
            <p v-if="error.client_network_mask" class="error">Please input remote network netmask</p>
          </a-form-item>
          <a-form-item label="Static key upload" required :label-col="labelCol" :wrapper-col="wrapperCol">
            <a-upload action="/upload" @change="onUploadClientStatic" :data="{path: '/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.secretstatic.key'}">
              <a-button size="small" type="primary" icon="upload" @click="temp='/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.secretstatic.key';" :disabled="disableUpload">{{ $t('upgrade.Select File') }}</a-button>
            </a-upload>
            <template v-if="client.secret">
              Uploaded
            </template>
          </a-form-item>
        </template>
        <template v-else>
          <a-form-item label="Remote host/IP address" name="client_remote" :label-col="labelCol" :wrapper-col="wrapperCol" required>
            <a-input placeholder="Please input remote host/IP address" v-model="client.remote" />
            <p v-if="error.client_remote" class="error">Please input remote host/IP address</p>
          </a-form-item>
          <a-form-item label="Port" name="client_port" :label-col="labelCol" :wrapper-col="wrapperCol" >
            <a-input placeholder="Please input port" v-model="client.port" />
            <p v-if="error.client_port" class="error">Please input port</p>
          </a-form-item>
          <a-form-item label="Remote network IP address" name="client_network_ip" :label-col="labelCol" :wrapper-col="wrapperCol" >
            <a-input placeholder="Please input remote network IP address" v-model="client.network_ip" />
            <p v-if="error.client_network_ip" class="error">Please input remote network IP address</p>
          </a-form-item>
          <a-form-item label="Remote network netmask" name="client_network_mask" :label-col="labelCol" :wrapper-col="wrapperCol" >
            <a-input placeholder="Please input remote network netmask" v-model="client.network_mask" />
            <p v-if="error.client_network_mask" class="error">Please input remote network netmask</p>
          </a-form-item>
          <a-form-item label="Certificate authority certificate upload" required :label-col="labelCol" :wrapper-col="wrapperCol">
            <a-upload action="/upload" @change="onUploadClientCaca" :data="{path: '/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.caca.cert.pem'}">
              <a-button size="small" type="primary" icon="upload" @click="temp='/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.caca.cert.pem';" :disabled="disableUpload">{{ $t('upgrade.Select File') }}</a-button>
            </a-upload>
            <template v-if="client.ca">
              Uploaded
            </template>
          </a-form-item>
          <a-form-item label="Client certificate upload" required :label-col="labelCol" :wrapper-col="wrapperCol">
            <a-upload action="/upload" @change="onUploadClientCert" :data="{path: '/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.certclient.cert.pem'}">
              <a-button size="small" type="primary" icon="upload" @click="temp='/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.certclient.cert.pem';" :disabled="disableUpload">{{ $t('upgrade.Select File') }}</a-button>
            </a-upload>
            <template v-if="client.cert">
              Uploaded
            </template>
          </a-form-item>
          <a-form-item label="Client key upload" required :label-col="labelCol" :wrapper-col="wrapperCol">
            <a-upload action="/upload" @change="onUploadClientKey" :data="{path: '/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.keyclient.key.pem'}">
              <a-button size="small" type="primary" icon="upload" @click="temp='/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.keyclient.key.pem';" :disabled="disableUpload">{{ $t('upgrade.Select File') }}</a-button>
            </a-upload>
            <template v-if="client.key">
              Uploaded
            </template>
          </a-form-item>
        </template>
        <a-form-item :label-col="labelCol" :wrapper-col="wrapperCol">
          <a-button type="primary" key="submit" @click="applyClientConfig">
            Submit
          </a-button>
        </a-form-item>
      </a-form>
    </template>
  </div>
</template>

<script>
export default {
  name: 'Configuration',
  props: {
    type: Boolean,
    name: String,
    instanceData: Object
  },
  data () {
    return {
      visible: false,
      authenticationType: 'static',
      client: {
        remote: '',
        local_ip: '',
        remote_ip: '',
        network_ip: '',
        network_mask: '',
        enable: false,
        secret: '',
        ca: '',
        cert: '',
        key: '',
        port: ''
      },
      server: {
        local_ip: '',
        remote_ip: '',
        network_ip: '',
        network_mask: '',
        server_netmask: '',
        server_ip: '',
        enable: false,
        secret: '',
        ca: '',
        cert: '',
        key: '',
        dh: '',
        port: ''
      },
      error: {
        server_local_ip: false,
        server_remote_ip: false,
        server_network_ip: false,
        server_network_mask: false,
        server_netmask: false,
        server_ip: false,
        server_port: false,
        client_remote: false,
        client_local_ip: false,
        client_remote_ip: false,
        client_network_ip: false,
        client_network_mask: false,
        client_port: false
      },
      labelCol: {
        span: 8
      },
      wrapperCol: {
        span: 10
      },
      router_lan: '',
      router_mask: '',
      temp: '',
      disableUpload: false
    }
  },
  created () {
    this.addInfo()
    this.$network.load().then(() => {
      const iface = this.$network.getInterface('lan')
      if (!iface) {
        this.waninfo = []
        this.wanIsUp = false
        return
      }
      this.waninfo = [
        [this.$t('home.IP Address'), iface.getIPv4Addrs().join(', ')],
        [this.$t('home.Gateway'), iface.getIPv4Gateway()],
        ['DNS', iface.getDNSAddrs().join(', ')]
      ]
      this.router_lan = iface.getIPv4Addrs()
      this.$rpc.call('openvpnapp', 'getNetwork', { section: iface.name, option: 'netmask' }).then(r => {
        if (r) {
          if (r.length > 0) {
            this.router_mask = r[0]
            this.router_lan = this.router_lan[0]
          }
        }
      })
    })
  },
  methods: {
    validateIp (value) {
      if (/^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(value)) {
        return false
      } else {
        return true // kai blogas ip
      }
    },
    validateMask (value) {
      if (/^((128|192|224|240|248|252|254)\.0\.0\.0)|(255\.(((0|128|192|224|240|248|252|254)\.0\.0)|(255\.(((0|128|192|224|240|248|252|254)\.0)|255\.(0|128|192|224|240|248|252|254|255)))))$/.test(value)) {
        return false
      } else {
        return true // kai blogas mask
      }
    },
    validateNumber (value) {
      if (/^\d+$/.test(value)) {
        return true
      } else {
        return false
      }
    },
    onClose () {
      this.visible = false
    },
    ip2long (ip) {
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
      var baseIp
      var longIp
      longIp = this.ip2long(inputIp)
      if (routerMask && ((baseIp = this.ip2long(routerLan)) >= 0)) {
        var range = -this.maskSize(routerMask)
        var longMask = -this.maskSize(inputMask)
        console.log('Router mask size: ' + range)
        console.log('Input mask size: ' + longMask)
        if ((longIp > baseIp - 1 || longIp === baseIp) && ((longIp < baseIp + range - 1) || (longIp === baseIp + range - 1))) {
          return true
        } else {
          var ipArray = inputIp.match(/^(\d+)\.(\d+)\.(\d+)\.(\d+)$/)
          console.log(ipArray[4])
          var suma = +ipArray[4] + +longMask - +1
          console.log(suma)
          if (+ipArray[4] > 1 && suma > 256) {
            return true
          }
          if (+ipArray[4] === +longMask && +ipArray[4] !== 255) {
            return true
          }
          if ((baseIp > longIp - 1 || baseIp === longIp) && ((baseIp < longIp + longMask - 1) || (baseIp === longIp + longMask - 1))) {
            return true
          }
        }
      } else return false
    },
    maskSize (IPaddress) {
      var ip = IPaddress.match(/^(\d+)\.(\d+)\.(\d+)\.(\d+)$/)
      if (ip) {
        return (+ip[1] << 24) + (+ip[2] << 16) + (+ip[3] << 8) + (+ip[4])
      }
      return null
    },
    handleServerChange (value) {
      this.authenticationType = value
      if (value === 'static') {
        this.deleteKey('Server', this.server.ca, this.name, 'ca')
        this.deleteKey('Server', this.server.cert, this.name, 'cert')
        this.deleteKey('Server', this.server.key, this.name, 'key')
        this.deleteKey('Server', this.server.dh, this.name, 'dh')
        this.server.ca = ''
        this.server.cert = ''
        this.server.key = ''
        this.server.dh = ''
        this.instanceData.ca = ''
        this.instanceData.cert = ''
        this.instanceData.key = ''
        this.instanceData.dh = ''
      } else {
        this.deleteKey('Server', this.server.secret, this.name, 'secret')
        this.server.secret = ''
        this.instanceData.secret = ''
      }
    },
    handleClientChange (value) {
      this.authenticationType = value
      if (value === 'static') {
        this.deleteKey('Client', this.client.ca, this.name, 'ca')
        this.deleteKey('Client', this.client.cert, this.name, 'cert')
        this.deleteKey('Client', this.client.key, this.name, 'key')
        this.client.ca = ''
        this.client.cert = ''
        this.client.key = ''
        this.instanceData.ca = ''
        this.instanceData.cert = ''
        this.instanceData.key = ''
      } else {
        this.deleteKey('Client', this.client.secret, this.name, 'secret')
        this.client.secret = ''
        this.instanceData.secret = ''
      }
    },
    deleteKey (type, value, name, keyType) {
      if (value !== '' && value !== undefined) {
        this.$rpc.call('openvpnapp', 'delete_keys', { path: value, name: name, key_type: keyType }).then(r => { })
      }
    },
    addInfo () {
      if (this.instanceData.type === 'server') {
        if (Object.prototype.hasOwnProperty.call(this.instanceData, 'enable')) {
          if (this.instanceData.enable === '1') {
            this.server.enable = true
          } else {
            this.server.enable = false
          }
        }
        if (Object.prototype.hasOwnProperty.call(this.instanceData, '_auth')) {
          if (this.instanceData._auth === 'skey') {
            this.authenticationType = 'static'
            if (Object.prototype.hasOwnProperty.call(this.instanceData, 'local_ip')) {
              this.server.local_ip = this.instanceData.local_ip
            }
            if (Object.prototype.hasOwnProperty.call(this.instanceData, 'remote_ip')) {
              this.server.remote_ip = this.instanceData.remote_ip
            }
            if (Object.prototype.hasOwnProperty.call(this.instanceData, 'network_ip')) {
              this.server.network_ip = this.instanceData.network_ip
            }
            if (Object.prototype.hasOwnProperty.call(this.instanceData, 'network_mask')) {
              this.server.network_mask = this.instanceData.network_mask
            }
            this.server.secret = this.instanceData.secret
            this.server.port = this.instanceData.port
          } else {
            this.authenticationType = 'tls'
            if (Object.prototype.hasOwnProperty.call(this.instanceData, 'server_ip')) {
              this.server.server_ip = this.instanceData.server_ip
            }
            if (Object.prototype.hasOwnProperty.call(this.instanceData, 'server_netmask')) {
              this.server.server_netmask = this.instanceData.server_netmask
            }
            this.server.port = this.instanceData.port
            this.server.ca = this.instanceData.ca
            this.server.cert = this.instanceData.cert
            this.server.key = this.instanceData.key
            this.server.dh = this.instanceData.dh
          }
        }
      } else {
        if (Object.prototype.hasOwnProperty.call(this.instanceData, 'enable')) {
          if (this.instanceData.enable === '1') {
            this.client.enable = true
          } else {
            this.client.enable = false
          }
        }
        if (Object.prototype.hasOwnProperty.call(this.instanceData, '_auth')) {
          if (this.instanceData._auth === 'skey') {
            this.authenticationType = 'static'
            if (Object.prototype.hasOwnProperty.call(this.instanceData, 'remote')) {
              this.client.remote = this.instanceData.remote
            }
            if (Object.prototype.hasOwnProperty.call(this.instanceData, 'local_ip')) {
              this.client.local_ip = this.instanceData.local_ip
            }
            if (Object.prototype.hasOwnProperty.call(this.instanceData, 'remote_ip')) {
              this.client.remote_ip = this.instanceData.remote_ip
            }
            if (Object.prototype.hasOwnProperty.call(this.instanceData, 'network_ip')) {
              this.client.network_ip = this.instanceData.network_ip
            }
            if (Object.prototype.hasOwnProperty.call(this.instanceData, 'network_mask')) {
              this.client.network_mask = this.instanceData.network_mask
            }
            this.client.port = this.instanceData.port
            this.client.secret = this.instanceData.secret
          } else {
            this.authenticationType = 'tls'
            if (Object.prototype.hasOwnProperty.call(this.instanceData, 'remote')) {
              this.client.remote = this.instanceData.remote
            }
            if (Object.prototype.hasOwnProperty.call(this.instanceData, 'server_ip')) {
              this.client.server_ip = this.instanceData.server_ip
            }
            if (Object.prototype.hasOwnProperty.call(this.instanceData, 'server_netmask')) {
              this.client.server_netmask = this.instanceData.server_netmask
            }
            if (Object.prototype.hasOwnProperty.call(this.instanceData, 'network_ip')) {
              this.client.network_ip = this.instanceData.network_ip
            }
            if (Object.prototype.hasOwnProperty.call(this.instanceData, 'network_mask')) {
              this.client.network_mask = this.instanceData.network_mask
            }
            this.client.port = this.instanceData.port
            this.client.ca = this.instanceData.ca
            this.client.cert = this.instanceData.cert
            this.client.key = this.instanceData.key
          }
        }
      }
    },
    applyServerConfig () {
      var check = false
      if (this.authenticationType === 'static') {
        if (Object.prototype.hasOwnProperty.call(this.instanceData, 'secret')) {
          if (this.server.secret.length <= 0 && this.instanceData.secret.length > 0) {
            this.server.secret = this.instanceData.secret
          }
        }
        this.error.server_local_ip = false
        if (this.server.local_ip.length <= 0 || this.validateIp(this.server.local_ip)) {
          check = true
          this.error.server_local_ip = true
          if (this.validateIp(this.server.local_ip) && this.server.local_ip.length > 0) {
            this.$message.error('Wrong IP address')
          }
        }
        this.error.server_network_ip = false
        if (this.server.network_ip.length <= 0 || this.validateIp(this.server.network_ip)) {
          check = true
          this.error.server_network_ip = true
          if (this.validateIp(this.server.network_ip) && this.server.network_ip.length > 0) {
            this.$message.error('Wrong IP address')
          }
        }
        this.error.server_remote_ip = false
        if (this.server.remote_ip.length <= 0 || this.validateIp(this.server.remote_ip)) {
          check = true
          this.error.server_remote_ip = true
          if (this.validateIp(this.server.remote_ip) && this.server.remote_ip.length > 0) {
            this.$message.error('Wrong IP address')
          }
        }
        this.error.server_remote_ip = false
        if (this.server.remote_ip.length > 0 && this.inSubNet(this.server.remote_ip, this.server.network_mask, this.router_lan, this.router_mask)) {
          check = true
          this.error.server_remote_ip = true
          this.$message.error('Remote network IP address is in router\'s Lan IP interval or bad remote network netmask')
        }
        this.error.server_network_mask = false
        if (this.server.network_mask.length <= 0 || this.validateMask(this.server.network_mask)) {
          check = true
          this.error.server_network_mask = true
          if (this.validateMask(this.server.network_mask) && this.server.network_mask.length > 0) {
            this.$message.error('Wrong netmask')
          }
        }
        if (this.server.remote_ip === this.router_lan[0]) {
          this.$message.error('Remote network IP is same as the router\'s LAN address')
          check = true
        }
        if (this.server.secret === undefined) {
          this.$message.error('Upload static key file')
        } else {
          if (this.server.secret === '') {
            this.$message.error('Upload static key file')
          }
          if (!check && this.server.secret.length > 0) {
            if (!this.validateNumber(this.server.port)) {
              this.server.port = 1194
            }
            var enableValue = 0
            if (this.server.enable) {
              enableValue = 1
            } else {
              enableValue = 0
            }
            this.$message.success('Configuration applied')
            this.$rpc.call('openvpnapp', 'setServerStaticKey', { name: this.name, type: 'openvpn', keepalive: '10 120', _name: this.name, data_ciphers: 'BF-CBC', persist_key: '1', port: this.server.port, persist_tun: '1', dev: 'tun_s_server', verb: '5', typetype: 'server', proto: 'udp', _auth: 'skey', cipher: 'BF-CBC', local_ip: this.server.local_ip, remote_ip: this.server.remote_ip, network_ip: this.server.network_ip, network_mask: this.server.network_mask, secret: this.server.secret, enable: enableValue }).then(r => { })
            this.onCloseModal()
          } else {
            this.$message.error('Not all fields are filled')
          }
        }
      } else {
        if (Object.prototype.hasOwnProperty.call(this.instanceData, 'ca')) {
          if (this.server.ca.length <= 0 && this.instanceData.ca.length > 0) {
            this.server.ca = this.instanceData.ca
          }
        }
        if (Object.prototype.hasOwnProperty.call(this.instanceData, 'cert')) {
          if (this.server.cert.length <= 0 && this.instanceData.cert.length > 0) {
            this.server.cert = this.instanceData.cert
          }
        }
        if (Object.prototype.hasOwnProperty.call(this.instanceData, 'key')) {
          if (this.server.key.length <= 0 && this.instanceData.key.length > 0) {
            this.server.key = this.instanceData.key
          }
        }
        if (Object.prototype.hasOwnProperty.call(this.instanceData, 'dh')) {
          if (this.server.dh.length <= 0 && this.instanceData.dh.length > 0) {
            this.server.dh = this.instanceData.dh
          }
        }
        this.error.server_ip = false
        if (this.server.server_ip.length <= 0 || this.validateIp(this.server.server_ip)) {
          check = true
          this.error.server_ip = true
          if (this.validateIp(this.server.server_ip) && this.server.server_ip.length > 0) {
            this.$message.error('Wrong IP address')
          }
        }
        this.error.server_netmask = false
        if (this.server.server_netmask.length <= 0 || this.validateMask(this.server.server_netmask)) {
          check = true
          this.error.server_netmask = true
          if (this.validateMask(this.server.server_netmask) && this.server.server_netmask.length > 0) {
            this.$message.error('Wrong netmask')
          }
        }
        if (this.server.ca === undefined || this.server.cert === undefined || this.server.key === undefined || this.server.dh === undefined) {
          this.$message.error('Upload needed files')
        } else {
          if (this.server.ca === '') {
            this.$message.error('Upload certificate authority certificate file')
          }
          if (this.server.cert === '') {
            this.$message.error('Upload server certificate file')
          }
          if (this.server.key === '') {
            this.$message.error('Upload server key file')
          }
          if (this.server.dh === '') {
            this.$message.error('Upload Diffie Hellman parameters file')
          }
          if (!check && this.server.ca.length > 0 && this.server.cert.length > 0 && this.server.key.length > 0 && this.server.dh.length > 0) {
            if (!this.validateNumber(this.server.port)) {
              this.server.port = 1194
            }
            var enableValue2 = 0
            if (this.server.enable) {
              enableValue2 = 1
            } else {
              enableValue2 = 0
            }
            this.$message.success('Configuration applied')
            this.$rpc.call('openvpnapp', 'setServerTls', { name: this.name, type: 'openvpn', keepalive: '10 120', _name: this.name, _tls_cipher: 'all', data_ciphers: 'BF-CBC', persist_key: '1', port: this.server.port, persist_tun: '1', dev: 'tun_s_server', verb: '5', typetype: 'server', proto: 'udp', _auth: 'tls', cipher: 'BF-CBC', server_ip: this.server.server_ip, server_netmask: this.server.server_netmask, auth: 'sha1', _tls_auth: 'none', ca: this.server.ca, cert: this.server.cert, key: this.server.key, dh: this.server.dh, tls_server: 1, client_config_dir: '/etc/openvpn/ccd', upload_files: 4, enable: enableValue2, push: 'route 192.168.145.0 255.255.255.0' }).then(r => { })
            this.onCloseModal()
          } else {
            this.$message.error('Not all fields are filled')
          }
        }
      }
    },
    applyClientConfig () {
      var check = false
      this.error.client_remote = false
      if (this.client.remote.length <= 0 || this.validateIp(this.client.remote)) {
        check = true
        this.error.client_remote = true
        if (this.validateIp(this.client.remote) && this.client.remote.length > 0) {
          this.$message.error('Wrong IP address')
        }
      }
      this.error.client_network_ip = false
      if (this.client.network_ip.length > 0 && this.inSubNet(this.client.network_ip, this.client.network_mask, this.router_lan, this.router_mask)) {
        check = true
        this.error.client_network_ip = true
        this.$message.error('Remote network IP address is in router\'s Lan IP interval or bad remote network netmask')
      }
      if (this.authenticationType === 'static') {
        if (Object.prototype.hasOwnProperty.call(this.instanceData, 'secret')) {
          if (this.client.secret.length <= 0 && this.instanceData.secret.length > 0) {
            this.client.secret = this.instanceData.secret
          }
        }
        this.error.client_local_ip = false
        if (this.client.local_ip.length <= 0 || this.validateIp(this.client.local_ip)) {
          check = true
          this.error.client_local_ip = true
          if (this.validateIp(this.client.local_ip) && this.client.local_ip.length > 0) {
            this.$message.error('Wrong IP address')
          }
        }
        this.error.client_remote_ip = false
        if (this.client.remote_ip.length <= 0 || this.validateIp(this.client.remote_ip)) {
          check = true
          this.error.client_remote_ip = true
          if (this.validateIp(this.client.remote_ip) && this.client.remote_ip.length > 0) {
            this.$message.error('Wrong IP address')
          }
        }
        this.error.client_network_ip = false
        if (this.client.network_ip.length <= 0 || this.validateIp(this.client.network_ip)) {
          check = true
          this.error.client_network_ip = true
          if (this.validateIp(this.client.network_ip) && this.client.network_ip.length > 0) {
            this.$message.error('Wrong IP address')
          }
        }
        this.error.client_network_mask = false
        if (this.client.network_mask.length <= 0 || this.validateMask(this.client.network_mask)) {
          check = true
          this.error.client_network_mask = true
          if (this.validateMask(this.client.network_mask) && this.client.network_mask.length > 0) {
            this.$message.error('Wrong netmask')
          }
        }
        if (this.client.network_ip === this.router_lan[0]) {
          this.$message.error('Remote network IP is same as the router\'s LAN address')
          check = true
        }
        if (this.client.secret === undefined) {
          this.$message.error('Upload static key file')
        } else {
          if (this.client.secret === '') {
            this.$message.error('Upload static key file')
          }
          if (!check && this.client.secret.length > 0) {
            if (!this.validateNumber(this.client.port)) {
              this.client.port = 1194
            }
            var enableValue = 0
            if (this.client.enable) {
              enableValue = 1
            } else {
              enableValue = 0
            }
            this.$message.success('Configuration applied')
            var statusFile2 = '/tmp/openvpn-status_' + this.name + '.log'
            this.$rpc.call('openvpnapp', 'setClientStaticKey', { name: this.name, type: 'openvpn', keepalive: '10 120', _name: this.name, data_ciphers: 'BF-CBC', nobind: '1', persist_key: '1', port: this.client.port, persist_tun: '1', dev: 'tun_c_' + this.name, status: statusFile2, verb: '5', typetype: 'client', proto: 'udp', _auth: 'skey', cipher: 'BF-CBC', remote: this.client.remote, resolv_retry: 'infinite', local_ip: this.client.local_ip, remote_ip: this.client.remote_ip, network_ip: this.client.network_ip, network_mask: this.client.network_mask, secret: this.client.secret, upload_files: 1, _tls_auth: 'none', enable: enableValue }).then(r => { })
            // this.$rpc.call('openvpnapp', 'createFile', { path: statusFile2 }).then(r => { })
            this.onCloseModal()
          } else {
            this.$message.error('Not all fields are filled')
          }
        }
      } else {
        if (Object.prototype.hasOwnProperty.call(this.instanceData, 'ca')) {
          if (this.client.ca.length <= 0 && this.instanceData.ca.length > 0) {
            this.client.ca = this.instanceData.ca
          }
        }
        if (Object.prototype.hasOwnProperty.call(this.instanceData, 'cert')) {
          if (this.client.cert.length <= 0 && this.instanceData.cert.length > 0) {
            this.client.cert = this.instanceData.cert
          }
        }
        if (Object.prototype.hasOwnProperty.call(this.instanceData, 'key')) {
          if (this.client.key.length <= 0 && this.instanceData.key.length > 0) {
            this.client.key = this.instanceData.key
          }
        }
        if (this.client.ca === undefined || this.client.cert === undefined || this.client.key === undefined) {
          this.$message.error('Upload needed files')
        } else {
          this.error.client_network_ip = false
          if (this.client.network_ip.length > 0 && this.client.network_mask.length <= 0) {
            check = true
            this.error.network_mask = true
            this.$message.error('Input network mask')
          } else if (this.client.network_mask.length > 0 && this.client.network_ip.length <= 0) {
            check = true
            this.error.network_ip = true
            this.$message.error('Input network ip')
          }
          if (this.client.network_ip.length > 0 && this.validateIp(this.client.network_ip)) {
            check = true
            this.error.client_network_ip = true
            this.$message.error('Wrong IP address')
          }
          this.error.client_network_mask = false
          if (this.client.network_mask.length > 0 && this.validateMask(this.client.network_mask)) {
            check = true
            this.error.client_network_mask = true
            this.$message.error('Wrong netmask')
          }
          if (this.client.ca === '') {
            this.$message.error('Upload certificate authority certificate file')
          }
          if (this.client.cert === '') {
            this.$message.error('Upload client certificate file')
          }
          if (this.client.key === '') {
            this.$message.error('Upload client certificate file')
          }
          if (!check && this.client.ca.length > 0 && this.client.cert.length > 0 && this.client.key.length > 0) {
            if (!this.validateNumber(this.client.port)) {
              this.client.port = 1194
            }
            var enableValue2 = 0
            if (this.client.enable) {
              enableValue2 = 1
            } else {
              enableValue2 = 0
            }
            this.$message.success('Configuration applied')
            var statusFile = '/tmp/openvpn-status_' + this.name + '.log'
            this.$rpc.call('openvpnapp', 'setClientTls', { name: this.name, type: 'openvpn', keepalive: '10 120', _name: this.name, _tls_cipher: 'all', data_ciphers: 'BF-CBC', nobind: '1', persist_key: '1', port: this.client.port, persist_tun: '1', dev: 'tun_c_' + this.name, status: statusFile, verb: '5', typetype: 'client', proto: 'udp', _auth: 'tls', cipher: 'BF-CBC', remote: this.client.remote, resolv_retry: 'infinite', auth: 'sha1', _tls_auth: 'none', ca: this.client.ca, cert: this.client.cert, key: this.client.key, upload_files: 3, tls_client: '1', client: '1', enable: enableValue2, network_ip: this.client.network_ip, network_mask: this.client.network_mask }).then(r => { })
            // this.$rpc.call('openvpnapp', 'createFile', { path: statusFile }).then(r => { })
            this.onCloseModal()
          } else {
            this.$message.error('Not all fields are filled')
          }
        }
      }
    },
    onUploadServerStatic (info) {
      if (this.onUpload(info)) {
        this.disableUpload = false
        this.server.secret = this.temp
        this.temp = ''
      }
    },
    onUploadServerCaca (info) {
      if (this.onUpload(info)) {
        this.disableUpload = false
        this.server.ca = this.temp
        this.temp = ''
      }
    },
    onUploadServerCert (info) {
      if (this.onUpload(info)) {
        this.disableUpload = false
        this.server.cert = this.temp
        this.temp = ''
      }
    },
    onUploadServerKey (info) {
      if (this.onUpload(info)) {
        this.disableUpload = false
        this.server.key = this.temp
        this.temp = ''
      }
    },
    onUploadServerDh (info) {
      if (this.onUpload(info)) {
        this.disableUpload = false
        this.server.dh = this.temp
        this.temp = ''
      }
    },
    onUploadClientStatic (info) {
      if (this.onUpload(info)) {
        this.disableUpload = false
        this.client.secret = this.temp
        this.temp = ''
      }
    },
    onUploadClientCaca (info) {
      if (this.onUpload(info)) {
        this.disableUpload = false
        this.client.ca = this.temp
        this.temp = ''
      }
    },
    onUploadClientCert (info) {
      if (this.onUpload(info)) {
        this.disableUpload = false
        this.client.cert = this.temp
        this.temp = ''
      }
    },
    onUploadClientKey (info) {
      if (this.onUpload(info)) {
        this.disableUpload = false
        this.client.key = this.temp
        this.temp = ''
      }
    },
    onUpload (info) {
      const file = info.file
      const status = file.status
      if (status === 'uploading') {
        this.disableUpload = true
        return false
      }
      if (status === 'removed') {
        this.disableUpload = false
        this.temp = ''
        return false
      }
      info.fileList.length = 0
      if (status !== 'done') {
        this.$message.error(`upload '${file.name}' failed.`)
        this.disableUpload = false
        this.temp = ''
        return false
      } else {
        this.$message.success(`file '${file.name}' uploaded`)
        this.disableUpload = false
        return true
      }
    },
    enableServerSwitch () {
      this.server.enable = !this.server.enable
      this.changeEnable(this.server.enable)
    },
    enableClientSwitch () {
      this.client.enable = !this.client.enable
      this.changeEnable(this.client.enable)
    },
    changeEnable (enableValue) {
      var value = 0
      if (enableValue) {
        value = 1
      } else {
        value = 0
      }
      this.$rpc.call('openvpnapp', 'set', { section: this.name, option: 'enable', value: value }).then(r => { })
    },
    onCloseModal () {
      this.$emit('close')
    }
  }
}
</script>

<style lang="stylus">
.error {
  color: red;
}
</style>
