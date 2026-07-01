<template>
  <div class="page-container dashboard enterprise-dashboard">
    <el-row :gutter="16" class="dashboard-row">
      <el-col v-for="k in kpis" :key="k.title" :xs="24" :sm="12" :md="12" :lg="6">
        <div class="kpi" :style="{ '--c': k.color }">
          <div class="cr-light-rays-layer kpi-rays" aria-hidden="true"><i></i><i></i></div>
          <div>
            <div class="num">{{ k.value }}</div>
            <div class="label">{{ k.title }}</div>
          </div>
          <el-icon size="42"><component :is="k.icon" /></el-icon>
        </div>
      </el-col>
    </el-row>
    <el-row :gutter="16" class="dashboard-row mt-20">
      <el-col :xs="24" :lg="16">
        <div class="chart-card">
          <div class="chart-title">近 7 天投递趋势</div>
          <div class="chart trend-chart">
            <svg v-if="trendRows.length" viewBox="0 0 640 260" preserveAspectRatio="none" role="img" aria-label="近 7 天投递趋势">
              <line v-for="y in chartGridY" :key="y" x1="44" x2="612" :y1="y" :y2="y" class="chart-grid-line" />
              <path :d="trendAreaPath" class="trend-area" />
              <path :d="trendLinePath" class="trend-line" />
              <g v-for="point in trendPoints" :key="point.label">
                <circle :cx="point.x" :cy="point.y" r="4.5" class="trend-dot" />
                <text :x="point.x" y="246" text-anchor="middle" class="chart-axis-label">{{ point.label }}</text>
              </g>
            </svg>
            <div v-else class="empty-chart">暂无投递趋势数据</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :lg="8">
        <div class="chart-card">
          <div class="chart-title">招聘转化漏斗</div>
          <div class="funnel-board">
            <div class="funnel-total">
              <span>累计投递</span>
              <strong>{{ funnelTotal }}</strong>
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
                  <span>占比 {{ item.percent }}%</span>
                  <span v-if="item.conversion !== null">转化 {{ item.conversion }}%</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </el-col>
    </el-row>
    <el-row :gutter="16" class="dashboard-row mt-20">
      <el-col :xs="24" :lg="12">
        <div class="chart-card">
          <div class="chart-title">投递处理状态</div>
          <div class="chart small donut-chart">
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
      <el-col :xs="24" :lg="12">
        <div class="chart-card">
          <div class="chart-title">核心指标对比</div>
          <div class="chart small bar-chart">
            <div
              v-for="item in metricRows"
              :key="item.name"
              class="metric-bar"
              :style="{ '--bar-color': item.color, '--bar-width': `${item.percent}%` }"
            >
              <div class="metric-head">
                <span>{{ item.name }}</span>
                <strong>{{ item.value }}</strong>
              </div>
              <div class="metric-track"><div class="metric-fill"></div></div>
            </div>
          </div>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Briefcase, Tickets, ChatLineRound, Medal } from '@element-plus/icons-vue'
import { enterpriseApi } from '@/api'

const data = ref({})

const funnelColors = ['#2563eb', '#0891b2', '#7c3aed', '#e45757']
const chartColors = ['#2563eb', '#0891b2', '#7c3aed', '#e45757', '#64748b']
const chartGridY = [38, 86, 134, 182, 230]
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
  { title: '发布职位', value: data.value.jobTotal || 0, icon: Briefcase, color: '#2563eb' },
  { title: '收到投递', value: data.value.applyTotal || 0, icon: Tickets, color: '#0891b2' },
  { title: '面试安排', value: data.value.interviewTotal || 0, icon: ChatLineRound, color: '#7c3aed' },
  { title: '已发 Offer', value: data.value.offerTotal || 0, icon: Medal, color: '#e45757' }
])
const rawFunnelItems = computed(() => [
  { name: '投递', value: data.value.applyTotal || 0 },
  { name: '待查看', value: data.value.applyPending || 0 },
  { name: '面试', value: data.value.applyInterview || 0 },
  { name: '录用', value: data.value.applyHired || 0 }
])
const funnelItems = computed(() => normalizeFunnel(rawFunnelItems.value))
const funnelTotal = computed(() => funnelItems.value[0]?.value || 0)
const trendRows = computed(() => (data.value.applyTrend || []).map((item) => ({
  label: item.date?.substring(5) || '',
  value: Number(item.count) || 0
})))
const trendPoints = computed(() => {
  const rows = trendRows.value
  const max = Math.max(...rows.map((item) => item.value), 1)
  const step = rows.length > 1 ? 568 / (rows.length - 1) : 0

  return rows.map((item, index) => ({
    ...item,
    x: 44 + step * index,
    y: 230 - (item.value / max) * 190
  }))
})
const trendLinePath = computed(() => trendPoints.value.map((point, index) => (
  `${index === 0 ? 'M' : 'L'} ${point.x} ${point.y}`
)).join(' '))
const trendAreaPath = computed(() => {
  if (!trendPoints.value.length) return ''
  const first = trendPoints.value[0]
  const last = trendPoints.value[trendPoints.value.length - 1]
  return `${trendLinePath.value} L ${last.x} 230 L ${first.x} 230 Z`
})
const statusRows = computed(() => {
  const rows = [
    { name: '待查看', value: data.value.applyPending || 0 },
    { name: '面试', value: data.value.applyInterview || 0 },
    { name: '录用', value: data.value.applyHired || 0 },
    {
      name: '其他',
      value: Math.max(
        (data.value.applyTotal || 0) -
          (data.value.applyPending || 0) -
          (data.value.applyInterview || 0) -
          (data.value.applyHired || 0),
        0
      )
    }
  ].map((item, index) => ({ ...item, color: chartColors[index] }))

  return rows.filter((item) => item.value > 0)
})
const statusTotal = computed(() => statusRows.value.reduce((sum, item) => sum + item.value, 0))
const statusDonutStyle = computed(() => {
  let cursor = 0
  const total = statusTotal.value || 1
  const slices = statusRows.value.map((item) => {
    const start = cursor
    cursor += (item.value / total) * 100
    return `${item.color} ${start}% ${cursor}%`
  })
  return { background: `conic-gradient(${slices.join(', ')})` }
})
const metricRows = computed(() => {
  const rows = [
    { name: '职位', value: data.value.jobTotal || 0 },
    { name: '在线', value: data.value.jobOnline || 0 },
    { name: '投递', value: data.value.applyTotal || 0 },
    { name: '面试', value: data.value.interviewTotal || 0 },
    { name: 'Offer', value: data.value.offerTotal || 0 }
  ]
  const max = Math.max(...rows.map((item) => item.value), 1)

  return rows.map((item, index) => ({
    ...item,
    color: chartColors[index],
    percent: item.value > 0 ? Math.max(Math.round((item.value / max) * 100), 8) : 0
  }))
})

onMounted(async () => {
  data.value = (await enterpriseApi.dashboard()).data || {}
})
</script>

<style scoped lang="scss">
.enterprise-dashboard {
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
  position: absolute;
  inset: auto -2.5rem -3rem auto;
  width: 8rem;
  height: 8rem;
  content: "";
  background: rgba(255,255,255,.10);
  transform: rotate(24deg);
}

.kpi .el-icon {
  position: relative;
  z-index: 1;
  width: 3.25rem;
  height: 3.25rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border: 1px solid rgba(255,255,255,.24);
  border-radius: var(--cr-radius-sm);
  background: rgba(255,255,255,.14);
}

.num {
  position: relative;
  z-index: 1;
  font-size: 32px;
  font-weight: 850;
  line-height: 1;
}

.label {
  position: relative;
  z-index: 1;
  margin-top: 8px;
  line-height: 1.4;
  opacity: 0.95;
  font-weight: 700;
}

.chart-card {
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

.chart-title {
  position: relative;
  font-weight: 820;
  margin-bottom: 8px;
  color: var(--cr-text);
  padding-left: 12px;
  line-height: 1.2;
}

.chart-title::before {
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

.chart.small {
  height: clamp(280px, 28vw, 340px);
}

.trend-chart,
.donut-chart,
.bar-chart {
  position: relative;
  display: grid;
  align-items: center;
}

.trend-chart svg {
  width: 100%;
  height: 100%;
  overflow: visible;
}

.chart-grid-line {
  stroke: rgba(148, 163, 184, 0.22);
  stroke-width: 1;
}

.trend-area {
  fill: rgba(37, 99, 235, 0.1);
}

.trend-line {
  fill: none;
  stroke: var(--cr-primary);
  stroke-width: 3.5;
  stroke-linecap: round;
  stroke-linejoin: round;
}

.trend-dot {
  fill: #fff;
  stroke: var(--cr-primary);
  stroke-width: 3;
}

.chart-axis-label {
  fill: var(--cr-text-muted);
  font-size: 12px;
  font-weight: 700;
}

.donut-chart {
  grid-template-columns: minmax(12rem, 0.8fr) minmax(12rem, 1fr);
  gap: 18px;
}

.donut-visual {
  position: relative;
  width: min(14rem, 72%);
  aspect-ratio: 1;
  place-self: center;
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

.bar-chart {
  align-content: center;
  gap: 17px;
}

.metric-bar {
  min-width: 0;
}

.metric-head {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  gap: 12px;
}

.metric-head span {
  color: var(--cr-text);
  font-size: 13px;
  font-weight: 700;
}

.metric-head strong {
  color: var(--bar-color);
  font-size: 22px;
  line-height: 1;
}

.metric-track {
  height: 13px;
  margin-top: 8px;
  overflow: hidden;
  border-radius: 999px;
  background: var(--cr-surface-muted);
}

.metric-fill {
  width: var(--bar-width);
  height: 100%;
  border-radius: inherit;
  background: linear-gradient(90deg, var(--bar-color), color-mix(in srgb, var(--bar-color) 50%, white));
  box-shadow: 0 6px 14px color-mix(in srgb, var(--bar-color) 18%, transparent);
}

.empty-chart {
  min-height: 12rem;
  display: grid;
  place-items: center;
  color: var(--cr-text-muted);
  font-size: 14px;
}

.funnel-board {
  min-height: clamp(330px, 34vw, 400px);
  padding-top: 18px;
  display: grid;
  gap: 18px;
  align-content: center;
}

.funnel-total {
  min-width: 0;
  padding: 14px 16px;
  border: 1px solid var(--cr-border-soft);
  border-radius: var(--cr-radius-sm);
  background: linear-gradient(180deg, #f8fbff, #fff);
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 12px;
}

.funnel-total span {
  color: var(--cr-text-muted);
  font-size: 13px;
  line-height: 1.4;
}

.funnel-total strong {
  color: var(--cr-text);
  font-size: 34px;
  line-height: 1;
}

.funnel-steps {
  min-width: 0;
  display: grid;
  gap: 14px;
}

.funnel-step {
  min-width: 0;
}

.funnel-step-head,
.funnel-meta {
  display: flex;
  justify-content: space-between;
  gap: 10px;
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
  font-size: 22px;
  line-height: 1;
}

.funnel-track {
  height: 13px;
  margin-top: 8px;
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
  margin-top: 6px;
  color: var(--cr-text-muted);
  font-size: 12px;
  line-height: 1.4;
}

@media (max-width: 640px) {
  .kpi {
    height: 104px;
    padding: 18px;
  }

  .num {
    font-size: 30px;
  }

  .chart-card {
    padding: 16px;
  }

  .chart,
  .chart.small {
    height: 320px;
  }

  .donut-chart {
    grid-template-columns: 1fr;
    height: auto;
    min-height: 0;
  }

  .donut-visual {
    width: min(13rem, 68vw);
  }

  .funnel-board {
    min-height: 0;
  }

  .funnel-meta {
    flex-wrap: wrap;
  }
}
</style>
