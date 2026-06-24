<template>
  <div class="page-container"><div class="page-card">
    <div class="header"><div><h2>我的帖子</h2><p>管理自己发布的求职交流内容。</p></div><el-button type="primary" @click="$router.push('/forum')">去社区发帖</el-button></div><el-divider/>
    <el-table :data="list" stripe v-loading="loading">
      <el-table-column prop="title" label="标题" min-width="220"/>
      <el-table-column prop="category" label="版块" width="110"><template #default="{row}"><el-tag>{{ row.category }}</el-tag></template></el-table-column>
      <el-table-column label="数据" width="180"><template #default="{row}">浏览 {{ row.viewCount||0 }} / 点赞 {{ row.likeCount||0 }} / 评论 {{ row.commentCount||0 }}</template></el-table-column>
      <el-table-column label="审核" width="100"><template #default="{row}"><el-tag :type="row.auditStatus===1?'success':row.auditStatus===2?'danger':'warning'">{{ ['待审核','通过','驳回'][row.auditStatus] }}</el-tag></template></el-table-column>
      <el-table-column prop="createTime" label="发布时间" width="180"/>
      <el-table-column label="操作" width="180"><template #default="{row}"><el-button text type="primary" @click="$router.push(`/forum/${row.id}`)">查看</el-button><el-button text type="danger" @click="del(row)">删除</el-button></template></el-table-column>
    </el-table>
    <div class="pagination-wrap"><el-pagination v-model:current-page="query.pageNum" :total="total" background layout="total,prev,pager,next" @current-change="load"/></div>
  </div></div>
</template>
<script setup>
import { reactive,ref,onMounted } from 'vue';import { ElMessageBox,ElMessage } from 'element-plus';import { forumApi } from '@/api'
const query=reactive({pageNum:1,pageSize:10});const list=ref([]);const total=ref(0);const loading=ref(false)
const load=async()=>{loading.value=true;try{const r=await forumApi.myPosts(query);list.value=r.data.records;total.value=Number(r.data.total)}finally{loading.value=false}}
const del=row=>ElMessageBox.confirm(`确定删除帖子「${row.title}」？`).then(async()=>{await forumApi.delPost(row.id);ElMessage.success('已删除');load()})
onMounted(load)
</script>
<style scoped>.header{display:flex;justify-content:space-between;align-items:center}.header h2{margin-bottom:6px}.header p{color:#909399}</style>
