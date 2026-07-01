<template>
  <div class="page-container resume-page">
    <el-row class="resume-layout" :gutter="16">
      <el-col class="resume-main-col" :span="17">
        <div class="page-card resume-main-card">
          <div class="header">
            <div>
              <h2>在线简历</h2>
              <p>建议完整填写基本信息、教育经历、项目/实习经历，提升简历通过率</p>
            </div>
            <div class="header-actions">
              <el-button :icon="View" @click="previewVisible = true">在线预览完整版</el-button>
              <el-button type="primary" plain :icon="Download" @click="printResume">下载PDF</el-button>
              <el-progress type="circle" :percentage="resume.completeRate || 0" :width="72" />
            </div>
          </div>
          <el-divider />

          <el-form :model="resume" label-width="100px">
            <el-row :gutter="16">
              <el-col :span="12"><el-form-item label="姓名"><el-input v-model="resume.name" /></el-form-item></el-col>
              <el-col :span="12"><el-form-item label="性别"><el-radio-group v-model="resume.gender"><el-radio :value="1">男</el-radio><el-radio :value="2">女</el-radio><el-radio :value="0">保密</el-radio></el-radio-group></el-form-item></el-col>
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
      <el-col class="resume-side-col" :span="7">
        <div class="page-card tips resume-tips">
          <div class="tips-head">
            <div>
              <h3>简历优化建议</h3>
              <p>按企业筛选习惯补齐关键内容</p>
            </div>
            <strong>{{ resume.completeRate || 0 }}%</strong>
          </div>
          <el-progress :percentage="resume.completeRate || 0" :stroke-width="10" />

          <div class="tips-status">
            <span>当前状态</span>
            <strong>{{ Number(resume.completeRate || 0) >= 80 ? '可以投递' : '继续完善' }}</strong>
            <p>{{ Number(resume.completeRate || 0) >= 80 ? '基础信息已经比较完整，下一步重点补项目成果、实习职责和岗位关键词。' : '建议先补齐联系方式、教育经历、项目经历和自我评价，再开始批量投递。' }}</p>
          </div>

          <div class="tip-block priority-block">
            <h4>优先补强</h4>
            <div class="priority-list">
              <div>
                <span>联系方式</span>
                <strong>{{ resume.phone && resume.email ? '已完整' : '需补齐' }}</strong>
              </div>
              <div>
                <span>项目经历</span>
                <strong>{{ projects.length ? `${projects.length} 项` : '待新增' }}</strong>
              </div>
              <div>
                <span>实习经历</span>
                <strong>{{ experiences.length ? `${experiences.length} 段` : '可补充' }}</strong>
              </div>
            </div>
          </div>

          <div class="tip-block">
            <h4>写法模板</h4>
            <ul class="tips-list">
              <li><strong>项目：</strong>背景 + 负责模块 + 技术方案 + 结果数据。</li>
              <li><strong>技能：</strong>把“熟悉”改成可证明的框架、工具和产出。</li>
              <li><strong>评价：</strong>少写空话，多写岗位匹配点和协作优势。</li>
            </ul>
          </div>

          <div class="tip-block check-block">
            <h4>投递前检查</h4>
            <div class="check-grid">
              <span>电话可联系</span>
              <span>邮箱可联系</span>
              <span>经历有时间</span>
              <span>描述有结果</span>
            </div>
          </div>
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

    <el-dialog v-model="previewVisible" title="在线简历预览" width="760px" class="resume-preview-dialog">
      <div class="resume-preview">
        <div class="preview-head">
          <h1>{{ resume.name || '未填写姓名' }}</h1>
          <p>{{ resume.education || '学历未填' }} · {{ resume.college || '学院未填' }} · {{ resume.major || '专业未填' }}</p>
          <p>{{ resume.phone || '电话未填' }} ｜ {{ resume.email || '邮箱未填' }} ｜ {{ genderLabel(resume.gender) }} ｜ {{ resume.birth || '出生年月未填' }}</p>
        </div>
        <PreviewSection title="自我评价" :items="[resume.selfEval]" />
        <PreviewSection title="技能证书" :items="[resume.skillCert]" />
        <PreviewSection title="获奖经历" :items="[resume.award]" />
        <PreviewSection title="教育经历" :items="educations" type="education" />
        <PreviewSection title="项目经历" :items="projects" type="project" />
        <PreviewSection title="实习/工作经历" :items="experiences" type="experience" />
      </div>
      <template #footer>
        <el-button @click="previewVisible = false">关闭</el-button>
        <el-button type="primary" :icon="Download" @click="printResume">下载PDF</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, defineComponent, h, onMounted } from 'vue'
import { ElMessage, ElMessageBox, ElButton, ElTag } from 'element-plus'
import { Download, View } from '@element-plus/icons-vue'
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

const PreviewSection = defineComponent({
  props: { title: String, items: Array, type: String },
  setup(props) {
    const renderLine = (item) => {
      if (!props.type) return item || '暂无'
      const title = props.type === 'education'
        ? `${item.school || ''} ${item.major || ''} ${item.degree || ''}`.trim()
        : props.type === 'project'
          ? `${item.projectName || ''}${item.role ? ` · ${item.role}` : ''}`
          : `${item.company || ''}${item.position ? ` · ${item.position}` : ''}`
      return h('div', { class: 'preview-item' }, [
        h('div', { class: 'preview-item-title' }, title || '未填写标题'),
        h('div', { class: 'preview-item-time' }, `${item.startDate || ''} - ${item.endDate || ''}`),
        h('p', item.description || '暂无描述')
      ])
    }
    return () => h('section', { class: 'preview-section' }, [
      h('h2', props.title),
      props.items?.some(i => props.type ? true : !!i)
        ? props.items.filter(i => props.type ? true : !!i).map(renderLine)
        : h('p', { class: 'preview-empty' }, '暂无')
    ])
  }
})

const saving = ref(false)
const resume = reactive({ gender: 0, completeRate: 0, isPublic: 1 })
const educations = ref([]), projects = ref([]), experiences = ref([])
const dialog = ref(false), editType = ref('education')
const previewVisible = ref(false)
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
const genderLabel = (gender) => Number(gender) === 1 ? '男' : Number(gender) === 2 ? '女' : '保密'
const escapeHtml = (value) => String(value || '').replace(/[&<>"']/g, s => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[s]))
const paragraph = (value) => escapeHtml(value || '暂无').replace(/\n/g, '<br>')
const sectionHtml = (title, body) => `<section><h2>${title}</h2>${body}</section>`
const listHtml = (items, type) => {
  if (!items.length) return '<p class="empty">暂无</p>'
  return items.map(item => {
    const name = type === 'education'
      ? `${item.school || ''} ${item.major || ''} ${item.degree || ''}`.trim()
      : type === 'project'
        ? `${item.projectName || ''}${item.role ? ` · ${item.role}` : ''}`
        : `${item.company || ''}${item.position ? ` · ${item.position}` : ''}`
    return `<div class="item"><h3>${escapeHtml(name || '未填写标题')}</h3><div>${escapeHtml(item.startDate || '')} - ${escapeHtml(item.endDate || '')}</div><p>${paragraph(item.description)}</p></div>`
  }).join('')
}
const printResume = () => {
  const win = window.open('', '_blank')
  if (!win) { ElMessage.warning('浏览器阻止了打印窗口，请允许弹窗后重试'); return }
  const html = `<!doctype html><html><head><meta charset="utf-8"><title>${escapeHtml(resume.name || '在线简历')}</title><style>
    body{font-family:Arial,"Microsoft YaHei",sans-serif;color:#1f2937;margin:0;background:#f3f6fb;}
    .paper{width:760px;margin:24px auto;padding:40px 48px;background:#fff;box-shadow:0 8px 28px rgba(15,23,42,.12);}
    h1{margin:0 0 10px;font-size:30px;} .meta{color:#64748b;line-height:1.8;margin:0;}
    section{margin-top:24px;} h2{font-size:17px;border-left:4px solid #2563eb;padding-left:10px;margin:0 0 12px;}
    .item{padding:12px 0;border-bottom:1px solid #e5e7eb;} .item:last-child{border-bottom:0;}
    h3{font-size:15px;margin:0 0 6px;} .item div,.empty{color:#64748b;font-size:13px;} p{line-height:1.8;white-space:normal;margin:6px 0 0;}
    @media print{body{background:#fff}.paper{width:auto;margin:0;padding:0;box-shadow:none}}
  </style></head><body><main class="paper">
    <h1>${escapeHtml(resume.name || '未填写姓名')}</h1>
    <p class="meta">${escapeHtml(resume.education || '学历未填')} · ${escapeHtml(resume.college || '学院未填')} · ${escapeHtml(resume.major || '专业未填')}</p>
    <p class="meta">${escapeHtml(resume.phone || '电话未填')} ｜ ${escapeHtml(resume.email || '邮箱未填')} ｜ ${escapeHtml(genderLabel(resume.gender))} ｜ ${escapeHtml(resume.birth || '出生年月未填')}</p>
    ${sectionHtml('自我评价', `<p>${paragraph(resume.selfEval)}</p>`)}
    ${sectionHtml('技能证书', `<p>${paragraph(resume.skillCert)}</p>`)}
    ${sectionHtml('获奖经历', `<p>${paragraph(resume.award)}</p>`)}
    ${sectionHtml('教育经历', listHtml(educations.value, 'education'))}
    ${sectionHtml('项目经历', listHtml(projects.value, 'project'))}
    ${sectionHtml('实习/工作经历', listHtml(experiences.value, 'experience'))}
  </main><script>window.onload=function(){window.print()}<\/script></body></html>`
  win.document.write(html)
  win.document.close()
}
onMounted(load)
</script>

<style scoped lang="scss">
.header { display:flex; justify-content:space-between; align-items:center; gap:1rem; h2{margin-bottom:6px;} p{color:var(--cr-text-muted);} }
.header-actions { display:flex; align-items:center; gap:.75rem; flex-wrap:wrap; justify-content:flex-end; }
.resume-page {
  width: min(150rem, calc(100% - clamp(1rem, 3vw, 3rem)));
  padding: clamp(.75rem, 1.2vw, 1.25rem);
}
.resume-layout {
  align-items: flex-start;
}
.resume-main-card {
  min-height: clamp(47rem, calc(100dvh - 11.5rem), 56rem);
  padding: clamp(1.5rem, 1.7vw, 2rem);
}
.resume-main-card .header h2 {
  font-size: clamp(1.8rem, 1.55vw, 2.25rem);
  line-height: 1.25;
}
.resume-main-card .header p {
  margin-top: .45rem;
  font-size: clamp(1.0625rem, .96vw, 1.25rem);
  line-height: 1.65;
}
.resume-main-card :deep(.el-divider--horizontal) {
  margin: 1.5rem 0;
}
.resume-main-card :deep(.el-form-item) {
  margin-bottom: 1.35rem;
}
.resume-main-card :deep(.el-form-item__label) {
  height: 3.375rem;
  align-items: center;
  color: var(--cr-text-soft);
  font-size: 1.0625rem;
  font-weight: 700;
  line-height: 1.35;
}
.resume-main-card :deep(.el-input__wrapper) {
  min-height: 3.375rem;
  padding: 0 1.125rem;
}
.resume-main-card :deep(.el-input__inner),
.resume-main-card :deep(.el-radio__label),
.resume-main-card :deep(.el-textarea__inner) {
  font-size: 1.0625rem;
}
.resume-main-card :deep(.el-textarea__inner) {
  padding: 1rem 1.125rem;
  line-height: 1.7;
}
.resume-main-card :deep(.el-radio) {
  height: 3.375rem;
  margin-right: 1.5rem;
}
.resume-main-card :deep(.el-button) {
  min-height: 3rem;
  padding: 0 1.25rem;
  font-size: 1.0625rem;
}
.resume-side-col {
  display: flex;
}
.resume-tips {
  position: sticky;
  top: 20px;
  width: 100%;
  min-height: clamp(700px, calc(100dvh - 190px), 920px);
  padding: 28px;
}
.tips-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 16px;

  h3 {
    margin-bottom: 6px;
    color: var(--cr-text);
    font-size: 22px;
  }

  p {
    color: var(--cr-text-muted);
    font-size: 15px;
    line-height: 1.6;
  }

  strong {
    min-width: 72px;
    padding: 10px 12px;
    border-radius: 999px;
    background: var(--cr-primary-soft);
    color: var(--cr-primary);
    font-size: 20px;
    text-align: center;
  }
}
.tips-status {
  margin-top: 18px;
  padding: 18px;
  border: 1px solid rgba(37, 99, 235, 0.16);
  border-radius: 10px;
  background: linear-gradient(135deg, rgba(37, 99, 235, 0.08), rgba(8, 145, 178, 0.08));

  span {
    display: block;
    margin-bottom: 8px;
    color: var(--cr-text-muted);
    font-size: 14px;
    font-weight: 700;
  }

  strong {
    display: block;
    margin-bottom: 8px;
    color: var(--cr-text);
    font-size: 22px;
  }

  p {
    color: var(--cr-text-soft);
    font-size: 15px;
    line-height: 1.8;
  }
}
.tip-block {
  margin-top: 22px;
  padding-top: 20px;
  border-top: 1px solid var(--cr-border-soft);

  h4 {
    margin-bottom: 14px;
    color: var(--cr-text);
    font-size: 18px;
  }
}
.priority-list {
  display: grid;
  gap: 12px;

  div {
    min-width: 0;
    padding: 16px 18px;
    border: 1px solid var(--cr-border-soft);
    border-radius: 10px;
    background: var(--cr-surface-soft);
  }

  span {
    display: block;
    margin-bottom: 6px;
    color: var(--cr-text-muted);
    font-size: 14px;
  }

  strong {
    color: var(--cr-text);
    font-size: 18px;
  }
}
.tips-list {
  display: grid;
  gap: 12px;
  padding-left: 0;

  li {
    list-style: none;
    color: var(--cr-text-soft);
    line-height: 1.85;
    font-size: 15px;
  }

  strong {
    color: var(--cr-text);
  }
}
.check-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;

  span {
    min-width: 0;
    padding: 12px 10px;
    text-align: center;
    border: 1px solid var(--cr-border-soft);
    border-radius: 10px;
    background: #fff;
    color: var(--cr-primary);
    font-size: 14px;
    font-weight: 700;
  }
}
:deep(.resume-section) {
  padding: clamp(1.25rem, 1.5vw, 1.75rem);
}
:deep(.section-head){display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;h3{border-left:3px solid var(--cr-primary);padding-left:.75rem;color:var(--cr-text);font-size:1.375rem;line-height:1.35;}}
:deep(.section-head .el-button){min-height:2.5rem;padding:0 1rem;font-size:1rem;}
:deep(.section-item){display:flex;justify-content:space-between;gap:1rem;padding:1rem 1.125rem;border:1px solid var(--cr-border-soft);border-radius:.625rem;margin-bottom:.75rem;background:#fafafa;}
:deep(.item-title){font-size:1.0625rem;font-weight:700;color:var(--cr-text);margin-bottom:.375rem;}
:deep(.item-time){color:var(--cr-text-muted);font-size:.9375rem;margin-bottom:.375rem;}
:deep(.item-desc){color:var(--cr-text-soft);font-size:1rem;line-height:1.7;white-space:pre-line;}
:deep(.empty-line){color:var(--cr-text-muted);text-align:center;padding:2rem;font-size:1rem;}
.resume-preview { color:var(--cr-text); }
.preview-head { text-align:center; border-bottom:1px solid var(--cr-border-soft); padding-bottom:1rem; margin-bottom:1rem;
  h1{font-size:1.75rem;margin-bottom:.5rem;} p{color:var(--cr-text-muted);line-height:1.8;}
}
:deep(.preview-section){margin-top:1rem;h2{font-size:1rem;border-left:3px solid var(--cr-primary);padding-left:.625rem;margin-bottom:.75rem;}}
:deep(.preview-item){padding:.75rem 0;border-bottom:1px solid var(--cr-border-soft);p{white-space:pre-line;line-height:1.75;color:var(--cr-text-soft);}}
:deep(.preview-item:last-child){border-bottom:0;}
:deep(.preview-item-title){font-weight:650;color:var(--cr-text);margin-bottom:.25rem;}
:deep(.preview-item-time),:deep(.preview-empty){color:var(--cr-text-muted);font-size:.8125rem;}
@media (max-width:48rem){
  .resume-page {
    width: calc(100% - 1rem);
    padding: 0;
  }

  .resume-layout {
    margin-left: 0 !important;
    margin-right: 0 !important;
  }

  .resume-main-col,
  .resume-side-col {
    flex: 0 0 100%;
    max-width: 100%;
    padding-left: 0 !important;
    padding-right: 0 !important;
  }

  .header {
    align-items: flex-start;
    flex-direction: column;
  }

  .header-actions {
    width: 100%;
    justify-content: flex-start;
  }

  .header-actions :deep(.el-button) {
    flex: 1 1 10rem;
    margin-left: 0;
  }

  .header-actions :deep(.el-progress) {
    margin-left: auto;
  }

  .resume-main-card {
    min-height: 0;
    padding: 1rem;
  }

  .resume-main-card :deep(.el-form-item__label) {
    height: auto;
    font-size: 0.9375rem;
  }

  .resume-main-card :deep(.el-radio-group) {
    align-items: center;
  }

  .resume-main-card :deep(.el-radio) {
    height: auto;
    min-height: 2.25rem;
  }

  .resume-tips {
    position: static;
    min-height: 0;
    margin-top: 1rem;
    padding: 1rem;
  }

  :deep(.section-item) {
    flex-direction: column;
  }

  :deep(.section-item > div:last-child) {
    display: flex;
    flex-wrap: wrap;
  }
}
</style>

