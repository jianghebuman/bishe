<template>
  <div class="register-page">
    <header class="register-topbar">
      <router-link class="brand-mark" to="/">
        <span class="brand-icon">
          <Briefcase />
        </span>
        <span>校园招聘工作台</span>
      </router-link>
      <router-link class="ghost-link" to="/login">
        <el-icon><ArrowLeft /></el-icon>
        返回登录
      </router-link>
    </header>

    <main class="register-stage">
      <section class="register-shell" aria-label="账号注册">
        <aside class="register-brief">
          <div class="window-strip">
            <span></span>
            <span></span>
            <span></span>
          </div>
          <span class="brief-kicker">账号注册</span>
          <h1>{{ activeCopy.title }}</h1>
          <p>{{ activeCopy.description }}</p>
          <div class="brief-flow">
            <div v-for="item in activeCopy.flow" :key="item.title" class="flow-item">
              <component :is="item.icon" />
              <div>
                <b>{{ item.title }}</b>
                <span>{{ item.desc }}</span>
              </div>
            </div>
          </div>
        </aside>

        <section class="register-panel">
          <div class="role-switcher" aria-label="选择注册身份">
            <button
              v-for="item in roleOptions"
              :key="item.value"
              type="button"
              class="role-chip"
              :class="{ active: role === item.value }"
              :aria-pressed="role === item.value"
              @click="role = item.value"
            >
              <component :is="item.icon" />
              <span>{{ item.label }}</span>
            </button>
          </div>

          <el-form
            v-if="role === 'STUDENT'"
            ref="stuRef"
            :model="stuForm"
            :rules="stuRules"
            label-position="top"
            class="register-form"
          >
            <div class="form-section">
              <div class="section-heading">
                <span>登录信息</span>
                <small>用于后续进入学生工作台</small>
              </div>
              <div class="form-grid">
                <el-form-item label="账号" prop="username">
                  <el-input v-model="stuForm.username" :prefix-icon="User" placeholder="输入登录账号" size="large" />
                </el-form-item>
                <el-form-item label="密码" prop="password">
                  <el-input
                    v-model="stuForm.password"
                    :prefix-icon="Lock"
                    type="password"
                    show-password
                    placeholder="至少 6 位"
                    size="large"
                  />
                </el-form-item>
              </div>
            </div>

            <div class="form-section">
              <div class="section-heading">
                <span>学生信息</span>
                <small>建议与学籍信息保持一致</small>
              </div>
              <div class="form-grid">
                <el-form-item label="姓名" prop="realName">
                  <el-input v-model="stuForm.realName" placeholder="输入真实姓名" size="large" />
                </el-form-item>
                <el-form-item label="学号">
                  <el-input v-model="stuForm.studentNo" placeholder="输入学号" size="large" />
                </el-form-item>
                <el-form-item label="学院">
                  <el-input v-model="stuForm.college" placeholder="所在学院" size="large" />
                </el-form-item>
                <el-form-item label="专业">
                  <el-input v-model="stuForm.major" placeholder="所学专业" size="large" />
                </el-form-item>
                <el-form-item label="年级">
                  <el-input v-model="stuForm.grade" placeholder="如 2023级" size="large" />
                </el-form-item>
                <el-form-item label="手机号">
                  <el-input v-model="stuForm.phone" :prefix-icon="Phone" placeholder="用于接收面试联系" size="large" />
                </el-form-item>
                <el-form-item label="邮箱" class="wide-field">
                  <el-input v-model="stuForm.email" :prefix-icon="Message" placeholder="常用邮箱" size="large" />
                </el-form-item>
              </div>
            </div>

            <button class="primary-action" type="button" :disabled="loading" @click="registerStudent">
              <span>{{ loading ? '正在创建账号' : '创建学生账号' }}</span>
              <el-icon><Right /></el-icon>
            </button>
          </el-form>

          <el-form
            v-else
            ref="entRef"
            :model="entForm"
            :rules="entRules"
            label-position="top"
            class="register-form"
          >
            <div class="form-section">
              <div class="section-heading">
                <span>登录信息</span>
                <small>企业 HR 后续使用该账号管理招聘</small>
              </div>
              <div class="form-grid">
                <el-form-item label="账号" prop="username">
                  <el-input v-model="entForm.username" :prefix-icon="User" placeholder="输入登录账号" size="large" />
                </el-form-item>
                <el-form-item label="密码" prop="password">
                  <el-input
                    v-model="entForm.password"
                    :prefix-icon="Lock"
                    type="password"
                    show-password
                    placeholder="至少 6 位"
                    size="large"
                  />
                </el-form-item>
              </div>
            </div>

            <div class="form-section">
              <div class="section-heading">
                <span>企业资质信息</span>
                <small>注册后仍需上传营业执照等认证材料</small>
              </div>
              <div class="form-grid">
                <el-form-item label="企业名称" prop="companyName">
                  <el-input v-model="entForm.companyName" :prefix-icon="OfficeBuilding" placeholder="营业执照登记名称" size="large" />
                </el-form-item>
                <el-form-item label="统一社会信用代码" prop="creditCode">
                  <el-input
                    v-model.trim="entForm.creditCode"
                    :prefix-icon="Postcard"
                    maxlength="18"
                    placeholder="18 位大写字母或数字"
                    size="large"
                    @input="normalizeCreditCode"
                  />
                </el-form-item>
                <el-form-item label="所属行业" prop="industry">
                  <el-select v-model="entForm.industry" placeholder="选择行业" size="large">
                    <el-option v-for="item in industryOptions" :key="item" :label="item" :value="item" />
                  </el-select>
                </el-form-item>
                <el-form-item label="企业规模">
                  <el-select v-model="entForm.scale" placeholder="选择规模" size="large">
                    <el-option v-for="item in scaleOptions" :key="item" :label="item" :value="item" />
                  </el-select>
                </el-form-item>
                <el-form-item label="所在城市" prop="city">
                  <el-input v-model="entForm.city" :prefix-icon="Location" placeholder="如 北京、上海、深圳" size="large" />
                </el-form-item>
                <el-form-item label="官网">
                  <el-input v-model="entForm.website" :prefix-icon="Link" placeholder="https://example.com" size="large" />
                </el-form-item>
              </div>
            </div>

            <div class="form-section">
              <div class="section-heading">
                <span>招聘联系人</span>
                <small>用于管理员核验企业入驻信息</small>
              </div>
              <div class="form-grid">
                <el-form-item label="联系人姓名" prop="contactName">
                  <el-input v-model="entForm.contactName" placeholder="企业招聘负责人" size="large" />
                </el-form-item>
                <el-form-item label="联系电话" prop="contactPhone">
                  <el-input v-model="entForm.contactPhone" :prefix-icon="Phone" placeholder="手机号或固定电话" size="large" />
                </el-form-item>
                <el-form-item label="企业邮箱" prop="email" class="wide-field">
                  <el-input v-model="entForm.email" :prefix-icon="Message" placeholder="建议使用企业域名邮箱" size="large" />
                </el-form-item>
              </div>
            </div>

            <el-form-item prop="agreeTerms" class="agree-field">
              <el-checkbox v-model="entForm.agreeTerms" size="large">
                我确认企业信息真实有效，注册后将提交营业执照等认证材料
              </el-checkbox>
            </el-form-item>

            <button class="primary-action" type="button" :disabled="loading" @click="registerEnterprise">
              <span>{{ loading ? '正在提交入驻信息' : '提交企业入驻申请' }}</span>
              <el-icon><Right /></el-icon>
            </button>
          </el-form>

          <div class="panel-footer">
            <router-link to="/login">已有账号，去登录</router-link>
            <router-link to="/">先浏览招聘信息</router-link>
          </div>
        </section>
      </section>
    </main>
  </div>
</template>

<script setup>
import { computed, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  ArrowLeft,
  Briefcase,
  Check,
  DocumentChecked,
  Link,
  Location,
  Lock,
  Message,
  OfficeBuilding,
  Phone,
  Postcard,
  Right,
  School,
  Tickets,
  User
} from '@element-plus/icons-vue'
import { authApi } from '@/api'

const router = useRouter()
const role = ref('STUDENT')
const loading = ref(false)
const stuRef = ref()
const entRef = ref()

const roleOptions = [
  { value: 'STUDENT', label: '学生注册', icon: School },
  { value: 'ENTERPRISE', label: '企业入驻', icon: OfficeBuilding }
]

const copyMap = {
  STUDENT: {
    title: '把简历和投递记录放进同一个工作台。',
    description: '学生账号用于维护个人资料、在线简历、投递记录和面试安排。',
    flow: [
      { icon: User, title: '建立个人账号', desc: '填写基础身份信息' },
      { icon: Tickets, title: '完善求职资料', desc: '维护简历与求职意向' },
      { icon: Check, title: '跟进招聘流程', desc: '查看投递、面试与 Offer' }
    ]
  },
  ENTERPRISE: {
    title: '企业入驻先核验，再开展校园招聘。',
    description: '参照招聘平台常见做法，企业注册需提交公司资质和招聘联系人信息。',
    flow: [
      { icon: Postcard, title: '登记企业资质', desc: '填写统一社会信用代码' },
      { icon: DocumentChecked, title: '提交认证材料', desc: '注册后上传营业执照' },
      { icon: Check, title: '通过后发布岗位', desc: '管理员审核后开展招聘' }
    ]
  }
}

const activeCopy = computed(() => copyMap[role.value])

const stuForm = reactive({
  username: '',
  password: '',
  realName: '',
  studentNo: '',
  college: '',
  major: '',
  grade: '',
  phone: '',
  email: ''
})

const entForm = reactive({
  username: '',
  password: '',
  companyName: '',
  creditCode: '',
  industry: '',
  scale: '',
  city: '',
  contactName: '',
  contactPhone: '',
  email: '',
  website: '',
  agreeTerms: false
})

const industryOptions = ['互联网', '计算机软件', '电子商务', '金融', '教育培训', '制造业', '文化传媒', '医疗健康', '其他']
const scaleOptions = ['20人以下', '20-99人', '100-499人', '500-999人', '1000人以上']

const required = (msg) => [{ required: true, message: msg, trigger: 'blur' }]
const passwordRule = [
  { required: true, message: '请输入密码', trigger: 'blur' },
  { min: 6, message: '密码至少 6 位', trigger: 'blur' }
]
const emailRule = [
  { required: true, message: '请输入企业邮箱', trigger: 'blur' },
  { type: 'email', message: '请输入有效的企业邮箱', trigger: ['blur', 'change'] }
]
const phoneRule = [
  { required: true, message: '请输入联系电话', trigger: 'blur' },
  {
    pattern: /^1[3-9]\d{9}$|^0\d{2,3}-?\d{7,8}$/,
    message: '请输入有效的手机号或固定电话',
    trigger: 'blur'
  }
]
const creditCodeRule = [
  { required: true, message: '请输入统一社会信用代码', trigger: 'blur' },
  { pattern: /^[0-9A-Z]{18}$/, message: '请输入18位大写字母或数字', trigger: ['blur', 'change'] }
]

const stuRules = {
  username: required('请输入账号'),
  password: passwordRule,
  realName: required('请输入姓名')
}

const entRules = {
  username: required('请输入账号'),
  password: passwordRule,
  companyName: required('请输入企业名称'),
  creditCode: creditCodeRule,
  industry: required('请选择所属行业'),
  city: required('请输入所在城市'),
  contactName: required('请输入联系人姓名'),
  contactPhone: phoneRule,
  email: emailRule,
  agreeTerms: [
    {
      validator: (_rule, value, callback) => {
        if (value) callback()
        else callback(new Error('请确认企业信息真实有效'))
      },
      trigger: 'change'
    }
  ]
}

const normalizeCreditCode = (value) => {
  entForm.creditCode = value.toUpperCase().replace(/[^0-9A-Z]/g, '').slice(0, 18)
}

const registerStudent = () => {
  stuRef.value.validate(async (valid) => {
    if (!valid) return
    loading.value = true
    try {
      await authApi.registerStudent(stuForm)
      ElMessage.success('注册成功，请登录')
      router.push('/login')
    } finally {
      loading.value = false
    }
  })
}

const registerEnterprise = () => {
  entRef.value.validate(async (valid) => {
    if (!valid) return
    loading.value = true
    try {
      await authApi.registerEnterprise(entForm)
      ElMessage.success('企业账号已创建，请登录后完善企业认证')
      router.push('/login')
    } finally {
      loading.value = false
    }
  })
}
</script>

<style scoped lang="scss">
.register-page {
  position: relative;
  min-height: 100vh;
  overflow-x: hidden;
  color: #17231d;
  background:
    linear-gradient(90deg, rgba(23, 35, 29, 0.045) 1px, transparent 1px),
    linear-gradient(0deg, rgba(23, 35, 29, 0.045) 1px, transparent 1px),
    #edf2ee;
  background-size: 42px 42px;
  font-family: "Inter", "PingFang SC", "Microsoft YaHei", sans-serif;
}

.register-page::before {
  position: absolute;
  inset: 0;
  content: "";
  pointer-events: none;
  background:
    linear-gradient(115deg, rgba(238, 184, 82, 0.16), transparent 34%),
    linear-gradient(180deg, transparent 0%, rgba(47, 83, 72, 0.1) 100%);
}

.register-topbar {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: min(1480px, calc(100% - 64px));
  margin: 0 auto;
  padding: 24px 0 18px;
}

.brand-mark,
.ghost-link {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  font-size: 14px;
  font-weight: 800;
}

.brand-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  color: #f7efe0;
  background: #263a33;
  border: 1px solid rgba(23, 35, 29, 0.16);
  border-radius: 8px;

  svg {
    width: 18px;
    height: 18px;
  }
}

.ghost-link {
  padding: 9px 12px;
  color: #41554c;
  background: rgba(255, 255, 255, 0.58);
  border: 1px solid rgba(23, 35, 29, 0.12);
  border-radius: 8px;
  transition: color 0.2s ease, border-color 0.2s ease, transform 0.2s ease;
}

.ghost-link:hover {
  color: #17231d;
  border-color: rgba(23, 35, 29, 0.26);
  transform: translateY(-1px);
}

.register-stage {
  position: relative;
  z-index: 1;
  display: flex;
  justify-content: center;
  min-height: calc(100vh - 88px);
  padding: 24px 32px 48px;
}

.register-shell {
  display: grid;
  grid-template-columns: minmax(420px, 0.78fr) minmax(0, 1.34fr);
  width: min(1480px, 100%);
  overflow: hidden;
  border: 1px solid rgba(23, 35, 29, 0.2);
  border-radius: 18px;
  background: #fffdf7;
  box-shadow: 0 34px 70px rgba(35, 54, 45, 0.18);
}

.register-brief {
  position: relative;
  display: flex;
  flex-direction: column;
  min-height: 720px;
  padding: 42px;
  color: #f8f2e6;
  background:
    linear-gradient(90deg, rgba(255, 255, 255, 0.08) 1px, transparent 1px),
    linear-gradient(0deg, rgba(255, 255, 255, 0.06) 1px, transparent 1px),
    #223930;
  background-size: 32px 32px;
}

.window-strip {
  display: flex;
  gap: 8px;
  margin-bottom: 48px;

  span {
    width: 10px;
    height: 10px;
    border: 1px solid rgba(248, 242, 230, 0.42);
    border-radius: 50%;
  }
}

.brief-kicker {
  width: max-content;
  padding: 7px 10px;
  margin-bottom: 18px;
  color: #223930;
  background: #eeb852;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 900;
}

.register-brief h1 {
  margin: 0;
  font-size: clamp(30px, 3.6vw, 44px);
  line-height: 1.08;
  font-weight: 850;
}

.register-brief p {
  margin: 20px 0 0;
  color: rgba(248, 242, 230, 0.76);
  font-size: 15px;
  line-height: 1.8;
}

.brief-flow {
  display: grid;
  gap: 14px;
  margin-top: auto;
  padding-top: 42px;
}

.flow-item {
  display: grid;
  grid-template-columns: 38px minmax(0, 1fr);
  gap: 12px;
  align-items: start;
  padding: 14px 0;
  border-top: 1px dashed rgba(248, 242, 230, 0.22);

  svg {
    width: 20px;
    height: 20px;
    margin-top: 1px;
    color: #eeb852;
  }

  b {
    display: block;
    font-size: 14px;
  }

  span {
    display: block;
    margin-top: 5px;
    color: rgba(248, 242, 230, 0.66);
    font-size: 13px;
    line-height: 1.55;
  }
}

.register-panel {
  display: flex;
  flex-direction: column;
  padding: clamp(36px, 4vw, 56px);
  background: #fffdf7;
}

.role-switcher {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 10px;
  margin-bottom: 28px;
}

.role-chip {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  min-height: 46px;
  padding: 0 14px;
  color: #607168;
  background: #f4f7f3;
  border: 1px solid rgba(23, 35, 29, 0.1);
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 900;
  transition: background 0.2s ease, border-color 0.2s ease, color 0.2s ease, transform 0.2s ease;

  svg {
    width: 17px;
    height: 17px;
  }
}

.role-chip:hover {
  color: #17231d;
  border-color: rgba(23, 35, 29, 0.24);
  transform: translateY(-1px);
}

.role-chip.active {
  color: #fffaf0;
  background: #243a32;
  border-color: #243a32;
  box-shadow: inset 0 -2px 0 rgba(238, 184, 82, 0.78);
}

.register-form {
  display: grid;
  gap: 22px;

  :deep(.el-form-item) {
    margin-bottom: 0;
  }

  :deep(.el-form-item__label) {
    margin-bottom: 7px;
    color: #2d3a34;
    font-weight: 850;
    line-height: 1.2;
  }

  :deep(.el-input__wrapper),
  :deep(.el-select__wrapper) {
    min-height: 46px;
    border-radius: 8px;
    background: #f8faf6;
    box-shadow: inset 0 0 0 1px rgba(23, 35, 29, 0.12);
    transition: box-shadow 0.2s ease, background 0.2s ease;
  }

  :deep(.el-input__wrapper.is-focus),
  :deep(.el-select__wrapper.is-focused) {
    background: #ffffff;
    box-shadow: inset 0 0 0 1px #2f5f51, 0 0 0 4px rgba(47, 95, 81, 0.12);
  }

  :deep(.el-input__inner) {
    color: #17231d;
    font-weight: 650;
  }
}

.form-section {
  padding: 18px;
  border: 1px solid rgba(23, 35, 29, 0.1);
  border-radius: 8px;
  background: #fbfcf7;
}

.section-heading {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 14px;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px dashed rgba(23, 35, 29, 0.14);

  span {
    color: #17231d;
    font-size: 15px;
    font-weight: 900;
  }

  small {
    color: #718078;
    font-size: 12px;
    line-height: 1.45;
    text-align: right;
  }
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 18px 16px;
}

.wide-field {
  grid-column: 1 / -1;
}

.agree-field {
  padding: 2px 4px 0;

  :deep(.el-checkbox) {
    align-items: flex-start;
    min-width: 0;
    height: auto;
    color: #43564d;
    white-space: normal;
    font-weight: 750;
  }

  :deep(.el-checkbox__label) {
    min-width: 0;
    line-height: 1.6;
    white-space: normal;
  }
}

.primary-action {
  display: inline-flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  min-height: 52px;
  padding: 0 16px 0 20px;
  color: #fffaf0;
  background: #17231d;
  border: 1px solid #17231d;
  border-radius: 8px;
  box-shadow: 0 12px 26px rgba(23, 35, 29, 0.22);
  cursor: pointer;
  font-size: 15px;
  font-weight: 900;
  transition: background 0.2s ease, box-shadow 0.2s ease, transform 0.2s ease;
}

.primary-action:hover:not(:disabled) {
  background: #2d473c;
  box-shadow: 0 16px 30px rgba(23, 35, 29, 0.26);
  transform: translateY(-1px);
}

.primary-action:disabled {
  cursor: wait;
  opacity: 0.74;
}

.panel-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
  margin-top: 22px;
  padding-top: 18px;
  border-top: 1px solid rgba(23, 35, 29, 0.1);
  font-size: 14px;

  a {
    color: #2f5f51;
    font-weight: 850;
  }

  a:hover {
    color: #17231d;
  }
}

@media (max-width: 980px) {
  .register-shell {
    grid-template-columns: 1fr;
  }

  .register-brief {
    min-height: 0;
  }

  .brief-flow {
    margin-top: 34px;
    padding-top: 0;
  }
}

@media (max-width: 640px) {
  .register-topbar {
    width: min(100% - 28px, 1480px);
    padding-top: 16px;
  }

  .brand-mark span:last-child {
    display: none;
  }

  .register-stage {
    padding: 12px 14px 28px;
  }

  .register-shell {
    border-radius: 14px;
  }

  .register-brief,
  .register-panel {
    padding: 22px;
  }

  .window-strip {
    margin-bottom: 28px;
  }

  .register-brief h1 {
    font-size: 28px;
  }

  .role-switcher,
  .form-grid {
    grid-template-columns: 1fr;
  }

  .section-heading,
  .panel-footer {
    align-items: flex-start;
    flex-direction: column;
  }

  .section-heading small {
    text-align: left;
  }
}
</style>
