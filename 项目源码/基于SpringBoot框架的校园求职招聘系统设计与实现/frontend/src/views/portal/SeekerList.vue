<template>
  <div class="portal-content">
    <div class="page-card head">
      <div>
        <h2>求职栏</h2>
        <p>查看同学发布的求职信息，企业可登录后发起沟通。</p>
      </div>
      <el-button type="primary" @click="publish">发布求职信息</el-button>
    </div>

    <div class="page-card mt-20">
      <el-form inline>
        <el-form-item label="关键词">
          <el-input v-model="query.keyword" clearable placeholder="岗位/标题" @keyup.enter="reload" />
        </el-form-item>
        <el-form-item label="城市">
          <el-input v-model="query.city" clearable placeholder="期望城市" @keyup.enter="reload" />
        </el-form-item>
        <el-button type="primary" @click="reload">搜索</el-button>
      </el-form>
    </div>

    <div class="seeker-grid mt-20" v-loading="loading">
      <div class="seeker-card" v-for="item in list" :key="item.post.id" @click="$router.push(`/seeker/${item.post.id}`)">
        <div class="card-top">
          <el-avatar :src="item.student?.avatar"><el-icon><User /></el-icon></el-avatar>
          <div>
            <h3>{{ item.post.title }}</h3>
            <p>{{ item.student?.realName || '求职者' }} · {{ item.student?.college || '学院未填' }}</p>
          </div>
        </div>
        <div class="tags">
          <el-tag>{{ item.post.expectPost || '岗位不限' }}</el-tag>
          <el-tag type="success">{{ item.post.expectCity || '城市不限' }}</el-tag>
          <el-tag type="warning">{{ item.post.expectSalary || '薪资面议' }}</el-tag>
        </div>
        <p class="intro">{{ item.post.intro || '暂无介绍' }}</p>
        <div class="card-foot">
          <span>浏览 {{ item.post.viewCount || 0 }}</span>
          <el-button text type="primary">查看详情</el-button>
        </div>
      </div>
      <el-empty v-if="!loading && list.length === 0" class="grid-empty" description="暂无求职信息" />
    </div>
    <div class="pagination-wrap">
      <el-pagination v-model:current-page="query.pageNum" v-model:page-size="query.pageSize" :total="total" background layout="total,prev,pager,next" @current-change="load" />
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User } from '@element-plus/icons-vue'
import { publicApi } from '@/api'
import { useUserStore } from '@/store/user'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const list = ref([])
const total = ref(0)
const query = reactive({ pageNum: 1, pageSize: 9, keyword: '', city: '' })

const load = async () => {
  loading.value = true
  try {
    const res = await publicApi.seekerPosts(query)
    list.value = res.data.records || []
    total.value = Number(res.data.total || 0)
  } finally { loading.value = false }
}
const reload = () => { query.pageNum = 1; load() }
const publish = () => {
  if (!userStore.isLogin) { ElMessage.warning('请先登录'); router.push('/login'); return }
  if (userStore.role !== 'STUDENT') { ElMessage.warning('请使用学生账号发布'); return }
  router.push('/student/seeker-post')
}
onMounted(load)
</script>

<style scoped lang="scss">
.head { display:flex; justify-content:space-between; gap:1rem; align-items:center; h2{margin-bottom:.375rem;} p{color:var(--cr-text-muted);} }
.seeker-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(min(100%,20rem),1fr)); gap:1rem; }
.seeker-card { background:#fff; border:1px solid var(--cr-border-soft); border-radius:var(--cr-radius-sm); padding:1rem; box-shadow:var(--cr-shadow-soft); cursor:pointer; display:flex; flex-direction:column; gap:.875rem; min-height:13rem; transition:transform .18s, box-shadow .18s;
  &:hover { transform:translateY(-.125rem); box-shadow:var(--cr-shadow); }
}
.card-top { display:flex; gap:.75rem; align-items:center; min-width:0; h3{font-size:1rem;color:var(--cr-text);margin-bottom:.25rem;} p{color:var(--cr-text-muted);font-size:.8125rem;} }
.tags { display:flex; flex-wrap:wrap; gap:.375rem; }
.intro { color:var(--cr-text-soft); line-height:1.7; display:-webkit-box; -webkit-line-clamp:3; -webkit-box-orient:vertical; overflow:hidden; }
.card-foot { margin-top:auto; display:flex; justify-content:space-between; align-items:center; color:var(--cr-text-muted); font-size:.8125rem; }
@media (max-width:40rem){.head{align-items:stretch;flex-direction:column}.head :deep(.el-button){width:100%;}}
</style>
