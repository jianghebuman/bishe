<template>
  <div class="home portal-content">
    <!-- 轮播图 -->
    <el-carousel height="clamp(13.75rem, 24vw, 22.5rem)" class="banner" v-if="home.banners?.length">
      <el-carousel-item v-for="b in home.banners" :key="b.id">
        <div class="banner-item" :style="{ backgroundImage: `url(${b.imageUrl})` }">
          <div class="banner-title">{{ b.title }}</div>
        </div>
      </el-carousel-item>
    </el-carousel>

    <!-- 快速搜索 -->
    <div class="search-bar page-card mt-20">
      <form class="search-form" @submit.prevent="goSearch">
        <el-select v-model="city" placeholder="城市" size="large" class="city-select">
          <el-option label="全部城市" value="" />
          <el-option v-for="c in cities" :key="c.dictValue" :label="c.dictLabel" :value="c.dictValue" />
        </el-select>
        <el-input
          v-model="kw"
          placeholder="搜索岗位、企业、技能关键词"
          size="large"
          clearable
          class="keyword-input"
        />
        <el-button type="primary" native-type="submit" size="large" class="search-button">
          <el-icon><Search /></el-icon>
          <span>搜索</span>
        </el-button>
      </form>
    </div>

    <!-- 热门岗位 -->
    <div class="section page-card mt-20">
      <div class="section-title flex-between">
        <span><el-icon><Briefcase /></el-icon> 热门岗位</span>
        <router-link to="/jobs" class="more">查看更多 ></router-link>
      </div>
      <div class="job-grid">
        <div v-for="j in home.hotJobs" :key="j.id">
          <div class="job-card" @click="$router.push(`/job/${j.id}`)">
            <h4>{{ j.title }}</h4>
            <p class="salary">{{ j.salaryMin }}-{{ j.salaryMax }}K</p>
            <p class="meta">{{ j.city }} · {{ j.education }} · {{ j.jobType === 1 ? '全职' : '实习' }}</p>
            <p class="company">{{ j.companyName || '名企推荐' }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- 推荐企业 -->
    <div class="section page-card mt-20">
      <div class="section-title flex-between">
        <span><el-icon><OfficeBuilding /></el-icon> 推荐企业</span>
        <router-link to="/enterprises" class="more">查看更多 ></router-link>
      </div>
      <div class="ent-grid">
        <div v-for="e in home.recommendEnterprises" :key="e.id">
          <div class="ent-card" @click="$router.push(`/enterprise/${e.id}`)">
            <el-avatar class="ent-avatar" :src="e.logo" shape="square"><el-icon><OfficeBuilding /></el-icon></el-avatar>
            <p class="name">{{ e.companyName }}</p>
            <p class="meta">{{ e.industry }} · {{ e.scale }}</p>
          </div>
        </div>
      </div>
    </div>

    <div class="info-grid mt-20">
      <!-- 宣讲会 -->
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
      <!-- 招聘会 -->
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
      <!-- 公告资讯 -->
      <div class="page-card list-card">
        <div class="section-title flex-between"><span>就业资讯</span><router-link to="/news" class="more">更多 ></router-link></div>
        <ul>
          <li v-for="n in home.announcements" :key="n.id" class="clickable" @click="$router.push(`/news/${n.id}`)">
            <span class="dot"></span>
            <span class="title">{{ n.title }}</span>
          </li>
        </ul>
      </div>
    </div>
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
.banner { border-radius: var(--cr-radius); overflow: hidden; border: 1px solid var(--cr-border-soft); box-shadow: var(--cr-shadow-soft); }
.banner-item { width: 100%; height: 100%; background-size: cover; background-position: center; position: relative; }
.banner-item::after { content: ""; position: absolute; inset: 0; background: linear-gradient(90deg, rgba(12,24,45,.72), rgba(12,24,45,.24) 52%, rgba(12,24,45,.08)); }
.banner-title { position: absolute; z-index: 1; bottom: clamp(1rem, 2vw, 1.5rem); left: clamp(1rem, 3vw, 2rem); max-width: min(34rem, calc(100% - 2rem)); color: #fff; font-size: clamp(1.25rem, 2.3vw, 1.875rem); line-height: 1.25; font-weight: 750; text-shadow: 0 .125rem .5rem rgba(0,0,0,.42); }
.search-bar { display: block; }
.search-form { width: 100%; display: grid; grid-template-columns: minmax(7rem, .24fr) minmax(14rem, 1fr) auto; gap: clamp(.5rem, 1.2vw, .875rem); align-items: stretch; }
.city-select,
.keyword-input,
.search-button { min-width: 0; }
.search-button { min-inline-size: clamp(6rem, 9vw, 8rem); }
.search-button span { white-space: nowrap; }
.section-title { font-size: clamp(1rem, 1.4vw, 1.125rem); font-weight: 750; margin-bottom: 1rem; color: var(--cr-text); gap: .75rem; .el-icon { vertical-align: middle; margin-right: .25rem; color: var(--cr-primary); } }
.more { color: var(--cr-text-muted); font-size: .875rem; font-weight: 600; white-space: nowrap; }
.more:hover { color: var(--cr-primary); }
.job-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 14rem), 1fr)); gap: .875rem; }
.ent-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 9.5rem), 1fr)); gap: .875rem; }
.info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 20rem), 1fr)); gap: clamp(.875rem, 1.6vw, 1.25rem); }
.job-card { height: 100%; background: var(--cr-surface-soft); border: 0.0625rem solid var(--cr-border-soft); border-radius: var(--cr-radius-sm); padding: 1rem; cursor: pointer; transition: border-color .2s ease, box-shadow .2s ease, transform .2s ease;
  &:hover { border-color: rgba(37,99,235,.26); box-shadow: var(--cr-shadow-soft); transform: translateY(-.125rem); }
  h4 { color: var(--cr-text); margin-bottom: .5rem; font-size: .9375rem; line-height: 1.4; }
  .salary { color: var(--cr-danger); font-size: 1rem; font-weight: 750; margin-bottom: .375rem; }
  .meta { color: var(--cr-text-muted); font-size: .75rem; margin-bottom: .375rem; }
  .company { color: var(--cr-text-soft); font-size: .8125rem; }
}
.ent-card { height: 100%; text-align: center; padding: 1rem .5rem; cursor: pointer; border-radius: var(--cr-radius-sm); transition: background .2s, transform .2s;
  &:hover { background: var(--cr-surface-soft); transform: translateY(-.0625rem); }
  .ent-avatar { --el-avatar-size: clamp(3rem, 5vw, 4rem); }
  .name { margin-top: .5rem; font-size: .875rem; color: var(--cr-text); line-height: 1.4; }
  .meta { font-size: .75rem; color: var(--cr-text-muted); margin-top: .25rem; }
}
.list-card ul li { display: flex; align-items: center; padding: .625rem 0; border-bottom: 1px dashed #ebeef5; font-size: .875rem;
  .dot { width: .25rem; height: .25rem; background: var(--cr-primary); border-radius: 50%; margin-right: .5rem; flex: 0 0 auto; }
  .title { flex: 1; color: var(--cr-text); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .time { color: var(--cr-text-muted); font-size: .75rem; margin-left: .75rem; white-space: nowrap; }
  &:last-child { border-bottom: none; }
}
.list-card .clickable { cursor: pointer; }

@media (min-width: 87.5rem) {
  .banner { :deep(.el-carousel__container) { height: 22.5rem !important; } }
  .ent-card { min-height: 9.5rem; }
}

@media (max-width: 48rem) {
  .banner { :deep(.el-carousel__container) { height: clamp(11rem, 42vw, 14rem) !important; } }
  .search-form { grid-template-columns: minmax(7rem, .42fr) minmax(0, 1fr); }
  .search-button { grid-column: 1 / -1; width: 100%; min-inline-size: 0; }
}

@media (max-width: 30rem) {
  .search-form { grid-template-columns: 1fr; }
  .section-title { align-items: flex-start; }
}
</style>
