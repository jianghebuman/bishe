<template>
  <div class="page-container favorite-page">
    <div class="page-card header">
      <div>
        <h2>我的收藏</h2>
        <p>岗位和企业分开保存，后续比较、投递和查看更方便。</p>
      </div>
      <div class="header-actions">
        <el-button type="primary" @click="router.push('/jobs')">发现更多岗位</el-button>
        <el-button plain @click="router.push('/enterprises')">发现更多企业</el-button>
      </div>
    </div>

    <div class="page-card favorite-section">
      <div class="section-head">
        <div>
          <h3><el-icon><Briefcase /></el-icon> 岗位收藏</h3>
          <p>已收藏的岗位，点击查看可进入岗位详情。</p>
        </div>
      </div>

      <div class="section-body" v-loading="jobLoading">
        <div class="favorite-list job-list" v-if="jobList.length">
          <div class="fav-card job-card" v-for="f in jobList" :key="f.id">
            <div class="card-main">
              <div class="job-title">{{ f.job?.title || '岗位已下架' }}</div>
              <div class="salary">{{ formatSalary(f.job) }}</div>
              <div class="meta">
                {{ f.job?.city || '城市不限' }} · {{ f.job?.education || '学历不限' }} · {{ f.job?.jobType === 1 ? '全职' : '实习' }}
              </div>
              <div class="tags" v-if="f.job?.welfare">
                <el-tag v-for="w in splitTags(f.job.welfare)" :key="w" size="small" type="info" effect="plain">{{ w }}</el-tag>
              </div>
            </div>
            <div class="card-footer">
              <span>收藏于 {{ formatDate(f.createTime) }}</span>
              <div class="actions">
                <el-button text type="primary" @click="router.push(`/job/${f.jobId}`)">查看</el-button>
                <el-button text type="danger" @click="cancelJob(f)">取消收藏</el-button>
              </div>
            </div>
          </div>
        </div>
        <el-empty v-else-if="!jobLoading" description="暂无收藏岗位" />
      </div>

      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="jobQuery.pageNum"
          :total="jobTotal"
          :page-size="jobQuery.pageSize"
          background
          layout="total,prev,pager,next"
          @current-change="loadJobFavorites"
        />
      </div>
    </div>

    <div class="page-card favorite-section">
      <div class="section-head">
        <div>
          <h3><el-icon><OfficeBuilding /></el-icon> 企业收藏</h3>
          <p>已收藏的企业，点击查看可进入企业主页。</p>
        </div>
      </div>

      <div class="section-body" v-loading="enterpriseLoading">
        <div class="favorite-list enterprise-list" v-if="enterpriseList.length">
          <div class="fav-card enterprise-card" v-for="f in enterpriseList" :key="f.id">
            <el-avatar :src="f.enterprise?.logo" shape="square" class="logo">
              <el-icon><OfficeBuilding /></el-icon>
            </el-avatar>
            <div class="card-main">
              <div class="company">{{ f.enterprise?.companyName || '企业信息待完善' }}</div>
              <div class="meta">
                {{ f.enterprise?.industry || '行业不限' }} · {{ f.enterprise?.scale || '规模不限' }}
              </div>
              <div class="meta">{{ f.enterprise?.city || '所在地不限' }}</div>
              <div class="tags" v-if="f.enterprise?.welfare">
                <el-tag v-for="w in splitTags(f.enterprise.welfare)" :key="w" size="small" type="success" effect="plain">{{ w }}</el-tag>
              </div>
            </div>
            <div class="card-footer">
              <span>收藏于 {{ formatDate(f.createTime) }}</span>
              <div class="actions">
                <el-button text type="primary" @click="router.push(`/enterprise/${f.enterpriseId}`)">查看</el-button>
                <el-button text type="danger" @click="cancelEnterprise(f)">取消收藏</el-button>
              </div>
            </div>
          </div>
        </div>
        <el-empty v-else-if="!enterpriseLoading" description="暂无收藏企业" />
      </div>

      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="enterpriseQuery.pageNum"
          :total="enterpriseTotal"
          :page-size="enterpriseQuery.pageSize"
          background
          layout="total,prev,pager,next"
          @current-change="loadEnterpriseFavorites"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Briefcase, OfficeBuilding } from '@element-plus/icons-vue'
import { studentApi } from '@/api'

const router = useRouter()
const jobQuery = reactive({ pageNum: 1, pageSize: 6 })
const enterpriseQuery = reactive({ pageNum: 1, pageSize: 6 })
const jobList = ref([])
const enterpriseList = ref([])
const jobTotal = ref(0)
const enterpriseTotal = ref(0)
const jobLoading = ref(false)
const enterpriseLoading = ref(false)

const formatDate = (value) => value ? String(value).replace('T', ' ').substring(0, 16) : ''
const splitTags = (value) => String(value || '').split(',').filter(Boolean).slice(0, 3)
const formatSalary = (job) => {
  if (!job) return '薪资待定'
  if (job.salaryMin == null || job.salaryMax == null) return '薪资待定'
  return `${job.salaryMin}-${job.salaryMax}K`
}

const loadJobFavorites = async () => {
  jobLoading.value = true
  try {
    const r = await studentApi.favorites(jobQuery)
    jobList.value = r.data.records || []
    jobTotal.value = Number(r.data.total || 0)
  } finally {
    jobLoading.value = false
  }
}

const loadEnterpriseFavorites = async () => {
  enterpriseLoading.value = true
  try {
    const r = await studentApi.enterpriseFavorites(enterpriseQuery)
    enterpriseList.value = r.data.records || []
    enterpriseTotal.value = Number(r.data.total || 0)
  } finally {
    enterpriseLoading.value = false
  }
}

const cancelJob = async (row) => {
  await studentApi.delFavorite(row.jobId)
  ElMessage.success('已取消收藏')
  loadJobFavorites()
}

const cancelEnterprise = async (row) => {
  await studentApi.delEnterpriseFavorite(row.enterpriseId)
  ElMessage.success('已取消收藏')
  loadEnterpriseFavorites()
}

onMounted(() => {
  loadJobFavorites()
  loadEnterpriseFavorites()
})
</script>

<style scoped lang="scss">
.favorite-page {
  width: 100%;
  max-width: none;
  height: calc(100dvh - 70px - clamp(24px, 3vw, 40px));
  min-height: 48rem;
  margin: 0;
  padding: 0;
  display: grid;
  grid-template-rows: auto minmax(0, 1.08fr) minmax(0, .92fr);
  gap: clamp(.75rem, 1vw, 1rem);
}
.header { display: flex; justify-content: space-between; align-items: center; gap: 1rem;
  h2 { margin-bottom: .375rem; color: var(--cr-text); }
  p { color: var(--cr-text-muted); }
}
.header-actions { display: flex; gap: .625rem; flex-wrap: wrap; justify-content: flex-end; }
.favorite-section {
  min-width: 0;
  min-height: 0;
  display: grid;
  grid-template-rows: auto minmax(0, 1fr) auto;
}
.section-head { display: flex; justify-content: space-between; align-items: flex-start; gap: 1rem; margin-bottom: 1rem;
  h3 { display: flex; align-items: center; gap: .375rem; color: var(--cr-text); font-size: 1.125rem; }
  p { color: var(--cr-text-muted); font-size: .875rem; margin-top: .25rem; }
  .el-icon { color: var(--cr-primary); }
}
.section-body {
  min-height: 0;
  overflow: auto;
}
.section-body :deep(.el-empty) {
  height: 100%;
  min-height: 10rem;
}
.favorite-list {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 20rem), 1fr));
  align-content: center;
  gap: 1rem;
  min-height: 100%;
}
.fav-card { min-width: 0; min-height: 8.75rem; background: #fff; border: .0625rem solid var(--cr-border-soft); border-radius: var(--cr-radius); padding: 1rem; transition: box-shadow .2s ease, border-color .2s ease;
  &:hover { border-color: rgba(37, 99, 235, .22); box-shadow: var(--cr-shadow-soft); }
}
.job-card { display: flex; flex-direction: column; gap: .875rem; }
.enterprise-card { display: grid; grid-template-columns: auto minmax(0, 1fr); gap: .875rem; align-items: flex-start;
  .card-footer { grid-column: 1 / -1; }
}
.logo { --el-avatar-size: 3.75rem; flex-shrink: 0; }
.card-main { min-width: 0; }
.job-title, .company { color: var(--cr-text); font-weight: 750; line-height: 1.35; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.salary { color: var(--cr-danger); font-size: 1.125rem; font-weight: 750; margin-top: .5rem; }
.meta { color: var(--cr-text-muted); font-size: .8125rem; line-height: 1.7; margin-top: .25rem; }
.tags { display: flex; flex-wrap: wrap; gap: .375rem; margin-top: .625rem; }
.card-footer { display: flex; justify-content: space-between; align-items: center; gap: .75rem; align-self: end; margin-top: auto; padding-top: .75rem; border-top: .0625rem dashed var(--cr-border-soft); color: var(--cr-text-muted); font-size: .75rem; }
.actions { display: flex; align-items: center; gap: .5rem; }
.actions :deep(.el-button.is-text) {
  min-height: 2.5rem;
  min-width: 3.25rem;
  padding-inline: .875rem;
}
.pagination-wrap {
  min-height: 3rem;
  margin-top: 0;
  padding-top: .75rem;
  align-items: center;
  border-top: .0625rem solid var(--cr-border-soft);
}
.pagination-wrap :deep(.el-pagination) {
  justify-content: center;
  flex-wrap: wrap;
}

@media (max-width: 64rem) {
  .favorite-list { grid-template-columns: 1fr; }
}

@media (max-width: 42rem) {
  .favorite-page {
    height: auto;
    min-height: calc(100dvh - 94px);
    display: flex;
    flex-direction: column;
  }
  .favorite-section {
    min-height: 22rem;
  }
  .header, .card-footer { align-items: stretch; flex-direction: column; }
  .header-actions { flex-direction: column; }
  .header-actions :deep(.el-button) { width: 100%; margin-left: 0; }
  .enterprise-card { grid-template-columns: 1fr; }
  .actions { justify-content: flex-start; }
}
</style>
