<template>
  <vuci-form uci-config="example">
    <vuci-named-section name="example_sct" v-slot="{ s }" :card="false">
      <vuci-form-item-switch :uci-section="s" :label="'Enable'" name="enable" initial true-value="1" false-value="0" :help="'To enable example program'"/>
      <vuci-form-item-select :uci-section="s" :label="'Protocol'" name="proto" :options="proto" initial="static" required/>
      <vuci-form-item-input :uci-section="s" :label="'IP address'" name="address" placeholder="192.168.1.1." depend="proto == 'static'" rules="ipaddr"/>
    </vuci-named-section >
  </vuci-form>
</template>

<script>
export default {
  data () {
    return {
      proto: ['dhpc', 'static']
    }
  }
}
</script>
