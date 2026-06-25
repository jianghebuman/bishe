<template>
  <div class="portal-layout">
    <el-header class="portal-header">
      <div class="portal-content header-inner">
        <div class="logo" @click="$router.push('/')">
          <el-icon class="logo-icon"><School /></el-icon>
          <span>校园求职招聘系统</span>
        </div>
        <el-menu mode="horizontal" :default-active="$route.path" router class="nav" :ellipsis="false">
          <el-menu-item index="/">首页</el-menu-item>
          <el-menu-item index="/jobs">职位</el-menu-item>
          <el-menu-item index="/enterprises">企业</el-menu-item>
          <el-menu-item index="/talks">宣讲会</el-menu-item>
          <el-menu-item index="/fairs">招聘会</el-menu-item>
          <el-menu-item index="/news">资讯</el-menu-item>
          <el-menu-item index="/forum">社区</el-menu-item>
        </el-menu>
        <div class="user-area">
          <template v-if="userStore.isLogin">
            <el-dropdown trigger="click" @command="onCommand">
              <button class="user-link" type="button">
                <el-avatar class="user-avatar" :src="userStore.avatar"><el-icon><User /></el-icon></el-avatar>
                <span>{{ userStore.name || userStore.username }}</span>
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
import { useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { School, User } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'

const router = useRouter()
const userStore = useUserStore()

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
.user-area { display: flex; align-items: center; gap: 0.625rem; min-width: max-content; justify-content: flex-end; }
.user-avatar { --el-avatar-size: clamp(1.5rem, 2.4vw, 1.75rem); }
.user-link { appearance: none; border: 0; background: transparent; padding: 0.375rem 0.5rem; display: flex; align-items: center; gap: 0.375rem; cursor: pointer; color: var(--cr-text); font: inherit; border-radius: var(--cr-radius-sm); outline: none; }
.user-link:hover { background: var(--cr-surface-soft); }
.user-link:focus-visible { box-shadow: 0 0 0 0.1875rem rgba(37,99,235,.18); }
.user-link span:last-child { max-width: 8rem; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
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
}
</style>
