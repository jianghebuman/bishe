<template>
  <div class="page-container notice-page">
    <div class="page-card page-flex-card portal-list-card notice-list-card">
      <div class="header">
        <div>
          <h2>{{ title }}</h2>
          <p>{{ subtitle }}</p>
        </div>
        <el-button type="primary" plain :disabled="unread === 0" @click="readAll">全部标记已读（{{ unread }}）</el-button>
      </div>
      <el-divider />
      <el-tabs v-model="query.isRead" @tab-change="reload">
        <el-tab-pane label="全部消息" :name="''" />
        <el-tab-pane label="未读" :name="0" />
        <el-tab-pane label="已读" :name="1" />
      </el-tabs>
      <div class="page-flex-scroll notice-scroll" v-loading="loading">
        <div class="notice-item" v-for="n in list" :key="n.id" :class="{ unread: n.isRead === 0 }" @click="openDetail(n)">
          <div class="icon" :class="n.noticeType?.toLowerCase() || 'system'">{{ typeText(n.noticeType).substring(0, 1) }}</div>
          <div class="body">
            <div class="top">
              <span class="title">{{ n.title }}</span>
              <el-tag size="small" :type="tagType(n.noticeType)">{{ typeText(n.noticeType) }}</el-tag>
            </div>
            <p class="content">{{ n.content }}</p>
            <div class="meta">
              <span>{{ n.createTime }}</span>
              <div class="ops">
                <el-button text type="primary" @click.stop="openDetail(n)">查看详情</el-button>
                <el-button v-if="n.isRead === 0" text type="primary" @click.stop="read(n.id)">标记已读</el-button>
              </div>
            </div>
          </div>
        </div>
        <el-empty v-if="!loading && list.length === 0" description="暂无消息" />
      </div>
      <div class="pagination-wrap">
        <el-pagination v-model:current-page="query.pageNum" v-model:page-size="query.pageSize" :total="total"
          layout="total, prev, pager, next" background @current-change="load" />
      </div>
    </div>

    <el-dialog v-model="detailVisible" width="min(42rem, 92vw)" class="notice-detail-dialog">
      <template #header>
        <div class="detail-header">
          <span>{{ currentNotice?.title }}</span>
          <el-tag v-if="currentNotice" size="small" :type="tagType(currentNotice.noticeType)">{{ typeText(currentNotice.noticeType) }}</el-tag>
        </div>
      </template>
      <div v-if="currentNotice" class="detail-body">
        <div class="detail-meta">
          <span>{{ currentNotice.createTime }}</span>
          <span>{{ currentNotice.isRead === 0 ? '未读' : '已读' }}</span>
        </div>
        <div class="detail-content">{{ currentNotice.content }}</div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { noticeApi } from '@/api'
import { useUserStore } from '@/store/user'

defineProps({
  title: { type: String, default: '消息中心' },
  subtitle: { type: String, default: '系统通知、投递反馈、面试提醒和审核消息集中展示' }
})
const userStore = useUserStore()
const query = reactive({ pageNum: 1, pageSize: 6, isRead: '' })
const list = ref([])
const total = ref(0)
const unread = ref(0)
const loading = ref(false)
const detailVisible = ref(false)
const currentNotice = ref(null)
const typeText = (t) => ({ SYSTEM: '系统', APPLY: '投递', INTERVIEW: '面试', OFFER: 'Offer', AUDIT: '审核', ACTIVITY: '活动', CHAT: '沟通' }[t] || '系统')
const tagType = (t) => ({ APPLY: 'success', INTERVIEW: 'warning', OFFER: 'danger', AUDIT: 'primary', ACTIVITY: 'success', CHAT: 'warning' }[t] || 'info')
const loadUnread = async () => {
  unread.value = Number((await noticeApi.unread()).data || 0)
  userStore.setUnreadCounts(unread.value, userStore.unreadChatCount)
}
const load = async () => {
  loading.value = true
  try {
    const params = { pageNum: query.pageNum, pageSize: query.pageSize }
    if (query.isRead !== '') params.isRead = query.isRead
    const res = await noticeApi.list(params)
    list.value = res.data.records; total.value = Number(res.data.total)
    await loadUnread()
  } finally { loading.value = false }
}
const reload = () => { query.pageNum = 1; load() }
const read = async (id) => { await noticeApi.read(id); ElMessage.success('已标记为已读'); load() }
const readAll = async () => { await noticeApi.readAll(); ElMessage.success('已全部标记为已读'); load() }
const openDetail = async (notice) => {
  currentNotice.value = notice
  detailVisible.value = true
  if (notice.isRead === 0) {
    await noticeApi.read(notice.id)
    notice.isRead = 1
    currentNotice.value = { ...notice }
    await loadUnread()
  }
}
onMounted(load)
</script>

<style scoped lang="scss">
.notice-list-card { --portal-list-card-min-height: calc(100dvh - 11rem); }
.header { display:flex; justify-content:space-between; align-items:center; h2{margin-bottom:6px;} p{color:var(--cr-text-muted);} }
.notice-scroll { display:flex; flex-direction:column; }
.notice-item { flex:1; min-height:6.25rem; display:flex; align-items:center; gap:14px; padding:14px 0; border-bottom:1px dashed var(--cr-border-soft); cursor:pointer; transition:background .2s; &:hover{background:var(--cr-surface-soft)} &.unread .title::after{content:'未读';font-size:12px;background:var(--cr-danger);color:#fff;border-radius:8px;padding:1px 6px;margin-left:8px;} }
.icon { width:42px;height:42px;border-radius:50%;background:var(--cr-text-muted);color:#fff;display:flex;align-items:center;justify-content:center;font-weight:600;flex-shrink:0;&.apply,&.activity{background:var(--cr-success)}&.interview,&.chat{background:var(--cr-warning)}&.offer{background:var(--cr-danger)}&.audit{background:var(--cr-primary)} }
.body{flex:1;min-width:0}.top{display:flex;gap:8px;align-items:center}.title{font-weight:600;color:var(--cr-text)}.content{color:var(--cr-text-soft);line-height:1.6;margin:6px 0;display:-webkit-box;-webkit-line-clamp:1;-webkit-box-orient:vertical;overflow:hidden;}.meta{display:flex;justify-content:space-between;align-items:center;gap:12px;color:var(--cr-text-muted);font-size:12px;}.ops{display:flex;gap:4px;flex-shrink:0}
.detail-header{display:flex;align-items:center;gap:10px;padding-right:24px;font-weight:600;color:var(--cr-text);line-height:1.5}.detail-meta{display:flex;justify-content:space-between;gap:12px;color:var(--cr-text-muted);font-size:13px;margin-bottom:16px}.detail-content{color:var(--cr-text);font-size:15px;line-height:1.9;white-space:pre-line;background:var(--cr-surface-soft);border-radius:var(--cr-radius-sm);padding:18px;}
@media (max-width:40rem){.notice-item{flex:0 1 auto;align-items:flex-start}.header{align-items:stretch;flex-direction:column;gap:12px}.header :deep(.el-button){width:100%;}.meta{align-items:flex-start;flex-direction:column}.ops{flex-wrap:wrap}}
</style>

