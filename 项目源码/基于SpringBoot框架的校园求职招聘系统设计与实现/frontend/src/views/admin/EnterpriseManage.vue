<template>
  <AdminTablePage
    title="企业用户管理"
    desc="企业资料、账号状态与企业认证审核"
    :list="list"
    :total="total"
    :loading="loading"
    :query="query"
    :show-add="false"
    :action-width="320"
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
      <el-button text type="success" @click="openHr(row)">HR管理</el-button>
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

            <el-descriptions v-if="hasVerify(currentAudit)" title="权威数据核验痕迹" :column="2" border class="verify-block">
              <el-descriptions-item label="核验来源">
                <el-link v-if="currentAudit.verifySourceUrl" :href="currentAudit.verifySourceUrl" target="_blank" type="primary">
                  {{ currentAudit.verifySource || '权威数据来源' }}
                </el-link>
                <span v-else>{{ currentAudit.verifySource || '-' }}</span>
              </el-descriptions-item>
              <el-descriptions-item label="核验时间">{{ currentAudit.verifyTime || '-' }}</el-descriptions-item>
              <el-descriptions-item label="核验结论">
                <el-tag :type="verifyType(currentAudit.verifyResult)">{{ verifyText(currentAudit.verifyResult) }}</el-tag>
              </el-descriptions-item>
              <el-descriptions-item label="登记状态">{{ currentAudit.verifyStatus || '-' }}</el-descriptions-item>
              <el-descriptions-item label="权威企业名称">{{ currentAudit.verifyCompanyName || '-' }}</el-descriptions-item>
              <el-descriptions-item label="权威信用代码">{{ currentAudit.verifyCreditCode || '-' }}</el-descriptions-item>
              <el-descriptions-item label="核验说明" :span="2">{{ currentAudit.verifyRemark || '-' }}</el-descriptions-item>
              <el-descriptions-item label="快照哈希" :span="2">{{ currentAudit.verifySnapshotHash || '-' }}</el-descriptions-item>
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

            <el-form v-if="currentAudit" label-width="80px" class="audit-form">
              <el-form-item label="复核意见">
                <el-input v-model="remark" type="textarea" :rows="3" placeholder="通过可不填；驳回时请填写原因" />
              </el-form-item>
            </el-form>
          </template>
        </div>

        <template #footer>
          <el-button @click="auditDialog = false">关闭</el-button>
          <template v-if="currentAudit">
            <el-button v-if="currentAudit.auditStatus !== 2" type="success" @click="submitAudit(2)">通过认证</el-button>
            <el-button v-if="currentAudit.auditStatus !== 3" type="danger" @click="submitAudit(3)">驳回认证</el-button>
          </template>
        </template>
      </el-dialog>

      <el-dialog v-model="hrDialog" :title="hrEnterprise ? `${hrEnterprise.companyName} - HR管理` : 'HR管理'" width="920px">
        <div class="hr-toolbar">
          <el-input v-model="hrQuery.keyword" clearable placeholder="账号 / 姓名 / 电话 / 邮箱" @keyup.enter="reloadHr" />
          <el-button type="primary" @click="reloadHr">查询</el-button>
          <el-button type="primary" @click="openHrForm()">新增 HR</el-button>
        </div>
        <el-table :data="hrList" stripe v-loading="hrLoading">
          <el-table-column prop="username" label="账号" min-width="120" />
          <el-table-column prop="realName" label="姓名" min-width="110" />
          <el-table-column prop="phone" label="电话" min-width="130" />
          <el-table-column prop="email" label="邮箱" min-width="170" />
          <el-table-column label="权限" width="110">
            <template #default="{ row }">
              <el-tag :type="row.hrRole === 'SUPERVISOR' ? 'success' : 'info'">{{ roleText(row.hrRole) }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="状态" width="90">
            <template #default="{ row }">
              <el-tag :type="row.status === 1 ? 'success' : 'danger'">{{ row.status === 1 ? '正常' : '禁用' }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="300" fixed="right">
            <template #default="{ row }">
              <el-button text type="primary" @click="openHrForm(row)">编辑</el-button>
              <el-button text type="success" @click="changeHrRole(row)">
                {{ row.hrRole === 'SUPERVISOR' ? '设为普通' : '设为主管' }}
              </el-button>
              <el-button text @click="toggleHr(row)">{{ row.status === 1 ? '禁用' : '启用' }}</el-button>
              <el-button text @click="resetHr(row)">重置密码</el-button>
            </template>
          </el-table-column>
        </el-table>
        <div class="dialog-pagination">
          <el-pagination
            v-model:current-page="hrQuery.pageNum"
            :total="hrTotal"
            background
            layout="total,prev,pager,next"
            @current-change="loadHr"
          />
        </div>
      </el-dialog>

      <el-dialog v-model="hrFormDialog" :title="hrForm.id ? '编辑 HR' : '新增 HR'" width="560px" append-to-body>
        <el-form :model="hrForm" label-width="90px">
          <el-form-item label="账号">
            <el-input v-model="hrForm.username" :disabled="!!hrForm.id" />
          </el-form-item>
          <el-form-item label="姓名">
            <el-input v-model="hrForm.realName" />
          </el-form-item>
          <el-form-item label="电话">
            <el-input v-model="hrForm.phone" />
          </el-form-item>
          <el-form-item label="邮箱">
            <el-input v-model="hrForm.email" />
          </el-form-item>
          <el-form-item label="权限">
            <el-radio-group v-model="hrForm.hrRole">
              <el-radio value="SUPERVISOR">主管 HR</el-radio>
              <el-radio value="STAFF">普通 HR</el-radio>
            </el-radio-group>
          </el-form-item>
        </el-form>
        <template #footer>
          <el-button @click="hrFormDialog = false">取消</el-button>
          <el-button type="primary" @click="saveHr">保存</el-button>
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
const hrDialog = ref(false)
const hrFormDialog = ref(false)
const hrLoading = ref(false)
const hrEnterprise = ref(null)
const hrList = ref([])
const hrTotal = ref(0)
const hrQuery = reactive({ pageNum: 1, pageSize: 10, keyword: '' })
const hrForm = reactive({})

const auditText = (status) => ({ 0: '未认证', 1: '待审核', 2: '已通过', 3: '已驳回' }[status] || '未知')
const auditType = (status) => (status === 2 ? 'success' : status === 1 ? 'warning' : status === 3 ? 'danger' : 'info')
const verifyText = (status) => ({ 0: '未核验', 1: '一致', 2: '不一致', 3: '未接入或异常' }[status] || '未知')
const verifyType = (status) => (status === 1 ? 'success' : status === 2 ? 'danger' : status === 3 ? 'warning' : 'info')
const roleText = (role) => (role === 'SUPERVISOR' ? '主管 HR' : '普通 HR')
const hasVerify = (row) => !!row && row.verifyResult !== undefined && row.verifyResult !== null
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

const loadHr = async () => {
  if (!hrEnterprise.value?.id) return
  hrLoading.value = true
  try {
    const res = await adminApi.enterpriseHrs(hrEnterprise.value.id, hrQuery)
    hrList.value = res.data.records
    hrTotal.value = Number(res.data.total)
  } finally {
    hrLoading.value = false
  }
}

const reloadHr = () => {
  hrQuery.pageNum = 1
  loadHr()
}

const openHr = (row) => {
  hrEnterprise.value = row
  hrQuery.pageNum = 1
  hrQuery.keyword = ''
  hrDialog.value = true
  loadHr()
}

const openHrForm = (row) => {
  Object.keys(hrForm).forEach((key) => delete hrForm[key])
  Object.assign(hrForm, row || { username: '', realName: '', phone: '', email: '', hrRole: 'STAFF' })
  hrFormDialog.value = true
}

const saveHr = async () => {
  if (!hrForm.username || !hrForm.realName) {
    ElMessage.warning('请填写账号和姓名')
    return
  }
  if (hrForm.id) {
    await adminApi.updateEnterpriseHr(hrForm.id, hrForm)
  } else {
    await adminApi.addEnterpriseHr(hrEnterprise.value.id, hrForm)
  }
  ElMessage.success(hrForm.id ? '修改成功' : '新增成功，初始密码123456')
  hrFormDialog.value = false
  loadHr()
}

const changeHrRole = (row) => {
  const role = row.hrRole === 'SUPERVISOR' ? 'STAFF' : 'SUPERVISOR'
  ElMessageBox.confirm(`确定将「${row.username}」调整为${roleText(role)}？`).then(async () => {
    await adminApi.updateEnterpriseHrRole(row.id, role)
    ElMessage.success('角色已更新')
    loadHr()
  })
}

const toggleHr = (row) =>
  ElMessageBox.confirm(`确定${row.status === 1 ? '禁用' : '启用'}该 HR？`).then(async () => {
    await adminApi.toggleEnterpriseHr(row.id, row.status === 1 ? 0 : 1)
    ElMessage.success('操作成功')
    loadHr()
  })

const resetHr = (row) =>
  ElMessageBox.confirm(`确定将「${row.username}」密码重置为 123456？`).then(async () => {
    await adminApi.resetEnterpriseHr(row.id)
    ElMessage.success('密码已重置为123456')
  })

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

.verify-block {
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

.hr-toolbar {
  display: flex;
  gap: 10px;
  margin-bottom: 16px;
}

.hr-toolbar .el-input {
  width: 260px;
}

.dialog-pagination {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
}
</style>
