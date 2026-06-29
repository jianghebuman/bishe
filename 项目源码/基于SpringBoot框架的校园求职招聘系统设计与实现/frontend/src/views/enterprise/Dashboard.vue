<template>
  <div class="page-container dashboard enterprise-dashboard">
    <el-row :gutter="16" class="dashboard-row">
      <el-col v-for="k in kpis" :key="k.title" :xs="24" :sm="12" :md="12" :lg="6">
        <div class="kpi" :style="{ '--c': k.color }">
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
          <div ref="trendRef" class="chart"></div>
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
          <div ref="statusRef" class="chart small"></div>
        </div>
      </el-col>
      <el-col :xs="24" :lg="12">
        <div class="chart-card">
          <div class="chart-title">核心指标对比</div>
          <div ref="barRef" class="chart small"></div>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, nextTick } from 'vue'
import * as echarts from 'echarts'
import { Briefcase, Tickets, ChatLineRound, Medal } from '@element-plus/icons-vue'
import { enterpriseApi } from '@/api'

const data = ref({})
const trendRef = ref()
const statusRef = ref()
const barRef = ref()
let charts = []
let resizeObserver

const funnelColors = ['#2563eb', '#0891b2', '#7c3aed', '#e45757']
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

const resizeCharts = () => charts.forEach((chart) => chart.resize())

const observeChartResize = () => {
  resizeObserver?.disconnect()
  if (!window.ResizeObserver) return

  resizeObserver = new ResizeObserver(resizeCharts)
  ;[trendRef.value, statusRef.value, barRef.value]
    .filter(Boolean)
    .forEach((el) => resizeObserver.observe(el))
}

const init = () => {
  charts.forEach((chart) => chart.dispose())
  charts = []

  const trend = data.value.applyTrend || []
  const days = trend.map((i) => i.date?.substring(5))
  const nums = trend.map((i) => i.count)
  const trendChart = echarts.init(trendRef.value)
  trendChart.setOption({
    tooltip: { trigger: 'axis' },
    toolbox: { feature: { saveAsImage: {}, restore: {}, dataView: {} } },
    grid: { left: 40, right: 24, top: 44, bottom: 36, containLabel: true },
    xAxis: { type: 'category', data: days, boundaryGap: false },
    yAxis: { type: 'value', minInterval: 1 },
    series: [
      {
        name: '投递数',
        type: 'line',
        smooth: true,
        areaStyle: { color: 'rgba(37, 99, 235, .14)' },
        lineStyle: { width: 3 },
        data: nums,
        color: '#2563eb'
      }
    ]
  })
  charts.push(trendChart)

  const statusChart = echarts.init(statusRef.value)
  statusChart.setOption({
    tooltip: { trigger: 'item' },
    legend: { bottom: 0, type: 'scroll' },
    toolbox: { feature: { saveAsImage: {}, restore: {}, dataView: {} } },
    series: [
      {
        type: 'pie',
        radius: ['45%', '68%'],
        center: ['50%', '44%'],
        data: [
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
        ]
      }
    ]
  })
  charts.push(statusChart)

  const barChart = echarts.init(barRef.value)
  barChart.setOption({
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    toolbox: { feature: { saveAsImage: {}, restore: {}, dataView: {} } },
    grid: { left: 40, right: 24, top: 42, bottom: 36, containLabel: true },
    xAxis: { type: 'category', data: ['职位', '在线', '投递', '面试', 'Offer'] },
    yAxis: { type: 'value', minInterval: 1 },
    series: [
      {
        type: 'bar',
        barMaxWidth: 34,
        color: '#0891b2',
        data: [
          data.value.jobTotal || 0,
          data.value.jobOnline || 0,
          data.value.applyTotal || 0,
          data.value.interviewTotal || 0,
          data.value.offerTotal || 0
        ]
      }
    ]
  })
  charts.push(barChart)

  observeChartResize()
}

onMounted(async () => {
  data.value = (await enterpriseApi.dashboard()).data || {}
  await nextTick()
  init()
  window.addEventListener('resize', resizeCharts)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', resizeCharts)
  resizeObserver?.disconnect()
  charts.forEach((chart) => chart.dispose())
  charts = []
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
  height: 120px;
  border-radius: 12px;
  padding: 22px 24px;
  color: #fff;
  background:
    linear-gradient(135deg, color-mix(in srgb, var(--c) 88%, white), #15243b);
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: var(--cr-shadow-soft);
  overflow: hidden;
}

.num {
  font-size: 32px;
  font-weight: 700;
  line-height: 1;
}

.label {
  margin-top: 8px;
  line-height: 1.4;
  opacity: 0.95;
}

.chart-card {
  min-width: 0;
  height: 100%;
  background: #fff;
  border: 1px solid var(--cr-border-soft);
  border-radius: var(--cr-radius);
  padding: 18px;
  box-shadow: var(--cr-shadow-soft);
}

.chart-title {
  font-weight: 600;
  margin-bottom: 8px;
  color: var(--cr-text);
  border-left: 3px solid var(--cr-primary);
  padding-left: 10px;
  line-height: 1.2;
}

.chart {
  width: 100%;
  height: clamp(300px, 31vw, 380px);
  min-height: 300px;
}

.chart.small {
  height: clamp(280px, 28vw, 340px);
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

  .funnel-board {
    min-height: 0;
  }

  .funnel-meta {
    flex-wrap: wrap;
  }
}
</style>
