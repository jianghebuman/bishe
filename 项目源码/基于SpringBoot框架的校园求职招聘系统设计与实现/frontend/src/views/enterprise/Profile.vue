<template>
  <div class="page-container profile-page">
    <div class="page-card profile-card">
      <div class="header">
        <div>
          <h2>企业资料</h2>
          <p>展示在企业主页中，是学生了解企业的重要信息。</p>
        </div>
      </div>
      <el-divider />
      <div class="profile-body">
        <el-upload class="identity-uploader" :show-file-list="false" :http-request="uploadLogo" accept="image/*">
          <div class="identity-upload">
            <div class="identity-preview">
              <el-avatar :size="96" :src="form.logo" shape="square" class="logo-avatar">
                <el-icon><OfficeBuilding /></el-icon>
              </el-avatar>
              <span class="upload-mark"><el-icon><UploadFilled /></el-icon></span>
            </div>
            <div class="identity-copy">
              <span class="upload-label">{{ form.logo ? '更换 Logo' : '上传 Logo' }}</span>
              <span class="upload-sub">会显示在企业主页和岗位列表</span>
            </div>
          </div>
        </el-upload>
        <el-form :model="form" label-width="110px" class="profile-form">
          <el-row :gutter="20">
            <el-col :xs="24" :sm="12" :xl="8"><el-form-item label="企业名称"><el-input v-model="form.companyName" /></el-form-item></el-col>
            <el-col :xs="24" :sm="12" :xl="8"><el-form-item label="行业"><el-input v-model="form.industry" /></el-form-item></el-col>
            <el-col :xs="24" :sm="12" :xl="8"><el-form-item label="规模"><el-input v-model="form.scale" /></el-form-item></el-col>
            <el-col :xs="24" :sm="12" :xl="8"><el-form-item label="性质"><el-input v-model="form.nature" /></el-form-item></el-col>
            <el-col :xs="24" :sm="12" :xl="8"><el-form-item label="城市"><el-input v-model="form.city" /></el-form-item></el-col>
            <el-col :xs="24" :sm="12" :xl="8"><el-form-item label="联系人"><el-input v-model="form.contactName" /></el-form-item></el-col>
            <el-col :xs="24" :sm="12" :xl="8"><el-form-item label="联系电话"><el-input v-model="form.contactPhone" /></el-form-item></el-col>
            <el-col :xs="24" :sm="12" :xl="8"><el-form-item label="邮箱"><el-input v-model="form.email" /></el-form-item></el-col>
            <el-col :span="24"><el-form-item label="地址"><el-input v-model="form.address" /></el-form-item></el-col>
            <el-col :span="24"><el-form-item label="福利标签"><el-input v-model="form.welfare" placeholder="用逗号分隔，如 五险一金,年终奖" /></el-form-item></el-col>
            <el-col :span="24"><el-form-item label="企业简介"><el-input v-model="form.intro" type="textarea" :rows="5" maxlength="1000" show-word-limit /></el-form-item></el-col>
          </el-row>
          <el-form-item class="form-actions">
            <el-button type="primary" :loading="saving" @click="save">保存资料</el-button>
          </el-form-item>
        </el-form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { OfficeBuilding, UploadFilled } from '@element-plus/icons-vue'
import { enterpriseApi } from '@/api'
import { useUserStore } from '@/store/user'

const form = reactive({})
const saving = ref(false)
const store = useUserStore()

const load = async () => Object.assign(form, (await enterpriseApi.profile()).data || {})
const save = async () => {
  saving.value = true
  try {
    await enterpriseApi.updateProfile(form)
    ElMessage.success('保存成功')
  } finally {
    saving.value = false
  }
}

const uploadLogo = async ({ file }) => {
  const fd = new FormData()
  fd.append('file', file)
  const res = await enterpriseApi.uploadLogo(fd)
  form.logo = res.data
  store.setAvatar(res.data)
  ElMessage.success('Logo上传成功')
}

onMounted(load)
</script>

<style scoped lang="scss">
.profile-page {
  width: 100%;
  max-width: 1680px;
  margin: 0 auto;
}

.profile-card {
  padding: clamp(24px, 2vw, 34px);
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
  h2 { margin-bottom: 6px; }
  p { color: #909399; }
}

.profile-body {
  display: grid;
  grid-template-columns: minmax(248px, 300px) minmax(0, 1fr);
  gap: clamp(28px, 3vw, 48px);
  align-items: start;
}

.identity-uploader {
  width: 100%;

  :deep(.el-upload) {
    display: block;
    outline: none;
  }
}

.identity-upload {
  width: 100%;
  min-width: 0;
  min-height: 278px;
  padding: 24px 18px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 16px;
  border: 1px solid #d9ecff;
  border-radius: 8px;
  background: linear-gradient(180deg, #f8fbff 0%, #ffffff 100%);
  cursor: pointer;
  transition: border-color .2s ease, box-shadow .2s ease;

  &:hover {
    border-color: #409eff;
    box-shadow: 0 8px 18px rgba(64, 158, 255, .14);
  }
}

.identity-preview {
  position: relative;
  width: 96px;
  height: 96px;
  flex: 0 0 96px;
}

.logo-avatar {
  width: 96px !important;
  height: 96px !important;
  border: 2px solid #fff;
  border-radius: 8px;
  background: linear-gradient(135deg, #d9ecff, #faecd8);
  color: #409eff;
  font-size: 34px;
  box-shadow: inset 0 0 0 1px rgba(64, 158, 255, .16), 0 6px 16px rgba(31, 45, 61, .12);
}

.upload-mark {
  position: absolute;
  right: -4px;
  bottom: -4px;
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid #fff;
  border-radius: 50%;
  background: #409eff;
  color: #fff;
  box-shadow: 0 4px 10px rgba(64, 158, 255, .3);
}

.identity-copy {
  min-width: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.upload-label {
  color: #303133;
  font-size: 15px;
  font-weight: 600;
  line-height: 1.3;
}

.upload-sub {
  max-width: 190px;
  margin-top: 6px;
  color: #606266;
  font-size: 12px;
  line-height: 1.4;
}

.profile-form {
  width: 100%;
  max-width: none;

  :deep(.el-form-item) {
    margin-bottom: 18px;
  }
}

@media (max-width: 1180px) {
  .profile-card {
    padding: 24px;
  }

  .header {
    align-items: flex-start;
    flex-wrap: wrap;
  }

  .profile-body {
    grid-template-columns: 1fr;
    gap: 22px;
  }

  .identity-uploader,
  .identity-upload,
  .identity-uploader :deep(.el-upload) {
    width: 100%;
  }

  .identity-upload {
    min-width: 0;
    min-height: 220px;
  }
}

@media (max-width: 640px) {
  .profile-page {
    padding: 12px;
  }

  .profile-card {
    padding: 20px;
  }

  .identity-upload {
    min-height: 188px;
  }
}
</style>
