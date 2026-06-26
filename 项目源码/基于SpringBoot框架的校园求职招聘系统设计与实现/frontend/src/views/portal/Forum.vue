<template>
  <div class="forum-page portal-content">
    <div class="hero page-card">
      <div>
        <h2><el-icon><ChatDotRound /></el-icon> 求职社区</h2>
        <p>交流面试经验、分享求职技巧、记录 Offer 捷报</p>
      </div>
      <el-button type="primary" size="large" @click="openPublish"><el-icon><EditPen /></el-icon> 发布帖子</el-button>
    </div>

    <div class="toolbar page-card mt-20">
      <el-radio-group v-model="query.category" @change="reload">
        <el-radio-button label="">全部</el-radio-button>
        <el-radio-button label="求职交流">求职交流</el-radio-button>
        <el-radio-button label="经验分享">经验分享</el-radio-button>
        <el-radio-button label="offer捷报">Offer捷报</el-radio-button>
      </el-radio-group>
      <el-input v-model="query.keyword" placeholder="搜索帖子标题" clearable class="toolbar-search" @keyup.enter="reload">
        <template #append><el-button @click="reload"><el-icon><Search /></el-icon></el-button></template>
      </el-input>
    </div>

    <div class="content mt-20">
      <div class="main-list page-card page-flex-card portal-list-card" v-loading="loading">
        <div class="page-flex-scroll forum-scroll">
          <div class="post-item" v-for="p in posts" :key="p.id" @click="$router.push(`/forum/${p.id}`)">
            <div class="avatar">{{ (p.authorName || '同学').substring(0, 1) }}</div>
            <div class="post-body">
              <div class="post-title">
                <el-tag size="small" :type="tagType(p.category)" effect="plain">{{ p.category || '求职交流' }}</el-tag>
                <span>{{ p.title }}</span>
              </div>
              <p class="post-content">{{ p.content }}</p>
              <div class="post-meta">
                <span><el-icon><User /></el-icon> {{ p.authorName || '匿名同学' }}</span>
                <span><el-icon><Clock /></el-icon> {{ formatTime(p.createTime) }}</span>
                <span><el-icon><View /></el-icon> {{ p.viewCount || 0 }}</span>
                <span><el-icon><Pointer /></el-icon> {{ p.likeCount || 0 }}</span>
                <span><el-icon><ChatLineRound /></el-icon> {{ p.commentCount || 0 }}</span>
              </div>
            </div>
          </div>
          <el-empty v-if="!loading && posts.length === 0" description="暂无帖子，来发布第一条交流吧" />
        </div>
        <div class="pagination-wrap">
          <el-pagination v-model:current-page="query.pageNum" v-model:page-size="query.pageSize" :total="total"
            layout="total, prev, pager, next" background @current-change="load" />
        </div>
      </div>
      <div class="side">
        <div class="page-card side-card">
          <h3 class="side-title">社区公约</h3>
          <p>1. 分享真实求职经验，尊重他人隐私。</p>
          <p>2. 不发布虚假招聘、广告或攻击性内容。</p>
          <p>3. 面试经验建议包含岗位、流程、题型与复盘。</p>
          <p>4. Offer 信息可适度脱敏后再公开交流。</p>
        </div>
        <div class="page-card side-card">
          <h3 class="side-title">精选帖子</h3>
          <div class="side-posts">
            <div class="side-post" v-for="item in featuredPosts" :key="item.id" @click="$router.push(`/forum/${item.id}`)">
              <el-tag size="small" :type="tagType(item.category)" effect="plain">{{ item.category || '求职交流' }}</el-tag>
              <div class="side-post-body">
                <p class="side-post-title">{{ item.title }}</p>
                <p class="side-post-meta">{{ item.authorName || '匿名同学' }} · {{ formatTime(item.createTime) }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <el-dialog v-model="dialog" title="发布帖子" width="min(92vw, 38.75rem)">
      <el-form :model="form" label-width="5rem">
        <el-form-item label="版块">
          <el-select v-model="form.category" class="w-full">
            <el-option label="求职交流" value="求职交流" />
            <el-option label="经验分享" value="经验分享" />
            <el-option label="Offer捷报" value="offer捷报" />
          </el-select>
        </el-form-item>
        <el-form-item label="标题">
          <el-input v-model="form.title" maxlength="80" show-word-limit placeholder="请输入帖子标题" />
        </el-form-item>
        <el-form-item label="内容">
          <el-input v-model="form.content" type="textarea" :rows="8" maxlength="3000" show-word-limit placeholder="分享你的经历、问题或建议" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog = false">取消</el-button>
        <el-button type="primary" :loading="publishing" @click="submitPost">发布</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ChatDotRound, EditPen, Search, User, Clock, View, Pointer, ChatLineRound } from '@element-plus/icons-vue'
import { publicApi, forumApi } from '@/api'
import { useUserStore } from '@/store/user'

const router = useRouter()
const userStore = useUserStore()
const query = reactive({ pageNum: 1, pageSize: 6, keyword: '', category: '' })
const posts = ref([])
const total = ref(0)
const loading = ref(false)
const dialog = ref(false)
const publishing = ref(false)
const form = reactive({ title: '', content: '', category: '求职交流' })
const featuredPosts = ref([])

const tagType = (c) => c === '经验分享' ? 'success' : c === 'offer捷报' ? 'danger' : 'info'
const formatTime = (t) => t ? t.replace('T', ' ').substring(0, 16) : ''
const reload = () => { query.pageNum = 1; load() }
const load = async () => {
  loading.value = true
  try {
    const params = { ...query }
    if (!params.keyword) delete params.keyword
    if (!params.category) delete params.category
    const res = await publicApi.forumPosts(params)
    posts.value = res.data.records; total.value = Number(res.data.total)
    featuredPosts.value = (res.data.records || []).slice(0, 3)
  } finally { loading.value = false }
}
const openPublish = () => {
  if (!userStore.isLogin) { ElMessage.warning('请先登录学生账号'); router.push('/login'); return }
  if (userStore.role !== 'STUDENT') { ElMessage.warning('仅学生可发布帖子'); return }
  dialog.value = true
}
const submitPost = async () => {
  if (!form.title.trim() || !form.content.trim()) { ElMessage.warning('请填写标题和内容'); return }
  publishing.value = true
  try {
    await forumApi.publish(form)
    ElMessage.success('发布成功')
    dialog.value = false
    form.title = ''; form.content = ''; form.category = '求职交流'
    reload()
  } finally { publishing.value = false }
}
onMounted(load)
</script>

<style scoped lang="scss">
.hero { display: flex; justify-content: space-between; align-items: center; gap: 1rem; background: linear-gradient(135deg, #eef6ff, #fff); h2 { color: var(--cr-text); .el-icon { vertical-align: middle; } } p { color: var(--cr-text-muted); margin-top: .375rem; } }
.toolbar { display: grid; grid-template-columns: minmax(0, 1fr) minmax(14rem, .28fr); gap: clamp(.75rem, 2vw, 1rem); align-items: center; }
.toolbar :deep(.el-radio-group) { min-width: 0; overflow-x: auto; }
.toolbar-search { min-width: 0; }
.content { display: grid; grid-template-columns: minmax(0, 1fr) minmax(15rem, 18rem); gap: clamp(1rem, 2vw, 1.25rem); align-items: stretch; }
.main-list { --portal-list-card-min-height: calc(100dvh - 22rem); min-height: 0; }
.forum-scroll { display: flex; flex-direction: column; }
.side { display: grid; grid-template-rows: minmax(0, 1fr) minmax(0, 1fr); gap: clamp(1rem, 2vw, 1.25rem); min-height: 0; height: 100%; }
.side > .page-card { min-height: 0; }
.post-item { flex: 1; min-height: 5.875rem; display: flex; align-items: center; gap: .75rem; padding: .75rem 0; border-bottom: 0.0625rem dashed var(--cr-border-soft); cursor: pointer; &:hover .post-title span:last-child { color: var(--cr-primary); } }
.avatar { width: clamp(2.25rem, 5vw, 2.75rem); height: clamp(2.25rem, 5vw, 2.75rem); border-radius: 50%; background: linear-gradient(135deg, var(--cr-primary), var(--cr-success)); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 600; flex-shrink: 0; }
.post-body { flex: 1; min-width: 0; }
.post-title { display: flex; align-items: center; gap: .5rem; font-weight: 600; color: var(--cr-text); margin-bottom: .375rem; line-height: 1.35; }
.post-content { color: var(--cr-text-soft); font-size: .8125rem; line-height: 1.55; display: -webkit-box; -webkit-line-clamp: 1; -webkit-box-orient: vertical; overflow: hidden; margin-bottom: .375rem; }
.post-meta { display: flex; gap: .5rem .875rem; flex-wrap: wrap; color: var(--cr-text-muted); font-size: .75rem; .el-icon { vertical-align: middle; } }
.side-card { display: flex; flex-direction: column; gap: .5rem; min-height: 0; height: 100%; }
.side-title { color: var(--cr-text); font-size: .9375rem; font-weight: 600; }
.side-card p { color: var(--cr-text-soft); line-height: 1.65; font-size: .78125rem; }
.side-posts { display: flex; flex-direction: column; gap: .5rem; }
.side-post { display: grid; grid-template-columns: auto minmax(0, 1fr); gap: .5rem; align-items: start; padding: .5rem 0; border-bottom: 0.0625rem dashed #ebeef5; cursor: pointer; }
.side-post:hover .side-post-title { color: var(--cr-primary); }
.side-post-body { min-width: 0; }
.side-post-title { color: var(--cr-text); font-size: .875rem; line-height: 1.45; margin: 0; }
.side-post-meta { color: var(--cr-text-muted); font-size: .75rem; margin-top: .25rem; }
@media (max-width: 56.25rem) {
  .content,
  .toolbar { grid-template-columns: 1fr; }
  .side { grid-template-rows: auto; }
  .post-item { flex: 0 1 auto; }
}

@media (max-width: 40rem) {
  .hero { align-items: stretch; flex-direction: column; }
  .hero :deep(.el-button) { width: 100%; }
  .post-title { align-items: flex-start; flex-direction: column; }
}
</style>

