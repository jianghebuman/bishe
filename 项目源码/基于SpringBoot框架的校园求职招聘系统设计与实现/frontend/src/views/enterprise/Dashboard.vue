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
          <div ref="funnelRef" class="chart chart-funnel"></div>
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
const funnelRef = ref()
const statusRef = ref()
const barRef = ref()
let charts = []
let resizeObserver

const kpis = computed(() => [
  { title: '发布职位', value: data.value.jobTotal || 0, icon: Briefcase, color: '#2f7df6' },
  { title: '收到投递', value: data.value.applyTotal || 0, icon: Tickets, color: '#1f9d73' },
  { title: '面试安排', value: data.value.interviewTotal || 0, icon: ChatLineRound, color: '#d98718' },
  { title: '已发 Offer', value: data.value.offerTotal || 0, icon: Medal, color: '#d94c58' }
])

const resizeCharts = () => charts.forEach((chart) => chart.resize())

const observeChartResize = () => {
  resizeObserver?.disconnect()
  if (!window.ResizeObserver) return

  resizeObserver = new ResizeObserver(resizeCharts)
  ;[trendRef.value, funnelRef.value, statusRef.value, barRef.value]
    .filter(Boolean)
    .forEach((el) => resizeObserver.observe(el))
}

const funnelOption = (items) => ({
  tooltip: { trigger: 'item', formatter: '{b}: {c}' },
  toolbox: { feature: { saveAsImage: {}, restore: {}, dataView: {} } },
  series: [
    {
      type: 'funnel',
      sort: 'descending',
      gap: 4,
      left: '4%',
      top: 48,
      bottom: 38,
      width: '62%',
      minSize: '24%',
      maxSize: '88%',
      funnelAlign: 'center',
      label: {
        show: true,
        position: 'right',
        distance: 10,
        color: '#303133',
        fontSize: 13,
        formatter: ({ name, value }) => `${name}  ${value}`
      },
      labelLine: {
        show: true,
        length: 10,
        lineStyle: { color: '#a8b1c0' }
      },
      itemStyle: {
        borderColor: '#fff',
        borderWidth: 2
      },
      emphasis: {
        label: { fontSize: 14, fontWeight: 600 }
      },
      data: items
    }
  ]
})

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
        areaStyle: { color: 'rgba(47, 125, 246, .14)' },
        lineStyle: { width: 3 },
        data: nums,
        color: '#2f7df6'
      }
    ]
  })
  charts.push(trendChart)

  const funnelItems = [
    { name: '投递', value: data.value.applyTotal || 0 },
    { name: '待查看', value: data.value.applyPending || 0 },
    { name: '面试', value: data.value.applyInterview || 0 },
    { name: '录用', value: data.value.applyHired || 0 }
  ]
  const funnelChart = echarts.init(funnelRef.value)
  funnelChart.setOption(funnelOption(funnelItems))
  charts.push(funnelChart)

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
        color: '#1f9d73',
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
  background: linear-gradient(135deg, var(--c), #303133);
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 8px 20px rgba(20, 36, 60, 0.12);
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
  border: 1px solid #edf0f5;
  border-radius: 10px;
  padding: 18px;
  box-shadow: 0 2px 12px rgba(20, 36, 60, 0.05);
}

.chart-title {
  font-weight: 600;
  margin-bottom: 8px;
  border-left: 3px solid #2f7df6;
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

.chart-funnel {
  height: clamp(330px, 34vw, 400px);
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
  .chart.small,
  .chart-funnel {
    height: 320px;
  }
}
</style>
