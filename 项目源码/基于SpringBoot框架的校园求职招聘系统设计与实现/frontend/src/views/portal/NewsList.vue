<template>
  <div class="news-list portal-content">
    <div class="page-card head">
      <h2><el-icon><Notebook /></el-icon> 就业资讯</h2>
      <p class="sub">就业政策、招聘公告、求职技巧、校园新闻</p>
    </div>

    <div class="layout mt-20">
      <!-- 左侧资讯列表 -->
      <div class="page-card main">
        <el-tabs v-model="activeCat" @tab-change="onCatChange">
          <el-tab-pane label="全部" :name="0" />
          <el-tab-pane v-for="c in categories" :key="c.id" :label="c.name" :name="c.id" />
        </el-tabs>
        <div class="news-row" v-for="n in list" :key="n.id" @click="$router.push(`/news/${n.id}`)" v-loading="loading">
          <div class="cover" v-if="n.cover" :style="{ backgroundImage: `url(${n.cover})` }"></div>
          <div class="body">
            <h3 class="title">
              <el-tag size="small" type="danger" v-if="n.isTop" effect="dark" style="margin-right: 8px;">置顶</el-tag>
              {{ n.title }}
            </h3>
            <p class="summary">{{ n.summary }}</p>
            <div class="meta">
              <span>{{ n.author || '就业办' }}</span>
              <span>{{ formatDate(n.publishTime || n.createTime) }}</span>
              <span><el-icon><View /></el-icon> {{ n.viewCount || 0 }}</span>
            </div>
          </div>
        </div>
        <el-empty v-if="!loading && list.length === 0" description="暂无资讯" />
        <div class="pagination-wrap">
          <el-pagination v-model:current-page="query.pageNum" v-model:page-size="query.pageSize" :total="total"
            layout="prev, pager, next" background @current-change="load" />
        </div>
      </div>
      <!-- 右侧:热门 -->
      <div class="aside">
        <div class="page-card">
          <h3 class="block-title">热门阅读</h3>
          <ol class="hot-list">
            <li v-for="(h, i) in hot" :key="h.id" @click="$router.push(`/news/${h.id}`)">
              <span class="rank" :class="{ top: i < 3 }">{{ i + 1 }}</span>
              <span class="title">{{ h.title }}</span>
            </li>
          </ol>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { Notebook, View } from '@element-plus/icons-vue'
import { publicApi } from '@/api'
import request from '@/utils/request'

const activeCat = ref(0)
const query = reactive({ pageNum: 1, pageSize: 10, categoryId: undefined })
const list = ref([])
const total = ref(0)
const loading = ref(false)
const categories = ref([])
const hot = ref([])

const formatDate = (d) => d ? d.substring(0, 10) : ''

const load = async () => {
  loading.value = true
  try {
    const params = { ...query }
    if (!params.categoryId) delete params.categoryId
    const res = await publicApi.announcements(params)
    list.value = res.data.records; total.value = Number(res.data.total)
  } finally { loading.value = false }
}
const onCatChange = (v) => { query.categoryId = v || undefined; query.pageNum = 1; load() }

onMounted(async () => {
  try {
    // 资讯分类用通用 mapper 直查（公共接口未必暴露）
    const cat = await request.get('/public/news-categories').catch(() => null)
    if (cat) categories.value = cat.data || []
  } catch (e) {}
  await load()
  try {
    const res = await publicApi.announcements({ pageNum: 1, pageSize: 8 })
    hot.value = (res.data.records || []).sort((a, b) => (b.viewCount || 0) - (a.viewCount || 0)).slice(0, 8)
  } catch (e) {}
})
</script>

<style scoped lang="scss">
.head h2 { color: #303133; .el-icon { vertical-align: middle; } }
.head .sub { color: #909399; margin-top: 6px; }
.layout { display: grid; grid-template-columns: 1fr 280px; gap: 20px; }
.news-row { display: flex; gap: 16px; padding: 16px 0; border-bottom: 1px dashed #ebeef5; cursor: pointer;
  &:hover .title { color: #409eff; }
  .cover { width: 160px; height: 100px; background-size: cover; background-position: center; border-radius: 6px; flex-shrink: 0; }
  .body { flex: 1; min-width: 0; }
  .title { font-size: 16px; color: #303133; margin-bottom: 8px; display: flex; align-items: center; }
  .summary { color: #606266; font-size: 13px; line-height: 1.6; margin-bottom: 10px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
  .meta { display: flex; gap: 16px; color: #909399; font-size: 12px; .el-icon { vertical-align: middle; } }
}
.block-title { font-size: 15px; color: #303133; border-left: 3px solid #409eff; padding-left: 8px; margin-bottom: 12px; }
.hot-list { padding-left: 0;
  li { display: flex; align-items: center; gap: 8px; padding: 8px 0; border-bottom: 1px dashed #ebeef5; font-size: 13px; cursor: pointer;
    &:hover .title { color: #409eff; }
    .rank { width: 20px; height: 20px; background: #c0c4cc; color: #fff; text-align: center; line-height: 20px; border-radius: 4px; font-size: 12px;
      &.top { background: #f56c6c; }
    }
    .title { flex: 1; color: #303133; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  }
}
</style>
