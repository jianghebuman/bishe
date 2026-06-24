<template>
  <div class="home portal-content">
    <!-- 轮播图 -->
    <el-carousel height="320px" class="banner" v-if="home.banners?.length">
      <el-carousel-item v-for="b in home.banners" :key="b.id">
        <div class="banner-item" :style="{ backgroundImage: `url(${b.imageUrl})` }">
          <div class="banner-title">{{ b.title }}</div>
        </div>
      </el-carousel-item>
    </el-carousel>

    <!-- 快速搜索 -->
    <div class="search-bar page-card mt-20">
      <el-input v-model="kw" placeholder="搜索岗位、企业、技能关键词" size="large" style="flex: 1;" @keyup.enter="goSearch">
        <template #prepend>
          <el-select v-model="city" placeholder="城市" style="width: 110px">
            <el-option label="全部城市" value="" />
            <el-option v-for="c in cities" :key="c.dictValue" :label="c.dictLabel" :value="c.dictValue" />
          </el-select>
        </template>
        <template #append>
          <el-button type="primary" @click="goSearch"><el-icon><Search /></el-icon>&nbsp;搜索</el-button>
        </template>
      </el-input>
    </div>

    <!-- 热门岗位 -->
    <div class="section page-card mt-20">
      <div class="section-title flex-between">
        <span><el-icon><Briefcase /></el-icon> 热门岗位</span>
        <router-link to="/jobs" class="more">查看更多 ></router-link>
      </div>
      <el-row :gutter="16">
        <el-col :xs="24" :sm="12" :lg="6" :xl="4" v-for="j in home.hotJobs" :key="j.id">
          <div class="job-card" @click="$router.push(`/job/${j.id}`)">
            <h4>{{ j.title }}</h4>
            <p class="salary">{{ j.salaryMin }}-{{ j.salaryMax }}K</p>
            <p class="meta">{{ j.city }} · {{ j.education }} · {{ j.jobType === 1 ? '全职' : '实习' }}</p>
            <p class="company">{{ j.companyName || '名企推荐' }}</p>
          </div>
        </el-col>
      </el-row>
    </div>

    <!-- 推荐企业 -->
    <div class="section page-card mt-20">
      <div class="section-title flex-between">
        <span><el-icon><OfficeBuilding /></el-icon> 推荐企业</span>
        <router-link to="/enterprises" class="more">查看更多 ></router-link>
      </div>
      <el-row :gutter="16">
        <el-col :xs="12" :sm="8" :md="6" :lg="4" :xl="3" v-for="e in home.recommendEnterprises" :key="e.id">
          <div class="ent-card" @click="$router.push(`/enterprise/${e.id}`)">
            <el-avatar :size="64" :src="e.logo" shape="square"><el-icon><OfficeBuilding /></el-icon></el-avatar>
            <p class="name">{{ e.companyName }}</p>
            <p class="meta">{{ e.industry }} · {{ e.scale }}</p>
          </div>
        </el-col>
      </el-row>
    </div>

    <el-row :gutter="20" class="mt-20">
      <!-- 宣讲会 -->
      <el-col :xs="24" :lg="8">
        <div class="page-card list-card">
          <div class="section-title flex-between"><span>校园宣讲会</span><router-link to="/talks" class="more">更多 ></router-link></div>
          <ul>
            <li v-for="t in home.talks" :key="t.id">
              <span class="dot"></span>
              <span class="title">{{ t.title }}</span>
              <span class="time">{{ formatDate(t.talkTime) }}</span>
            </li>
          </ul>
        </div>
      </el-col>
      <!-- 招聘会 -->
      <el-col :xs="24" :lg="8">
        <div class="page-card list-card">
          <div class="section-title flex-between"><span>大型招聘会</span><router-link to="/fairs" class="more">更多 ></router-link></div>
          <ul>
            <li v-for="f in home.fairs" :key="f.id">
              <span class="dot"></span>
              <span class="title">{{ f.title }}</span>
              <span class="time">{{ formatDate(f.fairTime) }}</span>
            </li>
          </ul>
        </div>
      </el-col>
      <!-- 公告资讯 -->
      <el-col :xs="24" :lg="8">
        <div class="page-card list-card">
          <div class="section-title flex-between"><span>就业资讯</span><router-link to="/news" class="more">更多 ></router-link></div>
          <ul>
            <li v-for="n in home.announcements" :key="n.id" @click="$router.push(`/news/${n.id}`)" style="cursor: pointer;">
              <span class="dot"></span>
              <span class="title">{{ n.title }}</span>
            </li>
          </ul>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Search, Briefcase, OfficeBuilding } from '@element-plus/icons-vue'
import { publicApi } from '@/api'

const router = useRouter()
const home = reactive({ banners: [], hotJobs: [], recommendEnterprises: [], talks: [], fairs: [], announcements: [] })
const kw = ref('')
const city = ref('')
const cities = ref([])

const formatDate = (d) => d ? d.substring(0, 10) : ''
const goSearch = () => router.push({ path: '/jobs', query: { keyword: kw.value, city: city.value } })

onMounted(async () => {
  try {
    const res = await publicApi.home()
    Object.assign(home, res.data)
  } catch (e) {}
  try {
    const r = await publicApi.dict('city')
    cities.value = r.data
  } catch (e) {}
})
</script>

<style scoped lang="scss">
.banner { border-radius: 8px; overflow: hidden; }
.banner-item { width: 100%; height: 100%; background-size: cover; background-position: center; position: relative; }
.banner-title { position: absolute; bottom: 20px; left: 30px; color: #fff; font-size: 24px; font-weight: 600; text-shadow: 0 2px 8px rgba(0,0,0,.5); }
.search-bar { display: flex; }
.section-title { font-size: 18px; font-weight: 600; margin-bottom: 16px; .el-icon { vertical-align: middle; margin-right: 4px; } }
.more { color: #909399; font-size: 14px; font-weight: normal; }
.job-card { background: #f5f7fa; border-radius: 6px; padding: 16px; margin-bottom: 12px; cursor: pointer; transition: all .2s;
  &:hover { box-shadow: 0 4px 12px rgba(0,0,0,.1); transform: translateY(-2px); }
  h4 { color: #303133; margin-bottom: 8px; font-size: 15px; }
  .salary { color: #f56c6c; font-size: 16px; font-weight: 600; margin-bottom: 6px; }
  .meta { color: #909399; font-size: 12px; margin-bottom: 6px; }
  .company { color: #606266; font-size: 13px; }
}
.ent-card { text-align: center; padding: 16px 8px; cursor: pointer; border-radius: 6px; transition: background .2s;
  &:hover { background: #f5f7fa; }
  .name { margin-top: 8px; font-size: 14px; color: #303133; }
  .meta { font-size: 12px; color: #909399; margin-top: 4px; }
}
.list-card ul li { display: flex; align-items: center; padding: 10px 0; border-bottom: 1px dashed #ebeef5; font-size: 14px;
  .dot { width: 4px; height: 4px; background: #409eff; border-radius: 50%; margin-right: 8px; }
  .title { flex: 1; color: #303133; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .time { color: #909399; font-size: 12px; }
  &:last-child { border-bottom: none; }
}

@media (min-width: 1400px) {
  .banner { :deep(.el-carousel__container) { height: 360px !important; } }
  .job-card { min-height: 118px; }
  .ent-card { min-height: 150px; }
}

@media (max-width: 768px) {
  .banner { :deep(.el-carousel__container) { height: 220px !important; } }
  .banner-title { left: 18px; bottom: 16px; font-size: 20px; }
  .search-bar { padding: 14px; }
  .search-bar :deep(.el-input-group__prepend) { padding: 0 8px; }
  .search-bar :deep(.el-input-group__append) { padding: 0; }
  .search-bar :deep(.el-button) { padding: 0 12px; }
  .section-title { font-size: 16px; }
  .list-card { margin-bottom: 16px; }
}
</style>
