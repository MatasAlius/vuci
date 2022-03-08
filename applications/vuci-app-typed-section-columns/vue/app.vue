<template>
  <vuci-form uci-config="example">
    <vuci-typed-section type="interface" addremove :columns="columns">
      <template #address="{ s }">
        <vuci-form-item-input :uci-section="s"  name="address" rules="ipaddr"/>
      </template>
      <template #netmask="{ s }">
        <vuci-form-item-input :uci-section="s"  name="netmask" rules="netmask4"/>
      </template>
    </vuci-typed-section>
  </vuci-form>
</template>

<script>
export default {
  data () {
    return {
      columns: [
        { name: 'address', label: 'IP address changed' },
        { name: 'netmask', label: 'Netmask changed' }
      ]
    }
  }
}
</script>
