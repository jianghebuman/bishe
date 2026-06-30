<template>
  <div class="page-container student-screen-page intention-page">
    <div class="page-card student-screen-card intention-card">
      <div class="header">
        <h2>求职意向</h2>
        <p>用于系统为你推荐更匹配的岗位，也方便企业了解你的目标方向</p>
      </div>
      <el-divider />
      <div class="intention-body">
        <el-form :model="form" label-width="110px" class="form">
          <el-form-item label="期望岗位"><el-input v-model="form.expectPost" placeholder="如 Java开发工程师 / 产品经理" /></el-form-item>
          <el-form-item label="期望城市"><el-select v-model="form.expectCity" filterable allow-create default-first-option style="width:100%"><el-option v-for="c in cities" :key="c.dictValue" :label="c.dictLabel" :value="c.dictValue" /></el-select></el-form-item>
          <el-form-item label="期望薪资"><el-input v-model="form.expectSalary" placeholder="如 12-18K / 面议" /></el-form-item>
          <el-form-item label="求职类型"><el-radio-group v-model="form.jobType"><el-radio :label="1">全职</el-radio><el-radio :label="2">实习</el-radio></el-radio-group></el-form-item>
          <el-form-item label="到岗时间"><el-select v-model="form.arrivalTime" style="width:100%"><el-option label="随时到岗" value="随时到岗"/><el-option label="一周内" value="一周内"/><el-option label="一个月内" value="一个月内"/><el-option label="毕业后到岗" value="毕业后到岗"/></el-select></el-form-item>
          <el-form-item class="form-actions">
            <el-button type="primary" :loading="saving" @click="save">保存意向</el-button>
            <el-button @click="searchByIntention">按意向搜索岗位</el-button>
          </el-form-item>
        </el-form>
        <div class="intention-summary">
          <h3>当前方向</h3>
          <div class="summary-grid">
            <div><span>岗位</span><strong>{{ form.expectPost || '待填写' }}</strong></div>
            <div><span>城市</span><strong>{{ form.expectCity || '待填写' }}</strong></div>
            <div><span>薪资</span><strong>{{ form.expectSalary || '待填写' }}</strong></div>
            <div><span>类型</span><strong>{{ form.jobType === 2 ? '实习' : '全职' }}</strong></div>
            <div><span>到岗</span><strong>{{ form.arrivalTime || '待填写' }}</strong></div>
          </div>
          <div class="match-panel">
            <h4>推荐依据</h4>
            <p>保存后，岗位搜索会优先带入岗位、城市、类型和薪资区间，减少重复筛选。</p>
            <div class="match-steps">
              <span>方向</span>
              <span>城市</span>
              <span>薪资</span>
              <span>到岗</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { studentApi, publicApi } from '@/api'

const router = useRouter()
const saving = ref(false)
const cities = ref([])
const form = reactive({ expectPost: '', expectCity: '', expectSalary: '', jobType: 1, arrivalTime: '毕业后到岗' })
const load = async () => {
  const [i, c] = await Promise.all([studentApi.getIntention().catch(() => ({ data: null })), publicApi.dict('city')])
  Object.assign(form, i.data || {})
  cities.value = c.data || []
}
const save = async () => { saving.value = true; try { await studentApi.saveIntention(form); ElMessage.success('求职意向已保存') } finally { saving.value = false } }
const salaryPart = (text, index) => {
  const values = String(text || '').match(/\d+(?:\.\d+)?/g) || []
  return values[index] == null ? undefined : Number(values[index])
}
const searchByIntention = () => {
  const query = { intent: '1' }
  if (form.expectPost?.trim()) query.keyword = form.expectPost.trim()
  if (form.expectCity?.trim()) query.city = form.expectCity.trim()
  if (form.jobType) query.jobType = String(form.jobType)
  const min = salaryPart(form.expectSalary, 0)
  const max = salaryPart(form.expectSalary, 1)
  if (min != null) query.salaryMin = String(min)
  if (max != null) query.salaryMax = String(max)
  router.push({ path: '/jobs', query })
}
onMounted(load)
</script>

<style scoped lang="scss">
.header h2 { margin-bottom: 6px; } .header p { color: #909399; }
.intention-card {
  padding: clamp(24px, 2vw, 34px);
  min-height: min(52rem, calc(100dvh - 8rem));
  display: flex;
  flex-direction: column;
}
.intention-body {
  flex: 1;
  min-height: 0;
  display: grid;
  grid-template-columns: minmax(38rem, 50rem) minmax(22rem, 1fr);
  gap: clamp(28px, 4vw, 72px);
  align-items: stretch;
}
.form {
  width: 100%;
  align-self: center;
}
.intention-summary {
  width: 100%;
  align-self: center;
  padding: clamp(20px, 2vw, 28px);
  display: flex;
  flex-direction: column;
  border-radius: 8px;
  background: linear-gradient(180deg, #f8fbff 0%, #eef6ff 100%);
  border: 1px solid var(--cr-border-soft);
}
.intention-summary h3 {
  margin-bottom: 18px;
  color: var(--cr-text);
  font-size: 17px;
}
.summary-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
}
.summary-grid div {
  min-height: 86px;
  padding: 16px;
  border-radius: 8px;
  background: #fff;
  border: 1px solid var(--cr-border-soft);
}
.summary-grid span {
  display: block;
  margin-bottom: 8px;
  color: var(--cr-text-muted);
  font-size: 12px;
}
.summary-grid strong {
  color: var(--cr-text);
  font-size: 15px;
  line-height: 1.4;
  word-break: break-word;
}
.match-panel {
  margin-top: 24px;
  padding-top: 22px;
  border-top: 1px solid var(--cr-border-soft);
}
.match-panel h4 {
  margin-bottom: 10px;
  color: var(--cr-text);
  font-size: 15px;
}
.match-panel p {
  color: var(--cr-text-soft);
  font-size: 13px;
  line-height: 1.7;
}
.match-steps {
  margin-top: 16px;
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 10px;
}
.match-steps span {
  min-width: 0;
  padding: 12px 10px;
  text-align: center;
  border-radius: 8px;
  background: #fff;
  border: 1px solid var(--cr-border-soft);
  color: var(--cr-primary);
  font-size: 13px;
  font-weight: 700;
}
@media (max-width: 1180px) {
  .intention-body {
    grid-template-columns: 1fr;
  }
}
@media (max-width: 640px) {
  .summary-grid {
    grid-template-columns: 1fr;
  }

  .match-steps {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}
</style>
