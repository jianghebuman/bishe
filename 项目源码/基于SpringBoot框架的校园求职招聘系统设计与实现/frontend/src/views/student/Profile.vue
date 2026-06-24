<template>
  <div class="page-container profile-page">
    <div class="page-card profile-card">
      <div class="header">
        <div>
          <h2>个人信息维护</h2>
          <p>完善基础资料可以提升企业查看简历后的联系效率</p>
        </div>
      </div>
      <el-divider />
      <div class="profile-body">
        <el-upload class="identity-uploader" :show-file-list="false" :http-request="uploadAvatar" accept="image/*">
          <div class="identity-upload">
            <div class="identity-preview">
              <el-avatar :size="96" :src="form.avatar" class="avatar"><el-icon><User /></el-icon></el-avatar>
              <span class="upload-mark"><el-icon><UploadFilled /></el-icon></span>
            </div>
            <div class="identity-copy">
              <span class="upload-label">{{ form.avatar ? '更换头像' : '上传头像' }}</span>
              <span class="upload-sub">用于企业查看简历时识别你</span>
            </div>
          </div>
        </el-upload>
        <el-form :model="form" label-width="100px" class="form profile-form">
          <el-row :gutter="20">
            <el-col :xs="24" :sm="12" :xl="8"><el-form-item label="登录账号"><el-input v-model="form.username" disabled /></el-form-item></el-col>
            <el-col :xs="24" :sm="12" :xl="8"><el-form-item label="姓名"><el-input v-model="form.realName" /></el-form-item></el-col>
            <el-col :xs="24" :sm="12" :xl="8"><el-form-item label="学号"><el-input v-model="form.studentNo" /></el-form-item></el-col>
            <el-col :xs="24" :sm="12" :xl="8"><el-form-item label="性别"><el-radio-group v-model="form.gender"><el-radio :label="1">男</el-radio><el-radio :label="2">女</el-radio><el-radio :label="0">保密</el-radio></el-radio-group></el-form-item></el-col>
            <el-col :xs="24" :sm="12" :xl="8"><el-form-item label="学院"><el-input v-model="form.college" /></el-form-item></el-col>
            <el-col :xs="24" :sm="12" :xl="8"><el-form-item label="专业"><el-input v-model="form.major" /></el-form-item></el-col>
            <el-col :xs="24" :sm="12" :xl="8"><el-form-item label="年级"><el-input v-model="form.grade" /></el-form-item></el-col>
            <el-col :xs="24" :sm="12" :xl="8"><el-form-item label="学历"><el-select v-model="form.education" style="width:100%"><el-option label="大专" value="大专"/><el-option label="本科" value="本科"/><el-option label="硕士" value="硕士"/><el-option label="博士" value="博士"/></el-select></el-form-item></el-col>
            <el-col :xs="24" :sm="12" :xl="8"><el-form-item label="手机号"><el-input v-model="form.phone" /></el-form-item></el-col>
            <el-col :xs="24" :sm="12" :xl="8"><el-form-item label="邮箱"><el-input v-model="form.email" /></el-form-item></el-col>
            <el-col :span="24"><el-form-item label="个人简介"><el-input v-model="form.intro" type="textarea" :rows="4" maxlength="500" show-word-limit /></el-form-item></el-col>
          </el-row>
          <el-form-item class="form-actions">
            <el-button type="primary" :loading="saving" @click="save">保存资料</el-button>
            <el-button @click="load">重置</el-button>
          </el-form-item>
        </el-form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { UploadFilled, User } from '@element-plus/icons-vue'
import { studentApi } from '@/api'
import { useUserStore } from '@/store/user'

const userStore = useUserStore()
const saving = ref(false)
const form = reactive({})
const load = async () => { const res = await studentApi.profile(); Object.assign(form, res.data || {}) }
const save = async () => { saving.value = true; try { await studentApi.updateProfile(form); ElMessage.success('保存成功') } finally { saving.value = false } }
const uploadAvatar = async ({ file }) => {
  const fd = new FormData(); fd.append('file', file)
  const res = await studentApi.uploadAvatar(fd)
  form.avatar = res.data; userStore.setAvatar(res.data)
  ElMessage.success('头像上传成功')
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
  border: 1px solid #c6e2ff;
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

.avatar {
  width: 96px !important;
  height: 96px !important;
  border: 2px solid #fff;
  background: linear-gradient(135deg, #d9ecff, #e1f3d8);
  color: #409eff;
  font-size: 32px;
  box-shadow: inset 0 0 0 1px rgba(64, 158, 255, .16), 0 6px 16px rgba(31, 45, 61, .12);
}

.upload-mark {
  position: absolute;
  right: -3px;
  bottom: -3px;
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
