<template>
  <div class="portal-layout">
    <el-header class="portal-header">
      <div class="portal-content header-inner">
        <div class="logo" @click="$router.push('/')">
          <el-icon class="logo-icon"><School /></el-icon>
          <span>校园求职招聘系统</span>
        </div>
        <el-menu ref="navMenuRef" mode="horizontal" :default-active="$route.path" class="nav" :ellipsis="false" @select="handleNav">
          <el-menu-item index="/"><span class="nav-text">首页</span></el-menu-item>
          <el-menu-item index="/jobs"><span class="nav-text">职位</span></el-menu-item>
          <el-menu-item index="/enterprises"><span class="nav-text">企业</span></el-menu-item>
          <el-menu-item index="/seekers"><span class="nav-text">求职栏</span></el-menu-item>
          <el-menu-item index="/talks"><span class="nav-text">宣讲会</span></el-menu-item>
          <el-menu-item index="/fairs"><span class="nav-text">招聘会</span></el-menu-item>
          <el-menu-item index="/news"><span class="nav-text">资讯</span></el-menu-item>
          <el-menu-item index="/forum"><span class="nav-text">社区</span></el-menu-item>
          <el-menu-item :index="noticePath">
            <span class="nav-label">
              通知
              <span v-if="unreadCount" class="nav-unread">{{ formatBadge(unreadCount) }}</span>
            </span>
          </el-menu-item>
          <el-menu-item :index="chatPath">
            <span class="nav-label">
              在线沟通
              <span v-if="chatUnreadCount" class="nav-unread">{{ formatBadge(chatUnreadCount) }}</span>
            </span>
          </el-menu-item>
        </el-menu>
        <div class="user-area">
          <template v-if="userStore.isLogin">
            <el-dropdown trigger="click" popper-class="top-user-dropdown" @command="onCommand">
              <button class="top-user-entry cr-border-beam-surface" type="button">
                <span class="top-user-avatar-wrap">
                  <el-avatar :size="40" :src="userStore.avatar"><el-icon><User /></el-icon></el-avatar>
                </span>
                <span class="top-user-copy">
                  <span class="top-user-role">{{ roleLabel }}</span>
                  <span class="top-user-name">{{ userStore.name || userStore.username }}</span>
                </span>
                <el-icon class="top-user-arrow"><ArrowDown /></el-icon>
              </button>
              <template #dropdown>
                <el-dropdown-menu class="top-user-panel cr-border-beam-surface">
                  <div class="top-user-panel-head">
                    <el-avatar :size="46" :src="userStore.avatar"><el-icon><User /></el-icon></el-avatar>
                    <div>
                      <strong>{{ userStore.name || userStore.username }}</strong>
                      <span>{{ roleLabel }} · {{ userStore.username }}</span>
                    </div>
                  </div>
                  <div v-if="canUsePortalMessages" class="top-user-metrics">
                    <button type="button" @click="goNotice">
                      <el-icon><Bell /></el-icon>
                      <span>通知</span>
                      <b>{{ formatBadge(unreadCount || 0) }}</b>
                    </button>
                    <button type="button" @click="goChat">
                      <el-icon><ChatLineRound /></el-icon>
                      <span>沟通</span>
                      <b>{{ formatBadge(chatUnreadCount || 0) }}</b>
                    </button>
                  </div>
                  <el-dropdown-item command="center" class="top-user-menu-item">
                    <el-icon><UserFilled /></el-icon>
                    <span>个人中心</span>
                    <small>进入工作台</small>
                  </el-dropdown-item>
                  <el-dropdown-item command="logout" class="top-user-menu-item is-danger">
                    <el-icon><SwitchButton /></el-icon>
                    <span>退出登录</span>
                    <small>结束当前会话</small>
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>
          <template v-else>
            <el-button text @click="$router.push('/login')">登录</el-button>
            <el-button type="primary" @click="$router.push('/register')">注册</el-button>
          </template>
        </div>
      </div>
    </el-header>
    <el-main class="portal-main">
      <router-view />
    </el-main>
    <el-footer class="portal-footer">
      <div class="portal-content">
        <p>© 2026 校园求职招聘系统 | 基于 Spring Boot 框架的毕业设计</p>
        <p>Tech: Spring Boot · MyBatis-Plus · MySQL · Vue 3 · Element Plus · ECharts</p>
      </div>
    </el-footer>
  </div>
</template>

<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { School, User, ArrowDown, Bell, ChatLineRound, UserFilled, SwitchButton } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { showLoginPrompt } from '@/utils/loginPrompt'
import { refreshUnreadCounts } from '@/utils/unreadCounts'

const router = useRouter()
const userStore = useUserStore()
const navMenuRef = ref()
const unreadCount = computed(() => Number(userStore.unreadNoticeCount || 0))
const chatUnreadCount = computed(() => Number(userStore.unreadChatCount || 0))
const roleLabel = computed(() => ({ STUDENT: '学生用户', ENTERPRISE: '企业用户', ADMIN: '超级管理员' }[userStore.role] || '系统用户'))
const canUsePortalMessages = computed(() => ['STUDENT', 'ENTERPRISE'].includes(userStore.role))
let badgeTimer

const noticePath = '/notice'
const chatPath = '/chat'
const formatBadge = (count) => Number(count) > 99 ? '99+' : Number(count)
const resetNavActive = () => nextTick(() => navMenuRef.value?.updateActiveIndex(router.currentRoute.value.path))
const goNotice = () => {
  router.push(noticePath)
}
const goChat = () => {
  router.push(chatPath)
}

const handleNav = (path) => {
  if (path === noticePath || path === chatPath) {
    if (!userStore.isLogin) {
      showLoginPrompt(path === noticePath ? '登录后才能查看通知消息。' : '登录后才能进入在线沟通。')
      resetNavActive()
      return
    }
    if (!['STUDENT', 'ENTERPRISE'].includes(userStore.role)) {
      ElMessage.error('无权访问该页面')
      resetNavActive()
      return
    }
  }
  router.push(path)
}

const refreshBadges = async () => {
  try {
    await refreshUnreadCounts(userStore)
  } catch (e) {
    userStore.setUnreadCounts(0, 0)
  }
}

const onCommand = (cmd) => {
  if (cmd === 'logout') {
    ElMessageBox.confirm('退出后需要重新输入账号密码登录。', '退出登录', {
      type: 'warning',
      customClass: 'cr-confirm-box',
      confirmButtonClass: 'cr-confirm-primary',
      cancelButtonClass: 'cr-confirm-secondary',
      confirmButtonText: '退出登录',
      cancelButtonText: '取消',
      closeOnClickModal: false
    }).then(() => {
      userStore.logout(); router.push('/login')
    }).catch(() => {})
  } else if (cmd === 'center') {
    if (userStore.role === 'STUDENT') router.push('/student')
    else if (userStore.role === 'ENTERPRISE') router.push('/enterprise')
    else router.push('/admin')
  }
}

onMounted(() => {
  refreshBadges()
  badgeTimer = window.setInterval(refreshBadges, 30000)
})
onBeforeUnmount(() => window.clearInterval(badgeTimer))
watch(() => userStore.token, refreshBadges)
</script>

<style scoped lang="scss">
.portal-layout { min-height: 100dvh; display: flex; flex-direction: column; }
.portal-header {
  position: sticky;
  top: 0;
  z-index: 20;
  height: auto;
  min-height: 4.5rem;
  padding: 0.5rem 0;
  background:
    var(--cr-noise-texture),
    rgba(246, 251, 255, 0.78);
  background-size: 180px 180px, auto;
  background-blend-mode: soft-light, normal;
  border-bottom: 0.0625rem solid var(--cr-border-soft);
  box-shadow: 0 0.75rem 1.75rem rgba(16, 24, 39, 0.06);
  backdrop-filter: blur(1rem) saturate(140%);
}
.header-inner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: clamp(0.75rem, 2vw, 1.75rem);
  min-height: 4rem;
  padding: 0;
}
.logo {
  display: flex;
  align-items: center;
  gap: 0.625rem;
  cursor: pointer;
  min-width: max-content;
  color: var(--cr-text);
  font-size: 1.125rem;
  font-weight: 850;
  letter-spacing: 0;
}
.logo-icon { font-size: clamp(1.5rem, 2.2vw, 1.75rem); }
.logo .el-icon {
  width: 2.375rem;
  height: 2.375rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--cr-radius-sm);
  background: linear-gradient(135deg, var(--cr-primary), var(--cr-accent));
  color: #fff;
  box-shadow: 0 0.75rem 1.375rem rgba(36, 84, 214, 0.18);
}
.nav {
  flex: 1;
  min-width: 0;
  height: 2.875rem;
  min-height: 2.875rem;
  padding: 0.25rem;
  display: flex;
  align-items: center;
  overflow-x: auto;
  --el-menu-active-color: #fff;
  border: 0.0625rem solid rgba(203, 216, 231, 0.62);
  border-radius: 999rem;
  background:
    var(--cr-noise-texture),
    rgba(255, 255, 255, 0.58);
  background-size: 180px 180px, auto;
  background-blend-mode: soft-light, normal;
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.8);
}
.nav { scrollbar-width: none; }
.nav::-webkit-scrollbar { display: none; }
.nav :deep(.el-menu--horizontal),
.nav :deep(.el-menu) {
  height: 2.875rem;
  display: flex;
  align-items: center;
  border-bottom: 0;
  background: transparent;
}
.nav.el-menu--horizontal {
  border: 0.0625rem solid rgba(203, 216, 231, 0.62) !important;
  background:
    var(--cr-noise-texture),
    rgba(255, 255, 255, 0.58) !important;
}
.nav :deep(.el-menu-item) {
  min-width: auto;
  height: 2.375rem;
  display: inline-flex;
  align-items: center;
  line-height: normal !important;
  margin: 0;
  padding: 0 clamp(0.625rem, 1.35vw, 1.125rem) !important;
  justify-content: center;
  box-sizing: border-box;
  border-bottom: 0 !important;
  border-radius: 999rem;
  background: transparent !important;
  background-color: transparent !important;
  color: var(--cr-text-soft);
  font-size: 0.9375rem;
  font-weight: 760;
}
.nav :deep(.el-menu--horizontal > .el-menu-item:not(.is-disabled):hover),
.nav :deep(.el-menu--horizontal > .el-menu-item:not(.is-disabled):focus),
.nav :deep(.el-menu--horizontal > .el-menu-item:not(.is-disabled).is-focus),
.nav :deep(.el-menu-item:hover),
.nav :deep(.el-menu-item:focus) {
  color: var(--cr-primary) !important;
  background: rgba(36, 84, 214, 0.08) !important;
  background-color: rgba(36, 84, 214, 0.08) !important;
  border-radius: 999rem !important;
}
.nav :deep(.el-menu--horizontal > .el-menu-item.is-active),
.nav :deep(.el-menu-item.is-active) {
  color: #fff !important;
  border-bottom-color: transparent !important;
  background: var(--cr-primary) !important;
  background-color: var(--cr-primary) !important;
  border-radius: 999rem !important;
  font-weight: 850;
  text-shadow: 0 0.0625rem 0.125rem rgba(0, 0, 0, 0.22);
}
.nav :deep(.el-menu--horizontal > .el-menu-item.is-active:hover),
.nav :deep(.el-menu--horizontal > .el-menu-item.is-active:focus),
.nav :deep(.el-menu-item.is-active:hover),
.nav :deep(.el-menu-item.is-active:focus) {
  color: #fff !important;
  background: var(--cr-primary) !important;
  background-color: var(--cr-primary) !important;
}
.nav :deep(.el-menu-item.is-active *) {
  color: #fff !important;
}
.nav-text,
.nav-label {
  display: inline-flex;
  align-items: center;
  gap: 0.375rem;
  line-height: 1;
  transform: translateY(0.0625rem);
}
.nav-unread {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 1rem;
  height: 1rem;
  padding: 0 0.3125rem;
  border-radius: 999px;
  background: var(--cr-danger);
  color: #fff;
  font-size: 0.6875rem;
  font-weight: 700;
  line-height: 1;
}
.user-area { display: flex; align-items: center; gap: 0.625rem; min-width: max-content; justify-content: flex-end; }
:deep(.el-tooltip__trigger:focus-visible) { outline: none; }
:deep(.el-tooltip__trigger:focus) { outline: none; }
.portal-main { flex: 1; background: transparent; padding: clamp(0.875rem, 2vw, 1.625rem) 0; }
.portal-footer {
  position: relative;
  overflow: hidden;
  height: auto;
  padding: 1.625rem;
  color: #c6d5e5;
  text-align: center;
  font-size: 0.8125rem;
  line-height: 1.8;
  background:
    linear-gradient(135deg, rgba(15, 118, 110, 0.20), transparent 38%),
    linear-gradient(90deg, var(--cr-sidebar), #14253a);
}

@media (min-width: 87.5rem) {
  .nav :deep(.el-menu-item) { padding: 0 1.5rem !important; }
}

@media (max-width: 68.75rem) {
  .header-inner {
    flex-wrap: wrap;
    justify-content: flex-start;
  }
  .logo { font-size: 1.0625rem; }
  .nav { order: 3; flex-basis: 100%; }
  .nav :deep(.el-menu-item) { padding: 0 0.875rem !important; }
  .user-area { margin-left: auto; }
}

@media (max-width: 40rem) {
  .logo span { max-width: 52vw; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .header-inner { gap: 0.5rem 0.75rem; }
  .nav { margin-inline: -0.75rem; padding-inline: 0.75rem; scroll-padding-inline: 0.75rem; }
  .nav :deep(.el-menu) { min-width: max-content; }
  .user-area :deep(.el-button) { padding: 0.5rem 0.625rem; }
  .user-area :deep(.top-user-name) { max-width: 6.25rem; }
}
</style>
