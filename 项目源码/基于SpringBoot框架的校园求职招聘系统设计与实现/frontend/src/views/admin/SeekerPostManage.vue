<template>
  <AdminTablePage title="求职信息管理" desc="查看并删除学生发布的求职栏内容" :list="list" :total="total" :loading="loading" :query="query" :show-add="false" @load="load" :action-width="120">
    <template #toolbar>
      <el-input v-model="query.title" clearable placeholder="求职标题" />
      <el-input v-model="query.studentId" clearable placeholder="学生ID" />
      <el-select v-model="query.status" clearable placeholder="状态">
        <el-option label="展示" :value="1" />
        <el-option label="下架" :value="0" />
      </el-select>
      <el-button type="primary" @click="reload">查询</el-button>
    </template>
    <template #columns>
      <el-table-column label="标题" min-width="220"><template #default="{row}">{{ row.post.title }}</template></el-table-column>
      <el-table-column label="学生" width="120"><template #default="{row}">{{ row.student?.realName || row.post.studentId }}</template></el-table-column>
      <el-table-column label="期望岗位" min-width="140"><template #default="{row}">{{ row.post.expectPost || '-' }}</template></el-table-column>
      <el-table-column label="城市" width="120"><template #default="{row}">{{ row.post.expectCity || '-' }}</template></el-table-column>
      <el-table-column label="状态" width="90"><template #default="{row}"><el-tag :type="row.post.status===1?'success':'info'">{{ row.post.status===1?'展示':'下架' }}</el-tag></template></el-table-column>
      <el-table-column label="浏览" width="80"><template #default="{row}">{{ row.post.viewCount || 0 }}</template></el-table-column>
      <el-table-column label="更新时间" width="180"><template #default="{row}">{{ row.post.updateTime }}</template></el-table-column>
    </template>
    <template #rowActions="{row}">
      <el-button text type="danger" @click="del(row)">删除</el-button>
    </template>
  </AdminTablePage>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import AdminTablePage from '@/components/AdminTablePage.vue'
import { adminApi } from '@/api'

const query = reactive({ pageNum: 1, pageSize: 10, title: '', studentId: '', status: '' })
const list = ref([])
const total = ref(0)
const loading = ref(false)
const load = async () => {
  loading.value = true
  try {
    const p = { ...query }
    if (p.studentId === '') delete p.studentId
    if (p.status === '') delete p.status
    const res = await adminApi.seekerPosts(p)
    list.value = res.data.records || []
    total.value = Number(res.data.total || 0)
  } finally { loading.value = false }
}
const reload = () => { query.pageNum = 1; load() }
const del = (row) => ElMessageBox.confirm('确定删除该求职信息？').then(async () => {
  await adminApi.deleteSeekerPost(row.post.id)
  ElMessage.success('已删除')
  load()
})
onMounted(load)
</script>
