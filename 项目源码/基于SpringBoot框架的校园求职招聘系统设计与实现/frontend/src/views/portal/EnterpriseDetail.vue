<template>
  <div class="ent-detail portal-content" v-loading="loading">
    <div v-if="enterprise">
      <!-- 企业头部 -->
      <div class="page-card head">
        <el-avatar :size="100" :src="enterprise.logo" shape="square" class="logo"><el-icon size="40"><OfficeBuilding /></el-icon></el-avatar>
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

      <!-- 介绍 + 联系 -->
      <el-row :gutter="20" class="mt-20">
        <el-col :span="17">
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
              <el-empty v-if="jobs.length === 0" description="暂无在招职位" :image-size="80" />
            </div>
          </div>
        </el-col>
        <el-col :span="7">
          <div class="page-card contact">
            <h3 class="block-title">联系方式</h3>
            <p><b>联系人：</b>{{ enterprise.contactName || '-' }}</p>
            <p><b>电话：</b>{{ enterprise.contactPhone || '-' }}</p>
            <p><b>邮箱：</b>{{ enterprise.email || '-' }}</p>
            <p><b>官网：</b>{{ enterprise.website || '-' }}</p>
            <p><b>地址：</b>{{ enterprise.address || '-' }}</p>
          </div>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { OfficeBuilding, Star, User, Location } from '@element-plus/icons-vue'
import { publicApi } from '@/api'

const route = useRoute()
const loading = ref(false)
const enterprise = ref(null)
const jobs = ref([])

onMounted(async () => {
  loading.value = true
  try {
    const res = await publicApi.enterpriseDetail(route.params.id)
    const data = res.data
    enterprise.value = data.enterprise || data
    jobs.value = data.jobs || []
  } finally { loading.value = false }
})
</script>

<style scoped lang="scss">
.head { display: flex; gap: 20px; align-items: center; }
.logo { flex-shrink: 0; }
.info { flex: 1; }
.name { color: #303133; display: flex; align-items: center; gap: 10px; }
.meta { color: #606266; margin-top: 10px; .el-icon { vertical-align: middle; margin-right: 2px; } .sep { margin: 0 10px; color: #dcdfe6; } }
.welfare { margin-top: 12px; display: flex; gap: 6px; flex-wrap: wrap; }
.block-title { font-size: 16px; color: #303133; border-left: 3px solid #409eff; padding-left: 10px; margin-bottom: 14px; .cnt { color: #909399; font-size: 14px; margin-left: 6px; } }
.rich-text { color: #606266; line-height: 1.8; white-space: pre-line; }
.job-list { .job-item { display: flex; justify-content: space-between; align-items: center; padding: 14px; border-radius: 6px; cursor: pointer; transition: background .2s;
    &:hover { background: #f5f7fa; }
    .job-title { color: #303133; font-weight: 500; margin-bottom: 4px; }
    .job-meta { color: #909399; font-size: 12px; }
    .job-salary { color: #f56c6c; font-weight: 600; font-size: 16px; }
  }
}
.contact p { line-height: 2; font-size: 14px; color: #606266; b { color: #909399; } }
</style>
