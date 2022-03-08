<template>
  <div>
    <a-button type="primary" style="position: fixed; top: 30%; right: 0px" @click="visible=true">
    <a-icon type="monitor" />
    </a-button>
    <a-drawer
      title="Device info"
      :placement="placement"
      :closable="true"
      :visible="visible"
      @close="onClose"
    >
      <p><a-icon type="dashboard" /> CPU usage: {{ cpuPercentage }}%</p>
      <p v-if="sysinfo.length"><a-icon type="clock-circle" /> {{ sysinfo[0][0] }}: {{ sysinfo[0][1] }}</p>
      <p><a-icon type="desktop" /> Memory usage: {{ memPercentage }}%</p>
      <p><a-icon type="desktop" /> Memory usage: {{ (memTotal-memFree) | toMB }} MB</p>
      <p><a-icon type="desktop" /> Memory free: {{ memFree | toMB }} MB</p>
      <p><a-icon type="desktop" /> Memory total: {{ memTotal | toMB }} MB</p>
    </a-drawer>
  </div>
</template>

<script>
export default {
  name: 'PasswordModal',
  data () {
    return {
      placement: 'right',
      visible: false,
      lastCPUTime: null,
      cpuPercentage: 100,
      memPercentage: 100,
      memTotal: 0,
      memFree: 0,
      sysinfo: []
    }
  },
  created () {
  },
  filters: {
    toMB: function (value) {
      return (value / 1000000).toFixed(2)
    }
  },
  timers: {
    update: { time: 5000, autostart: true, immediate: true, repeat: true },
    updateCpuUsage: { time: 5000, autostart: true, immediate: true, repeat: true }
  },
  methods: {
    onClose () {
      this.visible = false
    },
    updateCpuUsage () {
      this.$rpc.call('system', 'cpu_time').then(times => {
        if (!this.lastCPUTime) {
          this.cpuPercentage = 0
          this.lastCPUTime = times
          return
        }

        const idle1 = this.lastCPUTime[3]
        const idle2 = times[3]

        let total1 = 0
        let total2 = 0

        this.lastCPUTime.forEach(t => {
          total1 += t
        })

        times.forEach(t => {
          total2 += t
        })

        this.cpuPercentage = Math.floor(((total2 - total1 - (idle2 - idle1)) / (total2 - total1)) * 100)
        this.lastCPUTime = times
      })
    },
    update () {
      this.$system.getInfo().then(({ uptime, memory }) => {
        this.sysinfo = [
          [this.$t('Uptime'), '%t'.format(uptime)]
        ]

        this.memTotal = memory.total
        this.memFree = memory.free
        this.memPercentage = Math.floor(((memory.total - memory.free) / memory.total) * 100)
      })
    }
  }
}
</script>

<style lang="stylus">
</style>
