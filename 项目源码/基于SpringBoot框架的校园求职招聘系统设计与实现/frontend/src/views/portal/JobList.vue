<template>
  <div class="job-list portal-content">
    <!-- 顶部搜索条 -->
    <form class="search-bar page-card" @submit.prevent="onSearch">
      <el-input v-model="query.keyword" placeholder="搜索岗位名称、关键技能" size="large" clearable class="search-input">
        <template #prefix><el-icon><Search /></el-icon></template>
      </el-input>
      <el-button type="primary" size="large" native-type="submit">搜索职位</el-button>
    </form>

    <!-- 筛选区 -->
    <div class="filter page-card mt-20">
      <div class="filter-row">
        <span class="label">城市：</span>
        <div class="options">
          <span class="opt" :class="{ active: isEmptyFilter('city') }" @click="setFilter('city', '')">全部</span>
          <span class="opt" v-for="c in cities" :key="c.dictValue" :class="{ active: hasFilter('city', c.dictValue) }" @click="setFilter('city', c.dictValue)">{{ c.dictLabel }}</span>
        </div>
      </div>
      <div class="filter-row">
        <span class="label">岗位类别：</span>
        <div class="options">
          <span class="opt" :class="{ active: isEmptyFilter('categoryId') }" @click="setFilter('categoryId', '')">全部</span>
          <span class="opt" v-for="c in categories" :key="c.id" :class="{ active: hasFilter('categoryId', c.id) }" @click="setFilter('categoryId', c.id)">{{ c.name }}</span>
        </div>
      </div>
      <div class="filter-row">
        <span class="label">学历要求：</span>
        <div class="options">
          <span class="opt" :class="{ active: isEmptyFilter('education') }" @click="setFilter('education', '')">不限</span>
          <span class="opt" v-for="e in educations" :key="e.dictValue" :class="{ active: hasFilter('education', e.dictValue) }" @click="setFilter('education', e.dictValue)">{{ e.dictLabel }}</span>
        </div>
      </div>
      <div class="filter-row">
        <span class="label">工作性质：</span>
        <div class="options">
          <span class="opt" :class="{ active: isEmptyFilter('jobType') }" @click="setFilter('jobType', '')">不限</span>
          <span class="opt" :class="{ active: hasFilter('jobType', 1) }" @click="setFilter('jobType', 1)">全职</span>
          <span class="opt" :class="{ active: hasFilter('jobType', 2) }" @click="setFilter('jobType', 2)">实习</span>
        </div>
      </div>
      <div class="filter-row">
        <span class="label">薪资范围：</span>
        <div class="options">
          <span class="opt" :class="{ active: isEmptyFilter('salaryMin') }" @click="setFilter('salaryMin', '')">不限</span>
          <span class="opt" :class="{ active: hasFilter('salaryMin', 5) }" @click="setFilter('salaryMin', 5)">5K以上</span>
          <span class="opt" :class="{ active: hasFilter('salaryMin', 10) }" @click="setFilter('salaryMin', 10)">10K以上</span>
          <span class="opt" :class="{ active: hasFilter('salaryMin', 15) }" @click="setFilter('salaryMin', 15)">15K以上</span>
          <span class="opt" :class="{ active: hasFilter('salaryMin', 20) }" @click="setFilter('salaryMin', 20)">20K以上</span>
        </div>
      </div>
    </div>

    <!-- 结果统计 -->
    <div class="result-info">
      <template v-if="recommended">暂无完全匹配，已推荐 <b>{{ total }}</b> 个相近职位</template>
      <template v-else>共找到 <b>{{ total }}</b> 个职位</template>
    </div>

    <!-- 职位列表 -->
    <div class="page-card page-flex-card portal-list-card mt-20">
      <div class="page-flex-scroll job-scroll">
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
      </div>
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
  </div>
</template>

<script setup>
import { reactive, ref, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { Search, Location, User, Briefcase } from '@element-plus/icons-vue'
import { publicApi } from '@/api'

const route = useRoute()
const query = reactive({ pageNum: 1, pageSize: 3, keyword: '', city: [], categoryId: [], education: [], jobType: [], salaryMin: [], salaryMax: '' })
const jobs = ref([])
const total = ref(0)
const recommended = ref(false)
const loading = ref(false)
const cities = ref([])
const categories = ref([])
const educations = ref([])

const listKeys = ['city', 'categoryId', 'education', 'jobType', 'salaryMin']
const toNumber = (value) => {
  const n = Number(value)
  return Number.isFinite(n) ? n : undefined
}
const toList = (value, mapper = v => v) => {
  if (value == null || value === '') return []
  const text = Array.isArray(value) ? value.join(',') : String(value)
  return text.split(/[,\uFF0C]/).map(v => mapper(v.trim())).filter(v => v !== '' && v != null)
}
const sameValue = (a, b) => String(a) === String(b)
const isEmptyFilter = (key) => query[key].length === 0
const hasFilter = (key, value) => query[key].some(v => sameValue(v, value))
const setFilter = (key, value) => {
  if (key === 'salaryMin') query.salaryMax = ''
  if (value === '') {
    query[key] = []
  } else {
    const values = query[key]
    const index = values.findIndex(v => sameValue(v, value))
    if (index >= 0) values.splice(index, 1)
    else values.push(value)
  }
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
    Object.keys(query).forEach(k => {
      const value = query[k]
      if (Array.isArray(value)) {
        if (value.length) params[k] = value.join(',')
      } else if (value !== '' && value != null) {
        params[k] = value
      }
    })
    const res = await publicApi.jobs(params)
    jobs.value = res.data.records || []
    total.value = Number(res.data.total || 0)
    recommended.value = !!res.data.recommended
  } finally { loading.value = false }
}

const applyRouteQuery = (routeQuery) => {
  query.keyword = routeQuery.keyword || ''
  query.salaryMax = routeQuery.salaryMax || ''
  query.city = toList(routeQuery.city)
  query.categoryId = toList(routeQuery.categoryId, toNumber)
  query.education = toList(routeQuery.education)
  query.jobType = toList(routeQuery.jobType, toNumber)
  query.salaryMin = toList(routeQuery.salaryMin, toNumber)
  listKeys.forEach(k => { query[k] = Array.from(new Map(query[k].map(v => [String(v), v])).values()) })
}

onMounted(async () => {
  // 接受首页和求职意向传过来的筛选条件
  applyRouteQuery(route.query)
  try {
    const [city, cat, edu] = await Promise.all([publicApi.dict('city'), publicApi.jobCategories(), publicApi.dict('education')])
    cities.value = city.data
    categories.value = cat.data
    educations.value = edu.data
  } catch (e) {}
  loadList()
})

watch(() => route.query, (nv) => {
  applyRouteQuery(nv)
  query.pageNum = 1
  loadList()
})
</script>

<style scoped lang="scss">
.search-bar { display: grid; grid-template-columns: minmax(14rem, 1fr) auto; align-items: center; gap: clamp(.5rem, 1.2vw, .875rem); }
.search-input { min-width: 0; }
.portal-list-card { --portal-list-card-min-height: calc(100dvh - 41rem); }
.filter-row { display: grid; grid-template-columns: minmax(5.5rem, max-content) minmax(0, 1fr); gap: .75rem; padding: .5rem 0; border-bottom: 0.0625rem dashed var(--cr-border-soft);
  &:last-child { border-bottom: none; }
  .label { color: var(--cr-text-muted); padding-top: .375rem; font-weight: 650; }
  .options { min-width: 0; display: flex; flex-wrap: wrap; gap: .5rem; }
  .opt { padding: .375rem .875rem; border: 0.0625rem solid transparent; border-radius: 999rem; cursor: pointer; font-size: .875rem; color: var(--cr-text-soft); transition: all .2s ease;
    &:hover { color: var(--cr-primary); background: var(--cr-primary-soft); }
    &.active { background: var(--cr-primary); border-color: var(--cr-primary); color: #fff; box-shadow: 0 .5rem 1rem rgba(37,99,235,.14); }
  }
}
.result-info { margin: .875rem 0 .5rem; color: var(--cr-text-soft); font-size: .875rem; b { color: var(--cr-danger); margin: 0 .25rem; } }
.job-scroll { display: flex; flex-direction: column; }
.job-list-wrap { flex: 1; display: flex; flex-direction: column; gap: .5rem; }
.job-row { flex: 1; min-height: 5.5rem; background: rgba(255,255,255,.96); border: 0.0625rem solid var(--cr-border-soft); border-radius: var(--cr-radius); padding: clamp(.875rem, 1.2vw, 1rem); display: grid; align-items: center; grid-template-columns: minmax(0, 1fr) minmax(11.25rem, 0.28fr); gap: 1rem; cursor: pointer; transition: border-color .2s ease, box-shadow .2s ease, transform .2s ease;
  &:hover { border-color: rgba(37,99,235,.28); box-shadow: var(--cr-shadow); transform: translateY(-.0625rem); }
  .job-main { min-width: 0; }
  .job-head { display: flex; align-items: center; justify-content: space-between; margin-bottom: .625rem;
    .title { font-size: 1.0625rem; font-weight: 750; color: var(--cr-text); min-width: 0; }
    .salary { color: var(--cr-danger); font-size: 1.0625rem; font-weight: 750; margin-left: .75rem; white-space: nowrap; }
  }
  .job-meta { display: flex; gap: .625rem 1rem; flex-wrap: wrap; color: var(--cr-text-muted); font-size: .8125rem; margin-bottom: .625rem;
    .el-icon { vertical-align: middle; }
  }
  .job-tags { display: flex; gap: .375rem; flex-wrap: wrap; }
  .job-side { min-width: 0; padding-left: 1.125rem; border-left: 0.0625rem solid var(--cr-border-soft); text-align: right;
    .company { font-size: .875rem; color: var(--cr-text); margin-bottom: .5rem; font-weight: 650; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    .publish { color: var(--cr-text-muted); font-size: .75rem; }
  }
}

@media (max-width: 51.25rem) {
  .job-row { flex: 0 1 auto; }

  .job-row {
    grid-template-columns: 1fr;
  }

  .job-row .job-side {
    padding-left: 0;
    padding-top: .75rem;
    border-left: 0;
    border-top: 0.0625rem solid var(--cr-border-soft);
    text-align: left;
  }
}

@media (max-width: 40rem) {
  .search-bar {
    align-items: stretch;
    grid-template-columns: 1fr;
  }

  .search-bar :deep(.el-button) {
    width: 100%;
  }

  .filter-row {
    grid-template-columns: 1fr;
    gap: .5rem;
  }

  .filter-row .label {
    padding-top: 0;
  }

  .job-row .job-head {
    align-items: flex-start;
    flex-direction: column;
    gap: .375rem;
  }

  .job-row .job-head .salary {
    margin-left: 0;
  }
}
</style>
