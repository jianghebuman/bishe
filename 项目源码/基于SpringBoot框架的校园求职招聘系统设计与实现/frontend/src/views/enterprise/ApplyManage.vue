<template>
  <div class="page-container enterprise-list-page">
    <div class="page-card page-flex-card compact-list-card enterprise-list-card">
      <div class="header">
        <h2>简历筛选</h2>
        <p>查看收到的简历、标记流程状态、发起面试或加入人才库。</p>
      </div>
      <el-divider />
      <el-radio-group v-model="query.status" @change="reload" class="mb-20">
        <el-radio-button :value="''">全部</el-radio-button>
        <el-radio-button v-for="(t, i) in statusTexts" :key="i" :value="i">{{ t }}</el-radio-button>
      </el-radio-group>
      <el-table :data="list" stripe v-loading="loading">
        <el-table-column prop="id" label="投递ID" width="90" />
        <el-table-column prop="studentName" label="投递人" width="110" />
        <el-table-column prop="resumeId" label="简历ID" width="90" />
        <el-table-column prop="jobId" label="岗位ID" width="90" />
        <el-table-column prop="applyRemark" label="学生附言" min-width="180" show-overflow-tooltip />
        <el-table-column label="状态" width="120">
          <template #default="{ row }"><el-tag :type="type(row.status)">{{ statusTexts[row.status] }}</el-tag></template>
        </el-table-column>
        <el-table-column prop="createTime" label="投递时间" width="180" />
        <el-table-column label="操作" width="360">
          <template #default="{ row }">
            <el-button text type="primary" @click="view(row)">查看简历</el-button>
            <el-dropdown @command="s => setStatus(row, s)">
              <el-button text>标记状态<el-icon><ArrowDown /></el-icon></el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item v-for="(t, i) in statusTexts" :key="i" :command="i">{{ t }}</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
            <el-button text type="success" @click="openInterview(row)">邀面试</el-button>
          </template>
        </el-table-column>
      </el-table>
      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="query.pageNum"
          :total="total"
          background
          layout="total,prev,pager,next"
          @current-change="load"
        />
      </div>
    </div>

    <el-dialog v-model="detailDialog" title="简历详情" width="900px" class="resume-dialog">
      <template v-if="detail">
        <el-descriptions title="投递信息" :column="2" border>
          <el-descriptions-item label="投递ID">{{ apply.id }}</el-descriptions-item>
          <el-descriptions-item label="投递人">{{ detail.applicantName || apply.studentName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="岗位ID">{{ apply.jobId }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="type(apply.status)">{{ statusTexts[apply.status] }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="投递时间">{{ apply.createTime }}</el-descriptions-item>
          <el-descriptions-item label="学生附言" :span="2">{{ apply.applyRemark || '-' }}</el-descriptions-item>
          <el-descriptions-item label="HR备注" :span="2">{{ apply.hrRemark || '-' }}</el-descriptions-item>
        </el-descriptions>

        <el-descriptions class="detail-section" title="在线简历" :column="2" border>
          <el-descriptions-item label="姓名">{{ resume.name || detail.applicantName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="性别">{{ genderText(resume.gender) }}</el-descriptions-item>
          <el-descriptions-item label="简历ID">{{ resume.id || '-' }}</el-descriptions-item>
          <el-descriptions-item label="完整度">{{ resume.completeRate != null ? `${resume.completeRate}%` : '-' }}</el-descriptions-item>
          <el-descriptions-item label="学院">{{ resume.college || '-' }}</el-descriptions-item>
          <el-descriptions-item label="专业">{{ resume.major || '-' }}</el-descriptions-item>
          <el-descriptions-item label="学历">{{ resume.education || '-' }}</el-descriptions-item>
          <el-descriptions-item label="出生年月">{{ resume.birth || '-' }}</el-descriptions-item>
          <el-descriptions-item label="手机号">{{ resume.phone || '-' }}</el-descriptions-item>
          <el-descriptions-item label="邮箱">{{ resume.email || '-' }}</el-descriptions-item>
          <el-descriptions-item label="技能证书" :span="2">{{ resume.skillCert || '-' }}</el-descriptions-item>
          <el-descriptions-item label="荣誉奖项" :span="2">{{ resume.award || '-' }}</el-descriptions-item>
          <el-descriptions-item label="自我评价" :span="2">{{ resume.selfEval || '-' }}</el-descriptions-item>
        </el-descriptions>

        <div class="detail-section">
          <h3>教育经历</h3>
          <el-table :data="detail.educations || []" border>
            <el-table-column prop="school" label="学校" min-width="140" />
            <el-table-column prop="major" label="专业" min-width="140" />
            <el-table-column prop="degree" label="学历" width="100" />
            <el-table-column label="时间" width="170">
              <template #default="{ row }">{{ row.startDate || '-' }} 至 {{ row.endDate || '-' }}</template>
            </el-table-column>
            <el-table-column prop="description" label="说明" min-width="180" show-overflow-tooltip />
          </el-table>
        </div>

        <div class="detail-section">
          <h3>项目经历</h3>
          <el-table :data="detail.projects || []" border>
            <el-table-column prop="projectName" label="项目" min-width="160" />
            <el-table-column prop="role" label="角色" width="130" />
            <el-table-column label="时间" width="170">
              <template #default="{ row }">{{ row.startDate || '-' }} 至 {{ row.endDate || '-' }}</template>
            </el-table-column>
            <el-table-column prop="description" label="说明" min-width="220" show-overflow-tooltip />
          </el-table>
        </div>

        <div class="detail-section">
          <h3>实习经历</h3>
          <el-table :data="detail.experiences || []" border>
            <el-table-column prop="company" label="单位" min-width="160" />
            <el-table-column prop="position" label="岗位" width="140" />
            <el-table-column label="时间" width="170">
              <template #default="{ row }">{{ row.startDate || '-' }} 至 {{ row.endDate || '-' }}</template>
            </el-table-column>
            <el-table-column prop="description" label="说明" min-width="220" show-overflow-tooltip />
          </el-table>
        </div>

        <div class="detail-section">
          <h3>附件简历</h3>
          <el-table :data="detail.attachments || []" border>
            <el-table-column prop="fileName" label="文件名" min-width="220" />
            <el-table-column prop="fileType" label="类型" width="100" />
            <el-table-column label="大小" width="110">
              <template #default="{ row }">{{ formatSize(row.fileSize) }}</template>
            </el-table-column>
            <el-table-column label="操作" width="100">
              <template #default="{ row }">
                <el-button text type="primary" @click="preview(row)">预览</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </template>
    </el-dialog>

    <el-dialog v-model="interviewDialog" title="发送面试邀请" width="620px">
      <el-form :model="interview" label-width="100px">
        <el-form-item label="面试时间">
          <el-date-picker v-model="interview.interviewTime" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" style="width:100%" />
        </el-form-item>
        <el-form-item label="面试方式">
          <el-radio-group v-model="interview.interviewType">
            <el-radio :value="1">现场</el-radio>
            <el-radio :value="2">线上</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="地点/链接"><el-input v-model="interview.location" /></el-form-item>
        <el-form-item label="联系人"><el-input v-model="interview.contact" /></el-form-item>
        <el-form-item label="备注"><el-input v-model="interview.remark" type="textarea" :rows="3" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="interviewDialog = false">取消</el-button>
        <el-button type="primary" @click="sendInterview">发送</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, reactive, ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { ArrowDown } from '@element-plus/icons-vue'
import { enterpriseApi } from '@/api'

const statusTexts = ['待查看', '已查看', '邀请面试', '笔试', '已录用', '不合适']
const type = s => s === 4 ? 'success' : s === 5 ? 'danger' : s >= 2 ? 'warning' : 'info'
const query = reactive({ pageNum: 1, pageSize: 10, status: '' })
const list = ref([])
const total = ref(0)
const loading = ref(false)
const detailDialog = ref(false)
const interviewDialog = ref(false)
const detail = ref(null)
const interview = reactive({})

const apply = computed(() => detail.value?.apply || {})
const resume = computed(() => detail.value?.resume || {})

const load = async () => {
  loading.value = true
  try {
    const p = { pageNum: query.pageNum, pageSize: query.pageSize }
    if (query.status !== '') p.status = query.status
    const r = await enterpriseApi.applyList(p)
    list.value = r.data.records
    total.value = Number(r.data.total)
  } finally {
    loading.value = false
  }
}
const reload = () => { query.pageNum = 1; load() }
const view = async row => {
  detail.value = (await enterpriseApi.applyDetail(row.id)).data
  detailDialog.value = true
  load()
}
const setStatus = async (row, s) => {
  await enterpriseApi.updateApplyStatus(row.id, s, 'HR已更新流程状态')
  ElMessage.success('状态已更新')
  load()
}
const openInterview = row => {
  Object.keys(interview).forEach(k => delete interview[k])
  Object.assign(interview, { applyId: row.id, studentId: row.studentId, jobId: row.jobId, interviewType: 1 })
  interviewDialog.value = true
}
const sendInterview = async () => {
  await enterpriseApi.sendInterview(interview)
  ElMessage.success('面试邀请已发送')
  interviewDialog.value = false
  load()
}
const genderText = val => val === 1 ? '男' : val === 2 ? '女' : val === 0 ? '保密' : '-'
const formatSize = size => {
  if (!size) return '-'
  if (size < 1024 * 1024) return `${Math.round(size / 1024)}KB`
  return `${(size / 1024 / 1024).toFixed(1)}MB`
}
const preview = row => window.open(row.fileUrl, '_blank')

onMounted(load)
</script>

<style scoped>
.header h2 { margin-bottom: 6px; }
.header p { color: #909399; }
.detail-section { margin-top: 22px; }
.detail-section h3 {
  margin: 0 0 12px;
  font-size: 16px;
  color: #303133;
}
</style>
