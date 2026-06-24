<template>
  <div class="news-detail portal-content" v-loading="loading">
    <div v-if="news">
      <div class="page-card article">
        <h1 class="title">{{ news.title }}</h1>
        <div class="meta">
          <span><el-icon><User /></el-icon> {{ news.author || '就业办' }}</span>
          <span><el-icon><Clock /></el-icon> {{ formatDateTime(news.publishTime || news.createTime) }}</span>
          <span><el-icon><View /></el-icon> {{ news.viewCount || 0 }} 次阅读</span>
        </div>
        <el-divider />
        <div class="content" v-html="news.content"></div>
        <el-divider />
        <div class="actions">
          <el-button @click="$router.push('/news')"><el-icon><Back /></el-icon> 返回列表</el-button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { User, Clock, View, Back } from '@element-plus/icons-vue'
import { publicApi } from '@/api'

const route = useRoute()
const loading = ref(false)
const news = ref(null)
const formatDateTime = (d) => d ? d.replace('T', ' ').substring(0, 16) : ''

onMounted(async () => {
  loading.value = true
  try {
    const res = await publicApi.announcementDetail(route.params.id)
    news.value = res.data
  } finally { loading.value = false }
})
</script>

<style scoped lang="scss">
.article { max-width: 900px; margin: 0 auto; padding: 40px 60px; }
.title { text-align: center; color: #303133; margin-bottom: 16px; line-height: 1.4; }
.meta { display: flex; justify-content: center; gap: 20px; color: #909399; font-size: 13px; .el-icon { vertical-align: middle; margin-right: 2px; } }
.content { color: #303133; font-size: 16px; line-height: 1.9; min-height: 200px;
  :deep(p) { margin-bottom: 12px; }
  :deep(img) { max-width: 100%; }
}
.actions { text-align: center; }
</style>
