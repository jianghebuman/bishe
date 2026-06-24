<template>
  <div class="fair-list portal-content">
    <div class="page-card head">
      <h2><el-icon><Calendar /></el-icon> 大型招聘会</h2>
      <p class="sub">面向全校学生的双选会、专场招聘会信息</p>
    </div>

    <div class="grid mt-20" v-loading="loading">
      <div class="fair-card" v-for="f in list" :key="f.id">
        <div class="cover" :style="f.cover ? { backgroundImage: `url(${f.cover})` } : { background: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)' }">
          <div class="cover-mask">
            <h3 class="title">{{ f.title }}</h3>
          </div>
        </div>
        <div class="body">
          <div class="info-row"><el-icon><Clock /></el-icon> {{ formatDateTime(f.fairTime) }}</div>
          <div class="info-row"><el-icon><Location /></el-icon> {{ f.location }}</div>
          <div class="info-row"><el-icon><Trophy /></el-icon> 主办方：{{ f.host || '校就业指导中心' }}</div>
          <p class="content">{{ f.content }}</p>
          <div class="stats">
            <div class="stat-item"><span class="num">{{ f.companyCount || 0 }}</span><span class="label">参会企业</span></div>
            <div class="stat-item"><span class="num">{{ f.jobCount || 0 }}</span><span class="label">提供岗位</span></div>
            <div class="stat-item"><span class="num">{{ f.signCount || 0 }}</span><span class="label">报名人数</span></div>
          </div>
          <el-button type="primary" style="width: 100%" @click="onSign(f)">立即报名</el-button>
        </div>
      </div>
      <el-empty v-if="!loading && list.length === 0" description="暂无招聘会" style="grid-column: 1 / -1;" />
    </div>

    <div class="pagination-wrap">
      <el-pagination v-model:current-page="query.pageNum" v-model:page-size="query.pageSize" :total="total"
        layout="total, prev, pager, next" background @current-change="load" />
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Calendar, Clock, Location, Trophy } from '@element-plus/icons-vue'
import { publicApi } from '@/api'

const query = reactive({ pageNum: 1, pageSize: 6 })
const list = ref([])
const total = ref(0)
const loading = ref(false)

const formatDateTime = (d) => d ? d.replace('T', ' ').substring(0, 16) : ''
const onSign = () => ElMessage.success('报名成功，请准时参加')

const load = async () => {
  loading.value = true
  try {
    const res = await publicApi.fairs(query)
    list.value = res.data.records; total.value = Number(res.data.total)
  } finally { loading.value = false }
}
onMounted(load)
</script>

<style scoped lang="scss">
.head h2 { color: #303133; .el-icon { vertical-align: middle; } }
.head .sub { color: #909399; margin-top: 6px; }
.grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; }
.fair-card { background: #fff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,.06);
  .cover { height: 140px; background-size: cover; background-position: center; position: relative;
    .cover-mask { position: absolute; inset: 0; background: linear-gradient(180deg, transparent, rgba(0,0,0,.6)); padding: 16px; display: flex; align-items: flex-end;
      .title { color: #fff; margin: 0; }
    }
  }
  .body { padding: 16px; }
  .info-row { color: #606266; font-size: 13px; line-height: 1.8; .el-icon { vertical-align: middle; margin-right: 4px; } }
  .content { color: #909399; font-size: 13px; margin: 10px 0; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
  .stats { display: flex; gap: 8px; padding: 12px; background: #f5f7fa; border-radius: 6px; margin-bottom: 12px;
    .stat-item { flex: 1; text-align: center;
      .num { display: block; color: #f56c6c; font-size: 20px; font-weight: 600; }
      .label { color: #909399; font-size: 12px; }
    }
  }
}
</style>
