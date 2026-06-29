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

      <el-divider />
      <div class="attach-head">
        <div>
          <h3>附件简历</h3>
          <p>可上传 PDF / Word 简历，在线沟通时可一键发送给 HR。</p>
        </div>
        <el-upload :show-file-list="false" accept=".pdf,.doc,.docx" :http-request="uploadAttachment">
          <el-button type="primary" plain :icon="Upload">上传简历</el-button>
        </el-upload>
      </div>
      <el-table :data="attachments" stripe class="mt-20">
        <el-table-column label="文件名" min-width="220">
          <template #default="{ row }"><el-icon><Document /></el-icon> {{ row.fileName }}</template>
        </el-table-column>
        <el-table-column label="类型" width="100"><template #default="{ row }"><el-tag>{{ ext(row.fileName) }}</el-tag></template></el-table-column>
        <el-table-column label="大小" width="120"><template #default="{ row }">{{ size(row.fileSize) }}</template></el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" @click="previewAttachment(row)">预览/下载</el-button>
            <el-button text type="danger" @click="removeAttachment(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="attachments.length === 0" description="还没有上传附件简历" />
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Document, Upload } from '@element-plus/icons-vue'
import { studentApi } from '@/api'

const saving = ref(false)
const resume = ref(null)
const attachments = ref([])
const form = reactive({ id: null, resumeId: null, title: '', expectPost: '', expectCity: '', expectSalary: '', intro: '', status: 1 })

const load = async () => {
  const [postRes, resumeRes, attachRes] = await Promise.all([studentApi.seekerPost(), studentApi.getResume(), studentApi.attachments()])
  resume.value = resumeRes.data
  attachments.value = attachRes.data || []
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
const uploadAttachment = async ({ file }) => {
  const fd = new FormData()
  fd.append('file', file)
  await studentApi.uploadAttachment(fd)
  ElMessage.success('附件简历上传成功')
  await load()
}
const removeAttachment = row => ElMessageBox.confirm(`确定删除「${row.fileName}」？`).then(async () => {
  await studentApi.delAttachment(row.id)
  ElMessage.success('已删除')
  await load()
})
const previewAttachment = row => window.open(row.fileUrl, '_blank')
const ext = n => (n || '').split('.').pop()?.toUpperCase() || '-'
const size = b => b ? (b / 1024 / 1024).toFixed(2) + ' MB' : '-'
onMounted(load)
</script>

<style scoped>
.header { display:flex; justify-content:space-between; align-items:flex-start; gap:1rem; flex-wrap:wrap; }
.header h2 { margin-bottom:.375rem; }
.header p { color:var(--cr-text-muted); }
.attach-head { display:flex; justify-content:space-between; align-items:flex-start; gap:1rem; flex-wrap:wrap; }
.attach-head h3 { margin-bottom:.375rem; color:var(--cr-text); }
.attach-head p { color:var(--cr-text-muted); }
</style>
