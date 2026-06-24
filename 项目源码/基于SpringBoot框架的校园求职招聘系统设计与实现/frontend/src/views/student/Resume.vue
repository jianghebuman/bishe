<template>
  <div class="page-container">
    <el-row :gutter="16">
      <el-col :span="17">
        <div class="page-card">
          <div class="header">
            <div>
              <h2>在线简历</h2>
              <p>建议完整填写基本信息、教育经历、项目/实习经历，提升简历通过率</p>
            </div>
            <el-progress type="circle" :percentage="resume.completeRate || 0" :width="72" />
          </div>
          <el-divider />

          <el-form :model="resume" label-width="100px">
            <el-row :gutter="16">
              <el-col :span="12"><el-form-item label="姓名"><el-input v-model="resume.name" /></el-form-item></el-col>
              <el-col :span="12"><el-form-item label="性别"><el-radio-group v-model="resume.gender"><el-radio :label="1">男</el-radio><el-radio :label="2">女</el-radio><el-radio :label="0">保密</el-radio></el-radio-group></el-form-item></el-col>
              <el-col :span="12"><el-form-item label="出生年月"><el-input v-model="resume.birth" placeholder="如 2003-05" /></el-form-item></el-col>
              <el-col :span="12"><el-form-item label="电话"><el-input v-model="resume.phone" /></el-form-item></el-col>
              <el-col :span="12"><el-form-item label="邮箱"><el-input v-model="resume.email" /></el-form-item></el-col>
              <el-col :span="12"><el-form-item label="学历"><el-input v-model="resume.education" /></el-form-item></el-col>
              <el-col :span="12"><el-form-item label="学院"><el-input v-model="resume.college" /></el-form-item></el-col>
              <el-col :span="12"><el-form-item label="专业"><el-input v-model="resume.major" /></el-form-item></el-col>
              <el-col :span="24"><el-form-item label="技能证书"><el-input v-model="resume.skillCert" type="textarea" :rows="3" /></el-form-item></el-col>
              <el-col :span="24"><el-form-item label="获奖经历"><el-input v-model="resume.award" type="textarea" :rows="3" /></el-form-item></el-col>
              <el-col :span="24"><el-form-item label="自我评价"><el-input v-model="resume.selfEval" type="textarea" :rows="4" /></el-form-item></el-col>
            </el-row>
            <el-form-item><el-button type="primary" :loading="saving" @click="saveResume">保存简历</el-button></el-form-item>
          </el-form>
        </div>

        <!-- 教育经历 -->
        <ResumeSection title="教育经历" type="education" :items="educations" @add="openEdu" @edit="openEdu" @del="delEducation" />
        <ResumeSection title="项目经历" type="project" :items="projects" @add="openProject" @edit="openProject" @del="delProject" />
        <ResumeSection title="实习/工作经历" type="experience" :items="experiences" @add="openExperience" @edit="openExperience" @del="delExperience" />
      </el-col>
      <el-col :span="7">
        <div class="page-card tips">
          <h3>简历优化建议</h3>
          <ul>
            <li>基本信息保持真实，手机号和邮箱必须可联系。</li>
            <li>项目经历建议用「背景-任务-行动-结果」描述。</li>
            <li>技能证书和获奖经历尽量量化成果。</li>
            <li>自我评价避免空话，突出岗位匹配度。</li>
          </ul>
        </div>
      </el-col>
    </el-row>

    <el-dialog v-model="dialog" :title="dialogTitle" width="620px">
      <el-form :model="editForm" label-width="90px">
        <template v-if="editType === 'education'">
          <el-form-item label="学校"><el-input v-model="editForm.school" /></el-form-item>
          <el-form-item label="专业"><el-input v-model="editForm.major" /></el-form-item>
          <el-form-item label="学历"><el-input v-model="editForm.degree" /></el-form-item>
        </template>
        <template v-else-if="editType === 'project'">
          <el-form-item label="项目名称"><el-input v-model="editForm.projectName" /></el-form-item>
          <el-form-item label="担任角色"><el-input v-model="editForm.role" /></el-form-item>
        </template>
        <template v-else>
          <el-form-item label="公司"><el-input v-model="editForm.company" /></el-form-item>
          <el-form-item label="职位"><el-input v-model="editForm.position" /></el-form-item>
        </template>
        <el-form-item label="开始时间"><el-input v-model="editForm.startDate" placeholder="如 2023-09" /></el-form-item>
        <el-form-item label="结束时间"><el-input v-model="editForm.endDate" placeholder="如 2024-06 / 至今" /></el-form-item>
        <el-form-item label="描述"><el-input v-model="editForm.description" type="textarea" :rows="4" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="dialog=false">取消</el-button><el-button type="primary" @click="saveSub">保存</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, defineComponent, h, onMounted } from 'vue'
import { ElMessage, ElMessageBox, ElButton, ElTag } from 'element-plus'
import { studentApi } from '@/api'

const ResumeSection = defineComponent({
  props: { title: String, type: String, items: Array }, emits: ['add', 'edit', 'del'],
  setup(props, { emit }) { return () => h('div', { class: 'page-card mt-20 resume-section' }, [
    h('div', { class: 'section-head' }, [h('h3', props.title), h(ElButton, { type: 'primary', plain: true, size: 'small', onClick: () => emit('add') }, () => '新增')]),
    props.items?.length ? props.items.map(it => h('div', { class: 'section-item' }, [
      h('div', { class: 'item-main' }, [
        h('div', { class: 'item-title' }, props.type === 'education' ? `${it.school || ''} · ${it.major || ''}` : props.type === 'project' ? it.projectName : `${it.company || ''} · ${it.position || ''}`),
        h('div', { class: 'item-time' }, `${it.startDate || ''} - ${it.endDate || ''}`),
        h('div', { class: 'item-desc' }, it.description || '')
      ]),
      h('div', [h(ElButton, { text: true, type: 'primary', onClick: () => emit('edit', it) }, () => '编辑'), h(ElButton, { text: true, type: 'danger', onClick: () => emit('del', it.id) }, () => '删除')])
    ])) : h('div', { class: 'empty-line' }, '暂无记录，请点击新增')
  ]) }
})

const saving = ref(false)
const resume = reactive({ gender: 0, completeRate: 0, isPublic: 1 })
const educations = ref([]), projects = ref([]), experiences = ref([])
const dialog = ref(false), editType = ref('education')
const editForm = reactive({})
const dialogTitle = computed(() => editType.value === 'education' ? '教育经历' : editType.value === 'project' ? '项目经历' : '实习/工作经历')

const resetEdit = (obj = {}) => { Object.keys(editForm).forEach(k => delete editForm[k]); Object.assign(editForm, obj, { resumeId: resume.id }) }
const ensureResume = async () => { if (!resume.id) await saveResume() }
const loadSub = async () => {
  if (!resume.id) return
  educations.value = (await studentApi.listEducation(resume.id)).data || []
  projects.value = (await studentApi.listProject(resume.id)).data || []
  experiences.value = (await studentApi.listExperience(resume.id)).data || []
}
const load = async () => {
  const res = await studentApi.getResume()
  if (res.data) Object.assign(resume, res.data)
  await loadSub()
}
const saveResume = async () => { saving.value = true; try { const res = await studentApi.saveResume(resume); resume.id = res.data.resumeId; resume.completeRate = res.data.completeRate || 0; ElMessage.success('简历保存成功'); await loadSub() } finally { saving.value = false } }
const openEdu = async (row) => { await ensureResume(); editType.value = 'education'; resetEdit(row || {}); dialog.value = true }
const openProject = async (row) => { await ensureResume(); editType.value = 'project'; resetEdit(row || {}); dialog.value = true }
const openExperience = async (row) => { await ensureResume(); editType.value = 'experience'; resetEdit(row || {}); dialog.value = true }
const saveSub = async () => {
  editForm.resumeId = resume.id
  if (editType.value === 'education') await studentApi.saveEducation(editForm)
  else if (editType.value === 'project') await studentApi.saveProject(editForm)
  else await studentApi.saveExperience(editForm)
  ElMessage.success('保存成功'); dialog.value = false; await load()
}
const delEducation = (id) => ElMessageBox.confirm('确定删除该教育经历？').then(async()=>{ await studentApi.delEducation(id); await load(); ElMessage.success('已删除') })
const delProject = (id) => ElMessageBox.confirm('确定删除该项目经历？').then(async()=>{ await studentApi.delProject(id); await load(); ElMessage.success('已删除') })
const delExperience = (id) => ElMessageBox.confirm('确定删除该经历？').then(async()=>{ await studentApi.delExperience(id); await load(); ElMessage.success('已删除') })
onMounted(load)
</script>

<style scoped lang="scss">
.header { display:flex; justify-content:space-between; align-items:center; h2{margin-bottom:6px;} p{color:#909399;} }
.tips ul { padding-left: 18px; li { list-style: disc; color:#606266; line-height:1.9; } }
:deep(.section-head){display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;h3{border-left:3px solid #409eff;padding-left:10px;color:#303133;}}
:deep(.section-item){display:flex;justify-content:space-between;padding:14px;border:1px solid #ebeef5;border-radius:6px;margin-bottom:10px;background:#fafafa;}
:deep(.item-title){font-weight:600;color:#303133;margin-bottom:4px;}
:deep(.item-time){color:#909399;font-size:12px;margin-bottom:6px;}
:deep(.item-desc){color:#606266;line-height:1.6;white-space:pre-line;}
:deep(.empty-line){color:#909399;text-align:center;padding:24px;}
</style>
