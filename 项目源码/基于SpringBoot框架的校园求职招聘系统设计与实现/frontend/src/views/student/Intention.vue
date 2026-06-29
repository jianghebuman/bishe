<template>
  <div class="page-container">
    <div class="page-card">
      <div class="header">
        <h2>求职意向</h2>
        <p>用于系统为你推荐更匹配的岗位，也方便企业了解你的目标方向</p>
      </div>
      <el-divider />
      <el-form :model="form" label-width="110px" class="form">
        <el-form-item label="期望岗位"><el-input v-model="form.expectPost" placeholder="如 Java开发工程师 / 产品经理" /></el-form-item>
        <el-form-item label="期望城市"><el-select v-model="form.expectCity" filterable allow-create default-first-option style="width:100%"><el-option v-for="c in cities" :key="c.dictValue" :label="c.dictLabel" :value="c.dictValue" /></el-select></el-form-item>
        <el-form-item label="期望薪资"><el-input v-model="form.expectSalary" placeholder="如 12-18K / 面议" /></el-form-item>
        <el-form-item label="求职类型"><el-radio-group v-model="form.jobType"><el-radio :label="1">全职</el-radio><el-radio :label="2">实习</el-radio></el-radio-group></el-form-item>
        <el-form-item label="到岗时间"><el-select v-model="form.arrivalTime" style="width:100%"><el-option label="随时到岗" value="随时到岗"/><el-option label="一周内" value="一周内"/><el-option label="一个月内" value="一个月内"/><el-option label="毕业后到岗" value="毕业后到岗"/></el-select></el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="saving" @click="save">保存意向</el-button>
          <el-button @click="searchByIntention">按意向搜索岗位</el-button>
        </el-form-item>
      </el-form>
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
.form { width: 620px; }
</style>
