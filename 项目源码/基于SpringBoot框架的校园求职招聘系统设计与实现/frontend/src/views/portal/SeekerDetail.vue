<template>
  <div class="portal-content" v-loading="loading">
    <template v-if="post">
      <div class="page-card head">
        <div class="student">
          <el-avatar :src="student?.avatar" class="avatar"><el-icon><User /></el-icon></el-avatar>
          <div>
            <h2>{{ post.title }}</h2>
            <p>{{ student?.realName || '求职者' }} · {{ student?.college || '-' }} · {{ student?.major || '-' }}</p>
          </div>
        </div>
        <el-button type="primary" @click="contact">联系TA</el-button>
      </div>

      <div class="detail-grid mt-20">
        <div class="page-card">
          <h3 class="block-title">求职意向</h3>
          <div class="tags">
            <el-tag>{{ post.expectPost || '岗位不限' }}</el-tag>
            <el-tag type="success">{{ post.expectCity || '城市不限' }}</el-tag>
            <el-tag type="warning">{{ post.expectSalary || '薪资面议' }}</el-tag>
          </div>
          <h3 class="block-title mt-20">自我介绍</h3>
          <p class="rich-text">{{ post.intro || '暂无介绍' }}</p>
          <template v-if="resume">
            <h3 class="block-title mt-20">简历摘要</h3>
            <p class="rich-text">{{ resume.selfEval || '暂无自我评价' }}</p>
            <p class="rich-text" v-if="resume.skillCert"><b>技能证书：</b>{{ resume.skillCert }}</p>
            <p class="rich-text" v-if="resume.award"><b>获奖经历：</b>{{ resume.award }}</p>
          </template>
        </div>
        <div class="page-card side">
          <h3 class="block-title">基本信息</h3>
          <p><b>学历：</b>{{ student?.education || resume?.education || '-' }}</p>
          <p><b>学院：</b>{{ student?.college || resume?.college || '-' }}</p>
          <p><b>专业：</b>{{ student?.major || resume?.major || '-' }}</p>
          <p><b>浏览：</b>{{ post.viewCount || 0 }}</p>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User } from '@element-plus/icons-vue'
import { publicApi } from '@/api'
import { useUserStore } from '@/store/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const post = ref(null)
const student = ref(null)
const resume = ref(null)

const contact = () => {
  if (!userStore.isLogin) { ElMessage.warning('请先登录'); router.push('/login'); return }
  if (userStore.role !== 'ENTERPRISE') { ElMessage.warning('请使用企业账号联系求职者'); return }
  router.push({ path: '/chat', query: { peerRole: 'STUDENT', peerId: post.value.studentId, peerName: student.value?.realName || `学生${post.value.studentId}`, seekerPostId: post.value.id } })
}

onMounted(async () => {
  loading.value = true
  try {
    const res = await publicApi.seekerPostDetail(route.params.id)
    post.value = res.data.post
    student.value = res.data.student
    resume.value = res.data.resume
  } finally { loading.value = false }
})
</script>

<style scoped lang="scss">
.head { display:flex; align-items:center; justify-content:space-between; gap:1rem; }
.student { display:flex; align-items:center; gap:1rem; min-width:0; h2{margin-bottom:.375rem;color:var(--cr-text);} p{color:var(--cr-text-muted);} }
.avatar { --el-avatar-size:4rem; flex-shrink:0; }
.detail-grid { display:grid; grid-template-columns:minmax(0,1fr) minmax(16rem,.32fr); gap:1rem; align-items:start; }
.block-title { font-size:1rem; color:var(--cr-text); border-left:.1875rem solid var(--cr-primary); padding-left:.625rem; margin-bottom:.875rem; }
.tags { display:flex; flex-wrap:wrap; gap:.5rem; }
.rich-text { color:var(--cr-text-soft); line-height:1.85; white-space:pre-line; }
.side p { line-height:2; color:var(--cr-text-soft); b{color:var(--cr-text-muted);} }
@media (max-width:56rem){.head{align-items:stretch;flex-direction:column}.detail-grid{grid-template-columns:1fr}.head :deep(.el-button){width:100%;}}
</style>
