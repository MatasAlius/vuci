<template>
  <div class="speed-test">
    <a-row :gutter="16">
      <location @cc="getLocation" />
      <a-col :span="8">
        <a-card title="Speed test" style="width: 400px" :bordered="false">
          <a-form @submit.prevent="startTest" :label-col="{ span: 8 }" :wrapper-col="{ span: 4 }">
            <a-form-item label="Choose server">
              <a-button @click="btnSelect"><a-icon type="dashboard" />{{ selectedServer.name }}</a-button>
            </a-form-item>
            <a-form-item>
              <a-button type="primary" html-type="submit" size="large">
                <a-icon type="play-circle" />Start
              </a-button>
            </a-form-item>
          </a-form>
        </a-card>
      </a-col>
    </a-row>

    <gauge
      :heading="gaugeTitle"
      :min="0"
      :max="100"
      :value="gaugeValue"
      :valueToExceedLimits="true"
      activeFill="red"
      inactiveFill="green"
    />
    <a-icon slot="icon" type="disconnect" />
    <a-icon slot="icon" type="check" />
    <a-steps :current="currentStep">
      <a-step title="Connecting" description="This is a connecting description.">
        <a-icon slot="icon" type="loading" />
      </a-step>
      <a-step title="Downlaod" description="This is a download description.">
        <a-icon slot="icon" type="download" />
      </a-step>
      <a-step title="Upload" description="This is a upload description.">
        <a-icon slot="icon" type="upload" />
      </a-step>
    </a-steps>

    <a-divider />

    <a-modal v-model="serverListModal" :width="800" title="Choose server" @cancel="btnSelect" :footer="null" :sorter="true">
      <a-table :columns="columns" :data-source="serverList">
        <span slot="name" slot-scope="text">
          <template> {{ text }}</template>
        </span>
        <span slot="country" slot-scope="text">
          <template> {{ text }}</template>
        </span>
        <span slot="sponsor" slot-scope="text">
          <template> {{ text }}</template>
        </span>
        <span slot="button" slot-scope="text, record">
          <a-button type="primary" ghost @click="selectServer(record.key, record.name)">Select</a-button>
        </span>
      </a-table>
    </a-modal>

    {{ user_code }}

    {{ selectedServer }}
    <br />
    Latencies:
    {{ serverUserCountry }} {{ serverUserCountry.length }}
    <a-divider />
    <!-- {{ serverList }} -->
  </div>
</template>

<script>
import { Gauge } from '@chrisheanan/vue-gauge'
import Location from './components/Location'

const columns = [
  {
    title: 'Name',
    dataIndex: 'name',
    key: 'name',
    scopedSlots: { customRender: 'name' }
  },
  {
    title: 'Country',
    dataIndex: 'country',
    key: 'country'
  },
  {
    title: 'Sponsor',
    dataIndex: 'sponsor',
    key: 'sponsor'
  },
  {
    scopedSlots: { customRender: 'button' }
  }
]

export default {
  components: {
    Gauge,
    Location
  },
  data () {
    return {
      columns,
      time: '',
      currentStep: 2,
      inputServer: 'best',
      gaugeValue: 0,
      gaugeTitle: 'Begin speed test',
      user_code: '',
      serverList: [],
      serverListModal: false,
      selectedServer: {
        id: -1,
        name: 'Best server',
        total: -1
      },
      serverUserCountry: []
    }
  },
  created () {
    // this.getLocation()
    this.getServerList()
    // error (6)
    // var url = 'http://speed-kaunas.zebra.lt/speedtest/upload.php'
    // var url = 'http://speedtest.meganet.lt/speedtest/speedtest/upload.php'
    // this.$rpc.call('speedtest', 'speedTestCurl', { url: url }).then(r => {
    //   console.log('Results:')
    //   console.log(r)
    // }).catch(err => {
    //   console.log('Klaida: ')
    //   console.log(err)
    // })
  },
  methods: {
    startTest () {
      console.log('startTest')
      if (this.selectedServer.id === -1) {
        console.log('Searching for best server')
      } else {
        console.log('Selected server: ' + this.selectedServer.name + ' , ' + this.selectedServer.id)
      }
    },
    btnSelect () {
      this.serverListModal = !this.serverListModal
    },
    selectServer (index, name) {
      this.serverListModal = false
      this.selectedServer.name = this.serverList[index].name + ' ' + this.serverList[index].sponsor
      this.selectedServer.id = index
    },
    getLocation (e) {
      this.user_code = e
    },
    getServerList () {
      this.$rpc.call('speedtest', 'getServerList', { }).then(data => {
        this.getReadFile()
      })
    },
    getReadFile () {
      this.serverList = []
      this.$rpc.call('speedtest', 'readFile', { from: 1, to: 6938 }).then(data => {
        if (data) {
          var parser = new DOMParser()
          var count = 0
          for (var i = 0; i < data.length; i++) {
            var xmlDoc = parser.parseFromString(data[i], 'text/xml')
            var xmlServer = xmlDoc.getElementsByTagName('server')
            if (xmlServer[0]) {
              this.serverList.push({ key: count, name: xmlServer[0].getAttribute('name'), url: xmlServer[0].getAttribute('url'), country: xmlServer[0].getAttribute('country'), sponsor: xmlServer[0].getAttribute('sponsor'), host: xmlServer[0].getAttribute('host') })
              if (this.user_code === xmlServer[0].getAttribute('cc')) {
                this.speedTestCurl(xmlServer[0].getAttribute('url'), count)
              }
              count++
            }
          }
        }
      })
    },
    speedTestCurl (url, index) {
      this.$rpc.call('speedtest', 'speedTestCurl', { url: url }).then(r => {
        if (r.ok) {
          this.serverUserCountry.push({ key: index, total: r.total })
          if (this.selectedServer.id > -1) {
            if (this.selectedServer.total > r.total) {
              this.selectedServer.id = index
              this.selectedServer.name = 'Best server (' + this.serverList[index].name + ')'
              this.selectedServer.total = r.total
            }
          } else {
            this.selectedServer.id = index
            this.selectedServer.name = 'Best server (' + this.serverList[index].name + ')'
            this.selectedServer.total = r.total
          }
        }
      })
    }
  }
}
</script>
