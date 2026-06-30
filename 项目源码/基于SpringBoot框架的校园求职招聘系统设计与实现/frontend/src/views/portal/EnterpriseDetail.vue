<template>
  <div class="ent-detail portal-content" v-loading="loading">
    <div v-if="enterprise">
      <!-- 企业头部 -->
      <div class="page-card head">
        <div class="head-main">
          <el-avatar :src="enterprise.logo" shape="square" class="logo"><el-icon class="logo-icon"><OfficeBuilding /></el-icon></el-avatar>
          <div class="info">
            <h2 class="name">
              {{ enterprise.companyName }}
              <el-tag v-if="enterprise.auditStatus === 2" type="success" size="small">已认证</el-tag>
            </h2>
            <p class="meta">
              <el-icon><Star /></el-icon> {{ enterprise.industry || '未知行业' }}
              <span class="sep">|</span>
              <el-icon><User /></el-icon> {{ enterprise.scale || '规模未知' }}
              <span class="sep">|</span>
              <el-icon><Location /></el-icon> {{ enterprise.city || '城市未知' }}
            </p>
            <p class="welfare" v-if="enterprise.welfare">
              <el-tag v-for="w in enterprise.welfare.split(',')" :key="w" size="small" type="warning" effect="plain">{{ w }}</el-tag>
            </p>
          </div>
        </div>
        <div class="head-actions">
          <el-button class="action-btn" type="primary" @click="goEnterpriseJobs">
            <el-icon><Briefcase /></el-icon> 查看岗位
          </el-button>
          <el-button class="action-btn" :type="favorited ? 'warning' : 'default'" @click="toggleFavorite">
            <el-icon><Star /></el-icon> {{ favorited ? '已收藏' : '收藏企业' }}
          </el-button>
          <el-button class="action-btn" @click="consultHr">
            <el-icon><ChatLineRound /></el-icon> 咨询HR
          </el-button>
        </div>
      </div>

      <!-- 介绍 + 联系 -->
      <div class="detail-grid mt-20">
        <div>
          <div class="page-card">
            <h3 class="block-title">企业介绍</h3>
            <div class="rich-text">{{ enterprise.intro || '该企业暂未填写介绍' }}</div>
          </div>
          <!-- 在招职位 -->
          <div class="page-card mt-20">
            <h3 class="block-title">在招职位 <span class="cnt">({{ jobs.length }})</span></h3>
            <div class="job-list">
              <div class="job-item" v-for="j in jobs" :key="j.id" @click="$router.push(`/job/${j.id}`)">
                <div class="job-left">
                  <div class="job-title">{{ j.title }}</div>
                  <div class="job-meta">{{ j.city }} · {{ j.education || '不限学历' }} · {{ j.jobType === 1 ? '全职' : '实习' }}</div>
                </div>
                <div class="job-salary">{{ j.salaryMin }}-{{ j.salaryMax }}K</div>
              </div>
              <el-empty v-if="jobs.length === 0" description="暂无在招职位" />
            </div>
          </div>
        </div>
        <div>
          <div class="page-card contact">
            <h3 class="block-title">联系方式</h3>
            <p><b>联系人：</b>{{ enterprise.contactName || '-' }}</p>
            <p><b>电话：</b>{{ enterprise.contactPhone || '-' }}</p>
            <p><b>邮箱：</b>{{ enterprise.email || '-' }}</p>
            <p><b>官网：</b>{{ enterprise.website || '-' }}</p>
            <p><b>地址：</b>{{ enterprise.address || '-' }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { OfficeBuilding, Star, User, Location, Briefcase, ChatLineRound } from '@element-plus/icons-vue'
import { publicApi, studentApi } from '@/api'
import { useUserStore } from '@/store/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const enterprise = ref(null)
const jobs = ref([])
const favorited = ref(false)

const ensureStudent = (message) => {
  if (!userStore.isLogin) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return false
  }
  if (userStore.role !== 'STUDENT') {
    ElMessage.warning(message)
    return false
  }
  return true
}

const goEnterpriseJobs = () => {
  if (!enterprise.value?.id) return
  router.push({
    path: '/jobs',
    query: {
      enterpriseId: enterprise.value.id,
      companyName: enterprise.value.companyName || ''
    }
  })
}

const checkFavorite = async () => {
  if (!enterprise.value?.id || !userStore.isLogin || userStore.role !== 'STUDENT') {
    favorited.value = false
    return
  }
  const res = await studentApi.checkEnterpriseFavorite(enterprise.value.id)
  favorited.value = !!res.data?.favorite
}

const toggleFavorite = async () => {
  if (!ensureStudent('请使用学生账号收藏企业')) return
  if (favorited.value) {
    await studentApi.delEnterpriseFavorite(enterprise.value.id)
    favorited.value = false
    ElMessage.success('已取消收藏')
  } else {
    await studentApi.addEnterpriseFavorite(enterprise.value.id)
    favorited.value = true
    ElMessage.success('已收藏')
  }
}

const consultHr = () => {
  if (!ensureStudent('请使用学生账号咨询HR')) return
  router.push({ path: '/student/chat', query: { peerRole: 'ENTERPRISE', peerId: enterprise.value.id, peerName: enterprise.value.companyName || `企业${enterprise.value.id}` } })
}

onMounted(async () => {
  loading.value = true
  try {
    const res = await publicApi.enterpriseDetail(route.params.id)
    const data = res.data
    enterprise.value = data.enterprise || data
    jobs.value = data.jobs || []
    await checkFavorite()
  } finally { loading.value = false }
})
</script>

<style scoped lang="scss">
.head { display: flex; gap: clamp(1rem, 2vw, 1.25rem); align-items: center; justify-content: space-between; }
.head-main { min-width: 0; display: flex; gap: clamp(1rem, 2vw, 1.25rem); align-items: center; }
.logo { --el-avatar-size: clamp(4rem, 9vw, 6.25rem); flex-shrink: 0; }
.logo-icon { font-size: clamp(2rem, 4vw, 2.5rem); }
.info { flex: 1; min-width: 0; }
.name { color: var(--cr-text); display: flex; align-items: center; gap: .625rem; flex-wrap: wrap; }
.meta { color: var(--cr-text-soft); margin-top: .625rem; .el-icon { vertical-align: middle; margin-right: .125rem; color: var(--cr-primary); } .sep { margin: 0 .625rem; color: var(--cr-border); } }
.welfare { margin-top: .75rem; display: flex; gap: .375rem; flex-wrap: wrap; }
.head-actions { flex: 0 0 8.75rem; display: flex; flex-direction: column; gap: .625rem; align-items: stretch; }
.action-btn { width: 8.75rem; height: 3.25rem; margin-left: 0; justify-content: center; }
.detail-grid { display: grid; grid-template-columns: minmax(0, 1fr) minmax(17.5rem, 0.34fr); gap: clamp(1rem, 2vw, 1.25rem); align-items: start; }
.block-title { font-size: 1rem; color: var(--cr-text); border-left: .1875rem solid var(--cr-primary); padding-left: .625rem; margin-bottom: .875rem; .cnt { color: var(--cr-text-muted); font-size: .875rem; margin-left: .375rem; } }
.rich-text { color: var(--cr-text-soft); line-height: 1.8; white-space: pre-line; }
.job-list { .job-item { display: flex; justify-content: space-between; align-items: center; gap: 1rem; padding: .875rem; border-radius: .375rem; cursor: pointer; transition: background .2s;
    &:hover { background: var(--cr-surface-soft); }
    .job-left { min-width: 0; }
    .job-title { color: var(--cr-text); font-weight: 650; margin-bottom: .25rem; }
    .job-meta { color: var(--cr-text-muted); font-size: .75rem; }
    .job-salary { color: var(--cr-danger); font-weight: 750; font-size: 1rem; white-space: nowrap; }
  }
}
.contact p { line-height: 2; font-size: .875rem; color: var(--cr-text-soft); b { color: var(--cr-text-muted); } }
@media (max-width: 56.25rem) {
  .head { align-items: stretch; flex-direction: column; }
  .head-main { align-items: flex-start; }
  .head-actions { flex: none; width: 100%; }
  .action-btn { width: 100%; }
  .detail-grid { grid-template-columns: 1fr; }
}
@media (max-width: 35rem) {
  .job-list .job-item { align-items: flex-start; flex-direction: column; gap: .5rem; }
}
</style>
