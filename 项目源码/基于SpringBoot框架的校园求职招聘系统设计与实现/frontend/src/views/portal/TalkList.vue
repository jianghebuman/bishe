<template>
  <div class="talk-list portal-content">
    <div class="page-card head">
      <h2><el-icon><ChatRound /></el-icon> 校园宣讲会</h2>
      <p class="sub">近期企业到校宣讲安排，提前了解、提前准备</p>
    </div>

    <div class="page-card page-flex-card portal-list-card compact-list-card mt-20">
      <div class="page-flex-scroll">
        <div ref="listRef" class="list" v-loading="loading">
          <div class="talk-item" v-for="t in list" :key="t.id">
            <div class="date">
              <div class="day">{{ getDay(t.talkTime) }}</div>
              <div class="month">{{ getMonth(t.talkTime) }}</div>
            </div>
            <div class="body">
              <h3 class="title">{{ t.title }}</h3>
              <div class="meta">
                <span><el-icon><OfficeBuilding /></el-icon> {{ t.companyName || '主办方' }}</span>
                <span><el-icon><Clock /></el-icon> {{ formatDateTime(t.talkTime) }}</span>
                <span><el-icon><Location /></el-icon> {{ t.location }}</span>
              </div>
              <p class="content">{{ t.content }}</p>
              <div class="footer">
                <el-tag size="small" type="success" v-if="t.signCount">已有 {{ t.signCount }} 人报名</el-tag>
                <el-button type="primary" plain class="sign-btn" @click="onSign(t)">报名参加</el-button>
              </div>
            </div>
          </div>
          <el-empty v-if="!loading && list.length === 0" description="暂无宣讲会安排" />
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
import { ChatRound, OfficeBuilding, Clock, Location } from '@element-plus/icons-vue'
import { activityApi, publicApi } from '@/api'
import { useUserStore } from '@/store/user'
import { showLoginPrompt, showSignupSuccessPrompt } from '@/utils/loginPrompt'
import { useResponsivePageSize } from '@/utils/responsivePageSize'
import { refreshUnreadCounts } from '@/utils/unreadCounts'

const userStore = useUserStore()
const query = reactive({ pageNum: 1, pageSize: 5 })
const list = ref([])
const total = ref(0)
const loading = ref(false)
const listRef = ref(null)

const formatDateTime = (d) => d ? d.replace('T', ' ').substring(0, 16) : ''
const getDay = (d) => d ? new Date(d.replace(' ', 'T')).getDate() : ''
const getMonth = (d) => d ? `${new Date(d.replace(' ', 'T')).getMonth() + 1}月` : ''
const onSign = async (talk) => {
  if (!userStore.isLogin) {
    showLoginPrompt('登录后才能报名参加宣讲会。')
    return
  }
  const res = await activityApi.sign(1, talk.id)
  showSignupSuccessPrompt(`${res.message || '报名成功，请准时参加'}。时间：${formatDateTime(talk.talkTime) || '待定'}，地点：${talk.location || '待定'}。`)
  await refreshUnreadCounts(userStore, { includeChat: false })
  load()
}

const load = async () => {
  loading.value = true
  try {
    const res = await publicApi.talks(query)
    list.value = res.data.records; total.value = Number(res.data.total)
  } finally { loading.value = false }
}
const { initResponsivePageSize } = useResponsivePageSize(listRef, query, load, { columns: 1, itemMinHeight: 146, gap: 10, rows: 5, minPageSize: 5, maxPageSize: 8, pagerReserve: 0 })

onMounted(async () => {
  await initResponsivePageSize()
  load()
})
</script>

<style scoped lang="scss">
.head h2 { color: var(--cr-text); .el-icon { vertical-align: middle; color: var(--cr-primary); } }
.head .sub { color: var(--cr-text-muted); margin-top: .375rem; }
.portal-list-card { --portal-list-card-min-height: calc(100dvh - 15.625rem); }
.list { display: grid; gap: .625rem; }
.talk-item { min-height: 9.125rem; background: #fff; border: 0.0625rem solid var(--cr-border-soft); border-radius: var(--cr-radius); padding: .875rem 1rem; display: grid; grid-template-columns: minmax(4rem, 4.5rem) minmax(0, 1fr); gap: .875rem; box-shadow: var(--cr-shadow-soft);
  .date { background: linear-gradient(135deg, var(--cr-primary), var(--cr-accent)); border-radius: var(--cr-radius-sm); color: #fff; text-align: center; padding: .625rem 0;
    .day { font-size: clamp(1.375rem, 3vw, 1.625rem); font-weight: 650; line-height: 1; }
    .month { font-size: .8125rem; margin-top: .25rem; }
  }
  .body { min-width: 0; }
  .title { color: var(--cr-text); margin-bottom: .3rem; line-height: 1.3; font-size: 1rem; }
  .meta { display: flex; flex-wrap: wrap; gap: .25rem .75rem; color: var(--cr-text-muted); font-size: .78125rem; margin-bottom: .3rem; .el-icon { vertical-align: middle; color: var(--cr-primary); } }
  .content { color: var(--cr-text-soft); font-size: .8125rem; line-height: 1.4; margin-bottom: .45rem; display: -webkit-box; -webkit-line-clamp: 1; -webkit-box-orient: vertical; overflow: hidden; }
  .footer { display: flex; justify-content: space-between; align-items: center; }
  .sign-btn { min-width: 7rem; height: 2.75rem; padding: 0 1.375rem; font-size: .9375rem; font-weight: 700; border-radius: .625rem; }
}

@media (max-width: 35rem) {
  .talk-item {
    grid-template-columns: 1fr;
    gap: .875rem;
  }

  .talk-item .date {
    display: flex;
    align-items: baseline;
    justify-content: center;
    gap: .5rem;
  }

  .talk-item .footer {
    align-items: stretch;
    flex-direction: column;
    gap: .625rem;
  }

  .talk-item .sign-btn {
    width: 100%;
  }
}
</style>
