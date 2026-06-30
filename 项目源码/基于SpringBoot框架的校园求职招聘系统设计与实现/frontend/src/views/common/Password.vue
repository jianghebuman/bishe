<template>
  <div class="page-container student-screen-page password-page">
    <div class="page-card student-screen-card password-card">
      <div class="header">
        <h2>修改密码</h2>
        <p>为了账号安全，建议定期修改密码，不要与其他平台使用相同密码。</p>
      </div>
      <el-divider />
      <div class="password-body">
        <el-form ref="formRef" :model="form" :rules="rules" label-width="110px" class="password-form">
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
          <div class="security-head">
            <h3>安全提示</h3>
            <p>修改前先确认当前账号状态，避免影响后续投递和通知接收。</p>
          </div>
          <ul>
            <li><strong>重新登录：</strong>修改成功后请使用新密码重新登录。</li>
            <li><strong>不要泄露：</strong>不要将密码告诉任何人，包括自称管理员或 HR 的人员。</li>
            <li><strong>忘记密码：</strong>可联系就业办管理员重置为初始密码。</li>
          </ul>
          <div class="security-state">
            <div><span>当前状态</span><strong>已登录</strong></div>
            <div><span>修改后</span><strong>重新登录</strong></div>
            <div><span>建议频率</span><strong>定期更新</strong></div>
          </div>
        </div>
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
.password-page {
  width: min(100rem, calc(100% - clamp(1rem, 3vw, 3rem)));
}
.password-card {
  min-height: min(52rem, calc(100dvh - 8rem));
  padding: clamp(24px, 2vw, 34px);
  display: flex;
  flex-direction: column;
}
.header h2 { margin-bottom: 6px; color: var(--cr-text); } .header p { color: var(--cr-text-muted); }
.password-body {
  flex: 1;
  min-height: 0;
  display: grid;
  grid-template-columns: minmax(36rem, 58rem) minmax(24rem, 1fr);
  gap: clamp(24px, 4vw, 72px);
  align-items: start;
  padding-top: clamp(40px, 6vh, 88px);
}
.password-form {
  width: 100%;
  align-self: start;
}
.security-tips {
  align-self: start;
  width: 100%;
  min-height: 23rem;
  padding: clamp(28px, 2.2vw, 38px);
  border: 1px solid rgba(37, 99, 235, 0.12);
  border-radius: 12px;
  background: var(--cr-surface-soft);
}
.security-head {
  margin-bottom: 20px;

  h3 {
    margin-bottom: 8px;
    color: var(--cr-text);
    font-size: 22px;
    line-height: 1.3;
  }

  p {
    color: var(--cr-text-muted);
    font-size: 16px;
    line-height: 1.7;
  }
}
.security-tips ul {
  display: grid;
  gap: 12px;
}
.security-tips li {
  padding: 14px 16px;
  list-style: none;
  border: 1px solid var(--cr-border-soft);
  border-radius: 10px;
  background: #fff;
  color: var(--cr-text-soft);
  font-size: 16px;
  line-height: 1.75;
}
.security-tips li strong {
  color: var(--cr-text);
}
.security-state {
  margin-top: 24px;
  padding-top: 22px;
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 14px;
  border-top: 1px solid var(--cr-border-soft);
}
.security-state div {
  min-width: 0;
  padding: 18px;
  border: 1px solid var(--cr-border-soft);
  border-radius: 10px;
  background: #fff;
}
.security-state span {
  display: block;
  margin-bottom: 8px;
  color: var(--cr-text-muted);
  font-size: 14px;
}
.security-state strong {
  color: var(--cr-text);
  font-size: 17px;
}
@media (max-width: 980px) {
  .password-body {
    grid-template-columns: 1fr;
  }

  .security-state {
    grid-template-columns: 1fr;
  }
}
</style>

