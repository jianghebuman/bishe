<template>
  <div class="login-container">
    <header class="login-topbar">
      <router-link class="brand-mark" to="/">
        <span class="brand-icon">
          <Briefcase />
        </span>
        <span>校园招聘工作台</span>
      </router-link>
      <router-link class="ghost-link" to="/">
        <el-icon><ArrowLeft /></el-icon>
        返回门户
      </router-link>
    </header>

    <main class="login-stage">
      <section class="login-window" aria-label="校园求职招聘系统登录">
        <aside class="career-board">
          <div class="window-strip">
            <span></span>
            <span></span>
            <span></span>
          </div>

          <div class="board-kicker">校园招聘系统 / 2026</div>
          <h1>登录工作台，岗位和简历各就各位。</h1>
          <p class="board-copy">
            学生查岗位，企业收简历，管理员处理审核。三个入口从这里分流。
          </p>

          <div class="entry-stack" aria-label="系统入口说明">
            <div class="entry-row">
              <span class="entry-code">学生</span>
              <div>
                <b>找岗位、投简历、看面试</b>
                <p>维护个人资料与求职记录，跟进投递进度。</p>
              </div>
            </div>
            <div class="entry-row">
              <span class="entry-code">企业</span>
              <div>
                <b>发岗位、收简历、约面试</b>
                <p>管理招聘职位、候选人筛选和 Offer 流程。</p>
              </div>
            </div>
            <div class="entry-row">
              <span class="entry-code">管理</span>
              <div>
                <b>做审核、发资讯、管数据</b>
                <p>维护招聘信息、公告内容和平台基础资料。</p>
              </div>
            </div>
          </div>
        </aside>

        <section class="auth-panel">
          <div class="auth-heading">
            <span class="auth-badge">
              <component :is="activeRole.icon" />
              {{ activeRole.label }}
            </span>
            <h2>{{ activeRole.title }}</h2>
            <p>{{ activeRole.description }}</p>
          </div>

          <div class="role-switcher" aria-label="选择登录身份">
            <button
              v-for="role in roleOptions"
              :key="role.value"
              type="button"
              class="role-chip"
              :class="{ active: form.role === role.value }"
              :aria-pressed="form.role === role.value"
              @click="form.role = role.value"
            >
              <component :is="role.icon" />
              <span>{{ role.label }}</span>
            </button>
          </div>

          <el-form :model="form" :rules="rules" ref="formRef" label-position="top" class="auth-form">
            <el-form-item prop="username" label="账号">
              <el-input v-model="form.username" placeholder="输入账号" :prefix-icon="User" size="large" />
            </el-form-item>
            <el-form-item prop="password" label="密码">
              <el-input
                v-model="form.password"
                type="password"
                placeholder="输入密码"
                :prefix-icon="Lock"
                show-password
                size="large"
                @keyup.enter="onLogin"
              />
            </el-form-item>
            <button class="primary-action" type="button" :disabled="loading" @click="onLogin">
              <span v-if="loading" class="action-spinner"></span>
              <span>{{ loading ? '正在核验身份' : activeRole.buttonText }}</span>
              <el-icon v-if="!loading"><Right /></el-icon>
            </button>
          </el-form>

          <div class="auth-links">
            <router-link v-if="form.role !== 'ADMIN'" to="/register">创建{{ activeRole.label }}账号</router-link>
            <router-link to="/">先浏览招聘信息</router-link>
          </div>
        </section>
      </section>
    </main>
  </div>
</template>

<script setup>
import { computed, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  ArrowLeft,
  Briefcase,
  DataAnalysis,
  Lock,
  OfficeBuilding,
  Right,
  School,
  User
} from '@element-plus/icons-vue'
import { authApi } from '@/api'
import { useUserStore } from '@/store/user'

const router = useRouter()
const userStore = useUserStore()
const formRef = ref()
const loading = ref(false)
const form = reactive({ username: '', password: '', role: 'STUDENT' })
const roleOptions = [
  {
    value: 'STUDENT',
    label: '学生',
    icon: School,
    title: '学生求职入口',
    description: '查看岗位、维护简历、跟进投递与面试安排。',
    buttonText: '进入学生工作台'
  },
  {
    value: 'ENTERPRISE',
    label: '企业 HR',
    icon: OfficeBuilding,
    title: '企业招聘入口',
    description: '发布岗位、筛选简历、管理宣讲会与 Offer 流程。',
    buttonText: '进入企业工作台'
  },
  {
    value: 'ADMIN',
    label: '管理员',
    icon: DataAnalysis,
    title: '平台管理入口',
    description: '审核企业与岗位，维护资讯、招聘会和基础数据。',
    buttonText: '进入管理后台'
  }
]
const activeRole = computed(() => roleOptions.find((item) => item.value === form.role) || roleOptions[0])
const rules = {
  username: [{ required: true, message: '请输入账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const onLogin = () => {
  formRef.value.validate(async (valid) => {
    if (!valid) return
    loading.value = true
    try {
      const res = await authApi.login(form)
      userStore.setUser(res.data)
      ElMessage.success('登录成功')
      const role = res.data.role
      if (role === 'STUDENT') router.push('/student')
      else if (role === 'ENTERPRISE') router.push('/enterprise')
      else router.push('/admin')
    } finally {
      loading.value = false
    }
  })
}
</script>

<style scoped lang="scss">
.login-container {
  position: relative;
  min-height: 100vh;
  overflow: hidden;
  color: #17231d;
  background:
    linear-gradient(90deg, rgba(23, 35, 29, 0.045) 1px, transparent 1px),
    linear-gradient(0deg, rgba(23, 35, 29, 0.045) 1px, transparent 1px),
    #edf2ee;
  background-size: 42px 42px;
  font-family: "Inter", "PingFang SC", "Microsoft YaHei", sans-serif;
}

.login-container::before {
  position: absolute;
  inset: 0;
  content: "";
  pointer-events: none;
  background:
    linear-gradient(115deg, rgba(238, 184, 82, 0.18), transparent 34%),
    linear-gradient(180deg, transparent 0%, rgba(47, 83, 72, 0.1) 100%);
}

.login-topbar {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: min(1480px, calc(100% - 64px));
  margin: 0 auto;
  padding: 24px 0 18px;
}

.brand-mark,
.ghost-link {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  font-size: 14px;
  font-weight: 700;
}

.brand-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  color: #f7efe0;
  background: #263a33;
  border: 1px solid rgba(23, 35, 29, 0.16);
  border-radius: 8px;

  svg {
    width: 18px;
    height: 18px;
  }
}

.ghost-link {
  color: #41554c;
  padding: 9px 12px;
  border: 1px solid rgba(23, 35, 29, 0.12);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.56);
  transition: color 0.2s ease, border-color 0.2s ease, transform 0.2s ease;
}

.ghost-link:hover {
  color: #17231d;
  border-color: rgba(23, 35, 29, 0.26);
  transform: translateY(-1px);
}

.login-stage {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: calc(100vh - 88px);
  padding: 24px 32px;
}

.login-window {
  display: grid;
  grid-template-columns: minmax(0, 1.08fr) minmax(440px, 0.86fr);
  width: min(1480px, 100%);
  min-height: 650px;
  overflow: hidden;
  border: 1px solid rgba(23, 35, 29, 0.2);
  border-radius: 18px;
  background: #fffaf0;
  box-shadow: 0 34px 70px rgba(35, 54, 45, 0.2);
}

.career-board {
  position: relative;
  display: flex;
  flex-direction: column;
  padding: 42px;
  color: #f8f2e6;
  background:
    linear-gradient(90deg, rgba(255, 255, 255, 0.08) 1px, transparent 1px),
    linear-gradient(0deg, rgba(255, 255, 255, 0.06) 1px, transparent 1px),
    #223930;
  background-size: 32px 32px;
}

.career-board::after {
  position: absolute;
  right: 32px;
  bottom: 32px;
  width: 210px;
  height: 150px;
  content: "";
  border-right: 1px solid rgba(247, 239, 224, 0.28);
  border-bottom: 1px solid rgba(247, 239, 224, 0.28);
}

.window-strip {
  display: flex;
  gap: 8px;
  margin-bottom: 46px;

  span {
    width: 10px;
    height: 10px;
    border: 1px solid rgba(248, 242, 230, 0.4);
    border-radius: 50%;
  }
}

.board-kicker {
  width: max-content;
  padding: 7px 10px;
  margin-bottom: 18px;
  font-size: 12px;
  font-weight: 800;
  letter-spacing: 0;
  color: #223930;
  background: #eeb852;
  border-radius: 6px;
}

.career-board h1 {
  width: min(520px, 100%);
  font-size: clamp(34px, 4.5vw, 52px);
  line-height: 1.04;
  font-weight: 850;
  margin: 0;
}

.board-copy {
  width: min(470px, 100%);
  margin: 20px 0 0;
  color: rgba(248, 242, 230, 0.76);
  font-size: 16px;
  line-height: 1.8;
}

.entry-stack {
  display: grid;
  gap: 12px;
  width: min(460px, 100%);
  margin-top: auto;
  padding-top: 42px;
}

.entry-row {
  display: grid;
  grid-template-columns: 74px minmax(0, 1fr);
  gap: 14px;
  align-items: center;
  padding: 12px 0;
  border-top: 1px dashed rgba(248, 242, 230, 0.22);

  b {
    display: block;
    font-size: 14px;
  }

  p {
    margin-top: 4px;
    color: rgba(248, 242, 230, 0.66);
    font-size: 13px;
  }
}

.entry-code {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  height: 34px;
  color: #223930;
  background: #f8f2e6;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 800;
}

.auth-panel {
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: 56px;
  background: #fffdf7;
}

.auth-heading {
  margin-bottom: 24px;

  h2 {
    margin: 16px 0 10px;
    color: #17231d;
    font-size: 28px;
    line-height: 1.25;
  }

  p {
    min-height: 44px;
    color: #607168;
    font-size: 14px;
    line-height: 1.7;
  }
}

.auth-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 8px 10px;
  color: #2b4b40;
  background: #ecf3ee;
  border: 1px solid rgba(43, 75, 64, 0.12);
  border-radius: 8px;
  font-size: 13px;
  font-weight: 800;

  svg {
    width: 16px;
    height: 16px;
  }
}

.role-switcher {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 8px;
  margin-bottom: 26px;
}

.role-chip {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 7px;
  min-height: 42px;
  padding: 0 10px;
  color: #607168;
  background: #f4f7f3;
  border: 1px solid rgba(23, 35, 29, 0.1);
  border-radius: 8px;
  cursor: pointer;
  font-size: 13px;
  font-weight: 800;
  transition: background 0.2s ease, border-color 0.2s ease, color 0.2s ease, transform 0.2s ease;

  svg {
    width: 16px;
    height: 16px;
  }
}

.role-chip:hover {
  color: #17231d;
  border-color: rgba(23, 35, 29, 0.24);
  transform: translateY(-1px);
}

.role-chip.active {
  color: #fffaf0;
  background: #243a32;
  border-color: #243a32;
  box-shadow: inset 0 -2px 0 rgba(238, 184, 82, 0.75);
}

.auth-form {
  :deep(.el-form-item) {
    margin-bottom: 18px;
  }

  :deep(.el-form-item__label) {
    margin-bottom: 7px;
    color: #2d3a34;
    font-weight: 800;
    line-height: 1.2;
  }

  :deep(.el-input__wrapper) {
    min-height: 48px;
    border-radius: 8px;
    background: #f8faf6;
    box-shadow: inset 0 0 0 1px rgba(23, 35, 29, 0.12);
    transition: box-shadow 0.2s ease, background 0.2s ease;
  }

  :deep(.el-input__wrapper.is-focus) {
    background: #ffffff;
    box-shadow: inset 0 0 0 1px #2f5f51, 0 0 0 4px rgba(47, 95, 81, 0.12);
  }

  :deep(.el-input__inner) {
    color: #17231d;
    font-weight: 650;
  }
}

.primary-action {
  display: inline-flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  min-height: 52px;
  margin-top: 4px;
  padding: 0 16px 0 20px;
  color: #fffaf0;
  background: #17231d;
  border: 1px solid #17231d;
  border-radius: 8px;
  box-shadow: 0 12px 26px rgba(23, 35, 29, 0.22);
  cursor: pointer;
  font-size: 15px;
  font-weight: 900;
  transition: background 0.2s ease, box-shadow 0.2s ease, transform 0.2s ease;
}

.primary-action:hover:not(:disabled) {
  background: #2d473c;
  box-shadow: 0 16px 30px rgba(23, 35, 29, 0.26);
  transform: translateY(-1px);
}

.primary-action:disabled {
  cursor: wait;
  opacity: 0.76;
}

.action-spinner {
  width: 16px;
  height: 16px;
  margin-right: 8px;
  border: 2px solid rgba(255, 250, 240, 0.35);
  border-top-color: #fffaf0;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

.auth-links {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
  margin-top: 18px;
  font-size: 14px;

  a {
    color: #2f5f51;
    font-weight: 800;
  }

  a:hover {
    color: #17231d;
  }
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

@media (max-width: 920px) {
  .login-stage {
    align-items: flex-start;
    padding-top: 12px;
  }

  .login-window {
    grid-template-columns: 1fr;
    min-height: 0;
  }

  .career-board {
    padding: 28px;
  }

  .window-strip {
    margin-bottom: 36px;
  }

  .career-board h1 {
    font-size: 36px;
  }

  .entry-stack {
    margin-top: 36px;
    padding-top: 12px;
  }

  .auth-panel {
    padding: 32px 28px;
  }
}

@media (max-width: 560px) {
  .login-topbar {
    width: min(100% - 28px, 1480px);
    padding-top: 16px;
  }

  .brand-mark span:last-child {
    display: none;
  }

  .login-stage {
    padding: 12px 14px 24px;
  }

  .login-window {
    border-radius: 14px;
  }

  .career-board {
    order: 2;
  }

  .auth-panel {
    order: 1;
  }

  .career-board {
    padding: 22px;
  }

  .career-board::after {
    display: none;
  }

  .career-board h1 {
    font-size: 28px;
  }

  .board-copy {
    font-size: 14px;
  }

  .window-strip {
    margin-bottom: 26px;
  }

  .entry-row {
    grid-template-columns: 62px minmax(0, 1fr);
  }

  .auth-panel {
    padding: 26px 20px;
  }

  .role-switcher {
    grid-template-columns: 1fr;
  }

  .auth-links {
    align-items: flex-start;
    flex-direction: column;
  }
}
</style>
