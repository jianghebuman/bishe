<template>
  <div class="page-container admin-dashboard">
    <el-row :gutter="16" class="dashboard-row">
      <el-col v-for="k in kpis" :key="k.title" :xs="24" :sm="12" :md="12" :lg="6">
        <div class="kpi" :style="{ '--c': k.color }">
          <div>
            <div class="num">{{ k.value }}</div>
            <div class="label">{{ k.title }}</div>
          </div>
          <el-icon size="44"><component :is="k.icon" /></el-icon>
        </div>
      </el-col>
    </el-row>
    <el-row :gutter="16" class="dashboard-row mt-20">
      <el-col :xs="24" :lg="12">
        <div class="panel">
          <div class="panel-title">投递到录用招聘漏斗</div>
          <div ref="funnelRef" class="chart chart-funnel"></div>
        </div>
      </el-col>
      <el-col :xs="24" :lg="12">
        <div class="panel">
          <div class="panel-title">投递状态分布</div>
          <div ref="statusRef" class="chart"></div>
        </div>
      </el-col>
    </el-row>
    <el-row :gutter="16" class="dashboard-row mt-20">
      <el-col :xs="24" :lg="12">
        <div class="panel">
          <div class="panel-title">各专业投递人数统计</div>
          <div ref="majorRef" class="chart"></div>
        </div>
      </el-col>
      <el-col :xs="24" :lg="12">
        <div class="panel">
          <div class="panel-title">岗位类别招聘数量</div>
          <div ref="categoryRef" class="chart"></div>
        </div>
      </el-col>
    </el-row>
    <el-row :gutter="16" class="dashboard-row mt-20">
      <el-col :xs="24" :lg="16">
        <div class="panel">
          <div class="panel-title">企业招聘活跃度 TOP</div>
          <div ref="enterpriseRef" class="chart"></div>
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
              <div class="rate-track">
                <div class="rate-fill" :style="{ width: `${item.safeValue}%` }"></div>
              </div>
              <div class="rate-meta">{{ item.caption }}</div>
            </div>
          </div>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, nextTick } from 'vue'
import * as echarts from 'echarts'
import { User, OfficeBuilding, Briefcase, Tickets } from '@element-plus/icons-vue'
import { adminApi } from '@/api'

const data = ref({})
const funnelRef = ref()
const statusRef = ref()
const majorRef = ref()
const categoryRef = ref()
const enterpriseRef = ref()
let charts = []
let resizeObserver

const clampRate = (value) => Math.min(Math.max(Number(value) || 0, 0), 100)

const kpis = computed(() => [
  { title: '学生总数', value: data.value.studentCount || 0, icon: User, color: '#2f7df6' },
  { title: '企业总数', value: data.value.enterpriseCount || 0, icon: OfficeBuilding, color: '#1f9d73' },
  { title: '岗位总数', value: data.value.jobCount || 0, icon: Briefcase, color: '#d98718' },
  { title: '投递总数', value: data.value.applyCount || 0, icon: Tickets, color: '#d94c58' }
])

const rates = computed(() => [
  {
    name: '面试通过率',
    value: clampRate(data.value.interviewPassRate),
    safeValue: clampRate(data.value.interviewPassRate),
    color: '#2f7df6',
    caption: '从面试进入通过状态的比例'
  },
  {
    name: 'Offer 接受率',
    value: clampRate(data.value.offerAcceptRate),
    safeValue: clampRate(data.value.offerAcceptRate),
    color: '#1f9d73',
    caption: '已发 Offer 中被接受的比例'
  }
])

const resizeCharts = () => charts.forEach((chart) => chart.resize())

const observeChartResize = () => {
  resizeObserver?.disconnect()
  if (!window.ResizeObserver) return

  resizeObserver = new ResizeObserver(resizeCharts)
  ;[funnelRef.value, statusRef.value, majorRef.value, categoryRef.value, enterpriseRef.value]
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
      left: '6%',
      top: 48,
      bottom: 38,
      width: '66%',
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

  const commonTool = { feature: { saveAsImage: {}, restore: {}, dataView: {} } }
  const funnel = echarts.init(funnelRef.value)
  funnel.setOption(funnelOption(data.value.funnel || []))
  charts.push(funnel)

  const status = echarts.init(statusRef.value)
  status.setOption({
    tooltip: { trigger: 'item' },
    legend: { bottom: 0, type: 'scroll' },
    toolbox: commonTool,
    series: [{ type: 'pie', radius: ['42%', '68%'], center: ['50%', '43%'], data: data.value.applyStatus || [] }]
  })
  charts.push(status)

  const majorData = data.value.majorApply || []
  const major = echarts.init(majorRef.value)
  major.setOption({
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    toolbox: { feature: { saveAsImage: {}, restore: {}, dataView: {}, dataZoom: {} } },
    grid: { left: 50, right: 24, top: 42, bottom: 58, containLabel: true },
    xAxis: { type: 'category', data: majorData.map((i) => i.name), axisLabel: { rotate: 25, interval: 0 } },
    yAxis: { type: 'value', minInterval: 1 },
    series: [{ type: 'bar', name: '投递人数', data: majorData.map((i) => i.value), color: '#2f7df6' }]
  })
  charts.push(major)

  const catData = data.value.categoryJob || []
  const cat = echarts.init(categoryRef.value)
  cat.setOption({
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    toolbox: commonTool,
    grid: { left: 45, right: 24, top: 42, bottom: 44, containLabel: true },
    xAxis: { type: 'category', data: catData.map((i) => i.name), axisLabel: { interval: 0 } },
    yAxis: { type: 'value', minInterval: 1 },
    series: [{ type: 'bar', name: '岗位数', data: catData.map((i) => i.value), color: '#1f9d73' }]
  })
  charts.push(cat)

  const entData = (data.value.enterpriseActive || []).slice().reverse()
  const ent = echarts.init(enterpriseRef.value)
  ent.setOption({
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    toolbox: commonTool,
    grid: { left: 120, right: 32, top: 42, bottom: 36, containLabel: true },
    xAxis: { type: 'value' },
    yAxis: { type: 'category', data: entData.map((i) => i.name) },
    series: [{ type: 'bar', name: '发布岗位数', data: entData.map((i) => i.value), color: '#d98718' }]
  })
  charts.push(ent)

  observeChartResize()
}

onMounted(async () => {
  data.value = (await adminApi.statistics()).data || {}
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
.admin-dashboard {
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
  background: linear-gradient(135deg, var(--c), #263445);
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 8px 22px rgba(20, 36, 60, 0.12);
  overflow: hidden;
}

.num {
  font-size: 34px;
  font-weight: 700;
  line-height: 1;
}

.label {
  margin-top: 8px;
  line-height: 1.4;
}

.panel {
  min-width: 0;
  height: 100%;
  background: #fff;
  border: 1px solid #edf0f5;
  border-radius: 10px;
  padding: 18px;
  box-shadow: 0 2px 12px rgba(20, 36, 60, 0.05);
}

.panel-title {
  font-weight: 600;
  color: #303133;
  border-left: 3px solid #2f7df6;
  padding-left: 10px;
  line-height: 1.2;
}

.chart {
  width: 100%;
  height: clamp(300px, 31vw, 380px);
  min-height: 300px;
}

.chart-funnel {
  height: clamp(320px, 32vw, 390px);
}

.rate-list {
  display: grid;
  gap: 22px;
  padding-top: 34px;
}

.rate-item {
  min-width: 0;
}

.rate-head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 12px;
  color: #303133;
}

.rate-head span {
  font-weight: 600;
  line-height: 1.4;
}

.rate-head strong {
  color: var(--rate-color);
  font-size: 30px;
  line-height: 1;
}

.rate-track {
  height: 12px;
  margin-top: 12px;
  overflow: hidden;
  border-radius: 999px;
  background: #eef2f7;
}

.rate-fill {
  height: 100%;
  min-width: 6px;
  border-radius: inherit;
  background: linear-gradient(90deg, var(--rate-color), rgba(38, 52, 69, 0.88));
}

.rate-meta {
  margin-top: 8px;
  color: #7b8494;
  font-size: 13px;
  line-height: 1.5;
}

@media (max-width: 640px) {
  .kpi {
    height: 104px;
    padding: 18px;
  }

  .num {
    font-size: 30px;
  }

  .panel {
    padding: 16px;
  }

  .chart,
  .chart-funnel {
    height: 320px;
  }
}
</style>
