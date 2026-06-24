<template>
  <div class="page-container">
    <div class="page-card">
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
      <div v-loading="loading">
        <div class="notice-item" v-for="n in list" :key="n.id" :class="{ unread: n.isRead === 0 }">
          <div class="icon" :class="n.noticeType?.toLowerCase() || 'system'">{{ typeText(n.noticeType).substring(0, 1) }}</div>
          <div class="body">
            <div class="top">
              <span class="title">{{ n.title }}</span>
              <el-tag size="small" :type="tagType(n.noticeType)">{{ typeText(n.noticeType) }}</el-tag>
            </div>
            <p class="content">{{ n.content }}</p>
            <div class="meta">
              <span>{{ n.createTime }}</span>
              <el-button v-if="n.isRead === 0" text type="primary" @click="read(n.id)">标记已读</el-button>
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
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { noticeApi } from '@/api'

defineProps({
  title: { type: String, default: '消息中心' },
  subtitle: { type: String, default: '系统通知、投递反馈、面试提醒和审核消息集中展示' }
})
const query = reactive({ pageNum: 1, pageSize: 10, isRead: '' })
const list = ref([])
const total = ref(0)
const unread = ref(0)
const loading = ref(false)
const typeText = (t) => ({ SYSTEM: '系统', APPLY: '投递', INTERVIEW: '面试', OFFER: 'Offer', AUDIT: '审核' }[t] || '系统')
const tagType = (t) => ({ APPLY: 'success', INTERVIEW: 'warning', OFFER: 'danger', AUDIT: 'primary' }[t] || 'info')
const loadUnread = async () => { unread.value = Number((await noticeApi.unread()).data || 0) }
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
onMounted(load)
</script>

<style scoped lang="scss">
.header { display:flex; justify-content:space-between; align-items:center; h2{margin-bottom:6px;} p{color:#909399;} }
.notice-item { display:flex; gap:14px; padding:18px 0; border-bottom:1px dashed #ebeef5; &.unread .title::after{content:'未读';font-size:12px;background:#f56c6c;color:#fff;border-radius:8px;padding:1px 6px;margin-left:8px;} }
.icon { width:42px;height:42px;border-radius:50%;background:#909399;color:#fff;display:flex;align-items:center;justify-content:center;font-weight:600;flex-shrink:0;&.apply{background:#67c23a}&.interview{background:#e6a23c}&.offer{background:#f56c6c}&.audit{background:#409eff} }
.body{flex:1}.top{display:flex;gap:8px;align-items:center}.title{font-weight:600;color:#303133}.content{color:#606266;line-height:1.7;margin:8px 0}.meta{display:flex;justify-content:space-between;color:#c0c4cc;font-size:12px;}
</style>
