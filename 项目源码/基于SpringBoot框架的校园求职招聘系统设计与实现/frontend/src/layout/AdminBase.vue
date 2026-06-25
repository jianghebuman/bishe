<template>
  <el-container class="admin-layout" :class="{ 'is-compact': isCompact }">
    <el-aside :width="asideWidth" class="aside">
      <div class="logo">
        <el-icon size="22"><School /></el-icon>
        <span v-if="!effectiveCollapse">{{ title }}</span>
      </div>
      <el-menu :default-active="$route.path" router :collapse="effectiveCollapse" text-color="#c9d1d9" active-text-color="#fff" class="menu">
        <template v-for="m in menus" :key="m.path">
          <el-menu-item :index="m.path">
            <el-icon><component :is="m.icon" /></el-icon>
            <template #title>{{ m.title }}</template>
          </el-menu-item>
        </template>
      </el-menu>
    </el-aside>
    <el-container>
      <el-header class="topbar flex-between">
        <div class="flex" style="align-items: center; gap: 12px;">
          <el-icon size="20" class="collapse-trigger" @click="collapse = !collapse">
            <Fold v-if="!effectiveCollapse" /><Expand v-else />
          </el-icon>
          <el-breadcrumb separator="/">
            <el-breadcrumb-item :to="{ path: menus[0]?.path }">{{ title }}</el-breadcrumb-item>
            <el-breadcrumb-item>{{ $route.meta.title }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        <div class="flex" style="align-items: center; gap: 16px;">
          <el-dropdown trigger="click" popper-class="top-user-dropdown" @command="onCmd">
            <span class="top-user-entry">
              <el-avatar :size="40" :src="userStore.avatar"><el-icon><User /></el-icon></el-avatar>
              <span class="top-user-name">{{ userStore.name || userStore.username }}</span>
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="portal">返回主界面</el-dropdown-item>
                <el-dropdown-item command="pwd">修改密码</el-dropdown-item>
                <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>
      <el-main class="main">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { School, Fold, Expand, User, ArrowDown } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'

defineProps({
  title: { type: String, default: '管理系统' },
  menus: { type: Array, default: () => [] },
  pwdPath: { type: String, default: '/admin/password' }
})
const collapse = ref(false)
const windowWidth = ref(window.innerWidth)
const isCompact = computed(() => windowWidth.value < 768)
const effectiveCollapse = computed(() => collapse.value || isCompact.value)
const asideWidth = computed(() => (effectiveCollapse.value ? '64px' : 'clamp(196px, 15vw, 232px)'))
const userStore = useUserStore()
const router = useRouter()
const route = useRoute()

const onCmd = (cmd) => {
  if (cmd === 'logout') {
    ElMessageBox.confirm('确定退出？', '提示', { type: 'warning' }).then(() => {
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
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', updateWindowWidth)
})
</script>

<style scoped lang="scss">
.admin-layout { min-height: 100dvh; height: 100dvh; min-width: 0; background: var(--cr-bg); }
.aside {
  background:
    linear-gradient(180deg, rgba(37, 99, 235, 0.18), transparent 30%),
    var(--cr-sidebar);
  transition: width .2s;
  overflow: hidden;
  flex-shrink: 0;
  border-right: 1px solid rgba(255, 255, 255, 0.08);
}
.logo { height: 62px; display: flex; align-items: center; gap: 10px; padding: 0 20px; color: #fff; font-weight: 700; border-bottom: 1px solid rgba(255,255,255,.1); white-space: nowrap; }
.logo .el-icon { color: #7dd3fc; }
.menu { border-right: none; }
:deep(.el-menu) { background: transparent !important; }
:deep(.el-menu-item) { margin: 4px 10px; border-radius: 10px; height: 44px; line-height: 44px; }
:deep(.el-menu-item:hover) { background: rgba(255,255,255,.08) !important; color: #fff !important; }
:deep(.el-menu-item.is-active) {
  background: linear-gradient(90deg, var(--cr-primary), var(--cr-accent)) !important;
  color: #fff !important;
  box-shadow: 0 10px 18px rgba(37, 99, 235, 0.22);
}
.topbar { background: rgba(255,255,255,.92); border-bottom: 1px solid var(--cr-border-soft); box-shadow: 0 8px 20px rgba(22, 38, 68, .05); padding: 0 clamp(12px, 1.6vw, 22px); height: 70px; min-width: 0; gap: 12px; backdrop-filter: blur(12px); }
.collapse-trigger { cursor: pointer; flex: 0 0 auto; }
.topbar .flex { min-width: 0; }
.topbar :deep(.el-breadcrumb) { min-width: 0; display: flex; align-items: center; flex-wrap: nowrap; }
.topbar :deep(.el-breadcrumb__item) { min-width: 0; }
.topbar :deep(.el-breadcrumb__inner) { display: inline-block; max-width: clamp(72px, 12vw, 180px); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; vertical-align: middle; }
.main { min-width: 0; background: transparent; padding: clamp(12px, 1.5vw, 20px); overflow-y: auto; overflow-x: hidden; }

.is-compact {
  .logo {
    justify-content: center;
    padding: 0;
  }

  .topbar {
    padding: 0 12px;
  }

  .topbar :deep(.el-breadcrumb__inner) {
    max-width: 72px;
  }

  :deep(.top-user-name) {
    max-width: 86px;
  }

  .main {
    padding: 12px;
  }
}

@media (max-width: 520px) {
  .topbar :deep(.el-breadcrumb) {
    display: none;
  }
}
</style>
