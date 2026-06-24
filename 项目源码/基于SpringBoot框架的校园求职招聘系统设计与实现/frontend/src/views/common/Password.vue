<template>
  <div class="page-container">
    <div class="page-card password-card">
      <div class="header">
        <h2>修改密码</h2>
        <p>为了账号安全，建议定期修改密码，不要与其他平台使用相同密码。</p>
      </div>
      <el-divider />
      <el-form ref="formRef" :model="form" :rules="rules" label-width="110px">
        <el-form-item label="原密码" prop="oldPassword">
          <el-input v-model="form.oldPassword" type="password" show-password placeholder="请输入当前密码" />
        </el-form-item>
        <el-form-item label="新密码" prop="newPassword">
          <el-input v-model="form.newPassword" type="password" show-password placeholder="建议 6 位以上，包含字母和数字" />
        </el-form-item>
        <el-form-item label="确认新密码" prop="confirmPassword">
          <el-input v-model="form.confirmPassword" type="password" show-password placeholder="请再次输入新密码" @keyup.enter="submit" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="loading" @click="submit">确认修改</el-button>
          <el-button @click="reset">重置</el-button>
        </el-form-item>
      </el-form>
      <div class="security-tips">
        <h3>安全提示</h3>
        <ul>
          <li>修改成功后请使用新密码重新登录。</li>
          <li>不要将密码告诉任何人，包括自称管理员或 HR 的人员。</li>
          <li>如忘记密码，可联系就业办管理员重置为初始密码。</li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { authApi } from '@/api'
import { useUserStore } from '@/store/user'
import { useRouter } from 'vue-router'

const router = useRouter()
const userStore = useUserStore()
const formRef = ref()
const loading = ref(false)
const form = reactive({ oldPassword: '', newPassword: '', confirmPassword: '' })
const validateConfirm = (rule, value, callback) => value !== form.newPassword ? callback(new Error('两次输入的新密码不一致')) : callback()
const rules = {
  oldPassword: [{ required: true, message: '请输入原密码', trigger: 'blur' }],
  newPassword: [{ required: true, message: '请输入新密码', trigger: 'blur' }, { min: 6, message: '新密码至少 6 位', trigger: 'blur' }],
  confirmPassword: [{ required: true, message: '请确认新密码', trigger: 'blur' }, { validator: validateConfirm, trigger: 'blur' }]
}
const reset = () => { form.oldPassword = ''; form.newPassword = ''; form.confirmPassword = '' }
const submit = () => {
  formRef.value.validate(async valid => {
    if (!valid) return
    loading.value = true
    try {
      await authApi.changePassword({ oldPassword: form.oldPassword, newPassword: form.newPassword })
      ElMessage.success('密码修改成功，请重新登录')
      userStore.logout()
      router.push('/login')
    } finally { loading.value = false }
  })
}
</script>

<style scoped lang="scss">
.password-card { max-width: 720px; margin: 0 auto; }
.header h2 { margin-bottom: 6px; color: #303133; } .header p { color: #909399; }
.security-tips { margin-top: 24px; background: #f5f7fa; border-radius: 8px; padding: 16px 20px; h3 { font-size: 15px; margin-bottom: 10px; color: #303133; } ul { padding-left: 18px; } li { list-style: disc; line-height: 1.8; color: #606266; font-size: 13px; } }
</style>
