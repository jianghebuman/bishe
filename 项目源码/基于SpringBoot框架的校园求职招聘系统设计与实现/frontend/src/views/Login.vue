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
          <BackgroundPaths3d class="auth-paths-3d" variant="dark" :density="16" />
          <div class="cr-aurora-layer auth-aurora" aria-hidden="true"></div>
          <div class="cr-light-rays-layer auth-rays" aria-hidden="true"><i></i><i></i><i></i></div>
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

          <div class="board-metrics" aria-label="平台能力概览">
            <div>
              <b>岗位检索</b>
              <span>城市、薪资、学历条件快速筛选</span>
            </div>
            <div>
              <b>简历流转</b>
              <span>投递、邀约、面试状态统一跟进</span>
            </div>
            <div>
              <b>审核管理</b>
              <span>企业资质、岗位内容、资讯公告集中维护</span>
            </div>
          </div>

          <div class="board-focus" aria-label="当前入口办理事项">
            <div class="focus-heading">
              <span>{{ activeRole.focusTitle }}</span>
              <small>{{ activeRole.focusCaption }}</small>
            </div>
            <ul>
              <li v-for="item in activeRole.focusItems" :key="item">{{ item }}</li>
            </ul>
          </div>

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
            <router-link
              v-if="form.role !== 'ADMIN'"
              :to="{ path: '/register', query: { role: form.role } }"
            >
              创建{{ activeRole.label }}账号
            </router-link>
            <router-link to="/">先浏览招聘信息</router-link>
          </div>

          <div class="auth-next">
            <div class="next-heading">登录后继续处理</div>
            <div class="next-grid">
              <span v-for="item in activeRole.nextSteps" :key="item">{{ item }}</span>
            </div>
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
import BackgroundPaths3d from '@/components/BackgroundPaths3d.vue'

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
    buttonText: '进入学生工作台',
    focusTitle: '学生登录后',
    focusCaption: '个人求职闭环',
    focusItems: ['补全求职意向与在线简历', '收藏合适岗位并发起投递', '查看面试通知和录用反馈'],
    nextSteps: ['完善在线简历', '查看岗位收藏', '跟进投递进度', '确认面试安排']
  },
  {
    value: 'ENTERPRISE',
    label: '企业 HR',
    icon: OfficeBuilding,
    title: '企业招聘入口',
    description: '发布岗位、筛选简历、管理宣讲会与 Offer 流程。',
    buttonText: '进入企业工作台',
    focusTitle: '企业登录后',
    focusCaption: '招聘执行台',
    focusItems: ['维护企业认证与招聘资料', '发布岗位并查看投递简历', '发起面试邀约和录用通知'],
    nextSteps: ['发布招聘岗位', '筛选候选简历', '安排面试邀约', '维护企业认证']
  },
  {
    value: 'ADMIN',
    label: '管理员',
    icon: DataAnalysis,
    title: '平台管理入口',
    description: '审核企业与岗位，维护资讯、招聘会和基础数据。',
    buttonText: '进入管理后台',
    focusTitle: '管理员登录后',
    focusCaption: '平台运营处理',
    focusItems: ['审核企业资质和岗位内容', '维护招聘会、宣讲会与资讯', '查看用户、投递和系统日志数据'],
    nextSteps: ['审核企业资料', '处理岗位发布', '维护招聘资讯', '查看平台数据']
  }
]
const activeRole = computed(() => roleOptions.find((item) => item.value === form.role) || roleOptions[0])
const rules = {
  username: [{ required: true, message: '请输入账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}
const roleHomeMap = {
  STUDENT: '/student/dashboard',
  ENTERPRISE: '/enterprise/dashboard',
  ADMIN: '/admin/dashboard'
}

const onLogin = () => {
  formRef.value.validate(async (valid) => {
    if (!valid) return
    loading.value = true
    try {
      const res = await authApi.login(form)
      userStore.setUser(res.data)
      ElMessage.success('登录成功')
      await router.replace(roleHomeMap[userStore.role] || '/')
    } catch (_error) {
    } finally {
      loading.value = false
    }
  })
}
</script>

<style scoped lang="scss">
.login-container {
  position: relative;
  --auth-shell-width: min(150rem, calc(100% - clamp(1.5rem, 4vw, 6rem)));
  min-height: 100dvh;
  overflow-x: hidden;
  color: #172033;
  background:
    linear-gradient(90deg, rgba(37, 99, 235, 0.05) 1px, transparent 1px),
    linear-gradient(0deg, rgba(37, 99, 235, 0.05) 1px, transparent 1px),
    #f4f7fb;
  background-size: 42px 42px;
  font-family: "Inter", "PingFang SC", "Microsoft YaHei", sans-serif;
}

.login-container::before {
  position: absolute;
  inset: 0;
  content: "";
  pointer-events: none;
  background:
    radial-gradient(circle at 16% 18%, rgba(8, 145, 178, 0.16), transparent 28%),
    linear-gradient(180deg, transparent 0%, rgba(37, 99, 235, 0.08) 100%);
}

.login-topbar {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: var(--auth-shell-width);
  margin: 0 auto;
  padding: clamp(1rem, 2dvh, 1.5rem) 0 clamp(0.75rem, 1.6dvh, 1.125rem);
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
  background: #2563eb;
  border: 1px solid rgba(37, 99, 235, 0.22);
  border-radius: 8px;

  svg {
    width: 18px;
    height: 18px;
  }
}

.ghost-link {
  color: #5d6f88;
  padding: 9px 12px;
  border: 1px solid rgba(93, 111, 136, 0.18);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.56);
  transition: color 0.2s ease, border-color 0.2s ease, transform 0.2s ease;
}

.ghost-link:hover {
  color: #172033;
  border-color: rgba(37, 99, 235, 0.32);
  transform: translateY(-1px);
}

.login-stage {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: calc(100dvh - clamp(4.75rem, 6dvh, 6.25rem));
  padding: clamp(1rem, 2dvh, 1.5rem) 0 clamp(1.5rem, 3dvh, 3rem);
}

.login-window {
  display: grid;
  grid-template-columns: minmax(34rem, 0.96fr) minmax(40rem, 1.04fr);
  width: var(--auth-shell-width);
  min-height: clamp(36rem, 86dvh, 92rem);
  overflow: hidden;
  border: 1px solid rgba(93, 111, 136, 0.18);
  border-radius: clamp(1rem, 1vw, 1.5rem);
  background: #ffffff;
  box-shadow: 0 34px 70px rgba(22, 38, 68, 0.16);
}

.career-board {
  position: relative;
  isolation: isolate;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  padding: clamp(2rem, 3.4vw, 5rem);
  color: #eef6ff;
  background:
    linear-gradient(90deg, rgba(255, 255, 255, 0.08) 1px, transparent 1px),
    linear-gradient(0deg, rgba(255, 255, 255, 0.06) 1px, transparent 1px),
    #15243b;
  background-size: 32px 32px;
}

.auth-rays {
  --cr-rays-color: rgba(105, 218, 255, 0.26);
  --cr-rays-opacity: 0.5;
  --cr-rays-blur: 1.5rem;
  --cr-rays-length: 72%;
  mix-blend-mode: screen;
}

.auth-aurora {
  --cr-aurora-opacity: 0.42;
  --cr-aurora-blend: screen;
  --cr-aurora-primary: rgba(64, 127, 255, 0.32);
  --cr-aurora-secondary: rgba(20, 184, 166, 0.24);
  --cr-aurora-tertiary: rgba(125, 211, 252, 0.18);
  --cr-aurora-blur: 1.75rem;
  --cr-aurora-x: 72%;
  --cr-aurora-y: 10%;
  inset: -34% -28% -10% -22%;
}

.auth-paths-3d {
  --paths-3d-opacity: 0.34;
  --paths-3d-blend: screen;
  inset: -4% -12% -4% -16%;
}

.career-board::after {
  position: absolute;
  right: 32px;
  bottom: 32px;
  width: 210px;
  height: 150px;
  content: "";
  border-right: 1px solid rgba(238, 246, 255, 0.26);
  border-bottom: 1px solid rgba(238, 246, 255, 0.26);
}

.career-board > :not(.auth-rays):not(.auth-aurora):not(.auth-paths-3d) {
  position: relative;
  z-index: 1;
}

.window-strip {
  display: flex;
  gap: 8px;
  margin-bottom: clamp(2.875rem, 7dvh, 7rem);

  span {
    width: 10px;
    height: 10px;
    border: 1px solid rgba(238, 246, 255, 0.42);
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
  color: #15243b;
  background: #0891b2;
  border-radius: 6px;
}

.career-board h1 {
  width: min(44rem, 100%);
  font-size: 3.25rem;
  line-height: 1.04;
  font-weight: 850;
  margin: 0;
}

.board-copy {
  width: min(38rem, 100%);
  margin: 1.25rem 0 0;
  color: rgba(238, 246, 255, 0.76);
  font-size: 1rem;
  line-height: 1.8;
}

.board-metrics {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 0.75rem;
  width: min(58rem, 100%);
  margin-top: clamp(2rem, 5dvh, 4.5rem);

  div {
    position: relative;
    overflow: hidden;
    min-height: 7rem;
    padding: 1rem;
    border: 1px solid rgba(238, 246, 255, 0.16);
    border-radius: 0.75rem;
    background:
      var(--cr-noise-texture),
      rgba(238, 246, 255, 0.06);
    background-size: 180px 180px, auto;
    background-blend-mode: soft-light, normal;
  }

  b {
    display: block;
    margin-bottom: 0.625rem;
    font-size: 0.9375rem;
  }

  span {
    display: block;
    color: rgba(238, 246, 255, 0.68);
    font-size: 0.8125rem;
    line-height: 1.65;
  }
}

.board-focus {
  width: min(42rem, 100%);
  margin-top: clamp(1.25rem, 3dvh, 2.5rem);
  padding: 1.125rem;
  border: 1px solid rgba(238, 246, 255, 0.14);
  border-radius: 0.75rem;
  background:
    var(--cr-noise-texture),
    rgba(8, 145, 178, 0.08);
  background-size: 180px 180px, auto;
  background-blend-mode: soft-light, normal;
  box-shadow: inset 3px 0 0 rgba(8, 145, 178, 0.86);
}

.focus-heading {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 1rem;
  padding-bottom: 0.75rem;
  border-bottom: 1px dashed rgba(238, 246, 255, 0.18);

  span {
    font-size: 0.9375rem;
    font-weight: 900;
  }

  small {
    color: rgba(238, 246, 255, 0.58);
    font-size: 0.75rem;
    font-weight: 800;
    white-space: nowrap;
  }
}

.board-focus ul {
  display: grid;
  gap: 0.75rem;
  margin-top: 0.875rem;
}

.board-focus li {
  position: relative;
  padding-left: 1.125rem;
  color: rgba(238, 246, 255, 0.72);
  font-size: 0.8125rem;
  line-height: 1.6;
}

.board-focus li::before {
  position: absolute;
  top: 0.62em;
  left: 0;
  width: 0.375rem;
  height: 0.375rem;
  content: "";
  background: #0891b2;
  border-radius: 50%;
  box-shadow: 0 0 0 0.25rem rgba(8, 145, 178, 0.14);
}

.entry-stack {
  display: grid;
  gap: 12px;
  width: min(40rem, 100%);
  margin-top: clamp(1.5rem, 4dvh, 3.25rem);
  padding-top: 0;
}

.entry-row {
  display: grid;
  grid-template-columns: 74px minmax(0, 1fr);
  gap: 14px;
  align-items: center;
  padding: 12px 0;
  border-top: 1px dashed rgba(238, 246, 255, 0.22);

  b {
    display: block;
    font-size: 14px;
  }

  p {
    margin-top: 4px;
    color: rgba(238, 246, 255, 0.66);
    font-size: 13px;
  }
}

.entry-code {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  height: 34px;
  color: #15243b;
  background: #eef6ff;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 800;
}

.auth-panel {
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: clamp(2rem, 3.4vw, 5rem);
  background:
    var(--cr-noise-texture),
    #ffffff;
  background-size: 180px 180px, auto;
  background-blend-mode: soft-light, normal;
}

.auth-heading {
  margin-bottom: 24px;

  h2 {
    margin: 16px 0 10px;
    color: #172033;
    font-size: 28px;
    line-height: 1.25;
  }

  p {
    min-height: 44px;
    color: #5d6f88;
    font-size: 14px;
    line-height: 1.7;
  }
}

.auth-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 8px 10px;
  color: #1d4ed8;
  background: #eaf1ff;
  border: 1px solid rgba(37, 99, 235, 0.14);
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
  color: #5d6f88;
  background: #f8fbff;
  border: 1px solid rgba(93, 111, 136, 0.16);
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
  color: #172033;
  border-color: rgba(37, 99, 235, 0.28);
  transform: translateY(-1px);
}

.role-chip.active {
  color: #ffffff;
  background: #2563eb;
  border-color: #2563eb;
  box-shadow: inset 0 -2px 0 rgba(8, 145, 178, 0.72);
}

.auth-form {
  :deep(.el-form-item) {
    margin-bottom: 18px;
  }

  :deep(.el-form-item__label) {
    margin-bottom: 7px;
    color: #172033;
    font-weight: 800;
    line-height: 1.2;
  }

  :deep(.el-input__wrapper) {
    min-height: 48px;
    border-radius: 8px;
    background: #f8fbff;
    box-shadow: inset 0 0 0 1px rgba(93, 111, 136, 0.2);
    transition: box-shadow 0.2s ease, background 0.2s ease;
  }

  :deep(.el-input__wrapper.is-focus) {
    background: #ffffff;
    box-shadow: inset 0 0 0 1px #2563eb, 0 0 0 4px rgba(37, 99, 235, 0.12);
  }

  :deep(.el-input__inner) {
    color: #172033;
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
  color: #ffffff;
  background: #172033;
  border: 1px solid #172033;
  border-radius: 8px;
  box-shadow: 0 12px 26px rgba(37, 99, 235, 0.24);
  cursor: pointer;
  font-size: 15px;
  font-weight: 900;
  transition: background 0.2s ease, box-shadow 0.2s ease, transform 0.2s ease;
}

.primary-action:hover:not(:disabled) {
  background: #1d4ed8;
  box-shadow: 0 16px 30px rgba(37, 99, 235, 0.28);
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
  border: 2px solid rgba(255, 255, 255, 0.38);
  border-top-color: #ffffff;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

.auth-links {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: nowrap;
  gap: 14px;
  margin-top: 18px;
  font-size: 14px;

  a {
    color: #2563eb;
    font-weight: 800;
    white-space: nowrap;
  }

  a:hover {
    color: #172033;
  }
}

.auth-next {
  margin-top: clamp(1.75rem, 4dvh, 3.5rem);
  padding-top: clamp(1.25rem, 2.5dvh, 2rem);
  border-top: 1px dashed rgba(93, 111, 136, 0.22);
}

.next-heading {
  margin-bottom: 0.875rem;
  color: #172033;
  font-size: 0.9375rem;
  font-weight: 900;
}

.next-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 0.75rem;

  span {
    min-width: 0;
    padding: 0.75rem 0.875rem;
    color: #5d6f88;
    background: #f8fbff;
    border: 1px solid rgba(93, 111, 136, 0.16);
    border-radius: 0.5rem;
    font-size: 0.875rem;
    font-weight: 750;
  }
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

@media (min-width: 1800px) {
  .login-window {
    min-height: clamp(36rem, 76dvh, 76rem);
  }

  .auth-panel {
    justify-content: center;
    padding-block: clamp(3rem, 6dvh, 6rem);
  }

  .auth-heading {
    margin-bottom: 2rem;
  }

  .career-board h1 {
    font-size: 4rem;
  }

  .auth-heading h2 {
    font-size: 2.25rem;
  }

  .auth-heading p,
  .auth-links {
    font-size: 1rem;
  }

  .role-chip {
    min-height: 3.5rem;
    font-size: 0.9375rem;
  }

  .role-switcher {
    gap: 0.75rem;
    margin-bottom: 2rem;
  }

  .auth-form {
    :deep(.el-form-item) {
      margin-bottom: 1.5rem;
    }

    :deep(.el-input__wrapper) {
      min-height: 3.75rem;
    }
  }

  .primary-action {
    min-height: 4.25rem;
    font-size: 1rem;
  }

  .auth-links {
    margin-top: 1.5rem;
  }
}

@media (min-width: 1800px) and (max-height: 1300px) {
  .login-window {
    min-height: calc(100dvh - 7.5rem);
  }

  .career-board,
  .auth-panel {
    padding: clamp(2rem, 2.6vw, 3.5rem);
  }

  .window-strip {
    margin-bottom: clamp(1.75rem, 4dvh, 3.5rem);
  }

  .career-board h1 {
    font-size: clamp(3rem, 3.4vw, 3.625rem);
  }

  .board-metrics {
    margin-top: clamp(1.5rem, 3dvh, 2.5rem);
  }

  .board-focus {
    margin-top: clamp(1rem, 2dvh, 1.5rem);
  }

  .entry-stack {
    margin-top: clamp(1rem, 2.5dvh, 2rem);
    gap: 0.5rem;
  }

  .entry-row {
    padding: 0.625rem 0;
  }

  .auth-next {
    margin-top: clamp(1.25rem, 2.5dvh, 2rem);
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
    order: 2;
  }

  .auth-panel {
    order: 1;
  }

  .career-board {
    padding: 28px;
  }

  .window-strip {
    margin-bottom: 36px;
  }

  .career-board h1 {
    font-size: 2.25rem;
  }

  .entry-stack {
    margin-top: 36px;
    padding-top: 12px;
  }

  .board-metrics {
    grid-template-columns: 1fr;
    margin-top: 28px;
  }

  .board-focus {
    margin-top: 20px;
  }

  .auth-panel {
    padding: 32px 28px;
  }

  .auth-next {
    margin-top: 24px;
  }
}

@media (max-width: 560px) {
  .login-topbar {
    width: calc(100% - 1.25rem);
    padding-top: 16px;
  }

  .brand-mark span:last-child {
    display: none;
  }

  .login-stage {
    padding: 12px 14px 24px;
  }

  .login-window {
    width: 100%;
    border-radius: 0.875rem;
  }

  .career-board {
    padding: 22px;
  }

  .career-board::after {
    display: none;
  }

  .career-board h1 {
    font-size: 1.75rem;
  }

  .board-copy {
    font-size: 0.875rem;
  }

  .window-strip {
    margin-bottom: 26px;
  }

  .entry-row {
    grid-template-columns: 62px minmax(0, 1fr);
  }

  .board-metrics div {
    min-height: 0;
  }

  .auth-panel {
    padding: 26px 20px;
  }

  .role-switcher {
    grid-template-columns: 1fr;
    gap: 6px;
    margin-bottom: 20px;
  }

  .role-chip {
    min-height: 40px;
    padding: 0 8px;
  }

  .auth-links {
    align-items: center;
    justify-content: space-between;
    flex-direction: row;
    flex-wrap: wrap;
    gap: 10px;
    font-size: 13px;
  }

  .next-grid {
    grid-template-columns: 1fr;
  }
}

/* visual refresh overrides */
.login-container {
  color: var(--cr-text);
  background:
    linear-gradient(135deg, rgba(15, 118, 110, 0.10), transparent 34%),
    linear-gradient(315deg, rgba(36, 84, 214, 0.10), transparent 40%),
    linear-gradient(90deg, rgba(36, 84, 214, 0.05) 1px, transparent 1px),
    linear-gradient(0deg, rgba(36, 84, 214, 0.05) 1px, transparent 1px),
    var(--cr-bg);
  font-family: "PingFang SC", "Microsoft YaHei", "Helvetica Neue", Arial, sans-serif;
}

.login-container::before {
  background:
    linear-gradient(90deg, rgba(255, 255, 255, 0.70), transparent 42%),
    linear-gradient(180deg, transparent 0%, rgba(36, 84, 214, 0.07) 100%);
}

.brand-icon,
.role-chip.active,
.primary-action {
  background: linear-gradient(135deg, var(--cr-primary), var(--cr-accent));
  border-color: var(--cr-primary);
}

.brand-icon,
.ghost-link,
.board-kicker,
.board-metrics div,
.board-focus,
.entry-code,
.auth-badge,
.role-chip,
.auth-form :deep(.el-input__wrapper),
.next-grid span,
.primary-action {
  border-radius: var(--cr-radius-sm);
}

.login-window {
  border-color: rgba(203, 216, 231, 0.9);
  border-radius: var(--cr-radius);
  box-shadow: 0 34px 70px rgba(16, 24, 39, 0.16), var(--cr-shadow-line);
}

.career-board {
  background:
    var(--cr-noise-texture),
    linear-gradient(135deg, rgba(15, 118, 110, 0.24), transparent 34%),
    linear-gradient(90deg, rgba(255, 255, 255, 0.08) 1px, transparent 1px),
    linear-gradient(0deg, rgba(255, 255, 255, 0.06) 1px, transparent 1px),
    var(--cr-sidebar);
  background-size: 180px 180px, auto, 32px 32px, 32px 32px, auto;
  background-blend-mode: soft-light, normal, normal, normal, normal;
}

.auth-panel {
  background:
    var(--cr-noise-texture),
    linear-gradient(180deg, #ffffff, #f8fbff);
  background-size: 180px 180px, auto;
  background-blend-mode: soft-light, normal;
}

.board-kicker {
  background: #8de2db;
}

.auth-heading h2,
.auth-form :deep(.el-form-item__label),
.auth-form :deep(.el-input__inner),
.next-heading {
  color: var(--cr-text);
}

.auth-heading p,
.role-chip,
.next-grid span,
.ghost-link {
  color: var(--cr-text-soft);
}

.auth-badge,
.auth-links a {
  color: var(--cr-primary);
}

.auth-badge {
  background: var(--cr-primary-soft);
  border-color: rgba(36, 84, 214, 0.14);
}

.auth-form :deep(.el-input__wrapper.is-focus) {
  box-shadow: inset 0 0 0 1px var(--cr-primary), var(--cr-ring);
}

.primary-action {
  min-height: 56px;
  padding: 0 20px 0 24px;
  border-radius: 12px;
  font-size: 16px;
  line-height: 1;
  box-shadow: 0 12px 26px rgba(36, 84, 214, 0.24);
}

.primary-action .el-icon {
  font-size: 18px;
}

.primary-action:hover:not(:disabled) {
  background: linear-gradient(135deg, var(--cr-primary-strong), var(--cr-accent));
  box-shadow: 0 16px 30px rgba(36, 84, 214, 0.28);
}

/* Material 3 inspired identity switch */
.role-switcher {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  align-items: stretch;
  gap: 4px;
  margin-bottom: 28px;
  padding: 4px;
  overflow: hidden;
  border: 1px solid rgba(36, 84, 214, 0.14);
  border-radius: 999px;
  background:
    linear-gradient(180deg, rgba(255, 255, 255, 0.92), rgba(239, 246, 255, 0.92)),
    rgba(232, 240, 253, 0.86);
  box-shadow:
    inset 0 1px 0 rgba(255, 255, 255, 0.86),
    inset 0 -1px 0 rgba(36, 84, 214, 0.08),
    0 10px 24px rgba(16, 24, 39, 0.07);
}

.role-chip {
  position: relative;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 7px;
  min-width: 0;
  min-height: clamp(48px, 2.55vw, 56px);
  height: 100%;
  padding: 0 12px;
  overflow: hidden;
  color: #58677f;
  background: transparent;
  border: 1px solid transparent;
  border-radius: 999px;
  box-shadow: none;
  cursor: pointer;
  font-size: clamp(13px, 0.72vw, 15px);
  font-weight: 900;
  line-height: 1;
  white-space: nowrap;
  transition:
    background 0.2s ease,
    border-color 0.2s ease,
    box-shadow 0.2s ease,
    color 0.2s ease,
    transform 0.2s ease;

  svg {
    flex: 0 0 auto;
    width: 22px;
    height: 22px;
    padding: 3px;
    border-radius: 999px;
    background: rgba(36, 84, 214, 0.08);
    color: currentColor;
    box-sizing: border-box;
    transition: background 0.2s ease, transform 0.2s ease;
  }

  span {
    display: inline-block;
    min-width: 0;
    line-height: 1;
    transform: translateY(0.5px);
  }
}

.role-chip:hover {
  color: var(--cr-text);
  background: rgba(255, 255, 255, 0.72);
  border-color: rgba(36, 84, 214, 0.12);
  transform: translateY(0);
}

.role-chip.active {
  color: #ffffff;
  background:
    linear-gradient(180deg, rgba(255, 255, 255, 0.18), transparent 42%),
    linear-gradient(135deg, var(--cr-primary), var(--cr-accent));
  border-color: rgba(255, 255, 255, 0.36);
  box-shadow:
    inset 0 1px 0 rgba(255, 255, 255, 0.28),
    inset 0 -1px 0 rgba(7, 89, 133, 0.48),
    0 8px 18px rgba(36, 84, 214, 0.22);
}

.role-chip.active svg {
  background: rgba(255, 255, 255, 0.22);
  transform: scale(1.04);
}

.role-chip:active {
  transform: scale(0.985);
}

.role-chip:focus-visible {
  outline: none;
  box-shadow:
    0 0 0 2px #ffffff,
    0 0 0 5px rgba(36, 84, 214, 0.28);
}

@media (max-width: 560px) {
  .role-switcher {
    grid-template-columns: 1fr;
    gap: 6px;
    padding: 6px;
    border-radius: 18px;
  }

  .role-chip {
    min-height: 46px;
    justify-content: center;
  }
}

@media (prefers-reduced-motion: reduce) {
  .role-chip,
  .role-chip svg {
    transition: none;
  }
}
</style>

