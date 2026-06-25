<template>
  <div class="portal-layout">
    <el-header class="portal-header">
      <div class="portal-content header-inner">
        <div class="logo" @click="$router.push('/')">
          <el-icon class="logo-icon"><School /></el-icon>
          <span>校园求职招聘系统</span>
        </div>
        <el-menu ref="navMenuRef" mode="horizontal" :default-active="$route.path" class="nav" :ellipsis="false" @select="handleNav">
          <el-menu-item index="/">首页</el-menu-item>
          <el-menu-item index="/jobs">职位</el-menu-item>
          <el-menu-item index="/enterprises">企业</el-menu-item>
          <el-menu-item index="/seekers">求职栏</el-menu-item>
          <el-menu-item index="/talks">宣讲会</el-menu-item>
          <el-menu-item index="/fairs">招聘会</el-menu-item>
          <el-menu-item index="/news">资讯</el-menu-item>
          <el-menu-item index="/forum">社区</el-menu-item>
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
              <button class="top-user-entry" type="button">
                <el-avatar :size="40" :src="userStore.avatar"><el-icon><User /></el-icon></el-avatar>
                <span class="top-user-name">{{ userStore.name || userStore.username }}</span>
                <el-icon><ArrowDown /></el-icon>
              </button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="center">个人中心</el-dropdown-item>
                  <el-dropdown-item command="logout">退出登录</el-dropdown-item>
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
import { School, User, ArrowDown } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { chatApi, noticeApi } from '@/api'
import { showLoginPrompt } from '@/utils/loginPrompt'

const router = useRouter()
const userStore = useUserStore()
const navMenuRef = ref()
const unreadCount = computed(() => Number(userStore.unreadNoticeCount || 0))
const chatUnreadCount = computed(() => Number(userStore.unreadChatCount || 0))
let badgeTimer

const noticePath = '/notice'
const chatPath = '/chat'
const formatBadge = (count) => Number(count) > 99 ? '99+' : Number(count)
const resetNavActive = () => nextTick(() => navMenuRef.value?.updateActiveIndex(router.currentRoute.value.path))

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
  if (!userStore.isLogin || userStore.role === 'ADMIN') {
    userStore.setUnreadCounts(0, 0)
    return
  }
  try {
    const [noticeRes, chatRes] = await Promise.all([noticeApi.unread(), chatApi.conversations()])
    const chatTotal = (chatRes.data || []).reduce((sum, item) => sum + Number(item.unread || 0), 0)
    userStore.setUnreadCounts(Number(noticeRes.data || 0), chatTotal)
  } catch (e) {
    userStore.setUnreadCounts(0, 0)
  }
}

const onCommand = (cmd) => {
  if (cmd === 'logout') {
    ElMessageBox.confirm('确定退出登录？', '提示', { type: 'warning' }).then(() => {
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
  min-height: 4.25rem;
  padding: 0;
  background: rgba(255, 255, 255, 0.88);
  border-bottom: 0.0625rem solid var(--cr-border-soft);
  box-shadow: 0 0.5rem 1.5rem rgba(22, 38, 68, 0.06);
  backdrop-filter: blur(0.875rem);
}
.header-inner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: clamp(0.75rem, 2vw, 1.75rem);
  min-height: 4.25rem;
  padding: 0.5rem 0;
}
.logo { display: flex; align-items: center; gap: 0.5rem; cursor: pointer; font-size: 1.125rem; font-weight: 700; color: var(--cr-text); min-width: max-content; }
.logo-icon { font-size: clamp(1.5rem, 2.2vw, 1.75rem); }
.logo .el-icon { color: var(--cr-primary); }
.nav { flex: 1; border-bottom: none; margin-left: 0; min-width: 0; overflow-x: auto; }
.nav { scrollbar-width: none; }
.nav::-webkit-scrollbar { display: none; }
.nav :deep(.el-menu--horizontal) { border-bottom: 0; }
.nav :deep(.el-menu-item) { min-width: auto; padding: 0 clamp(0.625rem, 1.5vw, 1.25rem); justify-content: center; color: var(--cr-text-soft); font-weight: 650; }
.nav :deep(.el-menu-item.is-active) { color: var(--cr-primary); border-bottom-color: var(--cr-primary); }
.nav-label { display: inline-flex; align-items: center; gap: 0.375rem; line-height: 1; }
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
.portal-footer { background: #172033; color: #b9c5d6; text-align: center; padding: 1.375rem; height: auto; font-size: 0.8125rem; line-height: 1.8; }

@media (min-width: 87.5rem) {
  .nav :deep(.el-menu-item) { padding: 0 1.5rem; }
}

@media (max-width: 68.75rem) {
  .header-inner {
    flex-wrap: wrap;
    justify-content: flex-start;
  }
  .logo { font-size: 1.0625rem; }
  .nav { order: 3; flex-basis: 100%; }
  .nav :deep(.el-menu-item) { padding: 0 0.875rem; }
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
