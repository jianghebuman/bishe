<template>
  <el-container class="admin-layout" :class="{ 'is-compact': isCompact }">
    <el-aside :width="asideWidth" class="aside">
      <div class="logo">
        <el-icon size="22"><School /></el-icon>
        <span v-if="!menuCollapsed">{{ title }}</span>
      </div>
      <el-menu :default-active="$route.path" router :mode="isCompact ? 'horizontal' : 'vertical'" :collapse="menuCollapsed" text-color="#c9d1d9" active-text-color="#fff" class="menu">
        <template v-for="m in menus" :key="m.path">
          <el-menu-item :index="m.path">
            <el-icon><component :is="m.icon" /></el-icon>
            <template #title>
              <span class="menu-title">
                {{ m.title }}
                <span v-if="isNoticeMenu(m) && unreadCount" class="menu-unread">{{ formatBadge(unreadCount) }}</span>
              </span>
            </template>
          </el-menu-item>
        </template>
      </el-menu>
    </el-aside>
    <el-container>
      <el-header class="topbar flex-between">
        <div class="flex" style="align-items: center; gap: 12px;">
          <el-icon size="20" class="collapse-trigger" @click="collapse = !collapse">
            <Fold v-if="!menuCollapsed" /><Expand v-else />
          </el-icon>
          <el-breadcrumb separator="/">
            <el-breadcrumb-item :to="{ path: menus[0]?.path }">{{ title }}</el-breadcrumb-item>
            <el-breadcrumb-item>{{ $route.meta.title }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        <div class="flex" style="align-items: center; gap: 16px;">
          <el-dropdown trigger="click" placement="bottom-end" popper-class="top-user-dropdown" :popper-options="userDropdownPopperOptions" @command="onCmd">
            <button class="top-user-entry cr-border-beam-surface" type="button">
              <span class="top-user-avatar-wrap">
                <el-avatar :size="40" :src="userStore.avatar"><el-icon><User /></el-icon></el-avatar>
              </span>
              <span class="top-user-copy">
                <span class="top-user-role">{{ roleLabel }}</span>
                <span class="top-user-name" :title="userStore.name || userStore.username">{{ userStore.name || userStore.username }}</span>
              </span>
              <el-icon class="top-user-arrow"><ArrowDown /></el-icon>
            </button>
            <template #dropdown>
              <el-dropdown-menu class="top-user-panel cr-border-beam-surface">
                <div class="top-user-panel-head">
                  <el-avatar :size="46" :src="userStore.avatar"><el-icon><User /></el-icon></el-avatar>
                  <div>
                    <strong>{{ userStore.name || userStore.username }}</strong>
                    <span class="top-user-panel-meta" :title="`${roleLabel} · ${userStore.username}`">{{ roleLabel }} · {{ userStore.username }}</span>
                  </div>
                </div>
                <el-dropdown-item command="portal" class="top-user-menu-item">
                  <el-icon><HomeFilled /></el-icon>
                  <span>返回主界面</span>
                  <small>浏览公开招聘门户</small>
                </el-dropdown-item>
                <el-dropdown-item command="pwd" class="top-user-menu-item">
                  <el-icon><Lock /></el-icon>
                  <span>修改密码</span>
                  <small>更新当前账号安全设置</small>
                </el-dropdown-item>
                <el-dropdown-item command="logout" class="top-user-menu-item is-danger">
                  <el-icon><SwitchButton /></el-icon>
                  <span>退出登录</span>
                  <small>结束当前会话</small>
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>
      <el-main ref="mainRef" class="main">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { ref, computed, nextTick, onMounted, onBeforeUnmount, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { School, Fold, Expand, User, ArrowDown, HomeFilled, Lock, SwitchButton } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { refreshUnreadCounts } from '@/utils/unreadCounts'

defineProps({
  title: { type: String, default: '管理系统' },
  menus: { type: Array, default: () => [] },
  pwdPath: { type: String, default: '/admin/password' }
})
const collapse = ref(false)
const windowWidth = ref(window.innerWidth)
const mainRef = ref()
const isCompact = computed(() => windowWidth.value < 900)
const menuCollapsed = computed(() => !isCompact.value && collapse.value)
const asideWidth = computed(() => (isCompact.value ? '100%' : menuCollapsed.value ? '64px' : 'clamp(196px, 15vw, 232px)'))
const userStore = useUserStore()
const router = useRouter()
const route = useRoute()
const unreadCount = computed(() => Number(userStore.unreadNoticeCount || 0))
const roleLabel = computed(() => ({ STUDENT: '学生用户', ENTERPRISE: '企业用户', ADMIN: '超级管理员' }[userStore.role] || '系统用户'))
const userDropdownPopperOptions = {
  modifiers: [
    { name: 'offset', options: { offset: [18, 8] } },
    { name: 'preventOverflow', options: { padding: { top: 8, right: 16, bottom: 8, left: 16 } } },
    { name: 'flip', options: { padding: 16 } }
  ]
}
let badgeTimer

const isNoticeMenu = (menu) => menu.path?.endsWith('/notice')
const formatBadge = (count) => Number(count) > 99 ? '99+' : Number(count)
const refreshBadges = async () => {
  try {
    await refreshUnreadCounts(userStore)
  } catch (e) {
    userStore.setUnreadCounts(0, 0)
  }
}

const onCmd = (cmd) => {
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
  } else if (cmd === 'portal') {
    router.push('/')
  } else if (cmd === 'pwd') {
    const base = route.path.split('/')[1]
    router.push(`/${base}/password`)
  }
}

const updateWindowWidth = () => {
  windowWidth.value = window.innerWidth
}

onMounted(() => {
  window.addEventListener('resize', updateWindowWidth)
  refreshBadges()
  badgeTimer = window.setInterval(refreshBadges, 30000)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', updateWindowWidth)
  window.clearInterval(badgeTimer)
})
watch(() => userStore.token, refreshBadges)
watch(() => route.fullPath, async () => {
  await nextTick()
  const mainEl = mainRef.value?.$el || mainRef.value
  mainEl?.scrollTo?.({ top: 0, left: 0 })
})
</script>

<style scoped lang="scss">
.admin-layout {
  min-height: 100dvh;
  height: 100dvh;
  min-width: 0;
  width: 100%;
  overflow: hidden;
  background:
    linear-gradient(135deg, rgba(15, 118, 110, 0.08), transparent 32%),
    linear-gradient(315deg, rgba(36, 84, 214, 0.10), transparent 42%),
    var(--cr-bg);
}
.aside {
  background:
    linear-gradient(160deg, rgba(15, 118, 110, 0.28), transparent 32%),
    linear-gradient(24deg, rgba(36, 84, 214, 0.24), transparent 52%),
    linear-gradient(180deg, var(--cr-sidebar), var(--cr-sidebar-2));
  transition: width .2s;
  overflow: hidden;
  flex-shrink: 0;
  border-right: 1px solid rgba(255, 255, 255, 0.08);
  box-shadow: 1rem 0 2.5rem rgba(16, 24, 39, 0.10);
}
.logo {
  height: 70px;
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 0 18px;
  color: #fff;
  font-weight: 850;
  border-bottom: 1px solid rgba(255,255,255,.10);
  white-space: nowrap;
  letter-spacing: 0;
}
.logo .el-icon {
  width: 2.25rem;
  height: 2.25rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  background: linear-gradient(135deg, var(--cr-primary), var(--cr-accent));
  border-radius: var(--cr-radius-sm);
  box-shadow: 0 0.75rem 1.375rem rgba(0, 0, 0, 0.18);
}
.menu { border-right: none; }
:deep(.el-menu) { background: transparent !important; }
:deep(.el-menu-item) {
  margin: 5px 10px;
  height: 44px;
  line-height: 44px;
  border-radius: var(--cr-radius-sm);
  font-weight: 730;
}
:deep(.el-menu-item .el-icon) {
  width: 28px;
  height: 28px;
  margin-right: 8px;
  border-radius: 8px;
  color: #9fb4cc;
  font-size: 17px;
  transition: background .18s, color .18s;
}
:deep(.el-menu-item:hover) { background: rgba(255,255,255,.08) !important; color: #fff !important; }
:deep(.el-menu-item:hover .el-icon) {
  background: rgba(255, 255, 255, 0.08);
  color: #eaf6ff;
}
:deep(.el-menu-item.is-active) {
  background: linear-gradient(90deg, var(--cr-primary), var(--cr-accent)) !important;
  color: #fff !important;
  box-shadow: 0 0.875rem 1.75rem rgba(36, 84, 214, 0.24);
}
:deep(.el-menu-item.is-active .el-icon) {
  background: rgba(255, 255, 255, 0.18);
  color: #fff;
}
.menu-title { min-width: 0; display: inline-flex; align-items: center; gap: 8px; }
.menu-unread {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 16px;
  height: 16px;
  padding: 0 5px;
  border-radius: 999px;
  background: var(--cr-danger);
  color: #fff;
  font-size: 11px;
  font-weight: 700;
  line-height: 1;
}
:deep(.el-menu--collapse .el-menu-item .el-icon) {
  margin-right: 0;
}
.topbar {
  height: 70px;
  min-width: 0;
  gap: 12px;
  padding: 0 clamp(12px, 1.6vw, 22px);
  background: rgba(255,255,255,.82);
  border-bottom: 1px solid rgba(203, 216, 231, 0.72);
  box-shadow: 0 0.75rem 1.75rem rgba(16, 24, 39, .06);
  backdrop-filter: blur(14px) saturate(140%);
}
.collapse-trigger {
  width: 2.25rem;
  height: 2.25rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--cr-radius-sm);
  background: rgba(36, 84, 214, 0.08);
  color: var(--cr-primary);
  cursor: pointer;
  flex: 0 0 auto;
}
.collapse-trigger:hover {
  background: var(--cr-primary);
  color: #fff;
}
.topbar .flex { min-width: 0; }
.topbar :deep(.el-breadcrumb) { min-width: 0; display: flex; align-items: center; flex-wrap: nowrap; }
.topbar :deep(.el-breadcrumb__item) { min-width: 0; }
.topbar :deep(.el-breadcrumb__inner) { display: inline-block; max-width: clamp(72px, 12vw, 180px); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; vertical-align: middle; }
.main { min-width: 0; background: transparent; padding: clamp(12px, 1.5vw, 20px); overflow-y: auto; overflow-x: hidden; }

.is-compact {
  > .el-container {
    flex: 1 1 100%;
    width: 100%;
    min-width: 0;
  }

  .aside {
    position: fixed;
    inset: auto 0 0;
    z-index: 40;
    width: 100% !important;
    height: calc(4.5rem + env(safe-area-inset-bottom));
    padding: 0.375rem 0.5rem calc(0.375rem + env(safe-area-inset-bottom));
    overflow-x: auto;
    overflow-y: hidden;
    border-top: 1px solid rgba(255, 255, 255, 0.12);
    border-right: 0;
    box-shadow: 0 -1rem 2.25rem rgba(16, 24, 39, 0.18);
    scrollbar-width: none;
  }

  .aside::-webkit-scrollbar {
    display: none;
  }

  .logo {
    display: none;
  }

  .menu {
    min-width: max-content;
    height: 100%;
    border-bottom: 0;
    overflow: visible;
  }

  :deep(.el-menu--horizontal) {
    height: 100%;
    border-bottom: 0;
  }

  :deep(.el-menu-item) {
    width: auto;
    min-width: 4.75rem;
    height: 3.75rem;
    margin: 0 0.125rem;
    padding: 0.375rem 0.625rem !important;
    display: inline-flex;
    flex-direction: column;
    justify-content: center;
    gap: 0.25rem;
    line-height: 1 !important;
    text-align: center;
  }

  :deep(.el-menu-item .el-icon) {
    width: 1.5rem;
    height: 1.5rem;
    margin-right: 0;
    font-size: 1rem;
  }

  .menu-title {
    max-width: 4.25rem;
    display: inline-flex;
    justify-content: center;
    font-size: 0.72rem;
    line-height: 1.1;
    white-space: nowrap;
  }

  .menu-unread {
    position: absolute;
    top: 0.35rem;
    right: 0.5rem;
  }

  .topbar {
    height: 3.875rem;
    padding: 0 0.625rem;
  }

  .collapse-trigger {
    display: none;
  }

  .topbar :deep(.el-breadcrumb__inner) {
    max-width: 72px;
  }

  :deep(.top-user-name) {
    max-width: 86px;
  }

  :deep(.top-user-entry) {
    width: 3rem;
    min-width: 3rem;
    max-width: 3rem;
    min-height: 3rem;
    padding: 0.25rem;
    justify-content: center;
    gap: 0;
  }

  :deep(.top-user-copy),
  :deep(.top-user-arrow) {
    display: none;
  }

  .main {
    padding: 0.625rem;
    padding-bottom: calc(5rem + env(safe-area-inset-bottom));
  }
}

@media (max-width: 520px) {
  .topbar :deep(.el-breadcrumb) {
    display: none;
  }
}
</style>
