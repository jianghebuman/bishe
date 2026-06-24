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
      <el-input v-model="query.keyword" placeholder="搜索帖子标题" clearable style="width: 260px" @keyup.enter="reload">
        <template #append><el-button @click="reload"><el-icon><Search /></el-icon></el-button></template>
      </el-input>
    </div>

    <div class="content mt-20">
      <div class="main-list page-card" v-loading="loading">
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
        <div class="pagination-wrap">
          <el-pagination v-model:current-page="query.pageNum" v-model:page-size="query.pageSize" :total="total"
            layout="total, prev, pager, next" background @current-change="load" />
        </div>
      </div>

      <div class="side">
        <div class="page-card tips">
          <h3>社区公约</h3>
          <p>1. 分享真实求职经验，尊重他人隐私。</p>
          <p>2. 不发布虚假招聘、广告或攻击性内容。</p>
          <p>3. 面试经验建议包含岗位、流程、题型与复盘。</p>
        </div>
        <div class="page-card mt-20 quick">
          <h3>热门话题</h3>
          <el-tag>春招</el-tag><el-tag type="success">简历优化</el-tag><el-tag type="warning">面试复盘</el-tag><el-tag type="danger">Offer选择</el-tag>
        </div>
      </div>
    </div>

    <el-dialog v-model="dialog" title="发布帖子" width="620px">
      <el-form :model="form" label-width="80px">
        <el-form-item label="版块">
          <el-select v-model="form.category" style="width: 100%">
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
const query = reactive({ pageNum: 1, pageSize: 10, keyword: '', category: '' })
const posts = ref([])
const total = ref(0)
const loading = ref(false)
const dialog = ref(false)
const publishing = ref(false)
const form = reactive({ title: '', content: '', category: '求职交流' })

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
.hero { display: flex; justify-content: space-between; align-items: center; background: linear-gradient(135deg, #eef6ff, #fff); h2 { color: #303133; .el-icon { vertical-align: middle; } } p { color: #909399; margin-top: 6px; } }
.toolbar { display: flex; justify-content: space-between; align-items: center; }
.content { display: grid; grid-template-columns: 1fr 280px; gap: 20px; }
.post-item { display: flex; gap: 14px; padding: 18px 0; border-bottom: 1px dashed #ebeef5; cursor: pointer; &:hover .post-title span:last-child { color: #409eff; } }
.avatar { width: 44px; height: 44px; border-radius: 50%; background: linear-gradient(135deg, #409eff, #67c23a); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 600; flex-shrink: 0; }
.post-body { flex: 1; min-width: 0; }
.post-title { display: flex; align-items: center; gap: 8px; font-weight: 600; color: #303133; margin-bottom: 8px; }
.post-content { color: #606266; line-height: 1.6; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; margin-bottom: 8px; }
.post-meta { display: flex; gap: 16px; color: #909399; font-size: 12px; .el-icon { vertical-align: middle; } }
.tips p { color: #606266; line-height: 1.8; font-size: 13px; }
.quick { display: flex; flex-direction: column; gap: 10px; }
</style>
