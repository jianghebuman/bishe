<template>
  <div class="job-list portal-content">
    <!-- 顶部搜索条 -->
    <div class="search-bar page-card">
      <el-input v-model="query.keyword" placeholder="搜索岗位名称、关键技能" size="large" clearable @keyup.enter="onSearch" style="flex: 1; margin-right: 12px;">
        <template #prefix><el-icon><Search /></el-icon></template>
      </el-input>
      <el-button type="primary" size="large" @click="onSearch">搜索职位</el-button>
    </div>

    <!-- 筛选区 -->
    <div class="filter page-card mt-20">
      <div class="filter-row">
        <span class="label">城市：</span>
        <div class="options">
          <span class="opt" :class="{ active: !query.city }" @click="setFilter('city', '')">全部</span>
          <span class="opt" v-for="c in cities" :key="c.dictValue" :class="{ active: query.city === c.dictValue }" @click="setFilter('city', c.dictValue)">{{ c.dictLabel }}</span>
        </div>
      </div>
      <div class="filter-row">
        <span class="label">岗位类别：</span>
        <div class="options">
          <span class="opt" :class="{ active: !query.categoryId }" @click="setFilter('categoryId', '')">全部</span>
          <span class="opt" v-for="c in categories" :key="c.id" :class="{ active: query.categoryId === c.id }" @click="setFilter('categoryId', c.id)">{{ c.name }}</span>
        </div>
      </div>
      <div class="filter-row">
        <span class="label">学历要求：</span>
        <div class="options">
          <span class="opt" :class="{ active: !query.education }" @click="setFilter('education', '')">不限</span>
          <span class="opt" v-for="e in educations" :key="e.dictValue" :class="{ active: query.education === e.dictValue }" @click="setFilter('education', e.dictValue)">{{ e.dictLabel }}</span>
        </div>
      </div>
      <div class="filter-row">
        <span class="label">工作性质：</span>
        <div class="options">
          <span class="opt" :class="{ active: !query.jobType }" @click="setFilter('jobType', '')">不限</span>
          <span class="opt" :class="{ active: query.jobType === 1 }" @click="setFilter('jobType', 1)">全职</span>
          <span class="opt" :class="{ active: query.jobType === 2 }" @click="setFilter('jobType', 2)">实习</span>
        </div>
      </div>
      <div class="filter-row">
        <span class="label">薪资范围：</span>
        <div class="options">
          <span class="opt" :class="{ active: !query.salaryMin }" @click="setFilter('salaryMin', '')">不限</span>
          <span class="opt" :class="{ active: query.salaryMin === 5 }" @click="setFilter('salaryMin', 5)">5K以上</span>
          <span class="opt" :class="{ active: query.salaryMin === 10 }" @click="setFilter('salaryMin', 10)">10K以上</span>
          <span class="opt" :class="{ active: query.salaryMin === 15 }" @click="setFilter('salaryMin', 15)">15K以上</span>
          <span class="opt" :class="{ active: query.salaryMin === 20 }" @click="setFilter('salaryMin', 20)">20K以上</span>
        </div>
      </div>
    </div>

    <!-- 结果统计 -->
    <div class="result-info">共找到 <b>{{ total }}</b> 个职位</div>

    <!-- 职位列表 -->
    <div class="job-list-wrap" v-loading="loading">
      <div class="job-row" v-for="j in jobs" :key="j.id" @click="$router.push(`/job/${j.id}`)">
        <div class="job-main">
          <div class="job-head">
            <span class="title">{{ j.title }}</span>
            <span class="salary">{{ j.salaryMin }}-{{ j.salaryMax }}K</span>
          </div>
          <div class="job-meta">
            <span><el-icon><Location /></el-icon> {{ j.city || '不限' }}</span>
            <span><el-icon><User /></el-icon> {{ j.education || '不限学历' }}</span>
            <span><el-icon><Briefcase /></el-icon> {{ j.jobType === 1 ? '全职' : '实习' }}</span>
            <span v-if="j.recruitNum">招聘 {{ j.recruitNum }} 人</span>
          </div>
          <div class="job-tags" v-if="j.welfare">
            <el-tag v-for="w in j.welfare.split(',').slice(0, 5)" :key="w" size="small" type="info" effect="plain">{{ w }}</el-tag>
          </div>
        </div>
        <div class="job-side">
          <div class="company">{{ j.companyName || '名企招聘' }}</div>
          <div class="publish">发布于 {{ relativeTime(j.publishTime) }}</div>
        </div>
      </div>
      <el-empty v-if="!loading && jobs.length === 0" description="暂无符合条件的职位" />
    </div>

    <!-- 分页 -->
    <div class="pagination-wrap">
      <el-pagination
        v-model:current-page="query.pageNum"
        v-model:page-size="query.pageSize"
        :total="total"
        layout="total, prev, pager, next, jumper"
        background
        @current-change="loadList"
      />
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { Search, Location, User, Briefcase } from '@element-plus/icons-vue'
import { publicApi } from '@/api'

const route = useRoute()
const query = reactive({ pageNum: 1, pageSize: 10, keyword: '', city: '', categoryId: '', education: '', jobType: '', salaryMin: '' })
const jobs = ref([])
const total = ref(0)
const loading = ref(false)
const cities = ref([])
const categories = ref([])
const educations = ref([])

const setFilter = (key, value) => {
  query[key] = value
  query.pageNum = 1
  loadList()
}

const onSearch = () => { query.pageNum = 1; loadList() }

const relativeTime = (dt) => {
  if (!dt) return ''
  const d = new Date(dt.replace(' ', 'T'))
  const diff = Date.now() - d.getTime()
  const day = Math.floor(diff / 86400000)
  if (day === 0) return '今天'
  if (day === 1) return '昨天'
  if (day < 30) return `${day}天前`
  return d.toLocaleDateString()
}

const loadList = async () => {
  loading.value = true
  try {
    const params = {}
    Object.keys(query).forEach(k => { if (query[k] !== '' && query[k] != null) params[k] = query[k] })
    const res = await publicApi.jobs(params)
    jobs.value = res.data.records
    total.value = Number(res.data.total)
  } finally { loading.value = false }
}

onMounted(async () => {
  // 接受首页传过来的 keyword/city
  if (route.query.keyword) query.keyword = route.query.keyword
  if (route.query.city) query.city = route.query.city
  try {
    const [city, cat, edu] = await Promise.all([publicApi.dict('city'), publicApi.jobCategories(), publicApi.dict('education')])
    cities.value = city.data
    categories.value = cat.data
    educations.value = edu.data
  } catch (e) {}
  loadList()
})

watch(() => route.query, (nv) => {
  if (nv.keyword !== undefined || nv.city !== undefined) {
    query.keyword = nv.keyword || ''
    query.city = nv.city || ''
    query.pageNum = 1
    loadList()
  }
})
</script>

<style scoped lang="scss">
.search-bar { display: flex; align-items: center; }
.filter-row { display: flex; padding: 8px 0; border-bottom: 1px dashed #ebeef5;
  &:last-child { border-bottom: none; }
  .label { width: 80px; color: #909399; flex-shrink: 0; padding-top: 6px; }
  .options { flex: 1; display: flex; flex-wrap: wrap; gap: 8px; }
  .opt { padding: 6px 14px; border-radius: 4px; cursor: pointer; font-size: 14px; color: #606266;
    &:hover { color: #409eff; }
    &.active { background: #409eff; color: #fff; }
  }
}
.result-info { margin: 20px 0 10px; color: #606266; font-size: 14px; b { color: #f56c6c; margin: 0 4px; } }
.job-row { background: #fff; border-radius: 6px; padding: 20px; margin-bottom: 12px; display: flex; cursor: pointer; transition: all .2s;
  &:hover { box-shadow: 0 4px 16px rgba(0,0,0,.1); transform: translateY(-1px); }
  .job-main { flex: 1; }
  .job-head { display: flex; align-items: center; justify-content: space-between; margin-bottom: 10px;
    .title { font-size: 17px; font-weight: 600; color: #303133; }
    .salary { color: #f56c6c; font-size: 17px; font-weight: 600; }
  }
  .job-meta { display: flex; gap: 16px; color: #909399; font-size: 13px; margin-bottom: 10px;
    .el-icon { vertical-align: middle; }
  }
  .job-tags { display: flex; gap: 6px; flex-wrap: wrap; }
  .job-side { width: 220px; padding-left: 20px; border-left: 1px solid #f0f0f0; text-align: right;
    .company { font-size: 14px; color: #303133; margin-bottom: 8px; }
    .publish { color: #c0c4cc; font-size: 12px; }
  }
}
</style>
