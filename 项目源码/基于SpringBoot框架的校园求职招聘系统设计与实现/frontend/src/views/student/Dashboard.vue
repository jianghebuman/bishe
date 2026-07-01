<template>
  <div class="page-container student-dashboard-page">
    <section class="career-command cr-magic-surface">
      <div class="command-copy">
        <span class="command-kicker">求职指挥台</span>
        <h2>{{ commandTitle }}</h2>
        <p>{{ nextTask.desc }}</p>
      </div>
      <div class="command-chips">
        <span v-for="chip in commandChips" :key="chip.label">
          <small>{{ chip.label }}</small>
          <b>{{ chip.value }}</b>
        </span>
      </div>
      <button class="command-action" type="button" @click="$router.push(nextTask.to)">
        <el-icon><component :is="nextTask.icon" /></el-icon>
        <span>{{ nextTask.button }}</span>
        <el-icon><Right /></el-icon>
      </button>
    </section>

    <el-row :gutter="16" class="dashboard-stats">
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

    <el-row :gutter="16" class="dashboard-workspace">
      <el-col class="dashboard-main-col" :span="16">
        <div class="page-card progress-card">
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

        <div class="page-card recent-card">
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
      <el-col class="dashboard-side-col" :span="8">
        <div class="profile-card page-card">
          <el-avatar :size="76" :src="profile.avatar"><el-icon><User /></el-icon></el-avatar>
          <h3>{{ profile.realName || profile.username }}</h3>
          <p>{{ profile.school || '未填写学校' }} · {{ profile.college || '未填写学院' }} · {{ profile.major || '未填写专业' }}</p>
          <el-divider />
          <div class="resume-rate">
            <span>简历完整度</span>
            <el-progress :percentage="resume?.completeRate || 0" :stroke-width="10" />
          </div>
        </div>
        <div class="page-card reminder-card">
          <div class="section-title">待办提醒</div>
          <el-timeline>
            <el-timeline-item
              v-for="notice in reminders"
              :key="notice.id"
              :type="noticeType(notice.noticeType)"
              :timestamp="notice.createTime"
              placement="top"
            >
              <div class="notice-reminder" @click="$router.push('/student/notice')">
                <strong>{{ notice.title }}</strong>
                <p>{{ notice.content }}</p>
              </div>
            </el-timeline-item>
          </el-timeline>
          <el-empty v-if="reminders.length === 0" description="暂无未读通知" :image-size="72" />
          <div class="notice-actions">
            <el-button text type="primary" @click="$router.push('/student/notice')">查看消息中心</el-button>
          </div>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ChatLineRound, Compass, Document, Medal, Right, Tickets, User } from '@element-plus/icons-vue'
import { noticeApi, studentApi } from '@/api'

const profile = reactive({})
const resume = ref(null)
const applies = ref([])
const reminders = ref([])
const interviewCount = ref(0)
const offerCount = ref(0)
const applyCount = ref(0)

const statusText = ['待查看', '已查看', '邀请面试', '笔试', '已录用', '不合适']
const applyText = (s) => statusText[s] || '未知'
const applyType = (s) => s === 4 ? 'success' : s === 5 ? 'danger' : s === 2 ? 'warning' : 'info'
const noticeType = (t) => ({ APPLY: 'success', INTERVIEW: 'warning', OFFER: 'danger', AUDIT: 'primary', CHAT: 'warning' }[t] || 'info')
const stepActive = computed(() => resume.value ? (offerCount.value > 0 ? 5 : interviewCount.value > 0 ? 4 : applyCount.value > 0 ? 3 : 2) : 1)
const nextTask = computed(() => {
  if (!profile.realName || !profile.school) {
    return { button: '完善资料', desc: '先把姓名、学校、专业和联系方式补齐，让企业快速判断匹配度。', to: '/student/profile', icon: User }
  }
  if (!resume.value) {
    return { button: '建立简历', desc: '把教育经历、项目经验和附件简历放进同一个简历档案。', to: '/student/resume', icon: Document }
  }
  if (!applyCount.value) {
    return { button: '寻找岗位', desc: '用岗位雷达筛选城市、薪资和学历要求，开始第一轮投递。', to: '/jobs', icon: Compass }
  }
  if (!interviewCount.value) {
    return { button: '查看投递', desc: '持续关注投递状态，及时处理企业查看、邀约和沟通消息。', to: '/student/apply', icon: Tickets }
  }
  return { button: '查看面试', desc: '面试安排已经产生，优先确认时间、地点和沟通记录。', to: '/student/interview', icon: ChatLineRound }
})
const commandTitle = computed(() => `${profile.realName || profile.username || '同学'}，下一步是${nextTask.value.button}`)
const commandChips = computed(() => [
  { label: '完整度', value: `${resume.value?.completeRate || 0}%` },
  { label: '投递', value: applyCount.value },
  { label: '面试', value: interviewCount.value }
])
const cards = computed(() => [
  { title: '简历完整度', value: (resume.value?.completeRate || 0) + '%', icon: Document, bg: 'linear-gradient(135deg,#2563eb,#0891b2)' },
  { title: '投递记录', value: applyCount.value, icon: Tickets, bg: 'linear-gradient(135deg,#0f766e,#2563eb)' },
  { title: '面试通知', value: interviewCount.value, icon: ChatLineRound, bg: 'linear-gradient(135deg,#7c3aed,#2563eb)' },
  { title: 'Offer', value: offerCount.value, icon: Medal, bg: 'linear-gradient(135deg,#e45757,#2563eb)' }
])

onMounted(async () => {
  const p = await studentApi.profile(); Object.assign(profile, p.data || {})
  const r = await studentApi.getResume().catch(() => ({ data: null })); resume.value = r.data
  const a = await studentApi.applyList({ pageNum: 1, pageSize: 5 }).catch(() => ({ data: { total: 0, records: [] } }))
  applyCount.value = Number(a.data.total || 0); applies.value = a.data.records || []
  const i = await studentApi.interviews({ pageNum: 1, pageSize: 1 }).catch(() => ({ data: { total: 0 } })); interviewCount.value = Number(i.data.total || 0)
  const o = await studentApi.offers({ pageNum: 1, pageSize: 1 }).catch(() => ({ data: { total: 0 } })); offerCount.value = Number(o.data.total || 0)
  const n = await noticeApi.list({ pageNum: 1, pageSize: 4, isRead: 0 }).catch(() => ({ data: { records: [] } }))
  reminders.value = n.data.records || []
})
</script>

<style scoped lang="scss">
.student-dashboard-page {
  width: min(150rem, calc(100% - clamp(1rem, 3vw, 3rem)));
  min-height: calc(100dvh - 70px - clamp(1.5rem, 3vw, 2.5rem));
  padding: clamp(.75rem, 1.2vw, 1.25rem);
  display: grid;
  grid-template-rows: auto auto minmax(0, 1fr);
  gap: clamp(.9rem, 1.2vw, 1.25rem);
}

.career-command {
  --cr-magic-x: 86%;
  --cr-magic-y: -22%;
  min-height: 8.25rem;
  padding: clamp(1rem, 1.8vw, 1.375rem);
  display: grid;
  grid-template-columns: minmax(18rem, 1fr) auto minmax(12rem, auto);
  gap: clamp(1rem, 2vw, 1.5rem);
  align-items: center;
}

.command-copy {
  min-width: 0;
}

.command-kicker {
  display: inline-flex;
  align-items: center;
  min-height: 1.625rem;
  padding: 0 .625rem;
  border-radius: 999rem;
  background: rgba(36, 84, 214, .09);
  color: var(--cr-primary);
  font-size: .75rem;
  font-weight: 900;
  line-height: 1;
}

.command-copy h2 {
  margin-top: .75rem;
  color: var(--cr-text);
  font-size: clamp(1.35rem, 2vw, 2rem);
  line-height: 1.18;
  font-weight: 900;
}

.command-copy p {
  margin-top: .5rem;
  max-width: 48rem;
  color: var(--cr-text-soft);
  font-size: .9375rem;
  line-height: 1.7;
}

.command-chips {
  display: grid;
  grid-template-columns: repeat(3, minmax(4.75rem, 1fr));
  gap: .5rem;
}

.command-chips span {
  min-width: 0;
  padding: .75rem .875rem;
  border: .0625rem solid rgba(203, 216, 231, .72);
  border-radius: var(--cr-radius-sm);
  background: rgba(255, 255, 255, .66);
  box-shadow: inset 0 .0625rem 0 rgba(255, 255, 255, .84);
}

.command-chips small,
.command-chips b {
  display: block;
  line-height: 1.1;
}

.command-chips small {
  color: var(--cr-text-muted);
  font-size: .75rem;
  font-weight: 800;
}

.command-chips b {
  margin-top: .375rem;
  color: var(--cr-text);
  font-size: clamp(1.125rem, 1.5vw, 1.5rem);
  font-weight: 950;
}

.command-action {
  min-width: 12rem;
  min-height: 3.25rem;
  padding: 0 .875rem 0 1rem;
  display: inline-flex;
  align-items: center;
  justify-content: space-between;
  gap: .625rem;
  border: 0;
  border-radius: .875rem;
  background:
    linear-gradient(180deg, rgba(255,255,255,.18), transparent 42%),
    linear-gradient(135deg, var(--cr-primary), var(--cr-accent));
  color: #fff;
  cursor: pointer;
  font-weight: 900;
  box-shadow: 0 .75rem 1.5rem rgba(36, 84, 214, .24);
  transition: transform .16s ease, box-shadow .18s ease, filter .18s ease;
}

.command-action:hover {
  filter: saturate(1.05) brightness(1.02);
  box-shadow: 0 .875rem 1.75rem rgba(36, 84, 214, .28);
  transform: translateY(-.0625rem);
}

.command-action:active {
  transform: translateY(.0625rem);
}

.command-action .el-icon:first-child {
  width: 2rem;
  height: 2rem;
  border-radius: .625rem;
  background: rgba(255, 255, 255, .18);
}

.dashboard-stats,
.dashboard-workspace {
  min-width: 0;
}
.dashboard-workspace {
  min-height: 0;
}
.dashboard-main-col,
.dashboard-side-col {
  min-height: 0;
  display: flex;
  flex-direction: column;
}
.progress-card {
  min-height: clamp(15rem, 20vh, 18rem);
}
.recent-card {
  flex: 1;
  min-height: 0;
  margin-top: clamp(.9rem, 1.2vw, 1.25rem);
  display: flex;
  flex-direction: column;
}
.recent-card :deep(.el-table) {
  flex: 1;
  min-height: 18rem;
  font-size: .9375rem;
}
.recent-card :deep(.el-table__inner-wrapper) {
  height: 100%;
}
.recent-card :deep(.el-table .cell) {
  line-height: 1.6;
}
.recent-card :deep(.el-table__row) {
  height: 3.375rem;
}
.stat-card {
  position: relative;
  overflow: hidden;
  height: 110px;
  border-radius: var(--cr-radius);
  color: #fff;
  padding: 22px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: var(--cr-shadow-soft), var(--cr-shadow-line);
  background-blend-mode: soft-light, normal;
  .num { position: relative; z-index: 1; font-size: 30px; font-weight: 850; line-height: 1; }
  .title { position: relative; z-index: 1; margin-top: 8px; opacity: .94; font-weight: 700; }
  .el-icon { position: relative; z-index: 1; width: 3.25rem; height: 3.25rem; display: inline-flex; align-items: center; justify-content: center; border: 1px solid rgba(255,255,255,.24); border-radius: var(--cr-radius-sm); background: rgba(255,255,255,.14); }
}
.stat-card::before {
  position: absolute;
  inset: -16% -10% auto auto;
  width: 76%;
  height: 82%;
  content: "";
  pointer-events: none;
  border-radius: 999rem;
  background: linear-gradient(180deg, rgba(255,255,255,.22), transparent 72%);
  filter: blur(1.35rem);
  opacity: .42;
  transform: rotate(-18deg);
  animation: stat-ray-breathe 15s ease-in-out infinite;
}
.stat-card::after {
  position: absolute;
  inset: auto -2.5rem -3rem auto;
  width: 8rem;
  height: 8rem;
  content: "";
  background: rgba(255,255,255,.10);
  transform: rotate(24deg);
}
.section-title {
  position: relative;
  margin-bottom: 18px;
  padding-left: 12px;
  color: var(--cr-text);
  font-size: 16px;
  font-weight: 820;
  line-height: 1.2;
}

@keyframes stat-ray-breathe {
  0%,
  100% { opacity: .22; }
  50% { opacity: .48; }
}
.section-title::before {
  position: absolute;
  top: 0.1rem;
  bottom: 0.1rem;
  left: 0;
  width: 0.25rem;
  content: "";
  border-radius: 999rem;
  background: linear-gradient(180deg, var(--cr-primary), var(--cr-accent));
}
.quick-actions { text-align: center; margin-top: 28px; }
.profile-card { text-align: center; h3 { margin: 12px 0 4px; color: var(--cr-text); } p { color: var(--cr-text-muted); } }
.resume-rate { text-align: left; span { display: block; color: var(--cr-text-soft); margin-bottom: 10px; } }
.notice-reminder { cursor: pointer; strong { color: var(--cr-text); } p { margin: 6px 0 0; color: var(--cr-text-soft); line-height: 1.6; } }
.notice-actions { margin-top: 8px; text-align: right; }
.reminder-card {
  flex: 1;
  min-height: 0;
  margin-top: clamp(.9rem, 1.2vw, 1.25rem);
  display: flex;
  flex-direction: column;
}
.reminder-card :deep(.el-timeline) {
  flex: 1;
  min-height: 0;
  overflow: auto;
  padding-right: .25rem;
}
.reminder-card :deep(.el-empty) {
  flex: 1;
}

@media (max-width: 900px) {
  .student-dashboard-page {
    min-height: 0;
    display: block;
  }
  .career-command {
    grid-template-columns: 1fr;
  }
  .command-chips {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
  .command-action {
    width: 100%;
  }
  :deep(.el-col) {
    max-width: 100%;
    flex: 0 0 100%;
  }
  .dashboard-workspace {
    margin-top: 1rem;
  }
  .profile-card {
    margin-top: 1rem;
  }
  .recent-card,
  .reminder-card {
    min-height: 22rem;
  }
}

@media (max-width: 520px) {
  .command-chips {
    grid-template-columns: 1fr;
  }
}
</style>
