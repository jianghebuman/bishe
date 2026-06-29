<template>
  <div class="page-container admin-dashboard">
    <el-row :gutter="16" class="dashboard-row">
      <el-col v-for="k in kpis" :key="k.title" :xs="24" :sm="12" :md="12" :lg="6">
        <div class="kpi" :style="{ '--c': k.color }">
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
          <div class="panel-title">投递到录用招聘漏斗</div>
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
          <div ref="statusRef" class="chart"></div>
        </div>
      </el-col>
    </el-row>
    <el-row :gutter="16" class="dashboard-row mt-20">
      <el-col :xs="24" :lg="12">
        <div class="panel">
          <div class="panel-title">各专业投递占比</div>
          <div class="donut-board">
            <div ref="majorRef" class="chart chart-donut"></div>
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
          <div class="panel-title">岗位类别招聘数量 TOP 8</div>
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
import { DocumentChecked, Histogram, OfficeBuilding, UserFilled } from '@element-plus/icons-vue'
import { adminApi } from '@/api'

const data = ref({})
const statusRef = ref()
const majorRef = ref()
const categoryRef = ref()
const enterpriseRef = ref()
let charts = []
let resizeObserver

const funnelColors = ['#2563eb', '#0891b2', '#7c3aed', '#e45757']
const chartPalette = ['#2563eb', '#0891b2', '#7c3aed', '#e45757', '#16a34a', '#f59e0b', '#475569', '#db2777']
const clampRate = (value) => Math.min(Math.max(Number(value) || 0, 0), 100)
const percentOf = (value, total) => total ? Math.round((value / total) * 100) : 0
const normalizeItems = (items = []) => (
  items
    .map((item) => ({ name: item.name, value: Number(item.value) || 0 }))
    .sort((a, b) => b.value - a.value)
)
const topItems = (items = [], limit = 8) => (
  normalizeItems(items).slice(0, limit)
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
  {
    name: '面试通过率',
    value: clampRate(data.value.interviewPassRate),
    safeValue: clampRate(data.value.interviewPassRate),
    color: '#2563eb',
    caption: '从面试进入通过状态的比例'
  },
  {
    name: 'Offer 接受率',
    value: clampRate(data.value.offerAcceptRate),
    safeValue: clampRate(data.value.offerAcceptRate),
    color: '#0891b2',
    caption: '已发 Offer 中被接受的比例'
  }
])
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

const resizeCharts = () => charts.forEach((chart) => chart.resize())

const observeChartResize = () => {
  resizeObserver?.disconnect()
  if (!window.ResizeObserver) return

  resizeObserver = new ResizeObserver(resizeCharts)
  ;[statusRef.value, majorRef.value, categoryRef.value, enterpriseRef.value]
    .filter(Boolean)
    .forEach((el) => resizeObserver.observe(el))
}

const init = () => {
  charts.forEach((chart) => chart.dispose())
  charts = []

  const commonTool = { feature: { saveAsImage: {}, restore: {}, dataView: {} } }
  const status = echarts.init(statusRef.value)
  status.setOption({
    tooltip: { trigger: 'item' },
    legend: { bottom: 0, type: 'scroll' },
    toolbox: commonTool,
    series: [{ type: 'pie', radius: ['42%', '68%'], center: ['50%', '43%'], data: data.value.applyStatus || [] }]
  })
  charts.push(status)

  const majorData = majorRows.value
  const majorTotalValue = majorTotal.value
  const major = echarts.init(majorRef.value)
  major.setOption({
    color: chartPalette,
    tooltip: { trigger: 'item', formatter: '{b}<br/>{c} 人 ({d}%)' },
    toolbox: commonTool,
    title: majorTotalValue ? {
      text: `${majorTotalValue}`,
      subtext: '投递人数',
      left: 'center',
      top: '42%',
      textAlign: 'center',
      textStyle: { color: '#15243b', fontSize: 26, fontWeight: 700 },
      subtextStyle: { color: '#64748b', fontSize: 12 }
    } : undefined,
    graphic: majorTotalValue ? [] : [{
      type: 'text',
      left: 'center',
      top: 'middle',
      style: { text: '暂无专业投递数据', fill: '#94a3b8', fontSize: 14 }
    }],
    series: [{
      type: 'pie',
      name: '投递人数',
      radius: ['50%', '72%'],
      center: ['50%', '48%'],
      minAngle: 8,
      padAngle: 2,
      avoidLabelOverlap: true,
      itemStyle: { borderColor: '#fff', borderRadius: 4, borderWidth: 2 },
      label: { show: false },
      labelLine: { show: false },
      data: majorData
    }]
  })
  charts.push(major)

  const catData = topItems(data.value.categoryJob || [])
  const cat = echarts.init(categoryRef.value)
  cat.setOption({
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    toolbox: commonTool,
    grid: { left: 102, right: 42, top: 42, bottom: 28, containLabel: true },
    xAxis: { type: 'value', minInterval: 1 },
    yAxis: {
      type: 'category',
      data: catData.map((i) => i.name).reverse(),
      axisLabel: { width: 88, overflow: 'truncate' }
    },
    series: [{ type: 'bar', name: '岗位数', data: catData.map((i) => i.value).reverse(), color: '#0891b2', barMaxWidth: 22 }]
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
    series: [{ type: 'bar', name: '发布岗位数', data: entData.map((i) => i.value), color: '#7c3aed' }]
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
  position: relative;
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
  background: #fff;
  border: 1px solid var(--cr-border-soft);
  border-radius: var(--cr-radius);
  padding: 18px;
  box-shadow: var(--cr-shadow-soft);
}

.panel-title {
  font-weight: 600;
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

.rate-list {
  display: grid;
  gap: 22px;
  padding-top: 34px;
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
}

.rate-head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 12px;
  color: var(--cr-text);
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
  background: var(--cr-surface-muted);
}

.rate-fill {
  height: 100%;
  min-width: 6px;
  border-radius: inherit;
  background: linear-gradient(90deg, var(--rate-color), rgba(21, 36, 59, 0.88));
}

.rate-meta {
  margin-top: 8px;
  color: var(--cr-text-muted);
  font-size: 13px;
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

  .donut-board {
    min-height: 0;
    grid-template-columns: 1fr;
    gap: 8px;
  }

  .chart-donut {
    height: 280px;
    min-height: 280px;
  }

  .donut-rank {
    padding-top: 0;
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
