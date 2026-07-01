<template>
  <div class="fair-list portal-content">
    <div class="page-card head">
      <h2><el-icon><Calendar /></el-icon> 大型招聘会</h2>
      <p class="sub">面向全校学生的双选会、专场招聘会信息</p>
    </div>

    <div class="page-card page-flex-card portal-list-card compact-list-card mt-20">
      <div class="page-flex-scroll">
        <div ref="gridRef" class="grid" v-loading="loading">
          <div class="fair-card" v-for="f in list" :key="f.id">
            <div class="cover" :style="f.cover ? { backgroundImage: `url(${f.cover})` } : { background: 'linear-gradient(135deg, #2563eb 0%, #0891b2 100%)' }">
              <div class="cover-mask">
                <h3 class="title">{{ f.title }}</h3>
              </div>
            </div>
            <div class="body">
              <div class="info-row"><el-icon><Clock /></el-icon> {{ formatDateTime(f.fairTime) }}</div>
              <div class="info-row"><el-icon><Location /></el-icon> {{ f.location }}</div>
              <div class="info-row"><el-icon><Trophy /></el-icon> 主办方：{{ f.host || '校就业指导中心' }}</div>
              <p class="content">{{ f.content }}</p>
              <div class="stats">
                <div class="stat-item"><span class="num">{{ f.companyCount || 0 }}</span><span class="label">参会企业</span></div>
                <div class="stat-item"><span class="num">{{ f.jobCount || 0 }}</span><span class="label">提供岗位</span></div>
                <div class="stat-item"><span class="num">{{ f.signCount || 0 }}</span><span class="label">报名人数</span></div>
              </div>
              <el-button type="primary" class="w-full sign-button" @click="onSign(f)">立即报名</el-button>
            </div>
          </div>
          <el-empty v-if="!loading && list.length === 0" description="暂无招聘会" class="grid-empty" />
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
import { Calendar, Clock, Location, Trophy } from '@element-plus/icons-vue'
import { activityApi, publicApi } from '@/api'
import { useUserStore } from '@/store/user'
import { showLoginPrompt, showSignupSuccessPrompt } from '@/utils/loginPrompt'
import { useResponsivePageSize } from '@/utils/responsivePageSize'
import { refreshUnreadCounts } from '@/utils/unreadCounts'

const userStore = useUserStore()
const query = reactive({ pageNum: 1, pageSize: 10 })
const list = ref([])
const total = ref(0)
const loading = ref(false)
const gridRef = ref(null)

const formatDateTime = (d) => d ? d.replace('T', ' ').substring(0, 16) : ''
const onSign = async (fair) => {
  if (!userStore.isLogin) {
    showLoginPrompt('登录后才能报名参加招聘会。')
    return
  }
  const res = await activityApi.sign(2, fair.id)
  showSignupSuccessPrompt(`${res.message || '报名成功，请准时参加'}。时间：${formatDateTime(fair.fairTime) || '待定'}，地点：${fair.location || '待定'}。`)
  await refreshUnreadCounts(userStore, { includeChat: false })
  load()
}

const load = async () => {
  loading.value = true
  try {
    const res = await publicApi.fairs(query)
    list.value = res.data.records; total.value = Number(res.data.total)
  } finally { loading.value = false }
}
const { initResponsivePageSize } = useResponsivePageSize(gridRef, query, load, { itemMinWidth: 360, itemMinHeight: 378, gap: 14, rows: 2 })

onMounted(async () => {
  await initResponsivePageSize()
  load()
})
</script>

<style scoped lang="scss">
.head h2 { color: var(--cr-text); .el-icon { vertical-align: middle; color: var(--cr-primary); } }
.head .sub { color: var(--cr-text-muted); margin-top: .375rem; }
.grid { display: grid; align-content: start; grid-template-columns: repeat(auto-fill, minmax(min(100%, 22.5rem), 1fr)); gap: .875rem; }
.fair-card { min-height: 23.625rem; background: #fff; border: 0.0625rem solid var(--cr-border-soft); border-radius: var(--cr-radius); overflow: hidden; box-shadow: var(--cr-shadow-soft); display: flex; flex-direction: column;
  .cover { aspect-ratio: 16 / 5; min-block-size: clamp(5.75rem, 10vw, 7rem); background-size: cover; background-position: center; position: relative;
    .cover-mask { position: absolute; inset: 0; background: linear-gradient(180deg, transparent, rgba(0,0,0,.62)); padding: .875rem; display: flex; align-items: flex-end;
      .title { color: #fff; margin: 0; font-size: 1rem; line-height: 1.35; }
    }
  }
  .body { flex: 1; display: flex; flex-direction: column; padding: .875rem; }
  .info-row { color: var(--cr-text-soft); font-size: .78125rem; line-height: 1.65; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; .el-icon { vertical-align: middle; margin-right: .25rem; color: var(--cr-primary); } }
  .content { color: var(--cr-text-muted); font-size: .78125rem; line-height: 1.55; margin: .5rem 0; display: -webkit-box; -webkit-line-clamp: 1; -webkit-box-orient: vertical; overflow: hidden; }
  .stats { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: .375rem; padding: .5rem; background: var(--cr-surface-soft); border-radius: var(--cr-radius-sm); margin: .625rem 0 .75rem;
    .stat-item { flex: 1; text-align: center;
      .num { display: block; color: var(--cr-danger); font-size: 1rem; font-weight: 750; line-height: 1.2; }
      .label { color: var(--cr-text-muted); font-size: .6875rem; }
    }
  }
  .sign-button {
    min-height: 2.625rem;
    font-size: .9375rem;
    font-weight: 800;
  }
}
</style>
