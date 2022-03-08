<template>
    <div class="matas">
        <a-input v-model="time"/>
        <a-button type="primary" @click="get_time">
            Gauti laika (matas)
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
            this.$rpc.call('matas', 'get_time', { }).then(r => {
            this.time = r.time
            })
        }
    }
}
</script>
