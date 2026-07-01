<template>
  <div class="ent-list portal-content">
    <div class="page-card head">
      <div>
        <h2><el-icon><OfficeBuilding /></el-icon> 名企推荐</h2>
        <p class="sub">汇聚优质企业，发现你的理想雇主</p>
      </div>
      <el-button class="favorite-entry" type="primary" plain @click="goFavorite">
        <el-icon><Star /></el-icon> 我的收藏
      </el-button>
    </div>

    <div class="page-card page-flex-card portal-list-card mt-20">
      <div class="page-flex-scroll ent-scroll">
        <div ref="gridRef" class="grid" v-loading="loading">
          <div class="ent-card" v-for="e in list" :key="e.id" @click="$router.push(`/enterprise/${e.id}`)">
            <el-avatar :src="e.logo" shape="square" class="logo"><el-icon class="logo-icon"><OfficeBuilding /></el-icon></el-avatar>
            <div class="info">
              <h3 class="name">{{ e.companyName }}</h3>
              <p class="meta">
                <span v-if="e.industry">{{ e.industry }}</span>
                <span class="sep" v-if="e.industry && e.scale">·</span>
                <span v-if="e.scale">{{ e.scale }}</span>
              </p>
              <p class="city" v-if="e.city"><el-icon><Location /></el-icon> {{ e.city }}</p>
              <p class="intro">{{ e.intro || '该企业暂未填写介绍' }}</p>
              <div class="chips">
                <el-tag v-if="e.nature" size="small" effect="plain">{{ e.nature }}</el-tag>
                <el-tag v-for="w in welfareTags(e.welfare)" :key="w" size="small" type="success" effect="plain">{{ w }}</el-tag>
              </div>
              <el-button class="favorite-btn" :type="favoriteIds.has(e.id) ? 'warning' : 'default'" plain size="small" @click.stop="toggleFavorite(e)">
                <el-icon><Star /></el-icon> {{ favoriteIds.has(e.id) ? '已收藏' : '收藏企业' }}
              </el-button>
            </div>
          </div>
          <el-empty v-if="!loading && list.length === 0" description="暂无企业" class="grid-empty" />
        </div>
      </div>
      <div class="pagination-wrap">
        <el-pagination v-model:current-page="query.pageNum" v-model:page-size="query.pageSize" :total="total"
          layout="total, prev, pager, next" background @current-change="load" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { OfficeBuilding, Location, Star } from '@element-plus/icons-vue'
import { publicApi, studentApi } from '@/api'
import { useUserStore } from '@/store/user'
import { useResponsivePageSize } from '@/utils/responsivePageSize'

const router = useRouter()
const userStore = useUserStore()
const query = reactive({ pageNum: 1, pageSize: 15 })
const list = ref([])
const total = ref(0)
const loading = ref(false)
const gridRef = ref(null)
const favoriteIds = ref(new Set())
const welfareTags = (welfare) => String(welfare || '').split(',').filter(Boolean).slice(0, 2)

const goFavorite = () => {
  if (!userStore.isLogin) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }
  if (userStore.role !== 'STUDENT') {
    ElMessage.warning('请使用学生账号查看收藏')
    return
  }
  router.push('/student/favorite')
}

const syncFavoriteStatus = async () => {
  if (!userStore.isLogin || userStore.role !== 'STUDENT' || list.value.length === 0) {
    favoriteIds.value = new Set()
    return
  }
  const rows = await Promise.all(list.value.map(async (enterprise) => {
    try {
      const res = await studentApi.checkEnterpriseFavorite(enterprise.id)
      return [enterprise.id, !!res.data?.favorite]
    } catch (e) {
      return [enterprise.id, false]
    }
  }))
  favoriteIds.value = new Set(rows.filter(([, favorite]) => favorite).map(([id]) => id))
}

const toggleFavorite = async (enterprise) => {
  if (!userStore.isLogin) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }
  if (userStore.role !== 'STUDENT') {
    ElMessage.warning('请使用学生账号收藏企业')
    return
  }
  const next = new Set(favoriteIds.value)
  if (next.has(enterprise.id)) {
    await studentApi.delEnterpriseFavorite(enterprise.id)
    next.delete(enterprise.id)
    ElMessage.success('已取消收藏')
  } else {
    await studentApi.addEnterpriseFavorite(enterprise.id)
    next.add(enterprise.id)
    ElMessage.success('已收藏')
  }
  favoriteIds.value = next
}

const load = async () => {
  loading.value = true
  try {
    const res = await publicApi.enterprises(query)
    list.value = res.data.records
    total.value = Number(res.data.total)
    await syncFavoriteStatus()
  } finally { loading.value = false }
}
const { initResponsivePageSize } = useResponsivePageSize(gridRef, query, load, { itemMinWidth: 340, itemMinHeight: 180, gap: 16, rows: 3 })

onMounted(async () => {
  await initResponsivePageSize()
  load()
})
</script>

<style scoped lang="scss">
.head { display: flex; align-items: center; justify-content: space-between; gap: 1rem; }
.head h2 { color: var(--cr-text); .el-icon { vertical-align: middle; color: var(--cr-primary); } }
.head .sub { color: var(--cr-text-muted); margin-top: .375rem; }
.favorite-entry { margin-left: 0; flex-shrink: 0; }
.portal-list-card { --portal-list-card-min-height: calc(100dvh - 15.625rem); }
.ent-scroll { display: flex; flex-direction: column; }
.grid { display: grid; align-content: start; grid-template-columns: repeat(auto-fill, minmax(min(100%, 21.25rem), 1fr)); grid-auto-rows: minmax(11.25rem, auto); gap: 1rem; }
.ent-card { min-height: 11.25rem; background: rgba(255,255,255,.96); border: 0.0625rem solid var(--cr-border-soft); border-radius: var(--cr-radius); padding: clamp(.9375rem, 1.2vw, 1.125rem); display: flex; align-items: stretch; gap: .875rem; cursor: pointer; transition: border-color .2s ease, box-shadow .2s ease, transform .2s ease;
  &:hover { border-color: rgba(37,99,235,.28); box-shadow: var(--cr-shadow); transform: translateY(-.125rem); }
  .logo { --el-avatar-size: clamp(3.5rem, 6vw, 4.5rem); flex-shrink: 0; }
  .logo-icon { font-size: clamp(1.5rem, 3vw, 2rem); }
  .info { flex: 1; min-width: 0; display: flex; flex-direction: column; }
  .name { font-size: 1.0625rem; color: var(--cr-text); margin-bottom: .25rem; line-height: 1.35; }
  .meta { font-size: .8125rem; color: var(--cr-text-muted); margin-bottom: .25rem; .sep { margin: 0 .375rem; } }
  .city { font-size: .8125rem; color: var(--cr-text-soft); margin-bottom: .375rem; .el-icon { vertical-align: middle; color: var(--cr-primary); } }
  .intro { color: var(--cr-text-soft); font-size: .8125rem; line-height: 1.55; margin-bottom: .5rem; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
  .chips { margin-top: auto; display: flex; flex-wrap: wrap; gap: .375rem; }
  .favorite-btn { width: max-content; margin: .75rem 0 0; }
}

@media (max-width: 28.75rem) {
  .head {
    align-items: stretch;
    flex-direction: column;
  }

  .favorite-entry {
    width: 100%;
  }

  .ent-card {
    align-items: flex-start;
    flex-direction: column;
  }

  .ent-card .favorite-btn {
    width: 100%;
  }
}
</style>
