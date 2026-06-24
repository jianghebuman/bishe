<template>
  <AdminTablePage
    title="企业用户管理"
    desc="企业资料、账号状态与企业认证审核"
    :list="list"
    :total="total"
    :loading="loading"
    :query="query"
    :show-add="false"
    :action-width="240"
    @load="load"
  >
    <template #toolbar>
      <el-input v-model="query.keyword" placeholder="企业名称" clearable style="width: 220px" @keyup.enter="reload" />
      <el-select v-model="query.auditStatus" clearable placeholder="认证状态" style="width: 140px">
        <el-option label="未认证" :value="0" />
        <el-option label="待审核" :value="1" />
        <el-option label="已通过" :value="2" />
        <el-option label="已驳回" :value="3" />
      </el-select>
      <el-button type="primary" @click="reload">查询</el-button>
    </template>

    <template #columns>
      <el-table-column prop="companyName" label="企业名称" min-width="180" />
      <el-table-column prop="industry" label="行业" width="120" />
      <el-table-column prop="scale" label="规模" width="120" />
      <el-table-column prop="city" label="城市" width="100" />
      <el-table-column label="认证" width="110">
        <template #default="{ row }">
          <el-tag :type="auditType(row.auditStatus)">{{ auditText(row.auditStatus) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="状态" width="90">
        <template #default="{ row }">
          <el-tag :type="row.status === 1 ? 'success' : 'danger'">{{ row.status === 1 ? '正常' : '禁用' }}</el-tag>
        </template>
      </el-table-column>
    </template>

    <template #rowActions="{ row }">
      <el-button text type="primary" @click="openAudit(row)">
        {{ row.auditStatus === 1 ? '审核' : '查看认证' }}
      </el-button>
      <el-button text @click="toggle(row)">{{ row.status === 1 ? '禁用' : '启用' }}</el-button>
    </template>

    <template #dialogs>
      <el-dialog v-model="auditDialog" title="企业认证审核" width="760px">
        <div v-loading="auditLoading">
          <el-descriptions v-if="currentEnterprise" :column="2" border class="mb-16">
            <el-descriptions-item label="企业名称">{{ currentEnterprise.companyName }}</el-descriptions-item>
            <el-descriptions-item label="认证状态">
              <el-tag :type="auditType(currentEnterprise.auditStatus)">
                {{ auditText(currentEnterprise.auditStatus) }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="统一社会信用代码">
              {{ currentEnterprise.creditCode || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="联系人">
              {{ currentEnterprise.contactName || '-' }} / {{ currentEnterprise.contactPhone || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="邮箱">{{ currentEnterprise.email || '-' }}</el-descriptions-item>
            <el-descriptions-item label="城市">{{ currentEnterprise.city || '-' }}</el-descriptions-item>
          </el-descriptions>

          <el-empty v-if="!currentAudit && !auditLoading" description="该企业暂未提交认证材料" />

          <template v-if="currentAudit">
            <el-descriptions :column="2" border>
              <el-descriptions-item label="执照编号">{{ currentAudit.licenseNo || '-' }}</el-descriptions-item>
              <el-descriptions-item label="提交时间">{{ currentAudit.createTime || '-' }}</el-descriptions-item>
              <el-descriptions-item label="审核状态">
                <el-tag :type="auditType(currentAudit.auditStatus)">
                  {{ auditText(currentAudit.auditStatus) }}
                </el-tag>
              </el-descriptions-item>
              <el-descriptions-item label="审核时间">{{ currentAudit.auditTime || '-' }}</el-descriptions-item>
              <el-descriptions-item label="审核意见" :span="2">
                {{ currentAudit.auditRemark || '-' }}
              </el-descriptions-item>
            </el-descriptions>

            <div class="material-block">
              <div class="material-item">
                <div class="material-title">营业执照</div>
                <el-image
                  v-if="isImage(currentAudit.licenseImg)"
                  class="material-image"
                  :src="currentAudit.licenseImg"
                  :preview-src-list="[currentAudit.licenseImg]"
                  fit="cover"
                >
                  <template #error>
                    <div class="material-error">
                      <span>材料暂不可预览</span>
                      <el-link :href="currentAudit.licenseImg" target="_blank" type="primary">打开材料</el-link>
                    </div>
                  </template>
                </el-image>
                <el-link v-else-if="currentAudit.licenseImg" :href="currentAudit.licenseImg" target="_blank" type="primary">
                  打开材料
                </el-link>
                <span v-else>-</span>
              </div>
              <div class="material-item">
                <div class="material-title">补充材料</div>
                <el-image
                  v-if="isImage(currentAudit.extraImg)"
                  class="material-image"
                  :src="currentAudit.extraImg"
                  :preview-src-list="[currentAudit.extraImg]"
                  fit="cover"
                >
                  <template #error>
                    <div class="material-error">
                      <span>材料暂不可预览</span>
                      <el-link :href="currentAudit.extraImg" target="_blank" type="primary">打开材料</el-link>
                    </div>
                  </template>
                </el-image>
                <el-link v-else-if="currentAudit.extraImg" :href="currentAudit.extraImg" target="_blank" type="primary">
                  打开材料
                </el-link>
                <span v-else>-</span>
              </div>
            </div>

            <el-form v-if="currentAudit.auditStatus === 1" label-width="80px" class="audit-form">
              <el-form-item label="审核意见">
                <el-input v-model="remark" type="textarea" :rows="3" placeholder="通过可不填；驳回时请填写原因" />
              </el-form-item>
            </el-form>
          </template>
        </div>

        <template #footer>
          <el-button @click="auditDialog = false">关闭</el-button>
          <template v-if="currentAudit && currentAudit.auditStatus === 1">
            <el-button type="success" @click="submitAudit(2)">通过认证</el-button>
            <el-button type="danger" @click="submitAudit(3)">驳回认证</el-button>
          </template>
        </template>
      </el-dialog>
    </template>
  </AdminTablePage>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import AdminTablePage from '@/components/AdminTablePage.vue'
import { adminApi } from '@/api'

const query = reactive({ pageNum: 1, pageSize: 10, keyword: '', auditStatus: '' })
const list = ref([])
const total = ref(0)
const loading = ref(false)
const auditDialog = ref(false)
const auditLoading = ref(false)
const currentEnterprise = ref(null)
const currentAudit = ref(null)
const remark = ref('')

const auditText = (status) => ({ 0: '未认证', 1: '待审核', 2: '已通过', 3: '已驳回' }[status] || '未知')
const auditType = (status) => (status === 2 ? 'success' : status === 1 ? 'warning' : status === 3 ? 'danger' : 'info')
const isImage = (url) => /\.(png|jpe?g|gif|bmp|webp)$/i.test(url || '')

const load = async () => {
  loading.value = true
  try {
    const params = { ...query }
    if (params.auditStatus === '') delete params.auditStatus
    const res = await adminApi.enterprises(params)
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

const toggle = (row) =>
  ElMessageBox.confirm(`确定${row.status === 1 ? '禁用' : '启用'}该企业？`).then(async () => {
    await adminApi.toggleEnterprise(row.id, row.status === 1 ? 0 : 1)
    load()
  })

const openAudit = async (row) => {
  currentEnterprise.value = row
  currentAudit.value = null
  remark.value = ''
  auditDialog.value = true
  auditLoading.value = true
  try {
    const res = await adminApi.auditList({ pageNum: 1, pageSize: 1, enterpriseId: row.id })
    currentAudit.value = (res.data.records || [])[0] || null
  } finally {
    auditLoading.value = false
  }
}

const submitAudit = async (status) => {
  if (!currentAudit.value) return
  const auditRemark = remark.value.trim()
  if (status === 3 && !auditRemark) {
    ElMessage.warning('请填写驳回原因')
    return
  }
  await adminApi.auditEnterprise(currentAudit.value.id, status, status === 2 ? auditRemark || '企业资质真实，审核通过' : auditRemark)
  ElMessage.success(status === 2 ? '认证已通过' : '认证已驳回')
  auditDialog.value = false
  load()
}

onMounted(load)
</script>

<style scoped>
.mb-16 {
  margin-bottom: 16px;
}

.material-block {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
  margin-top: 16px;
}

.material-item {
  min-height: 180px;
  padding: 12px;
  border: 1px solid #ebeef5;
  border-radius: 6px;
  background: #fafafa;
}

.material-title {
  margin-bottom: 10px;
  font-weight: 600;
  color: #303133;
}

.material-image {
  width: 100%;
  height: 160px;
  border-radius: 4px;
  background: #fff;
}

.material-error {
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  color: #909399;
}

.audit-form {
  margin-top: 16px;
}
</style>
