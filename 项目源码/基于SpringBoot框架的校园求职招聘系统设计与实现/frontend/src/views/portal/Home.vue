<template>
  <div class="home portal-content">
    <section class="hero-shell">
      <BackgroundPaths3d class="hero-paths-3d" variant="light" :density="20" />
      <Meteors3d class="hero-meteors-3d" :number="24" :min-delay="0.15" :max-delay="8" :min-duration="5" :max-duration="12" :travel="680" />
      <div class="cr-aurora-layer hero-aurora" aria-hidden="true"></div>
      <div class="cr-light-rays-layer hero-rays" aria-hidden="true"><i></i><i></i><i></i></div>
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
        <div class="hero-dock cr-mini-dock" aria-label="快捷入口">
          <button
            v-for="item in quickActions"
            :key="item.label"
            type="button"
            class="cr-dock-button"
            @click="$router.push(item.to)"
          >
            <el-icon><component :is="item.icon" /></el-icon>
            <span>{{ item.label }}</span>
            <small>{{ item.hint }}</small>
          </button>
        </div>
      </div>
      <div class="hero-board">
        <div class="board-grid" aria-hidden="true">
          <span v-for="i in 30" :key="i"></span>
        </div>
        <div class="showcase-panel">
          <div class="showcase-background">
            <svg class="showcase-noise-texture" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
              <filter id="home-showcase-noise">
                <feTurbulence type="fractalNoise" baseFrequency="0.42" numOctaves="6" stitchTiles="stitch" />
                <feColorMatrix type="saturate" values="0" />
                <feComponentTransfer>
                  <feFuncR type="linear" slope="0.16" />
                  <feFuncG type="linear" slope="0.16" />
                  <feFuncB type="linear" slope="0.16" />
                </feComponentTransfer>
              </filter>
              <rect width="100%" height="100%" filter="url(#home-showcase-noise)" opacity="0.64" />
            </svg>
            <BackgroundPaths3d class="showcase-paths-3d" variant="light" :density="18" />
            <Meteors3d class="showcase-meteors-3d" :number="10" :min-delay="0.4" :max-delay="7" :min-duration="4" :max-duration="9" :travel="240" />
            <div class="showcase-depth-grid" aria-hidden="true"></div>
            <div class="showcase-flow-lines" aria-hidden="true"></div>
            <div class="showcase-badge">
              <span>本周热度</span>
              <strong>{{ home.hotJobs?.length || 0 }} 个岗位</strong>
            </div>
          </div>
          <div class="board-card board-card-main">
            <span class="board-label">今日推荐</span>
            <strong>{{ firstJob?.title || '多模态算法工程师' }}</strong>
            <p>{{ firstJob?.companyName || '星火人工智能科技有限公司' }} · {{ firstJob?.city || '北京' }}</p>
            <div class="salary-range">{{ formatSalary(firstJob) }}</div>
          </div>
          <div class="board-card board-card-side">
            <span class="board-label">招聘活动</span>
            <strong>{{ home.talks?.length || 0 }} 场宣讲</strong>
            <p>{{ nextTalk?.title || '量海数据 BI 与分析宣讲会' }}</p>
          </div>
          <div class="board-card board-card-mini">
            <div class="mini-card-topline">
              <span class="mini-card-kicker">匹配流程</span>
              <strong>3 步完成</strong>
            </div>
            <div class="mini-card-summary">
              从岗位筛选到在线沟通，流程清晰直达。
            </div>
            <Meteors3d class="mini-meteors" :number="7" :min-delay="0.2" :max-delay="6" :min-duration="3" :max-duration="7" :travel="170" />
            <div class="flow-steps">
              <div class="flow-step">
                <span class="step-index">01</span>
                <div class="step-copy">
                  <b>岗位筛选</b>
                  <small>聚焦匹配岗位</small>
                </div>
              </div>
              <div class="flow-step">
                <span class="step-index">02</span>
                <div class="step-copy">
                  <b>简历投递</b>
                  <small>一键提交申请</small>
                </div>
              </div>
              <div class="flow-step">
                <span class="step-index">03</span>
                <div class="step-copy">
                  <b>在线沟通</b>
                  <small>快速接收反馈</small>
                </div>
              </div>
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

    <section class="magic-bento" aria-label="求职服务组件">
      <article
        v-for="card in bentoCards"
        :key="card.title"
        class="bento-card cr-magic-surface"
        :class="card.tone"
        role="button"
        tabindex="0"
        @click="$router.push(card.to)"
        @keydown.enter="$router.push(card.to)"
        @keydown.space.prevent="$router.push(card.to)"
      >
        <div class="bento-head">
          <span class="bento-icon"><el-icon><component :is="card.icon" /></el-icon></span>
          <span class="bento-value">{{ card.value }}</span>
        </div>
        <h3>{{ card.title }}</h3>
        <p>{{ card.desc }}</p>
        <div class="bento-foot">
          <span>{{ card.meta }}</span>
          <el-icon><Right /></el-icon>
        </div>
      </article>
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
import { Calendar, ChatLineRound, Compass, OfficeBuilding, Right, Search, Tickets } from '@element-plus/icons-vue'
import { publicApi } from '@/api'
import { useUserStore } from '@/store/user'
import BackgroundPaths3d from '@/components/BackgroundPaths3d.vue'
import Meteors3d from '@/components/Meteors3d.vue'

const router = useRouter()
const userStore = useUserStore()
const home = reactive({ hotJobs: [], recommendEnterprises: [], talks: [], fairs: [], announcements: [] })
const kw = ref('')
const city = ref('')
const cities = ref([])

const quickActions = [
  { label: '职位雷达', hint: '按技能筛选', to: '/jobs', icon: Compass },
  { label: '企业星图', hint: '看认证企业', to: '/enterprises', icon: OfficeBuilding },
  { label: '宣讲日历', hint: '近期活动', to: '/talks', icon: Calendar },
  { label: '在线沟通', hint: '消息入口', to: '/chat', icon: ChatLineRound }
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
const bentoCards = computed(() => [
  {
    title: '求职雷达',
    desc: '把城市、薪资和学历条件收束到一页，减少来回翻找。',
    value: `${home.hotJobs?.length || 0}+`,
    meta: '热门岗位',
    to: '/jobs',
    icon: Compass,
    tone: 'is-primary'
  },
  {
    title: '企业信号',
    desc: '认证企业、行业和规模直接对照，先判断是否值得投递。',
    value: `${home.recommendEnterprises?.length || 0}+`,
    meta: '认证企业',
    to: '/enterprises',
    icon: OfficeBuilding,
    tone: 'is-accent'
  },
  {
    title: '活动脉冲',
    desc: '宣讲会和招聘会聚在同一条时间线上，错过概率更低。',
    value: `${(home.talks?.length || 0) + (home.fairs?.length || 0)}+`,
    meta: '招聘活动',
    to: '/talks',
    icon: Calendar,
    tone: 'is-blue'
  },
  {
    title: '投递闭环',
    desc: '从浏览、收藏、投递到在线沟通，后续动作保持连续。',
    value: '3步',
    meta: '求职流程',
    to: '/jobs',
    icon: Tickets,
    tone: 'is-rose'
  }
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
  --hero-ink: #0b1728;
  --hero-panel: #10233a;
  position: relative;
  overflow: hidden;
  min-height: min(44rem, calc(100dvh - 7.25rem));
  display: grid;
  grid-template-columns: minmax(34rem, 0.98fr) minmax(29rem, 0.9fr);
  align-items: center;
  gap: clamp(2rem, 4vw, 4.75rem);
  padding: clamp(2rem, 4.6vw, 5.5rem);
  border: 1px solid rgba(203, 216, 231, .72);
  border-radius: 1rem;
  background:
    var(--cr-noise-texture),
    radial-gradient(circle at 77% 18%, rgba(36, 84, 214, .18), transparent 27rem),
    radial-gradient(circle at 13% 84%, rgba(15, 118, 110, .11), transparent 30rem),
    linear-gradient(108deg, rgba(255,255,255,.98) 0%, rgba(245,249,255,.96) 48%, rgba(225,239,246,.93) 100%);
  background-size: 180px 180px, auto, auto, auto;
  background-blend-mode: soft-light, normal, normal, normal;
  box-shadow:
    0 1.5rem 4rem rgba(16, 24, 39, .12),
    inset 0 1px 0 rgba(255, 255, 255, .88);
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
  --paths-3d-opacity: 0.24;
  --paths-3d-blend: multiply;
  inset: -7% -4% -5% -12%;
}

.hero-meteors-3d {
  z-index: 0;
  opacity: .58;
  mix-blend-mode: screen;
  --meteor-color: rgba(96, 165, 250, .7);
  --meteor-tail-color: rgba(37, 99, 235, .42);
  --meteor-glow: rgba(37, 99, 235, .22);
}

.hero-shell::before,
.hero-shell::after {
  content: "";
  position: absolute;
  pointer-events: none;
}

.hero-shell::before {
  inset: 1rem auto 1rem 1rem;
  width: .25rem;
  border-radius: 999rem;
  background: linear-gradient(180deg, var(--cr-accent), var(--cr-primary));
  box-shadow: 0 0 1.75rem rgba(15, 118, 110, .28);
}

.hero-shell::after {
  inset: auto clamp(1.5rem, 4vw, 4rem) clamp(1.25rem, 3.4vw, 3rem) auto;
  width: min(31rem, 35vw);
  height: 0.0625rem;
  background: linear-gradient(90deg, transparent, rgba(16, 24, 39, 0.18));
}

.hero-copy,
.hero-board {
  position: relative;
  z-index: 1;
}

.hero-kicker,
.section-heading p {
  color: var(--cr-accent);
  font-size: .78rem;
  font-weight: 900;
  letter-spacing: 0;
}

.hero-copy h1 {
  margin: .75rem 0 1.125rem;
  max-width: 49rem;
  color: var(--hero-ink);
  font-size: clamp(3.35rem, 5.4vw, 6.375rem);
  line-height: .96;
  font-weight: 950;
  letter-spacing: 0;
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
  background: linear-gradient(90deg, #143b96, #2563eb 42%, #0f766e 76%, #143b96);
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
  max-width: 43rem;
  color: var(--cr-text-soft);
  font-size: clamp(1rem, 1.28vw, 1.18rem);
  line-height: 1.9;
}

.hero-search {
  --shine-border-duration: 16s;
  --shine-border-opacity: .38;
  margin-top: clamp(1.5rem, 2.8vw, 2.375rem);
  width: min(49rem, 100%);
  position: relative;
  isolation: isolate;
  overflow: hidden;
  display: grid;
  grid-template-columns: minmax(7rem, .25fr) minmax(13rem, 1fr) auto;
  gap: .75rem;
  padding: .625rem;
  border: 1px solid rgba(188, 203, 221, .9);
  border-radius: .875rem;
  background: rgba(255,255,255,.9);
  box-shadow:
    0 1rem 2.25rem rgba(15, 23, 42, .1),
    inset 0 1px 0 rgba(255, 255, 255, .9);
  backdrop-filter: blur(1rem) saturate(150%);
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
  min-height: 3rem;
  border-radius: .625rem;
  box-shadow: none;
  background: #f5f8fc;
}

.search-button,
.primary-pill,
.ghost-pill {
  border-radius: .625rem;
  white-space: nowrap;
  transition: transform .16s ease, box-shadow .18s ease, background .18s ease, border-color .18s ease, color .18s ease;
}

.search-button {
  min-inline-size: 7.5rem;
  background:
    linear-gradient(180deg, rgba(255, 255, 255, .16), transparent 44%),
    linear-gradient(135deg, var(--cr-primary), #1743b6);
  border-color: transparent;
  box-shadow: 0 .75rem 1.5rem rgba(36, 84, 214, .24);
}

.search-button:hover,
.primary-pill:hover {
  background:
    linear-gradient(180deg, rgba(255, 255, 255, .18), transparent 44%),
    linear-gradient(135deg, var(--cr-primary-strong), #12358f);
  border-color: transparent;
}

.hero-actions {
  margin-top: 1.125rem;
  display: flex;
  flex-wrap: wrap;
  gap: .75rem;
}

.hero-dock {
  margin-top: 1.125rem;
}

.hero-dock .cr-dock-button {
  min-width: clamp(7.25rem, 8.8vw, 9.5rem);
}

.primary-pill {
  min-width: 8.5rem;
  background:
    linear-gradient(180deg, rgba(255, 255, 255, .16), transparent 45%),
    linear-gradient(135deg, var(--cr-primary), #1947bd);
  border-color: transparent;
  box-shadow: 0 .8rem 1.5rem rgba(36, 84, 214, .22);
}

.ghost-pill {
  --el-button-text-color: #10243d;
  --el-button-bg-color: transparent;
  --el-button-border-color: rgba(36,84,214,.18);
  --el-button-hover-text-color: var(--cr-primary);
  --el-button-hover-bg-color: transparent;
  --el-button-hover-border-color: rgba(36,84,214,.42);
  --el-button-active-text-color: var(--cr-primary-strong);
  --el-button-active-bg-color: transparent;
  --el-button-active-border-color: rgba(36,84,214,.5);
  min-width: 9.5rem;
  border-color: rgba(36,84,214,.18);
  color: #10243d;
  background:
    linear-gradient(180deg, rgba(255,255,255,.96), rgba(245,249,255,.9));
  box-shadow:
    0 .45rem 1rem rgba(15,23,42,.08),
    inset 0 1px 0 rgba(255,255,255,.9);
}

.ghost-pill:hover,
.ghost-pill:focus-visible,
.hero-actions .ghost-pill:hover,
.hero-actions .ghost-pill:focus-visible {
  color: var(--cr-primary);
  border-color: rgba(36,84,214,.42);
  background:
    linear-gradient(180deg, rgba(255,255,255,1), rgba(236,244,255,.96));
  box-shadow:
    0 .8rem 1.5rem rgba(36,84,214,.16),
    inset 0 1px 0 rgba(255,255,255,.94);
  transform: translateY(-1px);
}

.ghost-pill:focus-visible {
  outline: 3px solid rgba(36,84,214,.18);
  outline-offset: 2px;
}

.ghost-pill:active {
  transform: translateY(1px);
  box-shadow:
    0 .35rem .85rem rgba(36,84,214,.12),
    inset 0 1px 0 rgba(255,255,255,.85);
}

.hero-actions .ghost-pill:active {
  transform: translateY(1px);
}

.hero-board {
  min-height: 35rem;
  align-self: stretch;
  display: grid;
  align-items: center;
  perspective: 1200px;
}

.board-grid {
  position: absolute;
  inset: 1.75rem -1rem 1rem 4rem;
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: .75rem;
  opacity: .42;
}

.board-grid span {
  aspect-ratio: 1;
  border-radius: .625rem;
  background: linear-gradient(180deg, rgba(36,84,214,.12), rgba(15,118,110,.06));
  box-shadow: inset 0 1px 0 rgba(255,255,255,.64);
}

.showcase-panel {
  position: relative;
  z-index: 1;
  width: min(100%, 48rem);
  min-height: 32rem;
  justify-self: end;
  padding: 1rem;
  border: 1px solid rgba(203, 216, 231, .78);
  border-radius: 1rem;
  background:
    linear-gradient(135deg, rgba(255,255,255,.82), rgba(236,246,252,.58)),
    rgba(255,255,255,.38);
  box-shadow:
    0 1.5rem 3.25rem rgba(16, 24, 39, .13),
    inset 0 1px 0 rgba(255, 255, 255, .86);
  backdrop-filter: blur(1rem) saturate(140%);
  transform-style: preserve-3d;
}

.showcase-background {
  position: absolute;
  inset: 1rem;
  z-index: 0;
  overflow: hidden;
  border-radius: .875rem;
  isolation: isolate;
  pointer-events: none;
  background:
    linear-gradient(118deg, rgba(255,255,255,.82) 0%, transparent 34%, rgba(125,211,252,.2) 68%, transparent 100%),
    linear-gradient(142deg, rgba(36,84,214,.26) 0%, rgba(236,248,255,.82) 38%, rgba(15,118,110,.16) 72%, rgba(255,255,255,.88) 100%),
    linear-gradient(180deg, #f8fcff 0%, #e8f4fc 52%, #f5fbff 100%);
  box-shadow:
    inset 0 0 0 1px rgba(255, 255, 255, .64),
    inset 0 1px 0 rgba(255, 255, 255, .9),
    inset 0 -3rem 6rem rgba(36, 84, 214, .08);
  transform: translateZ(.5rem);
}

.showcase-background::before,
.showcase-background::after {
  position: absolute;
  inset: 0;
  z-index: 1;
  content: "";
  pointer-events: none;
}

.showcase-background::before {
  background:
    repeating-linear-gradient(90deg, rgba(255,255,255,.28) 0 1px, transparent 1px 5rem),
    repeating-linear-gradient(0deg, rgba(36,84,214,.08) 0 1px, transparent 1px 5rem),
    linear-gradient(90deg, rgba(255,255,255,.64), transparent 30%, rgba(255,255,255,.26) 76%, transparent),
    linear-gradient(180deg, transparent 46%, rgba(12, 30, 48, .13));
  mix-blend-mode: screen;
  opacity: .82;
}

.showcase-background::after {
  background:
    linear-gradient(112deg, transparent 0 24%, rgba(255,255,255,.82) 32%, transparent 43%),
    linear-gradient(112deg, transparent 0 56%, rgba(14,165,233,.34) 64%, transparent 76%),
    linear-gradient(155deg, transparent 0 40%, rgba(15,118,110,.18) 52%, transparent 68%);
  background-size: 190% 100%, 230% 100%, 100% 100%;
  mask-image: linear-gradient(108deg, transparent 3%, #000 16%, #000 86%, transparent 100%);
  animation: showcase-light-sweep 10s ease-in-out infinite;
  opacity: .72;
}

.showcase-noise-texture {
  position: absolute;
  inset: 0;
  z-index: 1;
  width: 100%;
  height: 100%;
  opacity: .58;
  mix-blend-mode: multiply;
  pointer-events: none;
}

.showcase-paths-3d {
  --paths-3d-opacity: .24;
  --paths-3d-blend: multiply;
  z-index: 2;
  inset: -12% -8% -18% -12%;
}

.showcase-meteors-3d {
  z-index: 3;
  opacity: .46;
  mix-blend-mode: screen;
  --meteor-color: rgba(59, 130, 246, .72);
  --meteor-tail-color: rgba(15, 118, 110, .5);
  --meteor-glow: rgba(14, 165, 233, .24);
}

.showcase-depth-grid {
  position: absolute;
  inset: 4.75rem 2rem 1.5rem 8.5rem;
  z-index: 2;
  border-radius: .625rem;
  background:
    linear-gradient(135deg, rgba(255,255,255,.46), transparent 30%),
    repeating-linear-gradient(90deg, rgba(15, 23, 42, .07) 0 1px, transparent 1px 3.75rem),
    repeating-linear-gradient(0deg, rgba(15, 23, 42, .05) 0 1px, transparent 1px 3.75rem);
  box-shadow:
    inset 0 0 0 1px rgba(255,255,255,.44),
    inset 0 0 3rem rgba(255,255,255,.34);
  transform: perspective(36rem) rotateX(58deg) rotateZ(-7deg) translateY(2.4rem);
  transform-origin: center bottom;
  opacity: .5;
}

.showcase-flow-lines {
  position: absolute;
  inset: 0;
  z-index: 3;
  pointer-events: none;
  background:
    radial-gradient(ellipse at 75% 12%, rgba(255,255,255,.46), transparent 34%),
    linear-gradient(112deg, transparent 0 48%, rgba(255,255,255,.48) 57%, transparent 70%);
  background-size: 100% 100%, 220% 100%;
  animation: showcase-light-sweep 12s ease-in-out infinite reverse;
  opacity: .58;
}

.showcase-badge {
  position: absolute;
  right: 1.15rem;
  top: 1.15rem;
  z-index: 4;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: .85rem;
  width: min(15.5rem, 36%);
  min-width: 12.5rem;
  min-height: 4.7rem;
  padding: .9rem 1rem .9rem 1.1rem;
  border: 1px solid rgba(191,211,235,.88);
  border-radius: .875rem;
  background:
    var(--cr-noise-texture),
    radial-gradient(circle at 100% 0%, rgba(36,84,214,.14), transparent 48%),
    linear-gradient(180deg, rgba(255,255,255,.94), rgba(239,248,255,.82));
  background-size: 180px 180px, auto, auto;
  color: var(--cr-text);
  box-shadow:
    0 .95rem 2rem rgba(15, 23, 42, .13),
    inset 0 1px 0 rgba(255,255,255,.9);
  backdrop-filter: blur(.9rem) saturate(145%);
}

.showcase-badge span {
  color: var(--cr-text-muted);
  font-size: .78rem;
  font-weight: 800;
  white-space: nowrap;
}

.showcase-badge strong {
  color: var(--cr-primary);
  font-size: clamp(1.2rem, 1.65vw, 1.55rem);
  line-height: 1.15;
  white-space: nowrap;
}

.board-card {
  position: absolute;
  z-index: 4;
  border: 1px solid rgba(203,216,231,.86);
  border-radius: .875rem;
  background:
    var(--cr-noise-texture),
    linear-gradient(180deg, rgba(255,255,255,.98), rgba(246,250,255,.94));
  background-size: 180px 180px, auto;
  background-blend-mode: soft-light, normal;
  box-shadow:
    0 1rem 2.25rem rgba(15, 23, 42, .12),
    inset 0 1px 0 rgba(255,255,255,.9);
  backdrop-filter: blur(.85rem) saturate(150%);
  transform: translateZ(3rem);
}

.board-card-main {
  --shine-border-duration: 18s;
  --shine-border-opacity: .32;
  top: 3.25rem;
  left: 1.25rem;
  width: min(24.5rem, 58%);
  padding: 1.35rem;
}

.board-card-side {
  bottom: 3rem;
  left: 1.75rem;
  width: min(20.75rem, 54%);
  padding: 1.15rem;
}

.board-card-mini {
  right: 1.35rem;
  bottom: 1rem;
  width: 17.75rem;
  padding: 1.15rem 1.15rem 1.05rem;
  display: grid;
  gap: .85rem;
  border-color: rgba(191, 211, 235, .88);
  background:
    var(--cr-noise-texture),
    radial-gradient(circle at 92% 8%, rgba(36, 84, 214, .16), transparent 36%),
    radial-gradient(circle at 0% 100%, rgba(15, 118, 110, .12), transparent 42%),
    linear-gradient(180deg, rgba(255,255,255,.95), rgba(238,247,255,.9));
  background-size: 180px 180px, auto, auto, auto;
  color: var(--cr-text);
  overflow: hidden;
  box-shadow:
    0 1.1rem 2.5rem rgba(15, 23, 42, .14),
    inset 0 1px 0 rgba(255,255,255,.9);
  transform: translateZ(5rem);
}

.mini-card-topline {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: .75rem;
}

.mini-card-kicker {
  display: inline-flex;
  align-items: center;
  color: var(--cr-primary);
  font-size: .75rem;
  font-weight: 800;
  letter-spacing: 0;
}

.board-card-mini .mini-card-topline strong {
  color: var(--cr-text);
  font-size: 1.45rem;
  line-height: 1.05;
  font-weight: 900;
  text-shadow: none;
}

.mini-card-summary {
  position: relative;
  z-index: 1;
  max-width: 12rem;
  color: var(--cr-text-soft);
  font-size: .8125rem;
  line-height: 1.5;
}

.mini-meteors {
  position: absolute;
  inset: 0;
  z-index: 0;
  border-radius: inherit;
  opacity: .28;
  mix-blend-mode: multiply;
  --meteor-color: rgba(36, 84, 214, .58);
  --meteor-tail-color: rgba(15, 118, 110, .38);
  --meteor-glow: rgba(14, 165, 233, .18);
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

.board-card strong {
  display: block;
  color: var(--cr-text);
  font-size: clamp(1.22rem, 1.75vw, 1.55rem);
  line-height: 1.25;
}

.board-card p {
  margin-top: .5rem;
  color: var(--cr-text-soft);
  line-height: 1.6;
}

.salary-range {
  margin-top: 1rem;
  color: var(--cr-danger);
  font-size: 1.65rem;
  font-weight: 900;
}

.flow-steps {
  position: relative;
  z-index: 1;
  display: grid;
  gap: .55rem;
}

.flow-steps::before {
  position: absolute;
  top: 1rem;
  bottom: 1rem;
  left: 1.25rem;
  width: .0625rem;
  content: "";
  background: linear-gradient(180deg, rgba(36,84,214,.34), rgba(15,118,110,.12));
}

.flow-step {
  position: relative;
  display: grid;
  grid-template-columns: 2.5rem minmax(0, 1fr);
  align-items: center;
  gap: .75rem;
  min-height: 3rem;
  padding: .7rem .8rem .7rem .45rem;
  border-radius: var(--cr-radius-sm);
  border: 1px solid rgba(191,211,235,.76);
  background:
    linear-gradient(135deg, rgba(255,255,255,.86), rgba(236,247,255,.68));
  box-shadow:
    inset 0 1px 0 rgba(255,255,255,.82),
    0 .45rem 1rem rgba(36,84,214,.08);
}

.step-index {
  position: relative;
  z-index: 1;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 2.35rem;
  height: 2.35rem;
  border-radius: 999rem;
  background: linear-gradient(135deg, rgba(125,211,252,.98), rgba(36,84,214,.98));
  color: #fff;
  font-size: .7rem;
  font-weight: 900;
  letter-spacing: 0;
  box-shadow: 0 .5rem 1rem rgba(8, 145, 178, .22);
}

.step-copy {
  position: relative;
  z-index: 1;
  display: grid;
  gap: .125rem;
  min-width: 0;
}

.step-copy b {
  color: var(--cr-text);
  font-size: .9625rem;
  line-height: 1.15;
}

.step-copy small {
  color: var(--cr-text-muted);
  font-size: .75rem;
  line-height: 1.2;
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

.magic-bento {
  display: grid;
  grid-template-columns: 1.1fr .9fr .9fr 1.1fr;
  gap: clamp(.875rem, 1.6vw, 1.25rem);
}

.bento-card {
  --bento-color: var(--cr-primary);
  min-height: clamp(12.5rem, 16vw, 16rem);
  padding: clamp(1rem, 1.8vw, 1.375rem);
  display: flex;
  flex-direction: column;
  cursor: pointer;
}

.bento-card.is-accent {
  --bento-color: var(--cr-accent);
  --cr-magic-x: 72%;
}

.bento-card.is-blue {
  --bento-color: #0ea5e9;
  --cr-magic-x: 50%;
  --cr-magic-y: 100%;
}

.bento-card.is-rose {
  --bento-color: var(--cr-danger);
  --cr-magic-x: 88%;
}

.bento-head,
.bento-foot {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: .75rem;
}

.bento-icon {
  width: 2.75rem;
  height: 2.75rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: .875rem;
  background:
    linear-gradient(180deg, rgba(255, 255, 255, .32), transparent 48%),
    color-mix(in srgb, var(--bento-color) 12%, white);
  color: var(--bento-color);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, .86);
}

.bento-icon .el-icon {
  font-size: 1.35rem;
}

.bento-value {
  color: var(--bento-color);
  font-size: clamp(1.5rem, 2.4vw, 2.5rem);
  font-weight: 950;
  line-height: 1;
}

.bento-card h3 {
  margin-top: auto;
  color: var(--cr-text);
  font-size: clamp(1.15rem, 1.45vw, 1.5rem);
  line-height: 1.2;
  font-weight: 900;
}

.bento-card p {
  margin-top: .625rem;
  color: var(--cr-text-soft);
  font-size: .9375rem;
  line-height: 1.65;
}

.bento-foot {
  margin-top: 1.25rem;
  padding-top: .875rem;
  border-top: .0625rem dashed rgba(148, 163, 184, .34);
  color: var(--cr-text-muted);
  font-size: .8125rem;
  font-weight: 800;
}

.bento-foot .el-icon {
  width: 1.875rem;
  height: 1.875rem;
  border-radius: 999rem;
  background: color-mix(in srgb, var(--bento-color) 10%, white);
  color: var(--bento-color);
  transition: transform .18s ease;
}

.bento-card:hover .bento-foot .el-icon {
  transform: translateX(.125rem);
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

@keyframes showcase-light-sweep {
  0%,
  100% {
    background-position: -80% 0, 120% 0;
    opacity: .42;
  }
  45%,
  58% {
    opacity: .82;
  }
  50% {
    background-position: 150% 0, -100% 0;
  }
}

@media (min-width: 75rem) {
  .job-grid {
    grid-template-columns: repeat(5, minmax(0, 1fr));
  }
}

@media (min-width: 100rem) {
  .hero-shell {
    grid-template-columns: minmax(48rem, .96fr) minmax(36rem, 1fr);
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

  .showcase-panel {
    min-height: 34rem;
    width: min(100%, 50rem);
  }

  .board-card-main {
    top: 3.75rem;
    left: 1.75rem;
  }

  .board-card-side {
    bottom: 3.5rem;
    left: 2rem;
  }

  .board-card-mini {
    right: 1.75rem;
    bottom: 1.25rem;
    width: 17.75rem;
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
    min-height: min(49rem, calc(100dvh - 8rem));
    grid-template-columns: minmax(58rem, .96fr) minmax(46rem, 1fr);
  }

  .showcase-panel {
    width: min(100%, 60rem);
    justify-self: start;
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
    width: 13.75rem;
    padding: .875rem;
    gap: .7rem;
  }

  .showcase-background {
    inset: .75rem;
  }

  .showcase-depth-grid {
    inset: 4.5rem .75rem .75rem 3.5rem;
  }

  .showcase-badge {
    top: .75rem;
    right: .75rem;
    min-width: 10.75rem;
    width: 42%;
    min-height: 3.75rem;
    padding: .7rem .8rem .7rem .95rem;
    gap: .55rem;
  }

  .showcase-badge span {
    font-size: .68rem;
  }

  .showcase-badge strong {
    font-size: 1rem;
  }

  .board-card-mini .mini-card-topline strong {
    font-size: 1.15rem;
  }

  .mini-card-summary {
    font-size: .75rem;
  }

  .flow-step {
    grid-template-columns: 2rem minmax(0, 1fr);
    min-height: 2.55rem;
    gap: .55rem;
    padding: .55rem .6rem .55rem .35rem;
  }

  .step-index {
    width: 1.95rem;
    height: 1.95rem;
  }

  .step-copy b {
    font-size: .875rem;
  }

  .step-copy small {
    font-size: .6875rem;
  }

  .stats-strip,
  .magic-bento,
  .activity-marquee,
  .info-grid {
    grid-template-columns: 1fr;
  }

  .bento-card {
    min-height: 11rem;
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

  .hero-dock,
  .hero-dock .cr-dock-button {
    width: 100%;
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

  .showcase-flow-lines {
    animation: none;
  }

  .hero-meteors-3d,
  .showcase-meteors-3d,
  .mini-meteors {
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
