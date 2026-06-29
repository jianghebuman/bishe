<template>
  <div class="page-container">
    <div class="page-card">
      <div class="header">
        <h2>人才库</h2>
        <p>沉淀优秀候选人，支持按专业、学历和关键词检索公开简历。</p>
      </div>
      <el-divider />
      <el-tabs v-model="tab">
        <el-tab-pane label="已收藏人才" name="pool" />
        <el-tab-pane label="发现候选人" name="search" />
      </el-tabs>

      <template v-if="tab === 'pool'">
        <el-form inline>
          <el-form-item label="标签"><el-input v-model="poolQuery.tag" clearable @keyup.enter="loadPool" /></el-form-item>
          <el-form-item label="关键词"><el-input v-model="poolQuery.keyword" clearable @keyup.enter="loadPool" /></el-form-item>
          <el-button type="primary" @click="loadPool">查询</el-button>
        </el-form>
        <el-table :data="pool" stripe v-loading="loading">
          <el-table-column prop="studentId" label="学生ID" width="100" />
          <el-table-column prop="resumeId" label="简历ID" width="100" />
          <el-table-column prop="tag" label="标签" width="140"><template #default="{ row }"><el-tag>{{ row.tag || '重点关注' }}</el-tag></template></el-table-column>
          <el-table-column prop="remark" label="备注" min-width="220" />
          <el-table-column prop="createTime" label="收藏时间" width="180" />
          <el-table-column label="操作" width="170">
            <template #default="{ row }">
              <el-button text type="primary" @click="chat(row.studentId, row.studentName || row.name)">联系</el-button>
              <el-button text type="danger" @click="remove(row)">移出</el-button>
            </template>
          </el-table-column>
        </el-table>
      </template>

      <template v-else>
        <el-form inline>
          <el-form-item label="专业"><el-input v-model="searchQuery.major" clearable /></el-form-item>
          <el-form-item label="学历"><el-input v-model="searchQuery.education" clearable /></el-form-item>
          <el-form-item label="关键词"><el-input v-model="searchQuery.keyword" clearable /></el-form-item>
          <el-button type="primary" @click="loadSearch">搜索</el-button>
        </el-form>
        <el-table :data="resumes" stripe v-loading="loading">
          <el-table-column prop="name" label="姓名" width="100" />
          <el-table-column prop="college" label="学院" min-width="140" />
          <el-table-column prop="major" label="专业" min-width="140" />
          <el-table-column prop="education" label="学历" width="90" />
          <el-table-column prop="completeRate" label="完整度" width="120"><template #default="{ row }"><el-progress :percentage="row.completeRate || 0" /></template></el-table-column>
          <el-table-column prop="skillCert" label="技能证书" min-width="220" show-overflow-tooltip />
          <el-table-column label="操作" width="190">
            <template #default="{ row }">
              <el-button text type="primary" @click="add(row)">加入人才库</el-button>
              <el-button text type="primary" @click="chat(row.studentId, row.name)">联系</el-button>
            </template>
          </el-table-column>
        </el-table>
      </template>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { enterpriseApi } from '@/api'

const router = useRouter()
const tab = ref('pool')
const loading = ref(false)
const pool = ref([])
const resumes = ref([])
const poolQuery = reactive({ pageNum: 1, pageSize: 10, tag: '', keyword: '' })
const searchQuery = reactive({ pageNum: 1, pageSize: 10, major: '', education: '', keyword: '' })

const loadPool = async () => {
  loading.value = true
  try { pool.value = (await enterpriseApi.talentList(poolQuery)).data.records || [] } finally { loading.value = false }
}
const loadSearch = async () => {
  loading.value = true
  try { resumes.value = (await enterpriseApi.searchTalent(searchQuery)).data.records || [] } finally { loading.value = false }
}
const add = async (row) => {
  await enterpriseApi.addTalent({ studentId: row.studentId, resumeId: row.id, tag: '重点关注', remark: `来自人才搜索：${row.major || ''}` })
  ElMessage.success('已加入人才库')
  tab.value = 'pool'
  loadPool()
}
const chat = (studentId, peerName) => {
  const query = { peerRole: 'STUDENT', peerId: studentId }
  if (peerName) query.peerName = peerName
  router.push({ path: '/chat', query })
}
const remove = (row) => ElMessageBox.confirm('确定移出人才库？').then(async () => {
  await enterpriseApi.delTalent(row.id)
  ElMessage.success('已移出')
  loadPool()
})
watch(tab, v => v === 'pool' ? loadPool() : loadSearch())
onMounted(loadPool)
</script>

<style scoped>
.header h2 { margin-bottom: 6px; }
.header p { color: #909399; }
</style>
