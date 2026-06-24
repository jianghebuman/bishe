<template>
  <div class="page-container">
    <div class="page-card">
      <div class="header"><div><h2>投递记录</h2><p>跟踪每份简历从投递到录用的处理进度。</p></div><el-button type="primary" @click="$router.push('/jobs')">继续投递</el-button></div>
      <el-divider />
      <el-radio-group v-model="query.status" @change="reload" class="mb-20">
        <el-radio-button :label="''">全部</el-radio-button><el-radio-button v-for="(t,i) in statusTexts" :key="i" :label="i">{{ t }}</el-radio-button>
      </el-radio-group>
      <el-table :data="list" stripe v-loading="loading">
        <el-table-column label="岗位" min-width="180"><template #default="{row}"><b>{{ row.job?.title || '-' }}</b><div class="sub">{{ row.job?.city }} · {{ row.job?.education }}</div></template></el-table-column>
        <el-table-column label="薪资" width="120"><template #default="{row}"><span class="salary">{{ row.job?.salaryMin }}-{{ row.job?.salaryMax }}K</span></template></el-table-column>
        <el-table-column label="状态" width="120"><template #default="{row}"><el-tag :type="statusType(row.status)">{{ statusTexts[row.status] }}</el-tag></template></el-table-column>
        <el-table-column prop="applyRemark" label="投递附言" min-width="160" show-overflow-tooltip />
        <el-table-column prop="hrRemark" label="HR备注" min-width="160" show-overflow-tooltip />
        <el-table-column prop="createTime" label="投递时间" width="180" />
        <el-table-column label="操作" width="160"><template #default="{row}"><el-button text type="primary" @click="$router.push(`/job/${row.jobId}`)">查看岗位</el-button><el-button v-if="row.status<=1" text type="danger" @click="withdraw(row)">撤回</el-button></template></el-table-column>
      </el-table>
      <div class="pagination-wrap"><el-pagination v-model:current-page="query.pageNum" :total="total" background layout="total,prev,pager,next" @current-change="load"/></div>
    </div>
  </div>
</template>
<script setup>
import { reactive, ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { studentApi } from '@/api'
const statusTexts=['待查看','已查看','邀请面试','笔试','已录用','不合适']
const statusType=s=>s===4?'success':s===5?'danger':s>=2?'warning':'info'
const query=reactive({pageNum:1,pageSize:10,status:''});const list=ref([]);const total=ref(0);const loading=ref(false)
const load=async()=>{loading.value=true;try{const p={pageNum:query.pageNum,pageSize:query.pageSize};if(query.status!=='')p.status=query.status;const r=await studentApi.applyList(p);list.value=r.data.records;total.value=Number(r.data.total)}finally{loading.value=false}}
const reload=()=>{query.pageNum=1;load()}
const withdraw=row=>ElMessageBox.confirm('确定撤回该投递？仅企业尚未深入处理时可撤回。').then(async()=>{await studentApi.cancelApply(row.id);ElMessage.success('已撤回');load()})
onMounted(load)
</script>
<style scoped lang="scss">.header{display:flex;justify-content:space-between;align-items:center;h2{margin-bottom:6px;}p{color:#909399;}}.sub{font-size:12px;color:#909399;margin-top:4px}.salary{color:#f56c6c;font-weight:600}</style>
