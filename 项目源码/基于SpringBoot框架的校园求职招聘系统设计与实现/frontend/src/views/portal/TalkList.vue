<template>
  <div class="talk-list portal-content">
    <div class="page-card head">
      <h2><el-icon><ChatRound /></el-icon> 校园宣讲会</h2>
      <p class="sub">近期企业到校宣讲安排，提前了解、提前准备</p>
    </div>

    <div class="list mt-20" v-loading="loading">
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

    <div class="pagination-wrap">
      <el-pagination v-model:current-page="query.pageNum" v-model:page-size="query.pageSize" :total="total"
        layout="total, prev, pager, next" background @current-change="load" />
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { ChatRound, OfficeBuilding, Clock, Location } from '@element-plus/icons-vue'
import { publicApi } from '@/api'

const query = reactive({ pageNum: 1, pageSize: 10 })
const list = ref([])
const total = ref(0)
const loading = ref(false)

const formatDateTime = (d) => d ? d.replace('T', ' ').substring(0, 16) : ''
const getDay = (d) => d ? new Date(d.replace(' ', 'T')).getDate() : ''
const getMonth = (d) => d ? `${new Date(d.replace(' ', 'T')).getMonth() + 1}月` : ''
const onSign = () => ElMessage.success('已报名，请准时参加')

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
.head h2 { color: #303133; .el-icon { vertical-align: middle; } }
.head .sub { color: #909399; margin-top: 6px; }
.talk-item { background: #fff; border-radius: 8px; padding: 20px; margin-bottom: 16px; display: flex; gap: 20px;
  .date { width: 80px; flex-shrink: 0; background: linear-gradient(135deg, #409eff, #5470c6); border-radius: 6px; color: #fff; text-align: center; padding: 14px 0;
    .day { font-size: 30px; font-weight: 600; line-height: 1; }
    .month { font-size: 14px; margin-top: 6px; }
  }
  .body { flex: 1; }
  .title { color: #303133; margin-bottom: 10px; }
  .meta { display: flex; gap: 16px; color: #909399; font-size: 13px; margin-bottom: 10px; .el-icon { vertical-align: middle; } }
  .content { color: #606266; line-height: 1.7; margin-bottom: 14px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
  .footer { display: flex; justify-content: space-between; align-items: center; }
}
</style>
