<template>
  <div class="page-container"><div class="page-card">
    <div class="header"><h2>面试通知</h2><p>及时确认面试安排，避免错过企业沟通。</p></div><el-divider/>
    <el-table :data="list" stripe v-loading="loading">
      <el-table-column prop="interviewTime" label="面试时间" width="180"/>
      <el-table-column label="方式" width="100"><template #default="{row}"><el-tag>{{ row.interviewType===2?'线上':'现场' }}</el-tag></template></el-table-column>
      <el-table-column prop="location" label="地点/链接" min-width="220" show-overflow-tooltip/>
      <el-table-column prop="contact" label="联系人" width="160"/>
      <el-table-column prop="remark" label="备注" min-width="180" show-overflow-tooltip/>
      <el-table-column label="确认状态" width="110"><template #default="{row}"><el-tag :type="row.studentStatus===1?'success':row.studentStatus===2?'danger':'warning'">{{ ['待确认','已确认','已拒绝'][row.studentStatus] }}</el-tag></template></el-table-column>
      <el-table-column label="操作" width="180"><template #default="{row}"><el-button v-if="row.studentStatus===0" text type="success" @click="confirm(row,1)">参加</el-button><el-button v-if="row.studentStatus===0" text type="danger" @click="confirm(row,2)">拒绝</el-button></template></el-table-column>
    </el-table>
    <div class="pagination-wrap"><el-pagination v-model:current-page="query.pageNum" :total="total" background layout="total,prev,pager,next" @current-change="load"/></div>
  </div></div>
</template>
<script setup>
import { reactive,ref,onMounted } from 'vue';import { ElMessageBox,ElMessage } from 'element-plus';import { studentApi } from '@/api'
const query=reactive({pageNum:1,pageSize:10});const list=ref([]);const total=ref(0);const loading=ref(false)
const load=async()=>{loading.value=true;try{const r=await studentApi.interviews(query);list.value=r.data.records;total.value=Number(r.data.total)}finally{loading.value=false}}
const confirm=(row,status)=>ElMessageBox.confirm(status===1?'确认参加该面试？':'确认拒绝该面试？').then(async()=>{await studentApi.confirmInterview(row.id,status);ElMessage.success('操作成功');load()})
onMounted(load)
</script>
<style scoped>.header h2{margin-bottom:6px}.header p{color:#909399}</style>
