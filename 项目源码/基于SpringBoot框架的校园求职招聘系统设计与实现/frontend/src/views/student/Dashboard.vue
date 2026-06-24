<template>
  <div class="page-container">
    <el-row :gutter="16">
      <el-col :span="6" v-for="card in cards" :key="card.title">
        <div class="stat-card" :style="{ background: card.bg }">
          <div>
            <div class="num">{{ card.value }}</div>
            <div class="title">{{ card.title }}</div>
          </div>
          <el-icon size="42"><component :is="card.icon" /></el-icon>
        </div>
      </el-col>
    </el-row>

    <el-row :gutter="16" class="mt-20">
      <el-col :span="16">
        <div class="page-card">
          <div class="section-title">求职进度</div>
          <el-steps :active="stepActive" finish-status="success" align-center>
            <el-step title="完善资料" description="个人信息与求职意向" />
            <el-step title="维护简历" description="在线简历/附件简历" />
            <el-step title="投递岗位" description="筛选职位并投递" />
            <el-step title="面试沟通" description="确认面试通知" />
            <el-step title="确认Offer" description="完成就业闭环" />
          </el-steps>
          <div class="quick-actions">
            <el-button type="primary" @click="$router.push('/student/profile')">完善个人信息</el-button>
            <el-button type="success" @click="$router.push('/student/resume')">编辑在线简历</el-button>
            <el-button type="warning" @click="$router.push('/jobs')">搜索职位</el-button>
          </div>
        </div>

        <div class="page-card mt-20">
          <div class="section-title">最近投递</div>
          <el-table :data="applies" stripe>
            <el-table-column prop="jobTitle" label="岗位" min-width="160" />
            <el-table-column prop="companyName" label="企业" min-width="150" />
            <el-table-column label="状态" width="110">
              <template #default="{ row }"><el-tag :type="applyType(row.status)">{{ applyText(row.status) }}</el-tag></template>
            </el-table-column>
            <el-table-column prop="createTime" label="投递时间" width="170" />
          </el-table>
        </div>
      </el-col>
      <el-col :span="8">
        <div class="profile-card page-card">
          <el-avatar :size="76" :src="profile.avatar"><el-icon><User /></el-icon></el-avatar>
          <h3>{{ profile.realName || profile.username }}</h3>
          <p>{{ profile.college || '未填写学院' }} · {{ profile.major || '未填写专业' }}</p>
          <el-divider />
          <div class="resume-rate">
            <span>简历完整度</span>
            <el-progress :percentage="resume?.completeRate || 0" :stroke-width="10" />
          </div>
        </div>
        <div class="page-card mt-20">
          <div class="section-title">待办提醒</div>
          <el-timeline>
            <el-timeline-item v-if="!profile.phone" type="warning">请完善手机号，便于企业联系</el-timeline-item>
            <el-timeline-item v-if="!resume" type="danger">还未创建在线简历</el-timeline-item>
            <el-timeline-item v-if="cards[1].value === 0" type="primary">开始搜索并投递心仪岗位</el-timeline-item>
            <el-timeline-item type="success">关注消息中心，及时处理面试和Offer</el-timeline-item>
          </el-timeline>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { User, Document, Tickets, ChatLineRound, Medal } from '@element-plus/icons-vue'
import { studentApi } from '@/api'

const profile = reactive({})
const resume = ref(null)
const applies = ref([])
const interviewCount = ref(0)
const offerCount = ref(0)
const applyCount = ref(0)

const statusText = ['待查看', '已查看', '邀请面试', '笔试', '已录用', '不合适']
const applyText = (s) => statusText[s] || '未知'
const applyType = (s) => s === 4 ? 'success' : s === 5 ? 'danger' : s === 2 ? 'warning' : 'info'
const stepActive = computed(() => resume.value ? (offerCount.value > 0 ? 5 : interviewCount.value > 0 ? 4 : applyCount.value > 0 ? 3 : 2) : 1)
const cards = computed(() => [
  { title: '简历完整度', value: (resume.value?.completeRate || 0) + '%', icon: Document, bg: 'linear-gradient(135deg,#409eff,#66b1ff)' },
  { title: '投递记录', value: applyCount.value, icon: Tickets, bg: 'linear-gradient(135deg,#67c23a,#95d475)' },
  { title: '面试通知', value: interviewCount.value, icon: ChatLineRound, bg: 'linear-gradient(135deg,#e6a23c,#f3d19e)' },
  { title: 'Offer', value: offerCount.value, icon: Medal, bg: 'linear-gradient(135deg,#f56c6c,#fab6b6)' }
])

onMounted(async () => {
  const p = await studentApi.profile(); Object.assign(profile, p.data || {})
  const r = await studentApi.getResume().catch(() => ({ data: null })); resume.value = r.data
  const a = await studentApi.applyList({ pageNum: 1, pageSize: 5 }).catch(() => ({ data: { total: 0, records: [] } }))
  applyCount.value = Number(a.data.total || 0); applies.value = a.data.records || []
  const i = await studentApi.interviews({ pageNum: 1, pageSize: 1 }).catch(() => ({ data: { total: 0 } })); interviewCount.value = Number(i.data.total || 0)
  const o = await studentApi.offers({ pageNum: 1, pageSize: 1 }).catch(() => ({ data: { total: 0 } })); offerCount.value = Number(o.data.total || 0)
})
</script>

<style scoped lang="scss">
.stat-card { height: 110px; border-radius: 10px; color: #fff; padding: 22px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 6px 16px rgba(0,0,0,.08); .num { font-size: 28px; font-weight: 700; } .title { margin-top: 8px; opacity: .95; } }
.section-title { font-size: 16px; font-weight: 600; color: #303133; margin-bottom: 18px; border-left: 3px solid #409eff; padding-left: 10px; }
.quick-actions { text-align: center; margin-top: 28px; }
.profile-card { text-align: center; h3 { margin: 12px 0 4px; } p { color: #909399; } }
.resume-rate { text-align: left; span { display: block; color: #606266; margin-bottom: 10px; } }
</style>
