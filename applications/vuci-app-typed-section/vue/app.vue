<template>
  <vuci-form uci-config="example">
    <vuci-typed-section type="interface" addremove v-slot="{ s }">
      <vuci-form-item-input :uci-section="s" label="IP address" name="address" rules="ipaddr"/>
      <vuci-form-item-input :uci-section="s" label="Netmask" name="netmask" rules="netmask4"/>
    </vuci-typed-section>
  </vuci-form>
</template>

<script>
export default {
  data () {
    return {

    }
  }
}
</script>
