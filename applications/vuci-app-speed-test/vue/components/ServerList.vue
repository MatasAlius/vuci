<template>
  <div class="serverlist">
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
  </div>
</template>

<script>

const columns = [
  {
    title: 'Name',
    dataIndex: 'name',
    key: 'name',
    scopedSlots: { customRender: 'name' },
    sorter: (a, b) => a.name > b.name ? 1 : -1
  },
  {
    title: 'Country',
    dataIndex: 'country',
    key: 'country',
    sorter: (a, b) => a.country > b.country ? 1 : -1,
<<<<<<< HEAD
    defaultSortOrder: 'ascend',
    filters: [
      {
        text: 'Finland',
        value: 'Finland'
      },
      {
        text: 'Estonia',
        value: 'Estonia'
      },
      {
        text: 'Lithuania',
        value: 'Lithuania'
      },
      {
        text: 'Latvia',
        value: 'Latvia'
      },
      {
        text: 'Poland',
        value: 'Poland'
      }
    ],
    onFilter: (value, record) => record.country.includes(value)
=======
    defaultSortOrder: 'ascend'
>>>>>>> 1da6e8bbb89cbdaf69b5c44c78be2d45d50bc380
  },
  {
    title: 'Sponsor',
    dataIndex: 'sponsor',
    key: 'sponsor',
    sorter: (a, b) => a.sponsor > b.sponsor ? 1 : -1
  },
  {
    scopedSlots: { customRender: 'button' }
  }
]

export default {
  name: 'ServerList',
  props: {
    serverList: Array
  },
  data () {
    return {
      columns
    }
  },
  methods: {
    selectServer (index, name) {
      this.$emit('selectServer', index)
    }
  }
}
</script>
