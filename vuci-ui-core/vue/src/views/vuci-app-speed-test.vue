<template>
  <div class="speed-test">
    <a-card title="Information" style="width: 400px">
      <h4>Public IP address: {{ user_ip }}</h4>
      <h4>Country: {{ user_country }}</h4>
      <h4>City: {{ user_city }}</h4>
      <h4>ISP: {{ user_isp }}</h4>
    </a-card>

    <gauge
      :heading="gaugeTitle"
      :min="0"
      :max="100"
      :value="gaugeValue"
      :valueToExceedLimits="true"
      activeFill="blue"
      inactiveFill="green"
    />
    <a-icon slot="icon" type="disconnect" />
    <a-icon slot="icon" type="check" />
    <a-steps :current="currentStep">
      <a-step title="Connecting" description="This is a description.">
        <a-icon slot="icon" type="loading" />
      </a-step>
      <a-step title="Downlaod" description="This is a description.">
        <a-icon slot="icon" type="download" />
      </a-step>
      <a-step title="Upload" description="This is a description.">
        <a-icon slot="icon" type="upload" />
      </a-step>
    </a-steps>

    <a-form layout="inline" @submit.prevent="startTest">
      <a-form-item label="Choose server">
        <a-select placeholder="best" v-model="inputServer">
          <a-select-option value="best">
            best
          </a-select-option>
          <a-select-option value="server">
            server list
          </a-select-option>
        </a-select>
      </a-form-item>
      <a-form-item>
        <a-button type="primary" html-type="submit">
          <a-icon type="play-circle" />Start
        </a-button>
      </a-form-item>
    </a-form>

    {{ serverList }}
  </div>
</template>

<script>
import { Gauge } from '@chrisheanan/vue-gauge'

export default {
  components: {
    Gauge
  },
  data () {
    return {
      time: '',
      currentStep: 2,
      inputServer: 'best',
      gaugeValue: 20,
      gaugeTitle: 'Begin speed test',
      user_ip: '',
      user_country: '',
      user_city: '',
      user_isp: '',
      serverList: []
    }
  },
  created () {
    this.getLocation()
    this.getServerList()
    this.getReadFile()
  },
  methods: {
    startTest () {
      console.log('startTest')
    },
    getLocation () {
      this.$rpc.call('speedtest', 'getLocation', { }).then(data => {
        const results = JSON.parse(data.result)
        this.user_ip = results.ip
        this.user_country = results.country
        this.user_city = results.city
        this.user_isp = results.isp
      })
    },
    getServerList () {
      this.$rpc.call('speedtest', 'getServerList', { }).then(data => {
        console.log(data.response)
        // console.log(data.result)
      })
    },
    getReadFile () {
      this.serverList = []
      this.$rpc.call('speedtest', 'readFile', { from: 1, to: 10 }).then(data => {
        var parser = new DOMParser()
        console.log(data.length)
        console.log(data)
        for (var i = 0; i < data.length; i++) {
          var xmlDoc = parser.parseFromString(data[i], 'text/xml')
          var xmlServer = xmlDoc.getElementsByTagName('server')
          console.log(data[i])
          if (xmlServer[0]) {
            console.log(xmlServer[0])
            console.log(xmlServer[0].getAttribute('name'))
            this.serverList.push({ name: xmlServer[0].getAttribute('name'), url: xmlServer[0].getAttribute('url'), country: xmlServer[0].getAttribute('country'), sponsor: xmlServer[0].getAttribute('sponsor'), host: xmlServer[0].getAttribute('host') })
          }
          console.log(i)
        }
        // this.serverList.push({  })
      })
      // this.$rpc.call('speedtest', 'readAllFile', { }).then(data => {
      //   console.log(data)
      // })
    }
  }
}
</script>
