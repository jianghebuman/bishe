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
        <div class="head-actions">
          <el-button @click="requestResume">请求查看简历</el-button>
          <el-button type="primary" @click="contact">联系TA</el-button>
        </div>
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
            <h3 class="block-title mt-20">在线简历完整版</h3>
            <div class="resume-panel">
              <div class="resume-head">
                <h4>{{ resume.name || student?.realName || '求职者' }}</h4>
                <p>{{ resume.education || '-' }} · {{ resume.college || student?.college || '-' }} · {{ resume.major || student?.major || '-' }}</p>
                <p>{{ genderLabel(resume.gender) }} · {{ resume.birth || '出生年月未填' }}</p>
              </div>
              <ResumeBlock title="自我评价" :content="resume.selfEval" />
              <ResumeBlock title="技能证书" :content="resume.skillCert" />
              <ResumeBlock title="获奖经历" :content="resume.award" />
              <ResumeList title="教育经历" :items="educations" type="education" />
              <ResumeList title="项目经历" :items="projects" type="project" />
              <ResumeList title="实习/工作经历" :items="experiences" type="experience" />
            </div>
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
import { defineComponent, h } from 'vue'
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
const educations = ref([])
const projects = ref([])
const experiences = ref([])

const ResumeBlock = defineComponent({
  props: { title: String, content: String },
  setup(props) {
    return () => props.content ? h('section', { class: 'resume-block' }, [
      h('h5', props.title),
      h('p', props.content)
    ]) : null
  }
})

const ResumeList = defineComponent({
  props: { title: String, items: Array, type: String },
  setup(props) {
    const itemTitle = (item) => props.type === 'education'
      ? `${item.school || ''} · ${item.major || ''} · ${item.degree || ''}`
      : props.type === 'project'
        ? `${item.projectName || ''}${item.role ? ` · ${item.role}` : ''}`
        : `${item.company || ''}${item.position ? ` · ${item.position}` : ''}`
    return () => props.items?.length ? h('section', { class: 'resume-block' }, [
      h('h5', props.title),
      props.items.map(item => h('div', { class: 'resume-item' }, [
        h('b', itemTitle(item)),
        h('span', `${item.startDate || ''} - ${item.endDate || ''}`),
        h('p', item.description || '')
      ]))
    ]) : null
  }
})

const contact = () => {
  if (!userStore.isLogin) { ElMessage.warning('请先登录'); router.push('/login'); return }
  if (userStore.role !== 'ENTERPRISE') { ElMessage.warning('请使用企业账号联系求职者'); return }
  router.push({ path: '/chat', query: { peerRole: 'STUDENT', peerId: post.value.studentId, peerName: student.value?.realName || `学生${post.value.studentId}`, seekerPostId: post.value.id } })
}
const requestResume = () => {
  if (!userStore.isLogin) { ElMessage.warning('请先登录'); router.push('/login'); return }
  if (userStore.role !== 'ENTERPRISE') { ElMessage.warning('请使用企业账号请求查看简历'); return }
  router.push({
    path: '/chat',
    query: {
      peerRole: 'STUDENT',
      peerId: post.value.studentId,
      peerName: student.value?.realName || `学生${post.value.studentId}`,
      seekerPostId: post.value.id,
      action: 'requestResume'
    }
  })
}
const genderLabel = (gender) => Number(gender) === 1 ? '男' : Number(gender) === 2 ? '女' : '保密'

onMounted(async () => {
  loading.value = true
  try {
    const res = await publicApi.seekerPostDetail(route.params.id)
    post.value = res.data.post
    student.value = res.data.student
    resume.value = res.data.resume
    educations.value = res.data.educations || []
    projects.value = res.data.projects || []
    experiences.value = res.data.experiences || []
  } finally { loading.value = false }
})
</script>

<style scoped lang="scss">
.head { display:flex; align-items:center; justify-content:space-between; gap:1rem; }
.head-actions { display:flex; gap:.75rem; flex-wrap:wrap; justify-content:flex-end; }
.student { display:flex; align-items:center; gap:1rem; min-width:0; h2{margin-bottom:.375rem;color:var(--cr-text);} p{color:var(--cr-text-muted);} }
.avatar { --el-avatar-size:4rem; flex-shrink:0; }
.detail-grid { display:grid; grid-template-columns:minmax(0,1fr) minmax(16rem,.32fr); gap:1rem; align-items:start; }
.block-title { font-size:1rem; color:var(--cr-text); border-left:.1875rem solid var(--cr-primary); padding-left:.625rem; margin-bottom:.875rem; }
.tags { display:flex; flex-wrap:wrap; gap:.5rem; }
.rich-text { color:var(--cr-text-soft); line-height:1.85; white-space:pre-line; }
.side p { line-height:2; color:var(--cr-text-soft); b{color:var(--cr-text-muted);} }
.resume-panel { border:1px solid var(--cr-border-soft); border-radius:var(--cr-radius-sm); padding:1rem; background:#fff; }
.resume-head { border-bottom:1px solid var(--cr-border-soft); padding-bottom:.75rem; margin-bottom:.875rem;
  h4{font-size:1.25rem;margin-bottom:.375rem;color:var(--cr-text);} p{color:var(--cr-text-muted);line-height:1.7;}
}
:deep(.resume-block){margin-top:1rem;h5{font-size:.9375rem;margin-bottom:.5rem;color:var(--cr-text);}.resume-item{padding:.625rem 0;border-bottom:1px dashed var(--cr-border-soft);} .resume-item:last-child{border-bottom:0;} b{display:block;color:var(--cr-text);margin-bottom:.25rem;} span{display:block;color:var(--cr-text-muted);font-size:.8125rem;margin-bottom:.25rem;} p{white-space:pre-line;color:var(--cr-text-soft);line-height:1.75;}}
@media (max-width:56rem){.head{align-items:stretch;flex-direction:column}.detail-grid{grid-template-columns:1fr}.head-actions{justify-content:stretch}.head-actions :deep(.el-button){width:100%;margin-left:0;}}
</style>
