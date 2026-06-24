<template>
  <div class="page-container"><div class="page-card">
    <div class="header"><div><h2>我的收藏</h2><p>收藏感兴趣的岗位，方便后续比较与投递。</p></div><el-button type="primary" @click="$router.push('/jobs')">发现更多岗位</el-button></div><el-divider/>
    <el-row :gutter="16" v-loading="loading">
      <el-col :span="12" v-for="f in list" :key="f.id">
        <div class="fav-card">
          <div class="job-title">{{ f.job?.title }}</div>
          <div class="salary">{{ f.job?.salaryMin }}-{{ f.job?.salaryMax }}K</div>
          <div class="meta">{{ f.job?.city }} · {{ f.job?.education }} · {{ f.job?.jobType===1?'全职':'实习' }}</div>
          <div class="footer"><span>收藏于 {{ f.createTime }}</span><div><el-button text type="primary" @click="$router.push(`/job/${f.jobId}`)">查看</el-button><el-button text type="danger" @click="cancel(f)">取消收藏</el-button></div></div>
        </div>
      </el-col>
    </el-row>
    <el-empty v-if="!loading&&list.length===0" description="暂无收藏岗位" />
    <div class="pagination-wrap"><el-pagination v-model:current-page="query.pageNum" :total="total" background layout="total,prev,pager,next" @current-change="load"/></div>
  </div></div>
</template>
<script setup>
import { reactive,ref,onMounted } from 'vue';import { ElMessage } from 'element-plus';import { studentApi } from '@/api'
const query=reactive({pageNum:1,pageSize:10});const list=ref([]);const total=ref(0);const loading=ref(false)
const load=async()=>{loading.value=true;try{const r=await studentApi.favorites(query);list.value=r.data.records;total.value=Number(r.data.total)}finally{loading.value=false}}
const cancel=async(row)=>{await studentApi.delFavorite(row.jobId);ElMessage.success('已取消收藏');load()}
onMounted(load)
</script>
<style scoped lang="scss">.header{display:flex;justify-content:space-between;align-items:center;h2{margin-bottom:6px;}p{color:#909399;}}.fav-card{background:#fff;border:1px solid #ebeef5;border-radius:8px;padding:18px;margin-bottom:16px;transition:.2s;&:hover{box-shadow:0 4px 14px rgba(0,0,0,.08)}}.job-title{font-weight:600;color:#303133;margin-bottom:8px}.salary{color:#f56c6c;font-size:18px;font-weight:600;margin-bottom:8px}.meta{color:#909399;font-size:13px}.footer{display:flex;justify-content:space-between;align-items:center;margin-top:14px;color:#c0c4cc;font-size:12px}</style>
