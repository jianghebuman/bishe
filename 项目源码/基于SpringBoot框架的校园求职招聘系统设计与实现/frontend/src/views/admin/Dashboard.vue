<template>
  <div class="page-container admin-dashboard">
    <el-row :gutter="16" class="dashboard-row">
      <el-col v-for="k in kpis" :key="k.title" :xs="24" :sm="12" :md="12" :lg="6">
        <div class="kpi" :style="{ '--c': k.color }">
          <div class="cr-light-rays-layer kpi-rays" aria-hidden="true"><i></i><i></i></div>
          <div>
            <div class="num">{{ k.value }}</div>
            <div class="label">{{ k.title }}</div>
          </div>
          <span class="kpi-icon">
            <el-icon><component :is="k.icon" /></el-icon>
          </span>
        </div>
      </el-col>
    </el-row>
    <el-row :gutter="16" class="dashboard-row mt-20">
      <el-col :xs="24" :lg="12">
        <div class="panel">
          <div class="panel-title">投递转化概览</div>
          <div class="funnel-board">
            <div class="funnel-total">
              <span>累计投递</span>
              <strong>{{ funnelTotal }}</strong>
              <em>份</em>
            </div>
            <div class="funnel-steps">
              <div
                v-for="item in funnelItems"
                :key="item.name"
                class="funnel-step"
                :style="{ '--bar-color': item.color, '--bar-width': `${item.barPercent}%` }"
              >
                <div class="funnel-step-head">
                  <span>{{ item.name }}</span>
                  <strong>{{ item.value }}</strong>
                </div>
                <div class="funnel-track">
                  <div class="funnel-fill"></div>
                </div>
                <div class="funnel-meta">
                  <span>占投递 {{ item.percent }}%</span>
                  <span v-if="item.conversion !== null">上步转化 {{ item.conversion }}%</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :lg="12">
        <div class="panel">
          <div class="panel-title">投递状态分布</div>
          <div class="chart status-donut-board">
            <div v-if="statusRows.length" class="donut-visual" :style="statusDonutStyle">
              <div class="donut-center">
                <strong>{{ statusTotal }}</strong>
                <span>总投递</span>
              </div>
            </div>
            <div v-else class="empty-chart">暂无投递状态数据</div>
            <div class="chart-legend">
              <div v-for="item in statusRows" :key="item.name" class="legend-item">
                <i :style="{ background: item.color }"></i>
                <span>{{ item.name }}</span>
                <strong>{{ item.value }}</strong>
              </div>
            </div>
          </div>
        </div>
      </el-col>
    </el-row>
    <el-row :gutter="16" class="dashboard-row mt-20">
      <el-col :xs="24" :lg="12">
        <div class="panel">
          <div class="panel-title">各专业投递占比</div>
          <div class="donut-board">
            <div class="chart chart-donut">
              <div v-if="majorRows.length" class="donut-visual" :style="majorDonutStyle">
                <div class="donut-center">
                  <strong>{{ majorTotal }}</strong>
                  <span>投递人数</span>
                </div>
              </div>
              <div v-else class="empty-chart">暂无专业投递数据</div>
            </div>
            <div class="donut-rank">
              <div class="donut-rank-head">
                <span>专业排行</span>
                <em>共 {{ majorRows.length }} 个</em>
              </div>
              <div class="donut-rank-list">
                <div
                  v-for="(item, index) in majorRank"
                  :key="item.name"
                  class="donut-rank-item"
                  :style="{ '--rank-color': item.color, '--rank-width': `${item.percent}%` }"
                >
                  <div class="rank-line">
                    <span class="rank-name"><i></i>{{ item.name }}</span>
                    <strong>{{ item.value }}</strong>
                  </div>
                  <div class="rank-track">
                    <div class="rank-fill"></div>
                  </div>
                  <small>{{ item.percent }}%</small>
                </div>
              </div>
            </div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :lg="12">
        <div class="panel">
          <div class="panel-title">热门岗位类别排行</div>
          <div class="leaderboard">
            <div v-if="!categoryRank.length" class="empty-chart">暂无岗位类别数据</div>
            <div
              v-for="item in categoryRank"
              v-else
              :key="item.name"
              class="leader-row"
              :class="{ hot: item.rank <= 3 }"
              :style="{ '--row-color': item.color, '--row-width': `${item.barPercent}%` }"
            >
              <span class="leader-rank">{{ rankNo(item.rank) }}</span>
              <div class="leader-main">
                <div class="leader-head">
                  <span class="leader-name">{{ item.name }}</span>
                  <strong>{{ item.value }}<em>{{ item.unit }}</em></strong>
                </div>
                <div class="leader-track">
                  <div class="leader-fill"></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </el-col>
    </el-row>
    <el-row :gutter="16" class="dashboard-row mt-20">
      <el-col :xs="24" :lg="16">
        <div class="panel">
          <div class="panel-title">企业岗位发布排行</div>
          <div class="leaderboard leaderboard-wide">
            <div v-if="!enterpriseRank.length" class="empty-chart">暂无企业发布数据</div>
            <div
              v-for="item in enterpriseRank"
              v-else
              :key="item.name"
              class="leader-row"
              :class="{ hot: item.rank <= 3 }"
              :style="{ '--row-color': item.color, '--row-width': `${item.barPercent}%` }"
            >
              <span class="leader-rank">{{ rankNo(item.rank) }}</span>
              <div class="leader-main">
                <div class="leader-head">
                  <span class="leader-name">{{ item.name }}</span>
                  <strong>{{ item.value }}<em>{{ item.unit }}</em></strong>
                </div>
                <div class="leader-track">
                  <div class="leader-fill"></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :lg="8">
        <div class="panel rate">
          <div class="panel-title">关键转化率</div>
          <div class="rate-list">
            <div v-for="item in rates" :key="item.name" class="rate-item" :style="{ '--rate-color': item.color }">
              <div class="rate-head">
                <span>{{ item.name }}</span>
                <strong>{{ item.value }}%</strong>
              </div>
              <div class="rate-meta">{{ item.caption }}</div>
              <div class="rate-track">
                <div class="rate-fill" :style="{ width: `${item.safeValue}%` }"></div>
              </div>
            </div>
          </div>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { DocumentChecked, Histogram, OfficeBuilding, UserFilled } from '@element-plus/icons-vue'
import { adminApi } from '@/api'

const data = ref({})

const funnelColors = ['#2563eb', '#0891b2', '#7c3aed', '#e45757']
const chartPalette = ['#2563eb', '#0891b2', '#7c3aed', '#e45757', '#16a34a', '#f59e0b', '#475569', '#db2777']
const leaderboardPalette = ['#2563eb', '#0891b2', '#7c3aed', '#e45757', '#16a34a', '#f59e0b', '#475569', '#db2777', '#0f766e', '#9333ea']
const clampRate = (value) => Math.min(Math.max(Number(value) || 0, 0), 100)
const percentOf = (value, total) => total ? Math.round((value / total) * 100) : 0
const rankNo = (rank) => String(rank).padStart(2, '0')
const normalizeItems = (items = []) => (
  items
    .map((item) => ({ name: item.name, value: Number(item.value) || 0 }))
    .sort((a, b) => b.value - a.value)
)
const topItems = (items = [], limit = 8) => (
  normalizeItems(items).slice(0, limit)
)
const rankingItems = (items = [], limit = 8, unit = '') => {
  const rows = topItems(items, limit)
  const max = rows[0]?.value || 0

  return rows.map((item, index) => ({
    ...item,
    unit,
    rank: index + 1,
    color: leaderboardPalette[index % leaderboardPalette.length],
    barPercent: max ? Math.max(Math.round((item.value / max) * 100), 8) : 0
  }))
}
const categoryRank = computed(() =>
  rankingItems(data.value.categoryJob || [], 8, '个')
)
const enterpriseRank = computed(() =>
  rankingItems(data.value.enterpriseActive || [], 10, '个')
)
const normalizeFunnel = (items = []) => {
  const rows = items.map((item) => ({ name: item.name, value: Number(item.value) || 0 }))
  const base = rows[0]?.value || Math.max(...rows.map((item) => item.value), 0)

  return rows.map((item, index) => {
    const percent = base ? Math.round((item.value / base) * 100) : 0
    const prev = rows[index - 1]?.value || 0
    const conversion = index === 0 ? null : (prev ? Math.round((item.value / prev) * 100) : 0)

    return {
      ...item,
      percent,
      conversion,
      barPercent: item.value > 0 ? Math.max(percent, 8) : 0,
      color: funnelColors[index % funnelColors.length]
    }
  })
}

const kpis = computed(() => [
  { title: '学生总数', value: data.value.studentCount || 0, icon: UserFilled, color: '#2563eb' },
  { title: '企业总数', value: data.value.enterpriseCount || 0, icon: OfficeBuilding, color: '#0891b2' },
  { title: '岗位总数', value: data.value.jobCount || 0, icon: Histogram, color: '#7c3aed' },
  { title: '投递总数', value: data.value.applyCount || 0, icon: DocumentChecked, color: '#e45757' }
])

const rates = computed(() => [
  ...(data.value.keyRates?.length ? data.value.keyRates : [
    { name: '面试通过率', value: data.value.interviewPassRate, caption: '从面试进入通过状态的比例' },
    { name: 'Offer 接受率', value: data.value.offerAcceptRate, caption: '已发 Offer 中被接受的比例' }
  ])
].map((item, index) => {
  const value = clampRate(item.value)
  return {
    ...item,
    value,
    safeValue: value,
    color: leaderboardPalette[index % leaderboardPalette.length]
  }
}))
const funnelItems = computed(() => normalizeFunnel(data.value.funnel || []))
const funnelTotal = computed(() => funnelItems.value[0]?.value || 0)
const majorRows = computed(() => normalizeItems(data.value.majorApply || []))
const majorTotal = computed(() => majorRows.value.reduce((sum, item) => sum + item.value, 0))
const majorRank = computed(() => (
  majorRows.value.slice(0, 6).map((item, index) => ({
    ...item,
    percent: percentOf(item.value, majorTotal.value),
    color: chartPalette[index % chartPalette.length]
  }))
))
const donutStyle = (rows, total) => {
  let cursor = 0
  const safeTotal = total || 1
  const slices = rows.map((item) => {
    const start = cursor
    cursor += (item.value / safeTotal) * 100
    return `${item.color} ${start}% ${cursor}%`
  })
  if (cursor < 100) {
    slices.push(`#e8eef6 ${cursor}% 100%`)
  }
  return { background: `conic-gradient(${slices.join(', ')})` }
}
const statusRows = computed(() => (data.value.applyStatus || [])
  .map((item, index) => ({ name: item.name, value: Number(item.value) || 0, color: chartPalette[index % chartPalette.length] }))
  .filter((item) => item.value > 0)
)
const statusTotal = computed(() => statusRows.value.reduce((sum, item) => sum + item.value, 0))
const statusDonutStyle = computed(() => donutStyle(statusRows.value, statusTotal.value))
const majorDonutStyle = computed(() => donutStyle(majorRank.value, majorTotal.value))

onMounted(async () => {
  data.value = (await adminApi.statistics()).data || {}
})
</script>

<style scoped lang="scss">
.admin-dashboard {
  min-width: 0;
}

.dashboard-row {
  row-gap: 16px;
}

.kpi {
  position: relative;
  height: 120px;
  border-radius: var(--cr-radius);
  padding: 22px 24px;
  color: #fff;
  background:
    var(--cr-noise-texture),
    linear-gradient(135deg, color-mix(in srgb, var(--c) 88%, white), #15243b);
  background-size: 180px 180px, auto;
  background-blend-mode: soft-light, normal;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: var(--cr-shadow-soft), var(--cr-shadow-line);
  overflow: hidden;
}

.kpi-rays {
  --cr-rays-color: rgba(255, 255, 255, 0.22);
  --cr-rays-opacity: 0.36;
  --cr-rays-blur: 1.25rem;
  --cr-rays-length: 68%;
}

.kpi::after {
  content: "";
  position: absolute;
  inset: auto -26px -34px auto;
  width: 112px;
  height: 112px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.1);
}

.kpi-icon {
  position: relative;
  z-index: 1;
  width: 56px;
  height: 56px;
  border: 1px solid rgba(255, 255, 255, 0.24);
  border-radius: 14px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background: rgba(255, 255, 255, 0.14);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.22);
}

.kpi-icon .el-icon {
  font-size: 30px;
}

.num {
  position: relative;
  z-index: 1;
  font-size: 34px;
  font-weight: 700;
  line-height: 1;
}

.label {
  position: relative;
  z-index: 1;
  margin-top: 8px;
  line-height: 1.4;
  color: rgba(255, 255, 255, 0.92);
}

.panel {
  min-width: 0;
  height: 100%;
  background:
    var(--cr-noise-texture),
    linear-gradient(180deg, rgba(255,255,255,.96), rgba(248,251,255,.94)),
    #fff;
  background-size: 180px 180px, auto, auto;
  background-blend-mode: soft-light, normal, normal;
  border: 1px solid var(--cr-border-soft);
  border-radius: var(--cr-radius);
  padding: 18px;
  box-shadow: var(--cr-shadow-soft), var(--cr-shadow-line);
}

.panel-title {
  position: relative;
  font-weight: 820;
  color: var(--cr-text);
  padding-left: 12px;
  line-height: 1.2;
}

.panel-title::before {
  position: absolute;
  top: 0.1rem;
  bottom: 0.1rem;
  left: 0;
  width: 0.25rem;
  content: "";
  border-radius: 999rem;
  background: linear-gradient(180deg, var(--cr-primary), var(--cr-accent));
}

.chart {
  width: 100%;
  height: clamp(300px, 31vw, 380px);
  min-height: 300px;
}

.status-donut-board {
  display: grid;
  grid-template-columns: minmax(12rem, 0.8fr) minmax(12rem, 1fr);
  align-items: center;
  gap: 18px;
}

.donut-board {
  min-height: clamp(300px, 31vw, 380px);
  display: grid;
  grid-template-columns: minmax(220px, 0.9fr) minmax(170px, 1fr);
  gap: 12px;
  align-items: center;
}

.chart-donut {
  height: clamp(270px, 25vw, 340px);
  min-height: 270px;
  display: grid;
  place-items: center;
}

.donut-visual {
  position: relative;
  width: min(14rem, 76%);
  aspect-ratio: 1;
  border-radius: 50%;
  box-shadow: inset 0 0 0 1px rgba(203, 216, 231, 0.8), var(--cr-shadow-soft);
}

.donut-visual::after {
  position: absolute;
  inset: 23%;
  content: "";
  border-radius: inherit;
  background: #fff;
  box-shadow: inset 0 0 0 1px rgba(203, 216, 231, 0.72);
}

.donut-center {
  position: absolute;
  inset: 28%;
  z-index: 1;
  display: grid;
  place-items: center;
  align-content: center;
}

.donut-center strong {
  color: var(--cr-text);
  font-size: clamp(1.75rem, 3vw, 2.75rem);
  line-height: 1;
}

.donut-center span {
  margin-top: 4px;
  color: var(--cr-text-muted);
  font-size: 12px;
  font-weight: 700;
}

.chart-legend {
  min-width: 0;
  display: grid;
  gap: 10px;
}

.legend-item {
  min-width: 0;
  display: grid;
  grid-template-columns: 10px minmax(0, 1fr) auto;
  align-items: center;
  gap: 10px;
  padding: 9px 10px;
  border-radius: 10px;
  background: #f8fbff;
}

.legend-item i {
  width: 10px;
  height: 10px;
  border-radius: 999px;
}

.legend-item span {
  min-width: 0;
  color: var(--cr-text);
  font-size: 13px;
  font-weight: 700;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.legend-item strong {
  color: var(--cr-text-soft);
  font-size: 15px;
}

.donut-rank {
  min-width: 0;
  padding-top: 22px;
}

.donut-rank-head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 10px;
  margin-bottom: 14px;
}

.donut-rank-head span {
  color: var(--cr-text);
  font-weight: 600;
  line-height: 1.4;
}

.donut-rank-head em {
  color: var(--cr-text-muted);
  font-size: 12px;
  font-style: normal;
  white-space: nowrap;
}

.donut-rank-list {
  display: grid;
  gap: 13px;
}

.donut-rank-item {
  min-width: 0;
}

.rank-line {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.rank-name {
  min-width: 0;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  color: var(--cr-text);
  font-size: 13px;
  font-weight: 600;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.rank-name i {
  flex: 0 0 auto;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--rank-color);
}

.rank-line strong {
  color: var(--rank-color);
  font-size: 17px;
  line-height: 1;
}

.rank-track {
  height: 7px;
  margin-top: 7px;
  overflow: hidden;
  border-radius: 999px;
  background: var(--cr-surface-muted);
}

.rank-fill {
  width: var(--rank-width);
  height: 100%;
  min-width: 5px;
  border-radius: inherit;
  background: linear-gradient(90deg, var(--rank-color), color-mix(in srgb, var(--rank-color) 48%, white));
}

.donut-rank-item small {
  display: block;
  margin-top: 4px;
  color: var(--cr-text-muted);
  font-size: 11px;
  line-height: 1.2;
}

.leaderboard {
  min-height: clamp(300px, 31vw, 380px);
  padding-top: 22px;
  display: grid;
  align-content: center;
  gap: 10px;
}

.leaderboard-wide {
  min-height: clamp(300px, 24vw, 370px);
}

.leader-row {
  min-width: 0;
  display: grid;
  grid-template-columns: 42px minmax(0, 1fr);
  gap: 12px;
  align-items: center;
  padding: 9px 12px;
  border: 1px solid transparent;
  border-radius: 10px;
  background: linear-gradient(90deg, color-mix(in srgb, var(--row-color) 8%, white), #fff 54%);
}

.leader-row.hot {
  border-color: color-mix(in srgb, var(--row-color) 18%, white);
  box-shadow: 0 10px 24px color-mix(in srgb, var(--row-color) 9%, transparent);
}

.leader-rank {
  width: 36px;
  height: 36px;
  border-radius: 9px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 13px;
  font-weight: 700;
  background: var(--row-color);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.22);
}

.leader-main {
  min-width: 0;
}

.leader-head {
  min-width: 0;
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 14px;
}

.leader-name {
  min-width: 0;
  color: var(--cr-text);
  font-size: 13px;
  font-weight: 600;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.leader-head strong {
  flex: 0 0 auto;
  color: var(--row-color);
  font-size: 18px;
  line-height: 1;
}

.leader-head em {
  margin-left: 2px;
  color: var(--cr-text-muted);
  font-size: 12px;
  font-style: normal;
  font-weight: 500;
}

.leader-track {
  height: 8px;
  margin-top: 8px;
  overflow: hidden;
  border-radius: 999px;
  background: var(--cr-surface-muted);
}

.leader-fill {
  width: var(--row-width);
  height: 100%;
  min-width: 8px;
  border-radius: inherit;
  background: linear-gradient(90deg, var(--row-color), color-mix(in srgb, var(--row-color) 38%, white));
}

.empty-chart {
  min-height: 220px;
  display: grid;
  place-items: center;
  color: var(--cr-text-muted);
  font-size: 14px;
}

.rate {
  display: flex;
  flex-direction: column;
}

.rate-list {
  flex: 1;
  min-height: 0;
  display: grid;
  align-content: space-between;
  gap: 10px;
  padding-top: 18px;
}

.funnel-board {
  min-height: clamp(320px, 32vw, 390px);
  padding-top: 22px;
  display: grid;
  grid-template-columns: minmax(118px, 0.34fr) minmax(0, 1fr);
  gap: 20px;
  align-items: center;
}

.funnel-total {
  min-width: 0;
  padding: 18px 16px;
  border: 1px solid var(--cr-border-soft);
  border-radius: var(--cr-radius-sm);
  background: linear-gradient(180deg, #f8fbff, #fff);
}

.funnel-total span,
.funnel-total em {
  display: block;
  color: var(--cr-text-muted);
  font-size: 13px;
  font-style: normal;
  line-height: 1.4;
}

.funnel-total strong {
  display: block;
  margin: 8px 0 4px;
  color: var(--cr-text);
  font-size: clamp(34px, 4vw, 48px);
  line-height: 1;
}

.funnel-steps {
  min-width: 0;
  display: grid;
  gap: 16px;
}

.funnel-step {
  min-width: 0;
}

.funnel-step-head,
.funnel-meta {
  display: flex;
  justify-content: space-between;
  gap: 12px;
}

.funnel-step-head {
  align-items: baseline;
  color: var(--cr-text);
}

.funnel-step-head span {
  font-weight: 600;
  line-height: 1.4;
}

.funnel-step-head strong {
  color: var(--bar-color);
  font-size: 24px;
  line-height: 1;
}

.funnel-track {
  height: 14px;
  margin-top: 9px;
  overflow: hidden;
  border-radius: 999px;
  background: var(--cr-surface-muted);
}

.funnel-fill {
  width: var(--bar-width);
  height: 100%;
  border-radius: inherit;
  background: linear-gradient(90deg, var(--bar-color), color-mix(in srgb, var(--bar-color) 52%, white));
  box-shadow: 0 6px 14px color-mix(in srgb, var(--bar-color) 22%, transparent);
}

.funnel-meta {
  margin-top: 7px;
  color: var(--cr-text-muted);
  font-size: 12px;
  line-height: 1.4;
}

.rate-item {
  min-width: 0;
  padding: 12px 14px;
  border-radius: 10px;
  border: 1px solid color-mix(in srgb, var(--rate-color) 16%, white);
  background:
    linear-gradient(90deg, color-mix(in srgb, var(--rate-color) 8%, white), #fff 58%),
    #fff;
}

.rate-head {
  display: flex;
  flex-direction: row;
  align-items: baseline;
  justify-content: space-between;
  gap: 10px;
  color: var(--cr-text);
}

.rate-head span {
  min-width: 0;
  font-weight: 600;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.rate-head strong {
  flex: 0 0 auto;
  color: var(--rate-color);
  font-size: 24px;
  font-weight: 800;
  line-height: 1;
}

.rate-track {
  height: 7px;
  margin-top: 8px;
  overflow: hidden;
  border-radius: 999px;
  background: color-mix(in srgb, var(--rate-color) 10%, white);
}

.rate-fill {
  height: 100%;
  min-width: 6px;
  border-radius: inherit;
  background: linear-gradient(90deg, var(--rate-color), color-mix(in srgb, var(--rate-color) 42%, #15243b));
}

.rate-meta {
  margin-top: 6px;
  color: var(--cr-text-muted);
  font-size: 12px;
  line-height: 1.5;
}

@media (max-width: 640px) {
  .kpi {
    height: 104px;
    padding: 18px;
  }

  .kpi-icon {
    width: 48px;
    height: 48px;
    border-radius: 12px;
  }

  .kpi-icon .el-icon {
    font-size: 26px;
  }

  .num {
    font-size: 30px;
  }

  .panel {
    padding: 16px;
  }

  .chart {
    height: 320px;
  }

  .status-donut-board {
    grid-template-columns: 1fr;
    height: auto;
    min-height: 0;
  }

  .donut-board {
    min-height: 0;
    grid-template-columns: 1fr;
    gap: 8px;
  }

  .chart-donut {
    height: 280px;
    min-height: 280px;
  }

  .donut-visual {
    width: min(13rem, 68vw);
  }

  .donut-rank {
    padding-top: 0;
  }

  .leaderboard {
    min-height: 0;
  }

  .leader-row {
    grid-template-columns: 34px minmax(0, 1fr);
    padding: 9px 10px;
  }

  .leader-rank {
    width: 30px;
    height: 30px;
  }

  .funnel-board {
    min-height: 0;
    grid-template-columns: 1fr;
    align-items: stretch;
  }

  .funnel-total {
    display: flex;
    align-items: baseline;
    gap: 8px;
  }

  .funnel-total strong {
    margin: 0;
    font-size: 32px;
  }

  .funnel-meta {
    flex-wrap: wrap;
  }
}
</style>
