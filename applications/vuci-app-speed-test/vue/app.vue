<template>
  <div class="speed-test">
    <h4>Speed test</h4>
    <a-input v-model="time"/>
    <a-button type="primary" @click="get_time">
      Get
    </a-button>
  </div>
</template>

<script>
export default {
  data () {
    return {
      time: ''
    }
  },
  methods: {
    get_time () {
      this.$rpc.call('speedtest', 'get_time', { }).then(r => {
        this.time = r.time
      })
    }
  }
}
</script>
