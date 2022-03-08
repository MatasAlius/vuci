<template>
  <div class="vuci-password-modal" v-if="visible">
    <a-modal v-model="visible" title="Change default password" on-ok="passChange" :closable=false :keyboard=false :maskClosable=false >
      <template slot="footer">
        <a-button key="submit" type="primary" :loading="loading" @click="passChange">
          Submit
        </a-button>
      </template>
      <a-form-model :model="form" :rules="rules" ref="form" :label-col="labelCol" :wrapper-col="wrapperCol">
        <a-form-model-item :label="$t('admin.Password')" prop="password">
          <a-input-password v-model="form.password"/>
        </a-form-model-item>
        <a-form-model-item :label="$t('admin.Confirmation')" prop="confirm">
          <a-input-password v-model="form.confirm"/>
        </a-form-model-item>
      </a-form-model>
    </a-modal>
  </div>
</template>

<script>
export default {
  name: 'PasswordModal',
  props: {
    visible: Boolean
  },
  data () {
    const validatePass = (rule, value, callback) => {
      if (value === '') {
        callback(new Error(this.$t('admin.Please enter your password')))
      } else {
        if (this.form.confirm !== '') { this.$refs.form.validateField('confirm') }
        callback()
      }
    }

    const validatorConfirm = (rule, value, callback) => {
      if (value === '') {
        callback(new Error(this.$t('admin.Please enter your password again')))
      } else if (value !== this.form.password) {
        callback(new Error(this.$t('admin.Inconsistent input password twice!')))
      } else {
        callback()
      }
    }

    return {
      labelCol: { span: 6 },
      wrapperCol: { span: 8 },
      form: {
        password: '',
        confirm: ''
      },
      rules: {
        password: [{ validator: validatePass }],
        confirm: [{ validator: validatorConfirm }]
      }
    }
  },
  methods: {
    passChange () {
      const that = this
      this.$refs.form.validate(valid => {
        if (!valid) return
        this.$rpc.call('ui', 'first_set', {
          username: this.$session.username(),
          password: this.form.password,
          lang: 'en'
        }).then(() => {
          sessionStorage.setItem('firsttime', 0)
          that.visible = false
        })
      })
    }
  }
}
</script>

<style lang="stylus">
</style>
