<template>
  <div class="portal-content">
    <div class="page-card head">
      <div>
        <h2>求职栏</h2>
        <p>查看同学发布的求职信息，企业可登录后发起沟通。</p>
      </div>
      <el-button type="primary" @click="publish">发布求职信息</el-button>
    </div>

    <div class="search-card page-card mt-20">
      <el-form inline>
        <el-form-item label="关键词">
          <el-input v-model="query.keyword" clearable placeholder="岗位/标题" @clear="reload" @input="reloadIfEmpty" @keyup.enter="reload" />
        </el-form-item>
        <el-form-item label="城市">
          <el-input v-model="query.city" clearable placeholder="期望城市" @clear="reload" @input="reloadIfEmpty" @keyup.enter="reload" />
        </el-form-item>
        <el-button type="primary" @click="reload">搜索</el-button>
        <el-button :type="showFilters ? 'primary' : 'default'" :icon="Filter" @click="showFilters = !showFilters">筛选</el-button>
        <el-button v-if="hasCondition" @click="clearAll">清空条件</el-button>
      </el-form>

      <div v-if="activeFilters.length" class="active-filters">
        <span class="active-label">已选</span>
        <el-tag v-for="item in activeFilters" :key="item.key" closable effect="plain" @close="removeFilter(item.key)">
          {{ item.label }}
        </el-tag>
      </div>

      <transition name="filter-drop">
        <div v-show="showFilters" class="filter-panel">
          <div class="filter-row">
            <span class="label">城市：</span>
            <div class="options">
              <span class="opt" :class="{ active: !query.city }" @click="setFilter('city', '')">全部</span>
              <span class="opt" v-for="c in cities" :key="c.dictValue" :class="{ active: query.city === c.dictValue }" @click="setFilter('city', c.dictValue)">{{ c.dictLabel }}</span>
            </div>
          </div>
          <div class="filter-row">
            <span class="label">求职方向：</span>
            <div class="options">
              <span class="opt" :class="{ active: !query.expectPost }" @click="setFilter('expectPost', '')">全部</span>
              <span class="opt" v-for="p in postTypes" :key="p.value" :class="{ active: query.expectPost === p.value }" @click="setFilter('expectPost', p.value)">{{ p.label }}</span>
            </div>
          </div>
          <div class="filter-row">
            <span class="label">学院：</span>
            <div class="options">
              <span class="opt" :class="{ active: !query.college }" @click="setFilter('college', '')">全部</span>
              <span class="opt" v-for="c in colleges" :key="c" :class="{ active: query.college === c }" @click="setFilter('college', c)">{{ c }}</span>
            </div>
          </div>
          <div class="filter-row">
            <span class="label">期望薪资：</span>
            <div class="options">
              <span class="opt" :class="{ active: !query.salaryMin }" @click="setFilter('salaryMin', '')">不限</span>
              <span class="opt" v-for="s in salaryOptions" :key="s.value" :class="{ active: query.salaryMin === s.value }" @click="setFilter('salaryMin', s.value)">{{ s.label }}</span>
            </div>
          </div>
        </div>
      </transition>
    </div>

    <div class="page-card page-flex-card portal-list-card mt-20">
      <div class="page-flex-scroll seeker-scroll">
        <div class="seeker-grid" v-loading="loading">
          <div class="seeker-card" v-for="item in list" :key="item.post.id" @click="$router.push(`/seeker/${item.post.id}`)">
            <div class="card-top">
              <el-avatar :src="item.student?.avatar"><el-icon><User /></el-icon></el-avatar>
              <div class="student-info">
                <h3>{{ item.post.title }}</h3>
                <p>{{ item.student?.realName || '求职者' }} · {{ item.student?.college || '学院未填' }}</p>
              </div>
            </div>
            <div class="student-meta">
              <span>{{ item.student?.major || '专业未填' }}</span>
              <span>{{ item.student?.education || '学历未填' }}</span>
              <span>{{ formatDate(item.post.createTime) }}</span>
            </div>
            <div class="tags">
              <el-tag size="small">{{ item.post.expectPost || '岗位不限' }}</el-tag>
              <el-tag size="small" type="success">{{ item.post.expectCity || '城市不限' }}</el-tag>
              <el-tag size="small" type="warning">{{ item.post.expectSalary || '薪资面议' }}</el-tag>
            </div>
            <p class="intro">{{ item.post.intro || '暂无介绍' }}</p>
            <div class="card-foot">
              <span>浏览 {{ item.post.viewCount || 0 }}</span>
              <el-button text type="primary">查看详情</el-button>
            </div>
          </div>
          <el-empty v-if="!loading && list.length === 0" class="grid-empty" description="暂无求职信息" />
        </div>
      </div>
      <div class="pagination-wrap">
        <el-pagination v-model:current-page="query.pageNum" v-model:page-size="query.pageSize" :total="total" background layout="total,prev,pager,next" @current-change="load" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, reactive, ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Filter, User } from '@element-plus/icons-vue'
import { publicApi } from '@/api'
import { useUserStore } from '@/store/user'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const list = ref([])
const total = ref(0)
const showFilters = ref(false)
const cities = ref([])
const postTypes = [
  { label: '后端开发', value: '后端' },
  { label: '前端开发', value: '前端' },
  { label: '测试开发', value: '测试' },
  { label: '算法', value: '算法' },
  { label: '设计', value: '设计' },
  { label: '运营', value: '运营' },
  { label: '人力资源', value: '人力资源' }
]
const colleges = ['计算机学院', '人工智能学院', '软件学院', '电子信息学院', '经济管理学院', '艺术设计学院']
const salaryOptions = [
  { label: '5K以上', value: 5 },
  { label: '8K以上', value: 8 },
  { label: '10K以上', value: 10 },
  { label: '12K以上', value: 12 }
]
const query = reactive({ pageNum: 1, pageSize: 10, keyword: '', city: '', expectPost: '', college: '', salaryMin: '' })

const hasCondition = computed(() => ['keyword', 'city', 'expectPost', 'college', 'salaryMin'].some(k => query[k] !== '' && query[k] != null))
const activeFilters = computed(() => {
  const filters = []
  if (query.keyword) filters.push({ key: 'keyword', label: `关键词：${query.keyword}` })
  if (query.city) filters.push({ key: 'city', label: `城市：${query.city}` })
  if (query.expectPost) {
    filters.push({ key: 'expectPost', label: `方向：${postTypes.find(p => p.value === query.expectPost)?.label || query.expectPost}` })
  }
  if (query.college) filters.push({ key: 'college', label: `学院：${query.college}` })
  if (query.salaryMin) filters.push({ key: 'salaryMin', label: `薪资：${query.salaryMin}K以上` })
  return filters
})
const formatDate = (d) => d ? d.replace('T', ' ').substring(0, 10) : '发布时间待定'

const buildParams = () => {
  const params = {}
  Object.keys(query).forEach(k => {
    if (query[k] !== '' && query[k] != null) params[k] = query[k]
  })
  return params
}

const load = async () => {
  loading.value = true
  try {
    const res = await publicApi.seekerPosts(buildParams())
    list.value = res.data.records || []
    total.value = Number(res.data.total || 0)
  } finally { loading.value = false }
}
const reload = () => { query.pageNum = 1; load() }
const reloadIfEmpty = (value) => { if (!String(value || '').trim()) reload() }
const setFilter = (key, value) => {
  query[key] = value
  reload()
}
const removeFilter = (key) => {
  query[key] = ''
  reload()
}
const clearAll = () => {
  query.keyword = ''
  query.city = ''
  query.expectPost = ''
  query.college = ''
  query.salaryMin = ''
  reload()
}
const publish = () => {
  if (!userStore.isLogin) { ElMessage.warning('请先登录'); router.push('/login'); return }
  if (userStore.role !== 'STUDENT') { ElMessage.warning('请使用学生账号发布'); return }
  router.push('/student/seeker-post')
}
onMounted(async () => {
  try {
    const res = await publicApi.dict('city')
    cities.value = res.data || []
  } catch (e) {}
  load()
})
</script>

<style scoped lang="scss">
.head { display:flex; justify-content:space-between; gap:1rem; align-items:center; h2{margin-bottom:.375rem;} p{color:var(--cr-text-muted);} }
.search-card { display: grid; gap: .875rem; }
.active-filters { display: flex; align-items: center; flex-wrap: wrap; gap: .5rem; padding-top: .25rem;
  .active-label { color: var(--cr-text-muted); font-size: .8125rem; font-weight: 650; }
}
.filter-panel { border-top: .0625rem solid var(--cr-border-soft); padding-top: .25rem; }
.filter-row { display: grid; grid-template-columns: minmax(5.5rem, max-content) minmax(0, 1fr); gap: .75rem; padding: .625rem 0; border-bottom: .0625rem dashed var(--cr-border-soft);
  &:last-child { border-bottom: 0; padding-bottom: 0; }
  .label { color: var(--cr-text-muted); padding-top: .375rem; font-weight: 650; }
  .options { min-width: 0; display: flex; flex-wrap: wrap; gap: .5rem; }
  .opt { padding: .375rem .875rem; border: .0625rem solid transparent; border-radius: 999rem; cursor: pointer; font-size: .875rem; color: var(--cr-text-soft); transition: all .2s ease;
    &:hover { color: var(--cr-primary); background: var(--cr-primary-soft); }
    &.active { background: var(--cr-primary); border-color: var(--cr-primary); color: #fff; box-shadow: 0 .5rem 1rem rgba(37,99,235,.14); }
  }
}
.filter-drop-enter-active, .filter-drop-leave-active { transition: opacity .18s ease, transform .18s ease; }
.filter-drop-enter-from, .filter-drop-leave-to { opacity: 0; transform: translateY(-.25rem); }
.portal-list-card { --portal-list-card-min-height: calc(100dvh - 22rem); }
.seeker-scroll { display:flex; flex-direction:column; }
.seeker-grid { flex:1; min-height:100%; display:grid; grid-template-columns:repeat(auto-fill,minmax(min(100%,20rem),1fr)); grid-auto-rows:minmax(15.25rem,1fr); gap:1rem; }
.seeker-card { min-height:15.25rem; background:#fff; border:1px solid var(--cr-border-soft); border-radius:var(--cr-radius-sm); padding:1rem; box-shadow:var(--cr-shadow-soft); cursor:pointer; display:flex; flex-direction:column; gap:.75rem; transition:transform .18s, box-shadow .18s;
  &:hover { transform:translateY(-.125rem); box-shadow:var(--cr-shadow); }
}
.card-top { display:flex; gap:.75rem; align-items:center; min-width:0; h3{font-size:1rem;color:var(--cr-text);margin-bottom:.25rem;line-height:1.35;} p{color:var(--cr-text-muted);font-size:.8125rem;} }
.student-info { min-width: 0; }
.student-meta { display:flex; flex-wrap:wrap; gap:.375rem .75rem; color:var(--cr-text-muted); font-size:.75rem; padding:.5rem .625rem; background:var(--cr-surface-soft); border-radius:var(--cr-radius-sm); }
.tags { display:flex; flex-wrap:wrap; gap:.375rem; }
.intro { color:var(--cr-text-soft); line-height:1.65; display:-webkit-box; -webkit-line-clamp:5; -webkit-box-orient:vertical; overflow:hidden; }
.card-foot { margin-top:auto; display:flex; justify-content:space-between; align-items:center; color:var(--cr-text-muted); font-size:.8125rem; }
@media (max-width:40rem){.head{align-items:stretch;flex-direction:column}.head :deep(.el-button){width:100%;}.filter-row{grid-template-columns:1fr;gap:.5rem}.filter-row .label{padding-top:0;}}
</style>
