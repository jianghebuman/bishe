<template>
  <div class="forum-detail portal-content" v-loading="loading">
    <div class="layout" v-if="post">
      <div class="main page-card">
        <div class="post-head">
          <el-tag :type="tagType(post.category)" effect="plain">{{ post.category || '求职交流' }}</el-tag>
          <h1>{{ post.title }}</h1>
          <div class="meta">
            <span><el-icon><User /></el-icon> {{ post.authorName || '匿名同学' }}</span>
            <span><el-icon><Clock /></el-icon> {{ formatTime(post.createTime) }}</span>
            <span><el-icon><View /></el-icon> {{ post.viewCount || 0 }} 浏览</span>
          </div>
        </div>
        <el-divider />
        <div class="post-content">{{ post.content }}</div>
        <div class="actions">
          <el-button type="primary" plain @click="likePost"><el-icon><Pointer /></el-icon> 点赞 {{ post.likeCount || 0 }}</el-button>
          <el-button @click="$router.push('/forum')">返回社区</el-button>
        </div>
      </div>

      <div class="comments page-card mt-20">
        <div class="comment-title">评论（{{ comments.length }}）</div>
        <div class="comment-editor">
          <el-input v-model="commentText" type="textarea" :rows="3" placeholder="写下你的看法，帮助更多同学" maxlength="500" show-word-limit />
          <div class="editor-footer"><el-button type="primary" :loading="commenting" @click="submitComment">发表评论</el-button></div>
        </div>
        <div class="comment-list">
          <div class="comment-item" v-for="c in comments" :key="c.id">
            <div class="avatar">{{ (c.authorName || '同').substring(0, 1) }}</div>
            <div class="body">
              <div class="name">{{ c.authorName || '匿名同学' }} <span>{{ formatTime(c.createTime) }}</span></div>
              <div class="text">{{ c.content }}</div>
            </div>
          </div>
          <el-empty v-if="comments.length === 0" description="暂无评论，快来抢沙发" :image-size="80" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Clock, View, Pointer } from '@element-plus/icons-vue'
import { publicApi, forumApi } from '@/api'
import { useUserStore } from '@/store/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const post = ref(null)
const comments = ref([])
const commentText = ref('')
const commenting = ref(false)

const tagType = (c) => c === '经验分享' ? 'success' : c === 'offer捷报' ? 'danger' : 'info'
const formatTime = (t) => t ? t.replace('T', ' ').substring(0, 16) : ''
const ensureStudent = () => {
  if (!userStore.isLogin) { ElMessage.warning('请先登录学生账号'); router.push('/login'); return false }
  if (userStore.role !== 'STUDENT') { ElMessage.warning('仅学生可参与互动'); return false }
  return true
}
const load = async () => {
  loading.value = true
  try {
    const [p, cs] = await Promise.all([publicApi.forumPostDetail(route.params.id), publicApi.forumComments(route.params.id)])
    post.value = p.data
    comments.value = cs.data || []
  } finally { loading.value = false }
}
const likePost = async () => {
  if (!ensureStudent()) return
  await forumApi.like(post.value.id)
  post.value.likeCount = (post.value.likeCount || 0) + 1
  ElMessage.success('点赞成功')
}
const submitComment = async () => {
  if (!ensureStudent()) return
  if (!commentText.value.trim()) { ElMessage.warning('请输入评论内容'); return }
  commenting.value = true
  try {
    await forumApi.comment(post.value.id, { content: commentText.value })
    ElMessage.success('评论成功')
    commentText.value = ''
    const cs = await publicApi.forumComments(route.params.id)
    comments.value = cs.data || []
  } finally { commenting.value = false }
}
onMounted(load)
</script>

<style scoped lang="scss">
.layout { max-width: 900px; margin: 0 auto; }
.post-head { text-align: center; h1 { margin: 14px 0; color: #303133; line-height: 1.4; } }
.meta { display: flex; justify-content: center; gap: 20px; color: #909399; font-size: 13px; .el-icon { vertical-align: middle; } }
.post-content { min-height: 180px; color: #303133; line-height: 1.9; font-size: 16px; white-space: pre-line; }
.actions { margin-top: 24px; text-align: center; }
.comment-title { font-size: 18px; font-weight: 600; margin-bottom: 14px; }
.comment-editor { background: #f5f7fa; padding: 14px; border-radius: 8px; margin-bottom: 16px; }
.editor-footer { margin-top: 10px; text-align: right; }
.comment-item { display: flex; gap: 12px; padding: 14px 0; border-bottom: 1px dashed #ebeef5; }
.avatar { width: 38px; height: 38px; border-radius: 50%; background: #409eff; color: #fff; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.body { flex: 1; .name { color: #303133; font-weight: 500; margin-bottom: 6px; span { color: #c0c4cc; font-weight: normal; font-size: 12px; margin-left: 10px; } } .text { color: #606266; line-height: 1.6; } }
</style>
