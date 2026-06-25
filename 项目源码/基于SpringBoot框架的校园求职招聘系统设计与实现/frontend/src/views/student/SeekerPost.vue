<template>
  <div class="page-container">
    <div class="page-card">
      <div class="header">
        <div>
          <h2>我的求职信息</h2>
          <p>发布到门户求职栏后，企业可通过站内沟通联系你。</p>
        </div>
        <el-switch v-model="form.status" :active-value="1" :inactive-value="0" active-text="展示" inactive-text="下架" @change="changeStatus" />
      </div>
      <el-divider />
      <el-form :model="form" label-width="6rem">
        <el-row :gutter="16">
          <el-col :span="12"><el-form-item label="求职标题"><el-input v-model="form.title" placeholder="如：计算机本科求Java后端实习" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="绑定简历"><el-select v-model="form.resumeId" class="w-full" placeholder="选择在线简历"><el-option v-if="resume" :label="`在线简历（完整度 ${resume.completeRate || 0}%）`" :value="resume.id" /></el-select></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="期望岗位"><el-input v-model="form.expectPost" /></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="期望城市"><el-input v-model="form.expectCity" placeholder="北京,杭州" /></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="期望薪资"><el-input v-model="form.expectSalary" placeholder="8K-12K" /></el-form-item></el-col>
          <el-col :span="24"><el-form-item label="自我介绍"><el-input v-model="form.intro" type="textarea" :rows="7" maxlength="2000" show-word-limit placeholder="简要介绍技能、项目经历和求职方向" /></el-form-item></el-col>
        </el-row>
        <el-form-item>
          <el-button type="primary" :loading="saving" @click="save">保存并发布</el-button>
          <el-button @click="$router.push('/seekers')">查看求职栏</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { studentApi } from '@/api'

const saving = ref(false)
const resume = ref(null)
const form = reactive({ id: null, resumeId: null, title: '', expectPost: '', expectCity: '', expectSalary: '', intro: '', status: 1 })

const load = async () => {
  const [postRes, resumeRes] = await Promise.all([studentApi.seekerPost(), studentApi.getResume()])
  resume.value = resumeRes.data
  if (postRes.data) Object.assign(form, postRes.data)
  else if (resume.value) {
    form.resumeId = resume.value.id
    form.expectPost = resume.value.major ? `${resume.value.major}相关岗位` : ''
    form.title = resume.value.name ? `${resume.value.name}的求职信息` : ''
  }
}
const save = async () => {
  saving.value = true
  try {
    await studentApi.saveSeekerPost(form)
    ElMessage.success('求职信息已保存')
    await load()
  } finally { saving.value = false }
}
const changeStatus = async (status) => {
  if (!form.id) return
  await studentApi.updateSeekerStatus(status)
  ElMessage.success(status === 1 ? '已展示' : '已下架')
}
onMounted(load)
</script>

<style scoped>
.header { display:flex; justify-content:space-between; align-items:flex-start; gap:1rem; flex-wrap:wrap; }
.header h2 { margin-bottom:.375rem; }
.header p { color:var(--cr-text-muted); }
</style>
