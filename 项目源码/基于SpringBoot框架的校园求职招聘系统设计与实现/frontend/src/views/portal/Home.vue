<template>
  <div class="home portal-content">
    <section class="hero-shell">
      <div class="hero-copy">
        <p class="hero-kicker">Campus recruitment hub</p>
        <h1>校园求职招聘系统</h1>
        <p class="hero-subtitle">连接学生、企业与就业活动，把岗位检索、简历投递、宣讲招聘和在线沟通放进同一个清晰入口。</p>
        <form class="hero-search" @submit.prevent="goSearch">
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
            <span>搜索职位</span>
          </el-button>
        </form>
        <div class="hero-actions">
          <el-button type="primary" size="large" class="primary-pill" @click="$router.push('/jobs')">浏览职位</el-button>
          <el-button size="large" class="ghost-pill" @click="goProfileAction">发布或完善信息</el-button>
        </div>
      </div>
      <div class="hero-board">
        <div class="board-grid" aria-hidden="true">
          <span v-for="i in 40" :key="i"></span>
        </div>
        <div class="board-card board-card-main">
          <span class="board-label">今日推荐</span>
          <strong>{{ firstJob?.title || '前端开发工程师' }}</strong>
          <p>{{ firstJob?.companyName || '优质企业' }} · {{ firstJob?.city || '杭州' }}</p>
          <div class="salary-range">{{ formatSalary(firstJob) }}</div>
        </div>
        <div class="board-card board-card-side">
          <span class="board-label">招聘活动</span>
          <strong>{{ home.talks?.length || 0 }} 场宣讲</strong>
          <p>{{ nextTalk?.title || '校企宣讲与招聘会同步更新' }}</p>
        </div>
        <div class="board-card board-card-mini">
          <span>匹配流程</span>
          <b>岗位筛选</b>
          <b>简历投递</b>
          <b>在线沟通</b>
        </div>
      </div>
    </section>

    <section class="stats-strip">
      <div v-for="item in stats" :key="item.label" class="stat-item">
        <strong>{{ item.value }}</strong>
        <span>{{ item.label }}</span>
      </div>
    </section>

    <section v-if="home.banners?.length" class="banner-section">
      <el-carousel height="clamp(14rem, 28dvh, 34rem)" class="banner">
        <el-carousel-item v-for="b in home.banners" :key="b.id">
          <div class="banner-item" :style="{ backgroundImage: `url(${b.imageUrl})` }">
            <div class="banner-title">{{ b.title }}</div>
          </div>
        </el-carousel-item>
      </el-carousel>
    </section>

    <section class="section feature-section">
      <div class="section-heading">
        <p>核心功能</p>
        <h2>把校园招聘常用动作集中处理</h2>
      </div>
      <div class="feature-grid">
        <div v-for="feature in features" :key="feature.title" class="feature-card">
          <div class="feature-icon">{{ feature.mark }}</div>
          <h3>{{ feature.title }}</h3>
          <p>{{ feature.description }}</p>
        </div>
      </div>
    </section>

    <section class="section jobs-section">
      <div class="section-heading with-link">
        <div>
          <p>热门岗位</p>
          <h2>近期浏览与投递较高的机会</h2>
        </div>
        <router-link to="/jobs" class="more">查看更多</router-link>
      </div>
      <div class="job-grid">
        <article v-for="j in home.hotJobs" :key="j.id" class="job-card" @click="$router.push(`/job/${j.id}`)">
          <div class="job-topline">
            <span class="company-mark">{{ getCompanyMark(j.companyName) }}</span>
            <span>{{ j.jobType === 1 ? '全职' : '实习' }}</span>
          </div>
          <h3>{{ j.title }}</h3>
          <p class="salary">{{ formatSalary(j) }}</p>
          <div class="job-tags">
            <span>{{ j.city || '不限城市' }}</span>
            <span>{{ j.education || '学历不限' }}</span>
            <span>{{ j.experience || '经验不限' }}</span>
          </div>
          <p class="company">{{ j.companyName || '名企推荐' }}</p>
        </article>
        <div v-if="!home.hotJobs?.length" class="empty-card">
          <strong>暂无热门岗位</strong>
          <span>后端服务启动并返回数据后，这里会展示近期热门机会。</span>
        </div>
      </div>
    </section>

    <section class="section enterprise-section">
      <div class="section-heading with-link">
        <div>
          <p>推荐企业</p>
          <h2>认证企业持续发布校园岗位</h2>
        </div>
        <router-link to="/enterprises" class="more">查看更多</router-link>
      </div>
      <div class="ent-grid">
        <article v-for="e in home.recommendEnterprises" :key="e.id" class="ent-card" @click="$router.push(`/enterprise/${e.id}`)">
          <el-avatar class="ent-avatar" :src="e.logo" shape="square"><el-icon><OfficeBuilding /></el-icon></el-avatar>
          <div>
            <h3>{{ e.companyName }}</h3>
            <p>{{ e.industry || '综合行业' }} · {{ e.scale || '规模待完善' }}</p>
          </div>
        </article>
        <div v-if="!home.recommendEnterprises?.length" class="empty-card">
          <strong>暂无推荐企业</strong>
          <span>认证企业数据返回后会自动出现在这里。</span>
        </div>
      </div>
    </section>

    <section class="info-grid">
      <div class="list-card">
        <div class="section-title flex-between"><span>校园宣讲会</span><router-link to="/talks" class="more">更多</router-link></div>
        <ul>
          <li v-for="t in home.talks" :key="t.id" class="clickable" @click="$router.push(`/talk/${t.id}`)">
            <span class="dot"></span>
            <span class="title">{{ t.title }}</span>
            <span class="time">{{ formatDate(t.talkTime) }}</span>
          </li>
        </ul>
        <div v-if="!home.talks?.length" class="empty-list">暂无宣讲会信息</div>
      </div>
      <div class="list-card">
        <div class="section-title flex-between"><span>大型招聘会</span><router-link to="/fairs" class="more">更多</router-link></div>
        <ul>
          <li v-for="f in home.fairs" :key="f.id" class="clickable" @click="$router.push(`/fair/${f.id}`)">
            <span class="dot"></span>
            <span class="title">{{ f.title }}</span>
            <span class="time">{{ formatDate(f.fairTime) }}</span>
          </li>
        </ul>
        <div v-if="!home.fairs?.length" class="empty-list">暂无招聘会信息</div>
      </div>
      <div class="list-card">
        <div class="section-title flex-between"><span>就业资讯</span><router-link to="/news" class="more">更多</router-link></div>
        <ul>
          <li v-for="n in home.announcements" :key="n.id" class="clickable" @click="$router.push(`/news/${n.id}`)">
            <span class="dot"></span>
            <span class="title">{{ n.title }}</span>
          </li>
        </ul>
        <div v-if="!home.announcements?.length" class="empty-list">暂无就业资讯</div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { computed, ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Search, OfficeBuilding } from '@element-plus/icons-vue'
import { publicApi } from '@/api'
import { useUserStore } from '@/store/user'

const router = useRouter()
const userStore = useUserStore()
const home = reactive({ banners: [], hotJobs: [], recommendEnterprises: [], talks: [], fairs: [], announcements: [] })
const kw = ref('')
const city = ref('')
const cities = ref([])

const features = [
  { mark: '企', title: '企业招聘管理', description: '企业完成认证后发布岗位、管理投递与面试安排，减少线下沟通成本。' },
  { mark: '岗', title: '职位精准检索', description: '按城市、岗位、学历与类型筛选机会，学生能更快找到合适岗位。' },
  { mark: '简', title: '简历与投递跟踪', description: '在线维护简历、查看投递记录和面试通知，流程状态一目了然。' },
  { mark: '聊', title: '校企在线沟通', description: '通知和在线沟通联动，让学生与企业及时确认关键招聘信息。' }
]

const formatDate = (d) => d ? d.substring(0, 10) : ''
const goSearch = () => router.push({ path: '/jobs', query: { keyword: kw.value, city: city.value } })
const goProfileAction = () => {
  if (!userStore.isLogin) {
    router.push('/login')
  } else if (userStore.role === 'STUDENT') {
    router.push('/student/seeker-post')
  } else if (userStore.role === 'ENTERPRISE') {
    router.push('/enterprise/job')
  } else {
    router.push('/admin')
  }
}
const firstJob = computed(() => home.hotJobs?.[0])
const nextTalk = computed(() => home.talks?.[0])
const stats = computed(() => [
  { value: `${home.hotJobs?.length || 0}+`, label: '热门岗位' },
  { value: `${home.recommendEnterprises?.length || 0}+`, label: '认证企业' },
  { value: `${(home.talks?.length || 0) + (home.fairs?.length || 0)}+`, label: '招聘活动' },
  { value: `${home.announcements?.length || 0}+`, label: '就业资讯' }
])

const formatSalary = (job) => {
  if (!job || (!job.salaryMin && !job.salaryMax)) return '薪资面议'
  if (job.salaryMin && job.salaryMax) return `${job.salaryMin}-${job.salaryMax}K`
  return `${job.salaryMin || job.salaryMax}K起`
}

const getCompanyMark = (name) => (name || '企').trim().slice(0, 1)

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
.home {
  display: grid;
  gap: clamp(1.25rem, 2.5vw, 2rem);
}

.hero-shell {
  position: relative;
  overflow: hidden;
  min-height: min(42rem, calc(100dvh - 8.5rem));
  display: grid;
  grid-template-columns: minmax(38rem, 1fr) minmax(24rem, .9fr);
  align-items: center;
  gap: clamp(1.5rem, 4vw, 4rem);
  padding: clamp(2rem, 5vw, 5rem);
  border: 1px solid rgba(23, 32, 51, .08);
  border-radius: 1.375rem;
  background:
    linear-gradient(135deg, rgba(255,255,255,.98), rgba(245,248,252,.92)),
    radial-gradient(circle at 14% 16%, rgba(8,145,178,.16), transparent 30%);
  box-shadow: 0 1.5rem 4rem rgba(22, 38, 68, .1);
}

.hero-shell::before,
.hero-shell::after {
  content: "";
  position: absolute;
  pointer-events: none;
}

.hero-shell::before {
  inset: -35% -8% auto auto;
  width: 35rem;
  height: 35rem;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(37,99,235,.16), transparent 62%);
}

.hero-shell::after {
  inset: auto 4% -16% auto;
  width: 18rem;
  height: 18rem;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(8,145,178,.18), transparent 68%);
}

.hero-copy,
.hero-board {
  position: relative;
  z-index: 1;
}

.hero-kicker,
.section-heading p {
  color: var(--cr-accent);
  font-size: .8125rem;
  font-weight: 800;
  letter-spacing: .08em;
  text-transform: uppercase;
}

.hero-copy h1 {
  margin: .875rem 0 1rem;
  max-width: 52rem;
  color: #101418;
  font-size: clamp(3rem, 4.9vw, 5.75rem);
  line-height: .98;
  font-weight: 900;
}

.hero-subtitle {
  max-width: 42rem;
  color: var(--cr-text-soft);
  font-size: clamp(1rem, 1.4vw, 1.25rem);
  line-height: 1.8;
}

.hero-search {
  margin-top: clamp(1.25rem, 2.4vw, 2rem);
  width: min(48rem, 100%);
  display: grid;
  grid-template-columns: minmax(7rem, .25fr) minmax(13rem, 1fr) auto;
  gap: .625rem;
  padding: .625rem;
  border: 1px solid rgba(23, 32, 51, .08);
  border-radius: 1rem;
  background: rgba(255,255,255,.9);
  box-shadow: 0 .875rem 2rem rgba(22, 38, 68, .08);
}

.city-select,
.keyword-input,
.search-button {
  min-width: 0;
}

.hero-search :deep(.el-input__wrapper),
.hero-search :deep(.el-select__wrapper) {
  min-height: 2.875rem;
  border-radius: .75rem;
  box-shadow: none;
  background: #f6f8fb;
}

.search-button,
.primary-pill,
.ghost-pill {
  border-radius: 999rem;
  white-space: nowrap;
}

.search-button {
  min-inline-size: 7.25rem;
  background: #101418;
  border-color: #101418;
}

.search-button:hover,
.primary-pill:hover {
  background: #24282d;
  border-color: #24282d;
}

.hero-actions {
  margin-top: 1rem;
  display: flex;
  flex-wrap: wrap;
  gap: .75rem;
}

.primary-pill {
  min-width: 8.5rem;
  background: #101418;
  border-color: #101418;
}

.ghost-pill {
  min-width: 9.5rem;
  border-color: rgba(23,32,51,.13);
  color: var(--cr-text);
}

.hero-board {
  min-height: 33rem;
}

.board-grid {
  position: absolute;
  inset: 1.5rem 0 0 2rem;
  display: grid;
  grid-template-columns: repeat(8, 1fr);
  gap: .625rem;
  opacity: .45;
}

.board-grid span {
  aspect-ratio: 1;
  border-radius: .5rem;
  background: rgba(37,99,235,.08);
}

.board-card {
  position: absolute;
  border: 1px solid rgba(23,32,51,.08);
  border-radius: 1rem;
  background: rgba(255,255,255,.92);
  box-shadow: 0 1rem 2.75rem rgba(22, 38, 68, .12);
  backdrop-filter: blur(.75rem);
}

.board-card-main {
  top: 3.25rem;
  right: 0;
  width: min(28rem, 88%);
  padding: 1.5rem;
}

.board-card-side {
  bottom: 2.5rem;
  left: 0;
  width: min(23rem, 78%);
  padding: 1.25rem;
}

.board-card-mini {
  right: 2.5rem;
  bottom: 0;
  width: 12rem;
  padding: 1rem;
  display: grid;
  gap: .5rem;
  background: #101418;
  color: #fff;
}

.board-label,
.board-card-mini span {
  display: block;
  margin-bottom: .625rem;
  color: var(--cr-text-muted);
  font-size: .75rem;
  font-weight: 700;
}

.board-card strong {
  display: block;
  color: var(--cr-text);
  font-size: clamp(1.25rem, 2vw, 1.75rem);
  line-height: 1.25;
}

.board-card p {
  margin-top: .5rem;
  color: var(--cr-text-soft);
  line-height: 1.6;
}

.salary-range {
  margin-top: 1.25rem;
  color: var(--cr-danger);
  font-size: 1.75rem;
  font-weight: 900;
}

.board-card-mini b {
  padding: .625rem .75rem;
  border-radius: .75rem;
  background: rgba(255,255,255,.1);
  font-size: .875rem;
}

.stats-strip,
.section,
.list-card {
  border: 1px solid var(--cr-border-soft);
  border-radius: 1.125rem;
  background: rgba(255,255,255,.94);
  box-shadow: var(--cr-shadow-soft);
}

.stats-strip {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  overflow: hidden;
}

.stat-item {
  padding: clamp(1rem, 2vw, 1.5rem);
  display: grid;
  gap: .25rem;
  border-right: 1px solid var(--cr-border-soft);
}

.stat-item:last-child {
  border-right: 0;
}

.stat-item strong {
  color: var(--cr-text);
  font-size: clamp(1.625rem, 3vw, 2.75rem);
  line-height: 1;
}

.stat-item span {
  color: var(--cr-text-muted);
  font-size: .875rem;
  font-weight: 700;
}

.banner-section {
  display: block;
}

.banner {
  border-radius: 1.125rem;
  overflow: hidden;
  border: 1px solid var(--cr-border-soft);
  box-shadow: var(--cr-shadow-soft);
}

.banner-item {
  width: 100%;
  height: 100%;
  background-size: cover;
  background-position: center;
  position: relative;
}

.banner-item::after {
  content: "";
  position: absolute;
  inset: 0;
  background: linear-gradient(90deg, rgba(12,24,45,.72), rgba(12,24,45,.24) 52%, rgba(12,24,45,.08));
}

.banner-title {
  position: absolute;
  z-index: 1;
  bottom: clamp(1rem, 3dvh, 3rem);
  left: clamp(1rem, 4vw, 4rem);
  max-width: min(54rem, calc(100% - 2rem));
  color: #fff;
  font-size: clamp(1.25rem, 2.3vw, 3rem);
  line-height: 1.18;
  font-weight: 800;
  text-shadow: 0 .125rem .5rem rgba(0,0,0,.42);
}

.section {
  padding: clamp(1.25rem, 2.6vw, 2rem);
}

.section-heading {
  margin-bottom: 1.25rem;
}

.section-heading h2 {
  margin-top: .375rem;
  color: var(--cr-text);
  font-size: clamp(1.5rem, 2.4vw, 2.5rem);
  line-height: 1.18;
}

.section-heading.with-link {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  gap: 1rem;
}

.more {
  color: var(--cr-text-muted);
  font-size: .875rem;
  font-weight: 700;
  white-space: nowrap;
}

.more:hover {
  color: var(--cr-primary);
}

.feature-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 1rem;
}

.feature-card,
.job-card,
.ent-card {
  border: 1px solid var(--cr-border-soft);
  border-radius: 1rem;
  background: var(--cr-surface);
  transition: border-color .2s ease, box-shadow .2s ease, transform .2s ease;
}

.feature-card {
  padding: 1.25rem;
}

.feature-card:hover,
.job-card:hover,
.ent-card:hover {
  border-color: rgba(16,20,24,.2);
  box-shadow: 0 .875rem 1.75rem rgba(22, 38, 68, .08);
  transform: translateY(-.125rem);
}

.feature-icon,
.company-mark {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: .875rem;
  background: #101418;
  color: #fff;
  font-weight: 900;
}

.feature-icon {
  width: 3rem;
  height: 3rem;
  margin-bottom: 1rem;
  font-size: 1rem;
}

.feature-card h3,
.job-card h3,
.ent-card h3 {
  color: var(--cr-text);
  font-size: 1rem;
  line-height: 1.4;
}

.feature-card p {
  margin-top: .5rem;
  color: var(--cr-text-soft);
  line-height: 1.7;
  font-size: .875rem;
}

.job-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 16rem), 1fr));
  gap: 1rem;
}

.job-card {
  min-height: 13.25rem;
  padding: 1.125rem;
  cursor: pointer;
}

.empty-card {
  grid-column: 1 / -1;
  min-height: 8rem;
  display: grid;
  place-items: center;
  gap: .375rem;
  text-align: center;
  border: 1px dashed var(--cr-border);
  border-radius: 1rem;
  background: #f8fbff;
  color: var(--cr-text-muted);
}

.empty-card strong {
  color: var(--cr-text-soft);
  font-size: 1rem;
}

.empty-card span {
  font-size: .875rem;
}

.job-topline {
  margin-bottom: 1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: .75rem;
  color: var(--cr-text-muted);
  font-size: .8125rem;
  font-weight: 700;
}

.company-mark {
  width: 2.25rem;
  height: 2.25rem;
  border-radius: 50%;
}

.salary {
  margin-top: .625rem;
  color: var(--cr-danger);
  font-size: 1.25rem;
  font-weight: 900;
}

.job-tags {
  margin-top: .875rem;
  display: flex;
  flex-wrap: wrap;
  gap: .5rem;
}

.job-tags span {
  padding: .3125rem .625rem;
  border-radius: 999rem;
  background: #f3f6fa;
  color: var(--cr-text-soft);
  font-size: .75rem;
}

.company {
  margin-top: 1rem;
  color: var(--cr-text-muted);
  font-size: .875rem;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.ent-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 16rem), 1fr));
  gap: 1rem;
}

.ent-card {
  min-height: 6.5rem;
  display: flex;
  align-items: center;
  gap: .875rem;
  padding: 1rem;
  cursor: pointer;
}

.ent-avatar {
  --el-avatar-size: 3.25rem;
  flex: 0 0 auto;
}

.ent-card p {
  margin-top: .375rem;
  color: var(--cr-text-muted);
  font-size: .8125rem;
  line-height: 1.5;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: clamp(.875rem, 1.6vw, 1.25rem);
}

.list-card {
  min-height: 18rem;
  padding: clamp(1rem, 1.8vw, 1.375rem);
}

.section-title {
  font-size: clamp(1rem, 1.4vw, 1.125rem);
  font-weight: 800;
  margin-bottom: 1rem;
  color: var(--cr-text);
  gap: .75rem;
}

.list-card ul li {
  display: flex;
  align-items: center;
  padding: .75rem 0;
  border-bottom: 1px dashed #e4eaf3;
  font-size: .875rem;
}

.list-card ul li:last-child {
  border-bottom: none;
}

.dot {
  width: .375rem;
  height: .375rem;
  background: #101418;
  border-radius: 50%;
  margin-right: .625rem;
  flex: 0 0 auto;
}

.title {
  flex: 1;
  color: var(--cr-text);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.time {
  color: var(--cr-text-muted);
  font-size: .75rem;
  margin-left: .75rem;
  white-space: nowrap;
}

.clickable {
  cursor: pointer;
}

.empty-list {
  min-height: 10rem;
  display: grid;
  place-items: center;
  color: var(--cr-text-muted);
  font-size: .875rem;
  border-radius: .875rem;
  background: #f8fbff;
}

@media (min-width: 75rem) {
  .job-grid {
    grid-template-columns: repeat(5, minmax(0, 1fr));
  }
}

@media (min-width: 100rem) {
  .hero-shell {
    grid-template-columns: minmax(46rem, .96fr) minmax(32rem, 1fr);
    padding: clamp(4rem, 5vw, 6.5rem);
  }

  .hero-copy h1 {
    max-width: 58rem;
    font-size: clamp(5.25rem, 5vw, 6.25rem);
  }

  .hero-subtitle {
    max-width: 48rem;
  }

  .hero-board {
    min-height: 38rem;
  }

  .board-card-main {
    top: 4rem;
    right: 2rem;
  }

  .board-card-side {
    bottom: 4.25rem;
    left: 1.5rem;
  }

  .board-card-mini {
    right: 5rem;
    width: 13rem;
  }

  .feature-grid {
    grid-template-columns: repeat(4, minmax(0, 1fr));
  }

  .ent-grid {
    grid-template-columns: repeat(4, minmax(0, 1fr));
  }
}

@media (min-width: 120rem) {
  .home {
    gap: 2.5rem;
  }

  .hero-shell {
    min-height: min(46rem, calc(100dvh - 8rem));
    grid-template-columns: minmax(52rem, .95fr) minmax(38rem, 1fr);
  }

  .job-grid {
    grid-template-columns: repeat(5, minmax(0, 1fr));
    gap: 1.25rem;
  }

  .feature-grid,
  .ent-grid,
  .info-grid {
    gap: 1.25rem;
  }

  .section,
  .list-card {
    padding: 2rem;
  }
}

@media (max-width: 68.75rem) {
  .hero-shell {
    grid-template-columns: 1fr;
    min-height: 0;
  }

  .hero-board {
    min-height: 24rem;
  }

  .feature-grid,
  .info-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 48rem) {
  .hero-shell {
    padding: 1.25rem;
    border-radius: 1rem;
  }

  .hero-copy h1 {
    font-size: clamp(2.25rem, 14vw, 3.75rem);
  }

  .hero-search {
    grid-template-columns: minmax(0, 1fr) minmax(5.25rem, auto);
    gap: .625rem;
    padding: .5rem;
  }

  .keyword-input {
    grid-column: 1 / -1;
    order: 1;
  }

  .city-select {
    grid-column: 1;
    order: 2;
  }

  .search-button {
    grid-column: 2;
    order: 2;
    min-inline-size: 5.25rem;
    padding-inline: .75rem;
  }

  .hero-board {
    min-height: 21rem;
  }

  .board-grid {
    inset: 1rem;
  }

  .board-card-main {
    top: 1.25rem;
    width: 88%;
  }

  .board-card-side {
    bottom: 2.75rem;
    width: 80%;
  }

  .board-card-mini {
    right: .5rem;
    width: 9.5rem;
  }

  .stats-strip,
  .feature-grid,
  .info-grid {
    grid-template-columns: 1fr;
  }

  .stat-item {
    border-right: 0;
    border-bottom: 1px solid var(--cr-border-soft);
  }

  .stat-item:last-child {
    border-bottom: 0;
  }

  .section-heading.with-link {
    align-items: flex-start;
  }

  .banner :deep(.el-carousel__container) {
    height: clamp(10.5rem, 52vw, 13.5rem) !important;
  }

  .banner-item::after {
    background: linear-gradient(180deg, rgba(12,24,45,.06), rgba(12,24,45,.24) 48%, rgba(12,24,45,.78));
  }

  .banner-title {
    right: .875rem;
    bottom: .875rem;
    left: .875rem;
    max-width: none;
    font-size: clamp(1.0625rem, 5vw, 1.375rem);
    line-height: 1.22;
    display: -webkit-box;
    overflow: hidden;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
  }
}

@media (max-width: 30rem) {
  .hero-actions :deep(.el-button) {
    flex: 1 1 100%;
  }
}
</style>
