<template>
  <div class="configuration">
    <a-form>
      <template v-if="type">
          <h2><a-icon type="cloud-server" /> {{ name }} configuration (server)</h2>
          <a-divider />
          <a-form-item label="Enable/disable" name="enable" required :label-col="labelCol" :wrapper-col="wrapperCol" >
            <a-switch name="enable" :checked="server.enable" @change="enableServerSwitch" />
          </a-form-item>
      </template>
      <template v-else>
          <h2><a-icon type="user" /> {{ name }} configuration (client)</h2>
          <a-divider />
          <a-form-item label="Enable/disable" name="enable" required :label-col="labelCol" :wrapper-col="wrapperCol" >
            <a-switch name="enable" :checked="client.enable" @change="enableClientSwitch" />
          </a-form-item>
      </template>
          <a-form-item label="Select authentication mode" required :label-col="labelCol" :wrapper-col="wrapperCol" >
            <a-select default-value="static" v-model="authenticationType" @change="handleChange">
              <a-select-option value="static">
                Static key
              </a-select-option>
              <a-select-option value="tls">
                TLS
              </a-select-option>
            </a-select>
          </a-form-item>
      <template v-if="type">
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
                <a-button size="small" type="primary" icon="upload" @click="tempName='/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.secretstatic.key';" :disabled="disableUpload">{{ $t('upgrade.Select File') }}</a-button>
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
                <a-button size="small" type="primary" icon="upload" @click="tempName='/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.caca.cert.pem';" :disabled="disableUpload">{{ $t('upgrade.Select File') }}</a-button>
              </a-upload>
              <template v-if="server.ca">
                Uploaded
              </template>
            </a-form-item>
            <a-form-item label="Server certificate upload" required :label-col="labelCol" :wrapper-col="wrapperCol">
              <a-upload action="/upload" @change="onUploadServerCert" :data="{path: '/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.certserver.cert.pem'}">
                <a-button size="small" type="primary" icon="upload" @click="tempName='/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.certserver.cert.pem';" :disabled="disableUpload">{{ $t('upgrade.Select File') }}</a-button>
              </a-upload>
              <template v-if="server.cert">
                Uploaded
              </template>
            </a-form-item>
            <a-form-item label="Server key upload" required :label-col="labelCol" :wrapper-col="wrapperCol">
              <a-upload action="/upload" @change="onUploadServerKey" :data="{path: '/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.keyserver.key.pem'}">
                <a-button size="small" type="primary" icon="upload" @click="tempName='/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.keyserver.key.pem';" :disabled="disableUpload">{{ $t('upgrade.Select File') }}</a-button>
              </a-upload>
              <template v-if="server.key">
                Uploaded
              </template>
            </a-form-item>
            <a-form-item label="Diffie Hellman parameters upload" required :label-col="labelCol" :wrapper-col="wrapperCol">
              <a-upload action="/upload" @change="onUploadServerDh" :data="{path: '/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.dhdh.pem'}">
                <a-button size="small" type="primary" icon="upload" @click="tempName='/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.dhdh.pem';" :disabled="disableUpload">{{ $t('upgrade.Select File') }}</a-button>
              </a-upload>
              <template v-if="server.dh">
                Uploaded
              </template>
            </a-form-item>
          </template>
      </template>

      <template v-else>
        <a-form-item label="Remote host/IP address" name="client_remote" :label-col="labelCol" :wrapper-col="wrapperCol" required>
          <a-input placeholder="Please input remote host/IP address" v-model="client.remote" />
          <p v-if="error.client_remote" class="error">Please input remote host/IP address</p>
        </a-form-item>
        <template v-if="authenticationType === 'static'">
          <a-form-item label="Port" name="client_port" :label-col="labelCol" :wrapper-col="wrapperCol" required >
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
          <a-form-item label="Remote network IP address" name="client_network_ip"  :label-col="labelCol" :wrapper-col="wrapperCol" >
            <a-input placeholder="Please input remote network IP address" v-model="client.network_ip" />
            <p v-if="error.client_network_ip" class="error">Please input remote network IP address</p>
          </a-form-item>
          <a-form-item label="Remote network netmask" name="client_network_mask" :label-col="labelCol" :wrapper-col="wrapperCol" >
            <a-input placeholder="Please input remote network netmask" v-model="client.network_mask" />
            <p v-if="error.client_network_mask" class="error">Please input remote network netmask</p>
          </a-form-item>
          <a-form-item label="Static key upload" required :label-col="labelCol" :wrapper-col="wrapperCol">
            <a-upload action="/upload" @change="onUploadClientStatic" :data="{path: '/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.secretstatic.key'}">
              <a-button size="small" type="primary" icon="upload" @click="tempName='/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.secretstatic.key';" :disabled="disableUpload">{{ $t('upgrade.Select File') }}</a-button>
            </a-upload>
            <template v-if="client.secret">
              Uploaded
            </template>
          </a-form-item>
        </template>
        <template v-else>
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
              <a-button size="small" type="primary" icon="upload" @click="tempName='/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.caca.cert.pem';" :disabled="disableUpload">{{ $t('upgrade.Select File') }}</a-button>
            </a-upload>
            <template v-if="client.ca">
              Uploaded
            </template>
          </a-form-item>
          <a-form-item label="Client certificate upload" required :label-col="labelCol" :wrapper-col="wrapperCol">
            <a-upload action="/upload" @change="onUploadClientCert" :data="{path: '/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.certclient.cert.pem'}">
              <a-button size="small" type="primary" icon="upload" @click="tempName='/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.certclient.cert.pem';" :disabled="disableUpload">{{ $t('upgrade.Select File') }}</a-button>
            </a-upload>
            <template v-if="client.cert">
              Uploaded
            </template>
          </a-form-item>
          <a-form-item label="Client key upload" required :label-col="labelCol" :wrapper-col="wrapperCol">
            <a-upload action="/upload" @change="onUploadClientKey" :data="{path: '/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.keyclient.key.pem'}">
              <a-button size="small" type="primary" icon="upload" @click="tempName='/etc/vuci-upload/openvpn/cbid.openvpn.' + name + '.keyclient.key.pem';" :disabled="disableUpload">{{ $t('upgrade.Select File') }}</a-button>
            </a-upload>
            <template v-if="client.key">
              Uploaded
            </template>
          </a-form-item>
        </template>
      </template>
      <a-form-item :label-col="labelCol" :wrapper-col="wrapperCol">
        <a-button type="primary" key="submit" @click="applyConfig(type)">
          Submit
        </a-button>
      </a-form-item>
    </a-form>
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
      tempName: '',
      disableUpload: false,
      check: false
    }
  },
  created () {
    this.addInfo()
    this.$network.load().then(() => {
      const iface = this.$network.getInterface('lan')
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
      if (/^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(value)) return false
      else return true
    },
    validateMask (value) {
      if (/^((128|192|224|240|248|252|254)\.0\.0\.0)|(255\.(((0|128|192|224|240|248|252|254)\.0\.0)|(255\.(((0|128|192|224|240|248|252|254)\.0)|255\.(0|128|192|224|240|248|252|254|255)))))$/.test(value)) return false
      else return true
    },
    validateNumber (value) {
      if (/^\d+$/.test(value)) return true
      else return false
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
        var ipArray = routerLan.match(/^(\d+)\.(\d+)\.(\d+)\.(\d+)$/)
        var temp = 0
        if (+ipArray[4] !== 0) temp = 1
        if ((longIp > baseIp - temp || longIp === baseIp) && ((longIp < baseIp + range - temp) || (longIp === baseIp + range - +1 - temp))) {
          return true
        } else {
          ipArray = inputIp.match(/^(\d+)\.(\d+)\.(\d+)\.(\d+)$/)
          var suma = +ipArray[4] + +longMask - +1
          if (+ipArray[4] > 1 && suma > 256) return true
          if (+ipArray[4] === +longMask && +ipArray[4] !== 255) return true
          temp = 0
          if (+ipArray[4] !== 0) temp = 1
          if ((baseIp > longIp - temp || baseIp === longIp) && ((baseIp < longIp + longMask - +1 - temp) || (baseIp === longIp + longMask - +1 - temp))) {
            return true
          }
        }
      } else return false
    },
    maskSize (IPaddress) {
      var ip = IPaddress.match(/^(\d+)\.(\d+)\.(\d+)\.(\d+)$/)
      if (ip) return (+ip[1] << 24) + (+ip[2] << 16) + (+ip[3] << 8) + (+ip[4])
      return null
    },
    handleChange (value) {
      this.authenticationType = value
      if (value === 'static') {
        this.instanceData.ca = ''
        this.instanceData.cert = ''
        this.instanceData.key = ''
        if (this.type) {
          this.deleteKey('Server', this.server.ca, this.name, 'ca')
          this.deleteKey('Server', this.server.cert, this.name, 'cert')
          this.deleteKey('Server', this.server.key, this.name, 'key')
          this.deleteKey('Server', this.server.dh, this.name, 'dh')
          this.server.ca = ''
          this.server.cert = ''
          this.server.key = ''
          this.server.dh = ''
          this.instanceData.dh = ''
        } else {
          this.deleteKey('Client', this.client.ca, this.name, 'ca')
          this.deleteKey('Client', this.client.cert, this.name, 'cert')
          this.deleteKey('Client', this.client.key, this.name, 'key')
          this.client.ca = ''
          this.client.cert = ''
          this.client.key = ''
        }
      } else {
        this.instanceData.secret = ''
        if (this.type) {
          this.deleteKey('Server', this.server.secret, this.name, 'secret')
          this.server.secret = ''
        } else {
          this.deleteKey('Client', this.client.secret, this.name, 'secret')
          this.client.secret = ''
        }
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
          this.server.enable = this.instanceEnable2(this.instanceData.enable)
        }
        if (Object.prototype.hasOwnProperty.call(this.instanceData, '_auth')) {
          this.server.port = this.instanceData.port
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
          } else {
            this.authenticationType = 'tls'
            if (Object.prototype.hasOwnProperty.call(this.instanceData, 'server_ip')) {
              this.server.server_ip = this.instanceData.server_ip
            }
            if (Object.prototype.hasOwnProperty.call(this.instanceData, 'server_netmask')) {
              this.server.server_netmask = this.instanceData.server_netmask
            }
            this.server.ca = this.instanceData.ca
            this.server.cert = this.instanceData.cert
            this.server.key = this.instanceData.key
            this.server.dh = this.instanceData.dh
          }
        }
      } else {
        if (Object.prototype.hasOwnProperty.call(this.instanceData, 'enable')) {
          this.client.enable = this.instanceEnable2(this.instanceData.enable)
        }
        if (Object.prototype.hasOwnProperty.call(this.instanceData, 'network_ip')) {
          this.client.network_ip = this.instanceData.network_ip
        }
        if (Object.prototype.hasOwnProperty.call(this.instanceData, 'network_mask')) {
          this.client.network_mask = this.instanceData.network_mask
        }
        if (Object.prototype.hasOwnProperty.call(this.instanceData, 'remote')) {
          this.client.remote = this.instanceData.remote
        }
        if (Object.prototype.hasOwnProperty.call(this.instanceData, '_auth')) {
          this.client.port = this.instanceData.port
          if (this.instanceData._auth === 'skey') {
            this.authenticationType = 'static'
            if (Object.prototype.hasOwnProperty.call(this.instanceData, 'local_ip')) {
              this.client.local_ip = this.instanceData.local_ip
            }
            if (Object.prototype.hasOwnProperty.call(this.instanceData, 'remote_ip')) {
              this.client.remote_ip = this.instanceData.remote_ip
            }
            this.client.secret = this.instanceData.secret
          } else {
            this.authenticationType = 'tls'
            if (Object.prototype.hasOwnProperty.call(this.instanceData, 'server_ip')) {
              this.client.server_ip = this.instanceData.server_ip
            }
            if (Object.prototype.hasOwnProperty.call(this.instanceData, 'server_netmask')) {
              this.client.server_netmask = this.instanceData.server_netmask
            }
            this.client.ca = this.instanceData.ca
            this.client.cert = this.instanceData.cert
            this.client.key = this.instanceData.key
          }
        }
      }
    },
    applyConfig (type) {
      this.check = false
      if (type) {
        if (this.authenticationType === 'static') {
          if (Object.prototype.hasOwnProperty.call(this.instanceData, 'secret')) {
            this.server.secret = this.filePathLength(this.server.secret, this.instanceData.secret)
          }
          this.error.server_local_ip = this.validate(this.server.local_ip)
          this.error.server_network_ip = this.validate(this.server.network_ip)
          this.error.server_remote_ip = this.validate(this.server.remote_ip)
          this.error.server_remote_ip = this.ipInRouterLan(this.server.remote_ip, this.server.network_mask)
          this.error.server_network_mask = this.validate(this.server.network_mask)
          this.sameIpMessage(this.server.remote, this.router_lan[0])
          if (this.server.secret === undefined) {
            this.$message.error('Upload static key file')
          } else {
            this.emptyFile(this.server.secret, 'Upload static key file')
            if (!this.check && this.server.secret.length > 0) {
              if (!this.validateNumber(this.server.port)) {
                this.server.port = 1194
              }
              var enableValue = this.instanceEnable(this.server.enable)
              this.$rpc.call('openvpnapp', 'setServerStaticKey', { name: this.name, type: 'openvpn', keepalive: '10 120', _name: this.name, data_ciphers: 'BF-CBC', persist_key: '1', port: this.server.port, persist_tun: '1', dev: 'tun_s_server', verb: '5', typetype: 'server', proto: 'udp', _auth: 'skey', cipher: 'BF-CBC', local_ip: this.server.local_ip, remote_ip: this.server.remote_ip, network_ip: this.server.network_ip, network_mask: this.server.network_mask, secret: this.server.secret, enable: enableValue }).then(r => { this.$uci.apply().then(() => { this.$rpc.call('openvpnapp', 'restartOpenVpn', { }).then(r => { this.$message.success('Configuration applied') }) }) })
              this.onCloseModal()
            } else {
              this.$message.error('Not all fields are filled')
            }
          }
        } else {
          if (Object.prototype.hasOwnProperty.call(this.instanceData, 'ca')) {
            this.server.ca = this.filePathLength(this.server.ca, this.instanceData.ca)
          }
          if (Object.prototype.hasOwnProperty.call(this.instanceData, 'cert')) {
            this.server.cert = this.filePathLength(this.server.cert, this.instanceData.cert)
          }
          if (Object.prototype.hasOwnProperty.call(this.instanceData, 'key')) {
            this.server.key = this.filePathLength(this.server.key, this.instanceData.key)
          }
          if (Object.prototype.hasOwnProperty.call(this.instanceData, 'dh')) {
            this.server.dh = this.filePathLength(this.server.dh, this.instanceData.dh)
          }
          this.error.server_ip = this.validate(this.server.server_ip)
          this.error.server_netmask = this.validate(this.server.server_netmask)
          if (this.server.ca === undefined || this.server.cert === undefined || this.server.key === undefined || this.server.dh === undefined) {
            this.$message.error('Upload needed files')
          } else {
            this.emptyFile(this.server.ca, 'Upload certificate authority certificate file')
            this.emptyFile(this.server.cert, 'Upload server certificate file')
            this.emptyFile(this.server.key, 'Upload server key file')
            this.emptyFile(this.server.dh, 'Upload Diffie Hellman parameters file')
            if (!this.check && this.server.ca.length > 0 && this.server.cert.length > 0 && this.server.key.length > 0 && this.server.dh.length > 0) {
              if (!this.validateNumber(this.server.port)) {
                this.server.port = 1194
              }
              var enableValue2 = this.instanceEnable(this.server.enable)
              this.$rpc.call('openvpnapp', 'setServerTls', { name: this.name, type: 'openvpn', keepalive: '10 120', _name: this.name, _tls_cipher: 'all', data_ciphers: 'BF-CBC', persist_key: '1', port: this.server.port, persist_tun: '1', dev: 'tun_s_server', verb: '5', typetype: 'server', proto: 'udp', _auth: 'tls', cipher: 'BF-CBC', server_ip: this.server.server_ip, server_netmask: this.server.server_netmask, auth: 'sha1', _tls_auth: 'none', ca: this.server.ca, cert: this.server.cert, key: this.server.key, dh: this.server.dh, tls_server: 1, client_config_dir: '/etc/openvpn/ccd', upload_files: 4, enable: enableValue2, push: 'route 192.168.145.0 255.255.255.0' }).then(r => { this.$uci.apply().then(() => { this.$rpc.call('openvpnapp', 'restartOpenVpn', { }).then(r => { this.$message.success('Configuration applied') }) }) })
              this.onCloseModal()
            } else {
              this.$message.error('Not all fields are filled')
            }
          }
        }
      } else {
        this.error.client_remote = this.validate(this.client.remote)
        this.error.client_network_ip = this.ipInRouterLan(this.client.network_ip, this.client.network_mask)
        if (this.client.network_ip.length > 0 && this.client.network_mask.length <= 0) {
          this.check = true
          this.error.network_mask = true
          this.$message.error('Input network mask')
        } else if (this.client.network_mask.length > 0 && this.client.network_ip.length <= 0) {
          this.check = true
          this.error.network_ip = true
          this.$message.error('Input network ip')
        }
        this.error.client_network_ip = false
        if (this.client.network_ip.length > 0 && this.validateIp(this.client.network_ip)) {
          this.error.client_network_ip = true
          this.wrongIpMessage(this.client.local_ip)
        }
        this.error.client_network_mask = false
        if (this.client.network_mask.length > 0 && this.validateMask(this.client.network_mask)) {
          this.error.client_network_mask = true
          this.wrongMaskMessage(this.client.network_mask)
        }
        if (this.authenticationType === 'static') {
          if (Object.prototype.hasOwnProperty.call(this.instanceData, 'secret')) {
            this.client.secret = this.filePathLength(this.client.secret, this.instanceData.secret)
          }
          this.error.client_local_ip = this.validate(this.client.local_ip)
          this.error.client_remote_ip = this.validate(this.client.remote_ip)
          if (this.client.port.length <= 0 || !this.validateNumber(this.client.port)) {
            this.check = true
            this.error.client_port = true
            this.$message.error('Wrong port number')
          }
          this.sameIpMessage(this.client.network_ip, this.router_lan[0])
          if (this.client.secret === undefined) {
            this.$message.error('Upload static key file')
          } else {
            this.emptyFile(this.client.secret, 'Upload static key file')
            if (!this.check && this.client.secret.length > 0) {
              var enableValueC = this.instanceEnable(this.client.enable)
              var statusFile2 = '/tmp/openvpn-status_' + this.name + '.log'
              this.$rpc.call('openvpnapp', 'setClientStaticKey', { name: this.name, type: 'openvpn', keepalive: '10 120', _name: this.name, data_ciphers: 'BF-CBC', nobind: '1', persist_key: '1', port: this.client.port, persist_tun: '1', dev: 'tun_c_' + this.name, status: statusFile2, verb: '5', typetype: 'client', proto: 'udp', _auth: 'skey', cipher: 'BF-CBC', remote: this.client.remote, resolv_retry: 'infinite', local_ip: this.client.local_ip, remote_ip: this.client.remote_ip, network_ip: this.client.network_ip, network_mask: this.client.network_mask, secret: this.client.secret, upload_files: 1, _tls_auth: 'none', enable: enableValueC }).then(r => { this.$uci.apply().then(() => { this.$rpc.call('openvpnapp', 'restartOpenVpn', { }).then(r => { this.$message.success('Configuration applied') }) }) })
              this.onCloseModal()
            } else {
              this.$message.error('Not all fields are filled')
            }
          }
        } else {
          if (Object.prototype.hasOwnProperty.call(this.instanceData, 'ca')) {
            this.client.ca = this.filePathLength(this.client.ca, this.instanceData.ca)
          }
          if (Object.prototype.hasOwnProperty.call(this.instanceData, 'cert')) {
            this.client.cert = this.filePathLength(this.client.cert, this.instanceData.cert)
          }
          if (Object.prototype.hasOwnProperty.call(this.instanceData, 'key')) {
            this.client.key = this.filePathLength(this.client.key, this.instanceData.key)
          }
          if (this.client.ca === undefined || this.client.cert === undefined || this.client.key === undefined) {
            this.$message.error('Upload needed files')
          } else {
            this.emptyFile(this.client.ca, 'Upload certificate authority certificate file')
            this.emptyFile(this.client.cert, 'Upload client certificate file')
            this.emptyFile(this.client.key, 'Upload client certificate file')
            if (!this.check && this.client.ca.length > 0 && this.client.cert.length > 0 && this.client.key.length > 0) {
              if (!this.validateNumber(this.client.port)) {
                this.client.port = 1194
              }
              var enableValueC2 = this.instanceEnable(this.client.enable)
              var statusFile = '/tmp/openvpn-status_' + this.name + '.log'
              this.$rpc.call('openvpnapp', 'setClientTls', { name: this.name, type: 'openvpn', keepalive: '10 120', _name: this.name, _tls_cipher: 'all', data_ciphers: 'BF-CBC', nobind: '1', persist_key: '1', port: this.client.port, persist_tun: '1', dev: 'tun_c_' + this.name, status: statusFile, verb: '5', typetype: 'client', proto: 'udp', _auth: 'tls', cipher: 'BF-CBC', remote: this.client.remote, resolv_retry: 'infinite', auth: 'sha1', _tls_auth: 'none', ca: this.client.ca, cert: this.client.cert, key: this.client.key, upload_files: 3, tls_client: '1', client: '1', enable: enableValueC2, network_ip: this.client.network_ip, network_mask: this.client.network_mask }).then(r => { this.$uci.apply().then(() => { this.$rpc.call('openvpnapp', 'restartOpenVpn', { }).then(r => { this.$message.success('Configuration applied') }) }) })
              this.onCloseModal()
            } else {
              this.$message.error('Not all fields are filled')
            }
          }
        }
      }
    },
    validate (value) {
      if (value.length <= 0 || this.validateIp(value)) {
        this.wrongIpMessage(value)
        return true
      } else {
        return false
      }
    },
    wrongIpMessage (ip1) {
      this.check = true
      if (this.validateIp(ip1) && ip1.length > 0) {
        this.$message.error('Wrong IP address')
      }
    },
    wrongMaskMessage (mask1) {
      this.check = true
      if (this.validateMask(mask1) && mask1.length > 0) {
        this.$message.error('Wrong netmask')
      }
    },
    sameIpMessage (ip1, ip2) {
      if (ip1 === ip2) {
        this.$message.error('Remote network IP is same as the router\'s LAN address')
        this.check = true
      }
    },
    ipInRouterLan (ip1, mask1) {
      if (ip1.length > 0 && this.inSubNet(ip1, mask1, this.router_lan, this.router_mask)) {
        this.check = true
        this.$message.error('Remote network IP address is in router\'s Lan IP interval or bad remote network netmask')
        return true
      } else {
        return false
      }
    },
    emptyFile (value, text) {
      if (value === '') {
        this.$message.error(text)
      }
    },
    filePathLength (value, value2) {
      if (value.length <= 0 && value2.length > 0) {
        return value2
      } else {
        return value
      }
    },
    instanceEnable (enable) {
      if (enable) return 1
      else return 0
    },
    instanceEnable2 (value) {
      if (value === '1') return true
      else return false
    },
    onUploadServerStatic (info) {
      if (this.onUpload(info)) {
        this.server.secret = this.tempName
        this.tempName = ''
      }
    },
    onUploadServerCaca (info) {
      if (this.onUpload(info)) {
        this.server.ca = this.tempName
        this.tempName = ''
      }
    },
    onUploadServerCert (info) {
      if (this.onUpload(info)) {
        this.server.cert = this.tempName
        this.tempName = ''
      }
    },
    onUploadServerKey (info) {
      if (this.onUpload(info)) {
        this.server.key = this.tempName
        this.tempName = ''
      }
    },
    onUploadServerDh (info) {
      if (this.onUpload(info)) {
        this.server.dh = this.tempName
        this.tempName = ''
      }
    },
    onUploadClientStatic (info) {
      if (this.onUpload(info)) {
        this.client.secret = this.tempName
        this.tempName = ''
      }
    },
    onUploadClientCaca (info) {
      if (this.onUpload(info)) {
        this.client.ca = this.tempName
        this.tempName = ''
      }
    },
    onUploadClientCert (info) {
      if (this.onUpload(info)) {
        this.client.cert = this.tempName
        this.tempName = ''
      }
    },
    onUploadClientKey (info) {
      if (this.onUpload(info)) {
        this.client.key = this.tempName
        this.tempName = ''
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
        this.tempName = ''
        return false
      }
      info.fileList.length = 0
      if (status !== 'done') {
        this.$message.error(`upload '${file.name}' failed.`)
        this.disableUpload = false
        this.tempName = ''
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
      if (enableValue) value = 1
      else value = 0
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
  font-weight: bold;
}
</style>
