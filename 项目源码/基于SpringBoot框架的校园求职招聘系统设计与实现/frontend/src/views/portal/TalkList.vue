<template>
  <div class="talk-list portal-content">
    <div class="page-card head">
      <h2><el-icon><ChatRound /></el-icon> 校园宣讲会</h2>
      <p class="sub">近期企业到校宣讲安排，提前了解、提前准备</p>
    </div>

    <div class="page-card page-flex-card portal-list-card compact-list-card mt-20">
      <div class="page-flex-scroll">
        <div class="list" v-loading="loading">
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
                <el-button type="primary" plain size="small" @click="onSign(t)">报名参加</el-button>
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
import { activityApi, noticeApi, publicApi } from '@/api'
import { useUserStore } from '@/store/user'
import { showLoginPrompt, showSignupSuccessPrompt } from '@/utils/loginPrompt'

const userStore = useUserStore()
const query = reactive({ pageNum: 1, pageSize: 5 })
const list = ref([])
const total = ref(0)
const loading = ref(false)

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
  const unreadRes = await noticeApi.unread()
  userStore.setUnreadCounts(Number(unreadRes.data || 0), userStore.unreadChatCount)
  load()
}

const load = async () => {
  loading.value = true
  try {
    const res = await publicApi.talks(query)
    list.value = res.data.records; total.value = Number(res.data.total)
  } finally { loading.value = false }
}
onMounted(load)
</script>

<style scoped lang="scss">
.head h2 { color: var(--cr-text); .el-icon { vertical-align: middle; color: var(--cr-primary); } }
.head .sub { color: var(--cr-text-muted); margin-top: .375rem; }
.talk-item { background: #fff; border: 0.0625rem solid var(--cr-border-soft); border-radius: var(--cr-radius); padding: clamp(.875rem, 1.2vw, 1.05rem); margin-bottom: .75rem; display: grid; grid-template-columns: minmax(4rem, 4.625rem) minmax(0, 1fr); gap: clamp(.75rem, 1.5vw, 1rem); box-shadow: var(--cr-shadow-soft);
  &:last-child { margin-bottom: 0; }
  .date { background: linear-gradient(135deg, var(--cr-primary), var(--cr-accent)); border-radius: var(--cr-radius-sm); color: #fff; text-align: center; padding: .75rem 0;
    .day { font-size: clamp(1.375rem, 3vw, 1.625rem); font-weight: 650; line-height: 1; }
    .month { font-size: .8125rem; margin-top: .25rem; }
  }
  .body { min-width: 0; }
  .title { color: var(--cr-text); margin-bottom: .45rem; line-height: 1.35; font-size: 1rem; }
  .meta { display: flex; flex-wrap: wrap; gap: .35rem .875rem; color: var(--cr-text-muted); font-size: .78125rem; margin-bottom: .45rem; .el-icon { vertical-align: middle; color: var(--cr-primary); } }
  .content { color: var(--cr-text-soft); font-size: .8125rem; line-height: 1.55; margin-bottom: .625rem; display: -webkit-box; -webkit-line-clamp: 1; -webkit-box-orient: vertical; overflow: hidden; }
  .footer { display: flex; justify-content: space-between; align-items: center; }
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
}
</style>
