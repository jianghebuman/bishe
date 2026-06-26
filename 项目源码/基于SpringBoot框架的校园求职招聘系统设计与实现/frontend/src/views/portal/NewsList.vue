<template>
  <div class="news-list portal-content">
    <div class="page-card head">
      <h2><el-icon><Notebook /></el-icon> 就业资讯</h2>
      <p class="sub">就业政策、招聘公告、求职技巧、校园新闻</p>
    </div>

    <div class="layout mt-20">
      <!-- 左侧资讯列表 -->
      <div class="page-card main page-flex-card portal-list-card compact-list-card">
        <el-tabs v-model="activeCat" @tab-change="onCatChange">
          <el-tab-pane label="全部" :name="0" />
          <el-tab-pane v-for="c in categories" :key="c.id" :label="c.name" :name="c.id" />
        </el-tabs>
        <div class="page-flex-scroll">
          <div class="news-row" v-for="n in list" :key="n.id" @click="$router.push(`/news/${n.id}`)" v-loading="loading">
            <div class="cover" v-if="n.cover" :style="{ backgroundImage: `url(${n.cover})` }"></div>
            <div class="body">
              <h3 class="title">
                <el-tag size="small" type="danger" v-if="n.isTop" effect="dark" class="top-tag">置顶</el-tag>
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
        </div>
        <div class="pagination-wrap">
          <el-pagination v-model:current-page="query.pageNum" v-model:page-size="query.pageSize" :total="total"
            layout="prev, pager, next" background @current-change="load" />
        </div>
      </div>
      <div class="aside">
        <div class="page-card sidebar-card">
          <h3 class="block-title">资讯速览</h3>
          <div class="brief-list">
            <div class="brief-item" v-for="item in briefNews" :key="item.id" @click="$router.push(`/news/${item.id}`)">
              <el-tag size="small" :type="item.isTop ? 'danger' : 'info'" effect="plain">{{ item.isTop ? '置顶' : '推荐' }}</el-tag>
              <div class="brief-body">
                <p class="brief-title">{{ item.title }}</p>
                <p class="brief-meta">{{ formatDate(item.publishTime || item.createTime) }} · {{ item.author || '就业办' }}</p>
              </div>
            </div>
          </div>
        </div>
        <div class="page-card sidebar-card">
          <h3 class="block-title">活动提醒</h3>
          <div class="schedule-list">
            <div class="schedule-group">
              <div class="schedule-label">宣讲会</div>
              <div class="schedule-item" v-for="t in sidebarTalks" :key="t.id" @click="$router.push(`/talk/${t.id}`)">
                <span class="schedule-dot"></span>
                <div>
                  <p class="schedule-title">{{ t.title }}</p>
                  <p class="schedule-meta">{{ formatDateTime(t.talkTime) }} · {{ t.location || '待定' }}</p>
                </div>
              </div>
            </div>
            <div class="schedule-group">
              <div class="schedule-label">招聘会</div>
              <div class="schedule-item" v-for="f in sidebarFairs" :key="f.id" @click="$router.push(`/fair/${f.id}`)">
                <span class="schedule-dot alt"></span>
                <div>
                  <p class="schedule-title">{{ f.title }}</p>
                  <p class="schedule-meta">{{ formatDateTime(f.fairTime) }} · {{ f.location || '待定' }}</p>
                </div>
              </div>
            </div>
          </div>
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
const query = reactive({ pageNum: 1, pageSize: 6, categoryId: undefined })
const list = ref([])
const total = ref(0)
const loading = ref(false)
const categories = ref([])
const briefNews = ref([])
const sidebarTalks = ref([])
const sidebarFairs = ref([])
const formatDate = (d) => d ? d.substring(0, 10) : ''
const formatDateTime = (d) => d ? d.replace('T', ' ').substring(0, 16) : ''

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
    const home = await publicApi.home()
    const news = home.data?.announcements || []
    briefNews.value = news.slice(0, 2)
    sidebarTalks.value = (home.data?.talks || []).slice(0, 2)
    sidebarFairs.value = (home.data?.fairs || []).slice(0, 2)
  } catch (e) {}
})
</script>

<style scoped lang="scss">
.head h2 { color: var(--cr-text); .el-icon { vertical-align: middle; color: var(--cr-primary); } }
.head .sub { color: var(--cr-text-muted); margin-top: .375rem; }
.layout { display: grid; grid-template-columns: minmax(0, 1fr) minmax(15rem, 18rem); gap: clamp(1rem, 2vw, 1.25rem); align-items: start; }
.news-row { display: flex; gap: .875rem; padding: .75rem 0; border-bottom: 0.0625rem dashed #ebeef5; cursor: pointer;
  &:hover .title { color: var(--cr-primary); }
  .cover { width: clamp(6rem, 12vw, 8.25rem); aspect-ratio: 8 / 5; background-size: cover; background-position: center; border-radius: var(--cr-radius-sm); flex-shrink: 0; }
  .body { flex: 1; min-width: 0; }
  .title { font-size: .96875rem; color: var(--cr-text); margin-bottom: .375rem; display: flex; align-items: center; flex-wrap: wrap; gap: .375rem; line-height: 1.4; }
  .top-tag { margin-right: .125rem; }
  .summary { color: var(--cr-text-soft); font-size: .8125rem; line-height: 1.55; margin-bottom: .5rem; display: -webkit-box; -webkit-line-clamp: 1; -webkit-box-orient: vertical; overflow: hidden; }
  .meta { display: flex; gap: .5rem 1rem; flex-wrap: wrap; color: var(--cr-text-muted); font-size: .75rem; .el-icon { vertical-align: middle; } }
}
.block-title { font-size: .9375rem; color: var(--cr-text); border-left: .1875rem solid var(--cr-primary); padding-left: .5rem; margin-bottom: .75rem; }
.aside { display: grid; gap: clamp(1rem, 2vw, 1.25rem); min-height: 0; }
.aside > .page-card { min-height: 0; }
.sidebar-card { display: flex; flex-direction: column; gap: .625rem; min-height: 0; }
.brief-list, .schedule-list { display: flex; flex-direction: column; gap: .5rem; }
.brief-item, .schedule-item { cursor: pointer; }
.brief-item { display: grid; grid-template-columns: auto minmax(0, 1fr); gap: .5rem; align-items: start; padding: .5rem 0; border-bottom: 0.0625rem dashed #ebeef5;
  &:hover .brief-title { color: var(--cr-primary); }
}
.brief-body { min-width: 0; }
.brief-title, .schedule-title { color: var(--cr-text); font-size: .875rem; line-height: 1.45; margin: 0; }
.brief-meta, .schedule-meta { color: var(--cr-text-muted); font-size: .75rem; margin-top: .25rem; line-height: 1.5; }
.schedule-group { display: flex; flex-direction: column; gap: .5rem; }
.schedule-label { color: var(--cr-text); font-weight: 600; font-size: .8125rem; }
.schedule-item { display: grid; grid-template-columns: .5rem minmax(0, 1fr); gap: .5rem; align-items: start; padding: .375rem 0; border-bottom: 0.0625rem dashed #ebeef5;
  &:hover .schedule-title { color: var(--cr-primary); }
}
.schedule-dot { width: .5rem; height: .5rem; border-radius: 50%; background: var(--cr-primary); margin-top: .375rem; }
.schedule-dot.alt { background: var(--cr-success); }
ol { padding-left: 0; }
.hot-list { padding-left: 0;
  li { display: flex; align-items: center; gap: .5rem; padding: .5rem 0; border-bottom: 0.0625rem dashed #ebeef5; font-size: .8125rem; cursor: pointer;
    &:hover .title { color: var(--cr-primary); }
    .rank { width: 1.25rem; height: 1.25rem; background: #c0c4cc; color: #fff; text-align: center; line-height: 1.25rem; border-radius: .25rem; font-size: .75rem;
      &.top { background: var(--cr-danger); }
    }
    .title { flex: 1; color: var(--cr-text); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  }
}
@media (max-width: 56.25rem) {
  .layout { grid-template-columns: 1fr; }
  .aside { grid-template-rows: auto; }
}
@media (max-width: 35rem) {
  .news-row { flex-direction: column; }
  .news-row .cover { width: 100%; aspect-ratio: 16 / 9; }
}
</style>
