<template>
  <div class="job-detail portal-content" v-loading="loading">
    <div v-if="job">
      <!-- 头部 -->
      <div class="page-card head">
        <div class="head-left">
          <h2 class="title">{{ job.title }}</h2>
          <div class="salary">{{ job.salaryMin }}-{{ job.salaryMax }}K</div>
          <div class="meta">
            <el-tag size="small">{{ job.city || '不限' }}</el-tag>
            <el-tag size="small" type="info">{{ job.education || '学历不限' }}</el-tag>
            <el-tag size="small" type="warning">{{ job.jobType === 1 ? '全职' : '实习' }}</el-tag>
            <el-tag size="small" type="success" v-if="job.recruitNum">招聘 {{ job.recruitNum }} 人</el-tag>
            <el-tag size="small" v-if="job.experience">经验: {{ job.experience }}</el-tag>
          </div>
          <div class="welfare" v-if="job.welfare">
            <el-tag v-for="w in job.welfare.split(',')" :key="w" size="small" effect="plain" type="success">{{ w }}</el-tag>
          </div>
        </div>
        <div class="head-right">
          <el-button type="primary" size="large" :loading="applying" @click="onApply">
            <el-icon><Promotion /></el-icon> 立即投递
          </el-button>
          <el-button :type="favorited ? 'warning' : 'default'" size="large" @click="onFavorite">
            <el-icon><Star /></el-icon> {{ favorited ? '已收藏' : '收藏' }}
          </el-button>
          <div class="stats">
            <span>浏览 {{ job.viewCount || 0 }}</span>
            <span>投递 {{ job.applyCount || 0 }}</span>
          </div>
        </div>
      </div>

      <el-row :gutter="20" class="mt-20">
        <el-col :span="17">
          <!-- 岗位描述 -->
          <div class="page-card">
            <h3 class="block-title">岗位职责</h3>
            <div class="rich-text">{{ job.duty || '暂无描述' }}</div>

            <h3 class="block-title mt-20">任职要求</h3>
            <div class="rich-text">{{ job.requirement || '暂无要求' }}</div>

            <h3 class="block-title mt-20">专业要求</h3>
            <div class="rich-text">{{ job.majorRequire || '专业不限' }}</div>
          </div>
        </el-col>
        <el-col :span="7">
          <!-- 企业信息 -->
          <div class="page-card ent-card" v-if="enterprise">
            <div class="ent-head">
              <el-avatar :size="60" :src="enterprise.logo" shape="square"><el-icon><OfficeBuilding /></el-icon></el-avatar>
              <div class="ent-info">
                <h3>{{ enterprise.companyName }}</h3>
                <p>{{ enterprise.industry }} · {{ enterprise.scale }}</p>
              </div>
            </div>
            <el-divider />
            <p class="ent-line"><b>所在地：</b>{{ enterprise.city || '-' }}</p>
            <p class="ent-line"><b>地址：</b>{{ enterprise.address || '-' }}</p>
            <p class="ent-intro" v-if="enterprise.intro">{{ enterprise.intro }}</p>
            <el-button text type="primary" @click="$router.push(`/enterprise/${enterprise.id}`)">查看企业主页 →</el-button>
          </div>
        </el-col>
      </el-row>
    </div>

    <!-- 投递确认弹窗 -->
    <el-dialog v-model="applyDialog" title="投递岗位" width="500px">
      <el-form label-width="80px">
        <el-form-item label="选择简历">
          <el-select v-model="applyForm.resumeId" placeholder="使用在线简历" style="width: 100%">
            <el-option :value="null" label="使用在线简历" />
            <el-option v-for="r in resumes" :key="r.id" :value="r.id" :label="r.fileName" />
          </el-select>
        </el-form-item>
        <el-form-item label="附言">
          <el-input v-model="applyForm.applyRemark" type="textarea" :rows="3" placeholder="向 HR 介绍自己（选填）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="applyDialog = false">取消</el-button>
        <el-button type="primary" :loading="applying" @click="confirmApply">确认投递</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Promotion, Star, OfficeBuilding } from '@element-plus/icons-vue'
import { publicApi, studentApi } from '@/api'
import { useUserStore } from '@/store/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const applying = ref(false)
const job = ref(null)
const enterprise = ref(null)
const favorited = ref(false)
const applyDialog = ref(false)
const applyForm = reactive({ resumeId: null, applyRemark: '' })
const resumes = ref([])
const onlineResume = ref(null)

const ensureLogin = () => {
  if (!userStore.isLogin) { ElMessage.warning('请先登录'); router.push('/login'); return false }
  if (userStore.role !== 'STUDENT') { ElMessage.warning('请使用学生账号操作'); return false }
  return true
}

const onApply = async () => {
  if (!ensureLogin()) return
  try {
    const res = await studentApi.getResume()
    onlineResume.value = res.data
    resumes.value = res.data ? [{ id: res.data.id, fileName: `在线简历（完整度 ${res.data.completeRate || 0}%）` }] : []
  } catch (e) {}
  if (!onlineResume.value?.id) {
    ElMessage.warning('请先完善在线简历后再投递')
    router.push('/student/resume')
    return
  }
  applyForm.resumeId = onlineResume.value.id
  applyDialog.value = true
}

const confirmApply = async () => {
  applying.value = true
  try {
    await studentApi.apply({ jobId: job.value.id, resumeId: applyForm.resumeId, applyRemark: applyForm.applyRemark })
    ElMessage.success('投递成功，请在「投递记录」查看进度')
    applyDialog.value = false
  } finally { applying.value = false }
}

const onFavorite = async () => {
  if (!ensureLogin()) return
  if (favorited.value) {
    await studentApi.delFavorite(job.value.id)
    favorited.value = false
    ElMessage.success('已取消收藏')
  } else {
    await studentApi.addFavorite(job.value.id)
    favorited.value = true
    ElMessage.success('已收藏')
  }
}

const checkFavorite = async () => {
  if (userStore.role !== 'STUDENT') return
  try {
    const res = await studentApi.checkFavorite(job.value.id)
    favorited.value = !!res.data?.favorite
  } catch (e) {}
}

onMounted(async () => {
  loading.value = true
  try {
    const res = await publicApi.jobDetail(route.params.id)
    const data = res.data
    // 后端 detail 返回 Map: { job, enterprise }
    job.value = data.job || data
    enterprise.value = data.enterprise || null
    await checkFavorite()
  } finally { loading.value = false }
})
</script>

<style scoped lang="scss">
.head { display: flex; }
.head-left { flex: 1; }
.head-right { width: 240px; display: flex; flex-direction: column; gap: 10px; align-items: flex-end; }
.title { color: #303133; margin-bottom: 8px; }
.salary { color: #f56c6c; font-size: 26px; font-weight: 600; margin-bottom: 12px; }
.meta { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 10px; }
.welfare { display: flex; gap: 6px; flex-wrap: wrap; }
.stats { font-size: 12px; color: #909399; margin-top: 6px; span { margin-left: 10px; } }
.block-title { font-size: 16px; color: #303133; border-left: 3px solid #409eff; padding-left: 10px; }
.rich-text { color: #606266; line-height: 1.8; white-space: pre-line; margin-top: 10px; }
.ent-card { .ent-head { display: flex; gap: 12px; }
  .ent-info h3 { margin-bottom: 6px; font-size: 16px; }
  .ent-info p { color: #909399; font-size: 13px; }
  .ent-line { line-height: 1.8; font-size: 14px; color: #606266; b { color: #909399; }}
  .ent-intro { color: #606266; line-height: 1.6; margin: 12px 0; font-size: 13px; }
}
</style>
