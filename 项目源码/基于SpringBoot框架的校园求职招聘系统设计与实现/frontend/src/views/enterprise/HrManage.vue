<template>
  <div class="page-container enterprise-list-page">
    <div class="page-card page-flex-card compact-list-card enterprise-list-card">
      <div class="header">
        <div>
          <h2>HR 管理</h2>
          <p>维护本企业招聘账号，主管 HR 可调整账号状态和权限。</p>
        </div>
        <el-button type="primary" @click="open()">新增 HR</el-button>
      </div>
      <el-divider />
      <div class="toolbar">
        <el-input v-model="query.keyword" clearable placeholder="账号 / 姓名 / 电话 / 邮箱" style="width: 260px" @keyup.enter="reload" />
        <el-button type="primary" @click="reload">查询</el-button>
      </div>
      <el-table :data="list" stripe v-loading="loading">
        <el-table-column prop="username" label="账号" min-width="130" />
        <el-table-column prop="realName" label="姓名" min-width="120" />
        <el-table-column prop="phone" label="电话" min-width="130" />
        <el-table-column prop="email" label="邮箱" min-width="180" />
        <el-table-column label="权限" width="120">
          <template #default="{ row }">
            <el-tag :type="row.hrRole === 'SUPERVISOR' ? 'success' : 'info'">
              {{ roleText(row.hrRole) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'">{{ row.status === 1 ? '正常' : '禁用' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="260">
          <template #default="{ row }">
            <el-button text type="primary" @click="open(row)">编辑</el-button>
            <el-button text @click="toggle(row)">{{ row.status === 1 ? '禁用' : '启用' }}</el-button>
            <el-button text @click="reset(row)">重置密码</el-button>
          </template>
        </el-table-column>
      </el-table>
      <div class="pagination-wrap">
        <el-pagination v-model:current-page="query.pageNum" :total="total" background layout="total,prev,pager,next" @current-change="load" />
      </div>
    </div>

    <el-dialog v-model="dialog" :title="form.id ? '编辑 HR' : '新增 HR'" width="560px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="账号">
          <el-input v-model="form.username" :disabled="!!form.id" />
        </el-form-item>
        <el-form-item label="姓名">
          <el-input v-model="form.realName" />
        </el-form-item>
        <el-form-item label="电话">
          <el-input v-model="form.phone" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="form.email" />
        </el-form-item>
        <el-form-item label="权限">
          <el-radio-group v-model="form.hrRole">
            <el-radio value="SUPERVISOR">主管 HR</el-radio>
            <el-radio value="STAFF">普通 HR</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog = false">取消</el-button>
        <el-button type="primary" @click="save">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { enterpriseApi } from '@/api'

const query = reactive({ pageNum: 1, pageSize: 10, keyword: '' })
const list = ref([])
const total = ref(0)
const loading = ref(false)
const dialog = ref(false)
const form = reactive({})

const roleText = (role) => (role === 'SUPERVISOR' ? '主管 HR' : '普通 HR')

const load = async () => {
  loading.value = true
  try {
    const res = await enterpriseApi.hrs(query)
    list.value = res.data.records
    total.value = Number(res.data.total)
  } finally {
    loading.value = false
  }
}

const reload = () => {
  query.pageNum = 1
  load()
}

const open = (row) => {
  Object.keys(form).forEach((key) => delete form[key])
  Object.assign(form, row || { username: '', realName: '', phone: '', email: '', hrRole: 'STAFF' })
  dialog.value = true
}

const save = async () => {
  if (!form.username || !form.realName) {
    return ElMessage.warning('请填写账号和姓名')
  }
  if (form.id) await enterpriseApi.updateHr(form.id, form)
  else await enterpriseApi.addHr(form)
  ElMessage.success(form.id ? '修改成功' : '新增成功，初始密码123456')
  dialog.value = false
  load()
}

const toggle = (row) =>
  ElMessageBox.confirm(`确定${row.status === 1 ? '禁用' : '启用'}该 HR？`).then(async () => {
    await enterpriseApi.toggleHr(row.id, row.status === 1 ? 0 : 1)
    ElMessage.success('操作成功')
    load()
  })

const reset = (row) =>
  ElMessageBox.confirm(`确定将「${row.username}」密码重置为 123456？`).then(async () => {
    await enterpriseApi.resetHr(row.id)
    ElMessage.success('密码已重置为123456')
  })

onMounted(load)
</script>

<style scoped>
.header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
}

.header h2 {
  margin-bottom: 6px;
}

.header p {
  color: var(--cr-text-muted);
}

.toolbar {
  display: flex;
  gap: 10px;
  margin-bottom: 16px;
}
</style>
