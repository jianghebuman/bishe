<template>
  <div class="page-container">
    <div class="page-card">
      <div class="header">
        <div>
          <h2>附件简历</h2>
          <p>支持上传 PDF / Word 简历，投递时可作为附件补充。</p>
        </div>
        <el-upload :show-file-list="false" accept=".pdf,.doc,.docx" :http-request="upload">
          <el-button type="primary"><el-icon><Upload /></el-icon> 上传附件简历</el-button>
        </el-upload>
      </div>
      <el-divider />
      <el-table :data="list" stripe v-loading="loading">
        <el-table-column label="文件名" min-width="240">
          <template #default="{ row }"><el-icon><Document /></el-icon> {{ row.fileName }}</template>
        </el-table-column>
        <el-table-column label="类型" width="130"><template #default="{ row }"><el-tag>{{ ext(row.fileName) }}</el-tag></template></el-table-column>
        <el-table-column label="大小" width="130"><template #default="{ row }">{{ size(row.fileSize) }}</template></el-table-column>
        <el-table-column prop="createTime" label="上传时间" width="180" />
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" @click="preview(row)">预览/下载</el-button>
            <el-button text type="danger" @click="remove(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!loading && list.length === 0" description="还没有上传附件简历" />
    </div>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Upload, Document } from '@element-plus/icons-vue'
import { studentApi } from '@/api'
const list = ref([]), loading = ref(false)
const load = async () => { loading.value = true; try { list.value = (await studentApi.attachments()).data || [] } finally { loading.value = false } }
const upload = async ({ file }) => { const fd = new FormData(); fd.append('file', file); await studentApi.uploadAttachment(fd); ElMessage.success('上传成功'); load() }
const remove = row => ElMessageBox.confirm(`确定删除「${row.fileName}」？`).then(async()=>{ await studentApi.delAttachment(row.id); ElMessage.success('已删除'); load() })
const preview = row => window.open(row.fileUrl, '_blank')
const ext = n => (n || '').split('.').pop()?.toUpperCase() || '-'
const size = b => b ? (b / 1024 / 1024).toFixed(2) + ' MB' : '-'
onMounted(load)
</script>
<style scoped lang="scss">.header{display:flex;justify-content:space-between;align-items:center;h2{margin-bottom:6px;}p{color:#909399;}}</style>
