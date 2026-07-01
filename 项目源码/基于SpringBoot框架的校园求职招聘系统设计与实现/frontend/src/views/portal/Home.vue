<template>
  <div class="home portal-content">
    <section class="hero-shell">
      <BackgroundPaths3d class="hero-paths-3d" variant="light" :density="20" />
      <div class="cr-aurora-layer hero-aurora" aria-hidden="true"></div>
      <div class="cr-light-rays-layer hero-rays" aria-hidden="true"><i></i><i></i><i></i></div>
      <div class="meteor-layer hero-meteors" aria-hidden="true">
        <span v-for="meteor in heroMeteors" :key="meteor.left" :style="meteor"></span>
      </div>
      <div class="hero-copy">
        <p class="hero-kicker text-animate-line" style="--text-delay: .02s">Campus recruitment hub</p>
        <h1 class="animated-gradient-text text-animate-word" style="--text-delay: .08s">校园求职招聘系统</h1>
        <p class="hero-subtitle text-animate-line" style="--text-delay: .24s">
          连接学生、企业与就业活动，把<span class="text-highlighter">岗位检索</span>、<span class="text-highlighter">简历投递</span>、<span class="text-highlighter">宣讲招聘</span>和<span class="text-highlighter">在线沟通</span>放进同一个清晰入口。
        </p>
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
          <div class="meteor-layer mini-meteors" aria-hidden="true">
            <span v-for="meteor in miniMeteors" :key="`${meteor.top}-${meteor.left}`" :style="meteor"></span>
          </div>
          <div class="flow-card-head">
            <span>匹配流程</span>
            <strong>3 步完成</strong>
          </div>
          <div class="flow-steps">
            <div class="flow-step">
              <i>01</i>
              <b>岗位筛选</b>
            </div>
            <div class="flow-step">
              <i>02</i>
              <b>简历投递</b>
            </div>
            <div class="flow-step">
              <i>03</i>
              <b>在线沟通</b>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section class="stats-strip">
      <div v-for="item in stats" :key="item.label" class="stat-item">
        <strong>{{ item.value }}</strong>
        <span>{{ item.label }}</span>
      </div>
    </section>

    <section class="activity-marquee section" aria-label="校园招聘动态">
      <div class="marquee-head text-animate-on-view">
        <span>校招现场</span>
        <strong><span class="text-highlighter text-highlighter-soft">岗位、企业、宣讲</span>持续更新</strong>
      </div>
      <div class="marquee-viewport">
        <div class="marquee-track">
          <div v-for="copy in 2" :key="copy" class="marquee-group" :aria-hidden="copy === 2">
            <router-link
              v-for="(item, index) in marqueeItems"
              :key="`${copy}-${index}-${item.type}`"
              :to="item.to"
              class="marquee-chip"
              :tabindex="copy === 2 ? -1 : 0"
              :aria-label="`查看${item.type}：${item.title}`"
            >
              <span>{{ item.type }}</span>
              <strong>{{ item.title }}</strong>
              <em>{{ item.meta }}</em>
            </router-link>
          </div>
        </div>
      </div>
    </section>

    <section class="section jobs-section">
      <div class="section-heading with-link text-animate-on-view">
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
      <div class="section-heading with-link text-animate-on-view">
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
import BackgroundPaths3d from '@/components/BackgroundPaths3d.vue'

const router = useRouter()
const userStore = useUserStore()
const home = reactive({ hotJobs: [], recommendEnterprises: [], talks: [], fairs: [], announcements: [] })
const kw = ref('')
const city = ref('')
const cities = ref([])

const heroMeteors = [
  { top: '-8%', left: '58%', '--meteor-travel': '-34rem', animationDelay: '.2s', animationDuration: '8s' },
  { top: '2%', left: '74%', '--meteor-travel': '-30rem', animationDelay: '1.8s', animationDuration: '9.5s' },
  { top: '15%', left: '92%', '--meteor-travel': '-36rem', animationDelay: '3.1s', animationDuration: '10s' },
  { top: '32%', left: '84%', '--meteor-travel': '-26rem', animationDelay: '4.6s', animationDuration: '8.5s' },
  { top: '49%', left: '96%', '--meteor-travel': '-32rem', animationDelay: '6.2s', animationDuration: '11s' }
]
const miniMeteors = [
  { top: '8%', left: '80%', '--meteor-travel': '-9rem', animationDelay: '.4s', animationDuration: '5.5s' },
  { top: '36%', left: '96%', '--meteor-travel': '-8rem', animationDelay: '2.2s', animationDuration: '6.5s' },
  { top: '68%', left: '72%', '--meteor-travel': '-7rem', animationDelay: '3.8s', animationDuration: '6s' }
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
const fallbackMarqueeItems = [
  { type: '热招岗位', title: '前端开发工程师', meta: '杭州 · 18-28K', to: '/jobs' },
  { type: '认证企业', title: '星火人工智能科技有限公司', meta: '人工智能 · 校招中', to: '/enterprises' },
  { type: '校园宣讲', title: '量海数据 BI 与分析宣讲会', meta: '本周更新', to: '/talks' },
  { type: '招聘会', title: '春季校园双选会', meta: '多企业参与', to: '/fairs' },
  { type: '就业资讯', title: '简历投递与面试节奏指南', meta: '学生推荐', to: '/news' }
]
const marqueeItems = computed(() => {
  const items = []
  home.hotJobs?.slice(0, 5).forEach((j) => {
    items.push({ type: '热招岗位', title: j.title || '优质岗位', meta: `${j.city || '不限城市'} · ${formatSalary(j)}`, to: j.id ? `/job/${j.id}` : '/jobs' })
  })
  home.recommendEnterprises?.slice(0, 4).forEach((e) => {
    items.push({ type: '认证企业', title: e.companyName || '认证企业', meta: `${e.industry || '综合行业'} · 校招中`, to: e.id ? `/enterprise/${e.id}` : '/enterprises' })
  })
  home.talks?.slice(0, 3).forEach((t) => {
    items.push({ type: '校园宣讲', title: t.title || '校园宣讲会', meta: formatDate(t.talkTime) || '时间待定', to: t.id ? `/talk/${t.id}` : '/talks' })
  })
  home.fairs?.slice(0, 2).forEach((f) => {
    items.push({ type: '招聘会', title: f.title || '大型招聘会', meta: formatDate(f.fairTime) || '时间待定', to: f.id ? `/fair/${f.id}` : '/fairs' })
  })
  home.announcements?.slice(0, 3).forEach((n) => {
    items.push({ type: '就业资讯', title: n.title || '就业资讯', meta: '最新发布', to: n.id ? `/news/${n.id}` : '/news' })
  })
  return (items.length ? items : fallbackMarqueeItems).slice(0, 14)
})

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
  border: 1px solid rgba(203, 216, 231, .78);
  border-radius: var(--cr-radius);
  background:
    var(--cr-noise-texture),
    linear-gradient(115deg, rgba(255,255,255,.98) 0%, rgba(247,251,255,.94) 45%, rgba(231,242,245,.92) 100%),
    linear-gradient(90deg, rgba(15, 118, 110, .09) 1px, transparent 1px),
    linear-gradient(0deg, rgba(36, 84, 214, .06) 1px, transparent 1px);
  background-size: 180px 180px, auto, 2.25rem 2.25rem, 2.25rem 2.25rem;
  background-blend-mode: soft-light, normal, normal, normal;
  box-shadow: var(--cr-shadow);
}

.hero-rays {
  --cr-rays-color: rgba(82, 162, 255, 0.24);
  --cr-rays-opacity: 0.42;
  --cr-rays-length: 75%;
}

.hero-aurora {
  --cr-aurora-opacity: 0.3;
  --cr-aurora-primary: rgba(36, 84, 214, 0.28);
  --cr-aurora-secondary: rgba(15, 118, 110, 0.24);
  --cr-aurora-tertiary: rgba(34, 211, 238, 0.16);
  --cr-aurora-blur: 1.5rem;
  --cr-aurora-x: 82%;
  --cr-aurora-y: 8%;
  inset: -30% -18% -8% -14%;
}

.hero-paths-3d {
  --paths-3d-opacity: 0.36;
  --paths-3d-blend: multiply;
  inset: -7% -4% -5% -12%;
}

.meteor-layer {
  position: absolute;
  inset: 0;
  overflow: hidden;
  pointer-events: none;
}

.meteor-layer span {
  --meteor-angle: 215deg;
  --meteor-travel: -28rem;
  position: absolute;
  width: .1875rem;
  height: .1875rem;
  border-radius: 999rem;
  background: rgba(36, 84, 214, .48);
  box-shadow: 0 0 0 .0625rem rgba(255,255,255,.18), 0 0 1rem rgba(36,84,214,.18);
  opacity: 0;
  transform: rotate(var(--meteor-angle)) translateX(0);
  animation: meteor-flight linear infinite;
}

.meteor-layer span::after {
  content: "";
  position: absolute;
  top: 50%;
  right: 0;
  width: 4.75rem;
  height: .0625rem;
  transform: translateY(-50%);
  border-radius: 999rem;
  background: linear-gradient(90deg, rgba(36,84,214,.34), transparent);
}

.hero-meteors {
  z-index: 0;
  opacity: .5;
  mix-blend-mode: multiply;
}

.hero-shell::before,
.hero-shell::after {
  content: "";
  position: absolute;
  pointer-events: none;
}

.hero-shell::before {
  inset: 0 auto 0 0;
  width: 0.5rem;
  background: linear-gradient(180deg, var(--cr-primary), var(--cr-accent));
}

.hero-shell::after {
  inset: auto clamp(1.5rem, 4vw, 4rem) clamp(1.5rem, 4vw, 4rem) auto;
  width: min(26rem, 34vw);
  height: 0.0625rem;
  background: linear-gradient(90deg, transparent, rgba(16, 24, 39, 0.28));
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
  letter-spacing: 0;
}

.hero-copy h1 {
  margin: .875rem 0 1rem;
  max-width: 52rem;
  font-size: clamp(3rem, 4.9vw, 5.5rem);
  line-height: 1.02;
  font-weight: 900;
}

.hero-copy h1 span {
  display: inline-block;
}

.text-animate-word,
.text-animate-line,
.text-animate-on-view {
  --text-delay: 0s;
  opacity: 0;
  transform: translateY(.8rem);
  filter: blur(.5rem);
  animation: text-blur-in-up .72s cubic-bezier(.2, .75, .2, 1) forwards;
  animation-delay: var(--text-delay);
  will-change: opacity, transform, filter;
}

.text-animate-line,
.text-animate-on-view {
  display: block;
}

.text-animate-on-view {
  animation-timeline: view();
  animation-range: entry 0% cover 28%;
}

.animated-gradient-text {
  --gradient-size: 280%;
  background: linear-gradient(90deg, var(--cr-primary), var(--cr-accent), #2e6de8, var(--cr-primary));
  background-size: var(--gradient-size) 100%;
  background-clip: text;
  -webkit-background-clip: text;
  animation: text-gradient-flow 7.5s linear infinite;
  -webkit-text-fill-color: transparent;
}

.animated-gradient-text.text-animate-word {
  animation:
    text-blur-in-up .72s cubic-bezier(.2, .75, .2, 1) var(--text-delay) forwards,
    text-gradient-flow 7.5s linear infinite;
}

.text-highlighter {
  position: relative;
  z-index: 0;
  display: inline-block;
  color: color-mix(in srgb, var(--cr-text) 88%, var(--cr-accent));
  font-weight: 800;
}

.text-highlighter::after {
  position: absolute;
  z-index: -1;
  right: -.12em;
  bottom: .04em;
  left: -.12em;
  height: .45em;
  content: "";
  border-radius: 999rem 70% 82% 65%;
  background: linear-gradient(90deg, rgba(15, 118, 110, .20), rgba(36, 84, 214, .16));
  transform: rotate(-1.1deg) scaleX(.98);
  transform-origin: left center;
  animation: marker-swipe .72s ease-out both;
}

.text-highlighter-soft {
  font-weight: 900;
}

.text-highlighter-soft::after {
  height: .5em;
  opacity: .72;
}

.hero-subtitle {
  max-width: 42rem;
  color: var(--cr-text-soft);
  font-size: clamp(1rem, 1.4vw, 1.25rem);
  line-height: 1.8;
}

.hero-search {
  --shine-border-duration: 16s;
  --shine-border-opacity: .62;
  margin-top: clamp(1.25rem, 2.4vw, 2rem);
  width: min(48rem, 100%);
  position: relative;
  isolation: isolate;
  overflow: hidden;
  display: grid;
  grid-template-columns: minmax(7rem, .25fr) minmax(13rem, 1fr) auto;
  gap: .625rem;
  padding: .625rem;
  border: 1px solid rgba(203, 216, 231, .9);
  border-radius: var(--cr-radius);
  background: rgba(255,255,255,.86);
  box-shadow: var(--cr-shadow-soft), var(--cr-shadow-line);
}

.hero-search::before,
.board-card-main::before,
.job-card::before {
  content: "";
  position: absolute;
  inset: 0;
  z-index: 3;
  padding: var(--shine-border-width, 1px);
  border-radius: inherit;
  background-image: radial-gradient(circle, transparent 0 36%, rgba(15, 118, 110, .78), rgba(36, 84, 214, .68), transparent 66%);
  background-position: 0% 0%;
  background-size: 300% 300%;
  opacity: var(--shine-border-opacity, .55);
  pointer-events: none;
  -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  mask-composite: exclude;
  animation: shine-border-flow var(--shine-border-duration, 14s) linear infinite;
}

.city-select,
.keyword-input,
.search-button {
  min-width: 0;
}

.hero-search :deep(.el-input__wrapper),
.hero-search :deep(.el-select__wrapper) {
  min-height: 2.875rem;
  border-radius: var(--cr-radius-sm);
  box-shadow: none;
  background: #f6f8fb;
}

.search-button,
.primary-pill,
.ghost-pill {
  border-radius: var(--cr-radius-sm);
  white-space: nowrap;
}

.search-button {
  min-inline-size: 7.25rem;
  background: var(--cr-primary);
  border-color: var(--cr-primary);
}

.search-button:hover,
.primary-pill:hover {
  background: var(--cr-primary-strong);
  border-color: var(--cr-primary-strong);
}

.hero-actions {
  margin-top: 1rem;
  display: flex;
  flex-wrap: wrap;
  gap: .75rem;
}

.primary-pill {
  min-width: 8.5rem;
  background: var(--cr-primary);
  border-color: var(--cr-primary);
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
  opacity: .48;
}

.board-grid span {
  aspect-ratio: 1;
  border-radius: var(--cr-radius-sm);
  background: rgba(36,84,214,.08);
}

.board-card {
  position: absolute;
  border: 1px solid rgba(203,216,231,.9);
  border-radius: var(--cr-radius);
  background:
    var(--cr-noise-texture),
    rgba(255,255,255,.97);
  background-size: 180px 180px, auto;
  background-blend-mode: soft-light, normal;
  box-shadow: var(--cr-shadow-soft), var(--cr-shadow-line);
  backdrop-filter: blur(.75rem);
}

.board-card-main {
  --shine-border-duration: 18s;
  --shine-border-opacity: .46;
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
  width: 15.5rem;
  padding: 1.125rem;
  display: grid;
  gap: 1rem;
  background:
    radial-gradient(circle at 86% 100%, rgba(34, 211, 238, .16), transparent 38%),
    radial-gradient(circle at 0% 0%, rgba(36, 84, 214, .28), transparent 42%),
    linear-gradient(180deg, #16263d, var(--cr-sidebar-2));
  color: #fff;
  overflow: hidden;
}

.mini-meteors {
  z-index: 0;
  border-radius: inherit;
  opacity: .42;
}

.mini-meteors span {
  background: rgba(125, 211, 252, .58);
  box-shadow: 0 0 .65rem rgba(125,211,252,.22);
}

.mini-meteors span::after {
  width: 2.75rem;
  background: linear-gradient(90deg, rgba(125,211,252,.5), transparent);
}

.board-label {
  position: relative;
  z-index: 1;
  display: block;
  margin-bottom: .625rem;
  color: var(--cr-text-muted);
  font-size: .75rem;
  font-weight: 700;
}

.flow-card-head {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: .75rem;
}

.flow-card-head span {
  color: rgba(226, 237, 248, .74);
  font-size: .75rem;
  font-weight: 800;
}

.flow-card-head strong {
  color: #fff;
  font-size: 1.125rem;
  line-height: 1;
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

.flow-steps {
  position: relative;
  z-index: 1;
  display: grid;
  gap: .625rem;
}

.flow-steps::before {
  position: absolute;
  top: 1.1rem;
  bottom: 1.1rem;
  left: 1rem;
  width: .0625rem;
  content: "";
  background: linear-gradient(180deg, rgba(125,211,252,.7), rgba(255,255,255,.12));
}

.flow-step {
  position: relative;
  display: grid;
  grid-template-columns: 2rem minmax(0, 1fr);
  align-items: center;
  gap: .75rem;
  min-height: 2.75rem;
  padding: .625rem .75rem .625rem .625rem;
  border-radius: var(--cr-radius-sm);
  border: 1px solid rgba(255,255,255,.08);
  background: linear-gradient(135deg, rgba(255,255,255,.14), rgba(255,255,255,.07));
  box-shadow: inset 0 1px 0 rgba(255,255,255,.08);
}

.flow-step i {
  position: relative;
  z-index: 1;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 2.25rem;
  height: 2.25rem;
  border-radius: 999rem;
  background: linear-gradient(135deg, rgba(125,211,252,.95), rgba(36,84,214,.95));
  color: #fff;
  font-size: .6875rem;
  font-style: normal;
  font-weight: 900;
  box-shadow: 0 .5rem 1rem rgba(8, 145, 178, .22);
}

.flow-step b {
  position: relative;
  z-index: 1;
  color: #fff;
  font-size: .9375rem;
  line-height: 1.1;
}

.stats-strip,
.section,
.list-card {
  position: relative;
  isolation: isolate;
  overflow: hidden;
  border: 1px solid var(--cr-border-soft);
  border-radius: var(--cr-radius);
  background:
    var(--cr-noise-texture),
    linear-gradient(180deg, rgba(255,255,255,.96), rgba(248,251,255,.94)),
    #fff;
  background-size: 180px 180px, auto, auto;
  background-blend-mode: normal, normal, normal;
  box-shadow: var(--cr-shadow-soft), var(--cr-shadow-line);
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

.activity-marquee {
  display: grid;
  grid-template-columns: minmax(11rem, 0.18fr) minmax(0, 1fr);
  align-items: center;
  gap: clamp(1rem, 2vw, 2rem);
  padding: clamp(.875rem, 1.6vw, 1.25rem);
}

.marquee-head {
  display: grid;
  gap: .25rem;
}

.marquee-head span {
  color: var(--cr-accent);
  font-size: .75rem;
  font-weight: 800;
}

.marquee-head strong {
  color: var(--cr-text);
  font-size: clamp(1rem, 1.4vw, 1.25rem);
  line-height: 1.35;
}

.marquee-viewport {
  position: relative;
  overflow: hidden;
  min-width: 0;
  padding-block: .25rem;
  -webkit-mask-image: linear-gradient(90deg, transparent, #000 8%, #000 92%, transparent);
  mask-image: linear-gradient(90deg, transparent, #000 8%, #000 92%, transparent);
}

.marquee-track {
  --marquee-gap: .75rem;
  --marquee-duration: 52s;
  display: flex;
  width: max-content;
  gap: var(--marquee-gap);
}

.marquee-viewport:hover .marquee-group,
.marquee-viewport:focus-within .marquee-group {
  animation-play-state: paused;
}

.marquee-group {
  display: flex;
  flex: 0 0 auto;
  gap: var(--marquee-gap);
  min-width: max-content;
  animation: home-marquee var(--marquee-duration) linear infinite;
}

.marquee-chip {
  flex: 0 0 auto;
  width: clamp(15rem, 18vw, 22rem);
  min-height: 4.75rem;
  display: grid;
  align-content: center;
  gap: .1875rem;
  padding: .875rem 1rem;
  color: inherit;
  text-decoration: none;
  border: 1px solid rgba(203, 216, 231, .82);
  border-radius: var(--cr-radius);
  background:
    var(--cr-noise-texture),
    linear-gradient(135deg, rgba(255,255,255,.94), rgba(243,248,252,.9)),
    #fff;
  background-size: 180px 180px, auto, auto;
  background-blend-mode: normal, normal, normal;
  cursor: pointer;
  box-shadow: var(--cr-shadow-line);
  transition: transform .18s ease, border-color .18s ease, box-shadow .18s ease;
}

.marquee-chip:hover,
.marquee-chip:focus-visible {
  border-color: rgba(36, 84, 214, .32);
  box-shadow: var(--cr-shadow-soft), var(--cr-shadow-line);
  outline: none;
  transform: translateY(-1px);
}

.marquee-chip span {
  color: var(--cr-accent);
  font-size: .6875rem;
  font-weight: 800;
}

.marquee-chip strong {
  color: var(--cr-text);
  font-size: .9375rem;
  line-height: 1.35;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.marquee-chip em {
  color: var(--cr-text-muted);
  font-size: .75rem;
  font-style: normal;
  font-weight: 700;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
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
  min-height: 2.25rem;
  padding: 0 .875rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border: .0625rem solid rgba(203, 216, 231, .78);
  border-radius: 999rem;
  background: rgba(255, 255, 255, .66);
  color: var(--cr-text-muted);
  font-size: .875rem;
  font-weight: 780;
  line-height: 1;
  white-space: nowrap;
  box-shadow: var(--cr-shadow-line);
  transition: transform .16s ease, color .18s ease, border-color .18s ease, background .18s ease, box-shadow .18s ease;
}

.more:hover {
  color: var(--cr-primary);
  border-color: rgba(36, 84, 214, .24);
  background: rgba(36, 84, 214, .08);
  box-shadow: 0 .5rem 1rem rgba(36, 84, 214, .12), var(--cr-shadow-line);
  transform: translateY(-.0625rem);
}

.job-card,
.ent-card {
  position: relative;
  isolation: isolate;
  overflow: hidden;
  border: 1px solid var(--cr-border-soft);
  border-radius: var(--cr-radius);
  background:
    var(--cr-noise-texture),
    linear-gradient(180deg, rgba(255,255,255,.97), rgba(248,251,255,.94)),
    var(--cr-surface);
  background-size: 180px 180px, auto, auto;
  background-blend-mode: soft-light, normal, normal;
  transition: border-color .2s ease, box-shadow .2s ease, transform .2s ease;
}

.job-card:hover,
.ent-card:hover {
  border-color: rgba(16,20,24,.2);
  box-shadow: var(--cr-shadow-soft);
  transform: translateY(-.125rem);
}

.company-mark {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--cr-radius-sm);
  background: linear-gradient(135deg, var(--cr-primary), var(--cr-accent));
  color: #fff;
  font-weight: 900;
}

.job-card h3,
.ent-card h3 {
  color: var(--cr-text);
  font-size: 1rem;
  line-height: 1.4;
}

.job-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(min(100%, 16rem), 1fr));
  gap: 1rem;
}

.job-card {
  --shine-border-duration: 14s;
  --shine-border-opacity: 0;
  min-height: 13.25rem;
  padding: 1.125rem;
  cursor: pointer;
}

.job-card:hover {
  --shine-border-opacity: .58;
}

.empty-card {
  grid-column: 1 / -1;
  min-height: 8rem;
  display: grid;
  place-items: center;
  gap: .375rem;
  text-align: center;
  border: 1px dashed var(--cr-border);
  border-radius: var(--cr-radius);
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
  border-radius: var(--cr-radius-sm);
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
  border-radius: var(--cr-radius-sm);
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
  grid-template-columns: repeat(auto-fill, minmax(min(100%, 16rem), 1fr));
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
  background: var(--cr-accent);
  border-radius: 999rem;
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

@keyframes home-marquee {
  from {
    transform: translateX(0);
  }
  to {
    transform: translateX(calc(-100% - var(--marquee-gap)));
  }
}

@keyframes text-gradient-flow {
  to {
    background-position: var(--gradient-size) 0;
  }
}

@keyframes marker-swipe {
  from {
    opacity: 0;
    transform: rotate(-1.1deg) scaleX(.18);
  }
  to {
    opacity: 1;
    transform: rotate(-1.1deg) scaleX(.98);
  }
}

@keyframes text-blur-in-up {
  to {
    opacity: 1;
    transform: translateY(0);
    filter: blur(0);
  }
}

@keyframes meteor-flight {
  0% {
    opacity: 0;
    transform: rotate(var(--meteor-angle)) translateX(0);
  }
  12% {
    opacity: .72;
  }
  54% {
    opacity: .48;
  }
  100% {
    opacity: 0;
    transform: rotate(var(--meteor-angle)) translateX(var(--meteor-travel));
  }
}

@keyframes shine-border-flow {
  0% {
    background-position: 0% 0%;
  }
  50% {
    background-position: 100% 100%;
  }
  100% {
    background-position: 0% 0%;
  }
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
    width: 16.25rem;
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
    width: 12.5rem;
    padding: .875rem;
    gap: .75rem;
  }

  .flow-card-head strong {
    font-size: .9375rem;
  }

  .flow-step {
    grid-template-columns: 1.75rem minmax(0, 1fr);
    min-height: 2.4rem;
    gap: .5rem;
    padding: .5rem;
  }

  .flow-step i {
    width: 1.75rem;
    height: 1.75rem;
  }

  .stats-strip,
  .activity-marquee,
  .info-grid {
    grid-template-columns: 1fr;
  }

  .activity-marquee {
    gap: .875rem;
  }

  .marquee-viewport {
    margin-inline: -.25rem;
  }

  .marquee-chip {
    width: clamp(14rem, 70vw, 20rem);
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

}

@media (max-width: 30rem) {
  .hero-actions :deep(.el-button) {
    flex: 1 1 100%;
  }
}

@media (prefers-reduced-motion: reduce) {
  .text-animate-word,
  .text-animate-line,
  .text-animate-on-view {
    opacity: 1;
    transform: none;
    filter: none;
    animation: none;
  }

  .animated-gradient-text {
    animation: none;
  }

  .text-highlighter::after {
    animation: none;
  }

  .hero-search::before,
  .board-card-main::before,
  .job-card::before {
    animation: none;
  }

  .meteor-layer {
    display: none;
  }

  .marquee-track {
    width: auto;
  }

  .marquee-group {
    flex-wrap: wrap;
    animation: none;
  }

  .marquee-group[aria-hidden="true"] {
    display: none;
  }
}
</style>
