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
          <BackgroundPaths3d class="auth-paths-3d" variant="dark" :density="16" />
          <div class="cr-aurora-layer auth-aurora" aria-hidden="true"></div>
          <div class="cr-light-rays-layer auth-rays" aria-hidden="true"><i></i><i></i><i></i></div>
          <div class="window-strip">
            <span></span>
            <span></span>
            <span></span>
          </div>
          <span class="brief-kicker">账号注册</span>
          <h1>{{ activeCopy.title }}</h1>
          <p>{{ activeCopy.description }}</p>
          <div class="brief-highlights" aria-label="注册完成后可使用的能力">
            <div v-for="item in activeCopy.highlights" :key="item.label">
              <b>{{ item.value }}</b>
              <span>{{ item.label }}</span>
            </div>
          </div>
          <div class="brief-checklist" aria-label="注册前准备">
            <div class="checklist-heading">
              <span>{{ activeCopy.checklist.title }}</span>
              <small>{{ activeCopy.checklist.caption }}</small>
            </div>
            <ul>
              <li v-for="item in activeCopy.checklist.items" :key="item">{{ item }}</li>
            </ul>
          </div>
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
                <el-form-item label="学校" prop="school">
                  <el-select v-model="stuForm.school" filterable placeholder="选择所在学校" size="large">
                    <el-option v-for="item in schoolOptions" :key="item.id || item.name" :label="item.name" :value="item.name" />
                  </el-select>
                </el-form-item>
                <el-form-item label="学号" prop="studentNo">
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
                <el-form-item label="手机号" prop="phone">
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
import { computed, onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
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
import { authApi, publicApi } from '@/api'
import BackgroundPaths3d from '@/components/BackgroundPaths3d.vue'

const router = useRouter()
const route = useRoute()
const role = ref(route.query.role === 'ENTERPRISE' ? 'ENTERPRISE' : 'STUDENT')
const loading = ref(false)
const stuRef = ref()
const entRef = ref()
const schoolOptions = ref([])

const roleOptions = [
  { value: 'STUDENT', label: '学生注册', icon: School },
  { value: 'ENTERPRISE', label: '企业入驻', icon: OfficeBuilding }
]

const copyMap = {
  STUDENT: {
    title: '把简历和投递记录放进同一个工作台。',
    description: '学生账号用于维护个人资料、在线简历、投递记录和面试安排。',
    highlights: [
      { value: '资料', label: '个人信息与求职意向' },
      { value: '简历', label: '在线简历和附件管理' },
      { value: '进度', label: '投递、面试、Offer 跟进' }
    ],
    checklist: {
      title: '学生注册准备',
      caption: '建议一次填准',
      items: ['学校、学号等学籍信息', '学院、专业、年级信息', '后续可继续完善在线简历']
    },
    flow: [
      { icon: User, title: '建立个人账号', desc: '填写基础身份信息' },
      { icon: Tickets, title: '完善求职资料', desc: '维护简历与求职意向' },
      { icon: Check, title: '跟进招聘流程', desc: '查看投递、面试与 Offer' }
    ]
  },
  ENTERPRISE: {
    title: '企业入驻先核验，再开展校园招聘。',
    description: '参照招聘平台常见做法，企业注册需提交公司资质和招聘联系人信息。',
    highlights: [
      { value: '资质', label: '企业认证资料留档' },
      { value: '岗位', label: '招聘岗位发布与刷新' },
      { value: '候选', label: '简历筛选和面试邀约' }
    ],
    checklist: {
      title: '入驻前准备',
      caption: '用于管理员核验',
      items: ['营业执照登记名称与统一社会信用代码', '招聘负责人姓名、电话和企业邮箱', '注册后在企业工作台补充认证附件']
    },
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
  school: '',
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
  realName: required('请输入姓名'),
  school: required('请选择学校'),
  studentNo: required('请输入学号'),
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入有效的手机号', trigger: 'blur' }
  ]
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

const loadSchools = async () => {
  const res = await publicApi.schools().catch(() => ({ data: [] }))
  schoolOptions.value = res.data || []
}

const registerStudent = () => {
  stuRef.value.validate(async (valid) => {
    if (!valid) return
    loading.value = true
    try {
      await authApi.registerStudent(stuForm)
      ElMessage.success('注册成功，请登录')
      router.push('/login')
    } catch (_error) {
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
    } catch (_error) {
    } finally {
      loading.value = false
    }
  })
}

onMounted(loadSchools)
</script>

<style scoped lang="scss">
.register-page {
  position: relative;
  --auth-shell-width: min(150rem, calc(100% - clamp(1.5rem, 4vw, 6rem)));
  min-height: 100dvh;
  overflow-x: hidden;
  color: #172033;
  background:
    linear-gradient(90deg, rgba(37, 99, 235, 0.05) 1px, transparent 1px),
    linear-gradient(0deg, rgba(37, 99, 235, 0.05) 1px, transparent 1px),
    #f4f7fb;
  background-size: 42px 42px;
  font-family: "Inter", "PingFang SC", "Microsoft YaHei", sans-serif;
}

.register-page::before {
  position: absolute;
  inset: 0;
  content: "";
  pointer-events: none;
  background:
    radial-gradient(circle at 16% 18%, rgba(8, 145, 178, 0.14), transparent 28%),
    linear-gradient(180deg, transparent 0%, rgba(37, 99, 235, 0.08) 100%);
}

.register-topbar {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: var(--auth-shell-width);
  margin: 0 auto;
  padding: clamp(1rem, 2dvh, 1.5rem) 0 clamp(0.75rem, 1.6dvh, 1.125rem);
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
  background: #2563eb;
  border: 1px solid rgba(37, 99, 235, 0.22);
  border-radius: 8px;

  svg {
    width: 18px;
    height: 18px;
  }
}

.ghost-link {
  padding: 9px 12px;
  color: #5d6f88;
  background: rgba(255, 255, 255, 0.58);
  border: 1px solid rgba(93, 111, 136, 0.18);
  border-radius: 8px;
  transition: color 0.2s ease, border-color 0.2s ease, transform 0.2s ease;
}

.ghost-link:hover {
  color: #172033;
  border-color: rgba(37, 99, 235, 0.32);
  transform: translateY(-1px);
}

.register-stage {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: flex-start;
  justify-content: center;
  min-height: calc(100dvh - clamp(4.75rem, 6dvh, 6.25rem));
  padding: clamp(1rem, 2dvh, 1.5rem) 0 clamp(1.5rem, 3dvh, 3rem);
}

.register-shell {
  display: grid;
  grid-template-columns: minmax(34rem, 0.92fr) minmax(42rem, 1.08fr);
  width: var(--auth-shell-width);
  min-height: clamp(36rem, 86dvh, 92rem);
  overflow: hidden;
  border: 1px solid rgba(93, 111, 136, 0.18);
  border-radius: clamp(1rem, 1vw, 1.5rem);
  background: #ffffff;
  box-shadow: 0 34px 70px rgba(22, 38, 68, 0.16);
}

.register-brief {
  position: relative;
  isolation: isolate;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  min-height: 100%;
  padding: clamp(2rem, 3.4vw, 5rem);
  color: #eef6ff;
  background:
    linear-gradient(90deg, rgba(255, 255, 255, 0.08) 1px, transparent 1px),
    linear-gradient(0deg, rgba(255, 255, 255, 0.06) 1px, transparent 1px),
    #15243b;
  background-size: 32px 32px;
}

.auth-rays {
  --cr-rays-color: rgba(105, 218, 255, 0.26);
  --cr-rays-opacity: 0.5;
  --cr-rays-blur: 1.5rem;
  --cr-rays-length: 72%;
  mix-blend-mode: screen;
}

.auth-aurora {
  --cr-aurora-opacity: 0.42;
  --cr-aurora-blend: screen;
  --cr-aurora-primary: rgba(64, 127, 255, 0.32);
  --cr-aurora-secondary: rgba(20, 184, 166, 0.24);
  --cr-aurora-tertiary: rgba(125, 211, 252, 0.18);
  --cr-aurora-blur: 1.75rem;
  --cr-aurora-x: 72%;
  --cr-aurora-y: 10%;
  inset: -34% -28% -10% -22%;
}

.auth-paths-3d {
  --paths-3d-opacity: 0.34;
  --paths-3d-blend: screen;
  inset: -4% -12% -4% -16%;
}

.register-brief > :not(.auth-rays):not(.auth-aurora):not(.auth-paths-3d) {
  position: relative;
  z-index: 1;
}

.window-strip {
  display: flex;
  gap: 8px;
  margin-bottom: clamp(3rem, 7dvh, 7rem);

  span {
    width: 10px;
    height: 10px;
    border: 1px solid rgba(238, 246, 255, 0.42);
    border-radius: 50%;
  }
}

.brief-kicker {
  width: max-content;
  padding: 7px 10px;
  margin-bottom: 18px;
  color: #15243b;
  background: #0891b2;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 900;
}

.register-brief h1 {
  margin: 0;
  width: min(44rem, 100%);
  font-size: 2.75rem;
  line-height: 1.08;
  font-weight: 850;
}

.register-brief p {
  width: min(38rem, 100%);
  margin: 20px 0 0;
  color: rgba(238, 246, 255, 0.76);
  font-size: 15px;
  line-height: 1.8;
}

.brief-highlights {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 0.75rem;
  width: min(42rem, 100%);
  margin-top: clamp(2rem, 4dvh, 3.5rem);

  div {
    position: relative;
    overflow: hidden;
    min-height: 6.75rem;
    padding: 1rem;
    border: 1px solid rgba(238, 246, 255, 0.16);
    border-radius: 0.75rem;
    background:
      var(--cr-noise-texture),
      rgba(238, 246, 255, 0.06);
    background-size: 180px 180px, auto;
    background-blend-mode: soft-light, normal;
  }

  b {
    display: block;
    margin-bottom: 0.625rem;
    color: #eef6ff;
    font-size: 1.25rem;
    font-weight: 900;
  }

  span {
    display: block;
    color: rgba(238, 246, 255, 0.68);
    font-size: 0.8125rem;
    line-height: 1.65;
  }
}

.brief-checklist {
  width: min(42rem, 100%);
  margin-top: clamp(1.25rem, 3dvh, 2.5rem);
  padding: 1.125rem;
  border: 1px solid rgba(238, 246, 255, 0.14);
  border-radius: 0.75rem;
  background:
    var(--cr-noise-texture),
    rgba(8, 145, 178, 0.08);
  background-size: 180px 180px, auto;
  background-blend-mode: soft-light, normal;
  box-shadow: inset 3px 0 0 rgba(8, 145, 178, 0.86);
}

.checklist-heading {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 1rem;
  padding-bottom: 0.75rem;
  border-bottom: 1px dashed rgba(238, 246, 255, 0.18);

  span {
    font-size: 0.9375rem;
    font-weight: 900;
  }

  small {
    color: rgba(238, 246, 255, 0.58);
    font-size: 0.75rem;
    font-weight: 800;
    white-space: nowrap;
  }
}

.brief-checklist ul {
  display: grid;
  gap: 0.75rem;
  margin-top: 0.875rem;
}

.brief-checklist li {
  position: relative;
  padding-left: 1.125rem;
  color: rgba(238, 246, 255, 0.72);
  font-size: 0.8125rem;
  line-height: 1.6;
}

.brief-checklist li::before {
  position: absolute;
  top: 0.62em;
  left: 0;
  width: 0.375rem;
  height: 0.375rem;
  content: "";
  background: #0891b2;
  border-radius: 50%;
  box-shadow: 0 0 0 0.25rem rgba(8, 145, 178, 0.14);
}

.brief-flow {
  display: grid;
  gap: 14px;
  width: min(40rem, 100%);
  margin-top: clamp(1.5rem, 4dvh, 3.25rem);
  padding-top: 0;
}

.flow-item {
  display: grid;
  grid-template-columns: 38px minmax(0, 1fr);
  gap: 12px;
  align-items: start;
  padding: 14px 0;
  border-top: 1px dashed rgba(238, 246, 255, 0.22);

  svg {
    width: 20px;
    height: 20px;
    margin-top: 1px;
    color: #0891b2;
  }

  b {
    display: block;
    font-size: 14px;
  }

  span {
    display: block;
    margin-top: 5px;
    color: rgba(238, 246, 255, 0.66);
    font-size: 13px;
    line-height: 1.55;
  }
}

.register-panel {
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: clamp(2rem, 3.4vw, 5rem);
  background:
    var(--cr-noise-texture),
    #ffffff;
  background-size: 180px 180px, auto;
  background-blend-mode: soft-light, normal;
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
  color: #5d6f88;
  background: #f8fbff;
  border: 1px solid rgba(93, 111, 136, 0.16);
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
  color: #172033;
  border-color: rgba(37, 99, 235, 0.28);
  transform: translateY(-1px);
}

.role-chip.active {
  color: #ffffff;
  background: #2563eb;
  border-color: #2563eb;
  box-shadow: inset 0 -2px 0 rgba(8, 145, 178, 0.72);
}

.register-form {
  display: grid;
  gap: 22px;

  :deep(.el-form-item) {
    margin-bottom: 0;
  }

  :deep(.el-form-item__label) {
    margin-bottom: 7px;
    color: #172033;
    font-weight: 850;
    line-height: 1.2;
  }

  :deep(.el-input__wrapper),
  :deep(.el-select__wrapper) {
    min-height: 46px;
    border-radius: 8px;
    background: #f8fbff;
    box-shadow: inset 0 0 0 1px rgba(93, 111, 136, 0.2);
    transition: box-shadow 0.2s ease, background 0.2s ease;
  }

  :deep(.el-input__wrapper.is-focus),
  :deep(.el-select__wrapper.is-focused) {
    background: #ffffff;
    box-shadow: inset 0 0 0 1px #2563eb, 0 0 0 4px rgba(37, 99, 235, 0.12);
  }

  :deep(.el-input__inner) {
    color: #172033;
    font-weight: 650;
  }
}

.form-section {
  padding: 18px;
  border: 1px solid rgba(93, 111, 136, 0.16);
  border-radius: 8px;
  background: #f8fbff;
}

.section-heading {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 14px;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px dashed rgba(93, 111, 136, 0.2);

  span {
    color: #172033;
    font-size: 15px;
    font-weight: 900;
  }

  small {
    color: #8a99ad;
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
    color: #5d6f88;
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
  color: #ffffff;
  background: #172033;
  border: 1px solid #172033;
  border-radius: 8px;
  box-shadow: 0 12px 26px rgba(37, 99, 235, 0.24);
  cursor: pointer;
  font-size: 15px;
  font-weight: 900;
  transition: background 0.2s ease, box-shadow 0.2s ease, transform 0.2s ease;
}

.primary-action:hover:not(:disabled) {
  background: #1d4ed8;
  box-shadow: 0 16px 30px rgba(37, 99, 235, 0.28);
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
  flex-wrap: nowrap;
  gap: 14px;
  margin-top: 22px;
  padding-top: 18px;
  border-top: 1px solid rgba(93, 111, 136, 0.16);
  font-size: 14px;

  a {
    color: #2563eb;
    font-weight: 850;
  }

  a:hover {
    color: #172033;
  }
}

@media (min-width: 1800px) {
  .register-shell {
    min-height: clamp(36rem, 78dvh, 78rem);
  }

  .register-topbar {
    padding: 1rem 0 0.75rem;
  }

  .register-stage {
    min-height: calc(100dvh - 4.5rem);
    padding: 0.75rem 0 1.25rem;
  }

  .register-panel {
    justify-content: flex-start;
    padding-block: clamp(3rem, 4.5dvh, 4.5rem) clamp(2.5rem, 4dvh, 4rem);
  }

  .register-brief h1 {
    font-size: 3.25rem;
  }

  .role-chip {
    min-height: 3.25rem;
    font-size: 0.9375rem;
  }

  .role-switcher {
    gap: 0.75rem;
    margin-bottom: 1.25rem;
  }

  .register-form {
    gap: 1rem;

    :deep(.el-input__wrapper),
    :deep(.el-select__wrapper) {
      min-height: 3.125rem;
    }
  }

  .form-section {
    padding: 1rem 1.125rem;
  }

  .section-heading {
    margin-bottom: 0.875rem;
    padding-bottom: 0.625rem;
  }

  .form-grid {
    gap: 0.875rem 1rem;
  }

  .agree-field {
    padding-top: 0;
  }

  .primary-action {
    min-height: 3.5rem;
    font-size: 1rem;
  }

  .panel-footer {
    margin-top: 1rem;
    padding-top: 1rem;
  }
}

@media (min-width: 1800px) and (max-height: 1300px) {
  .register-shell {
    min-height: calc(100dvh - 7.5rem);
  }

  .register-brief,
  .register-panel {
    padding: clamp(2rem, 2.6vw, 3.5rem);
  }

  .window-strip {
    margin-bottom: clamp(1.75rem, 4dvh, 3.5rem);
  }

  .register-brief h1 {
    font-size: clamp(2.5rem, 3vw, 3rem);
  }

  .brief-highlights {
    margin-top: clamp(1.5rem, 3dvh, 2.25rem);
  }

  .brief-checklist {
    margin-top: clamp(1rem, 2dvh, 1.5rem);
  }

  .brief-flow {
    margin-top: clamp(1rem, 2.5dvh, 2rem);
    gap: 0.5rem;
  }

  .flow-item {
    padding: 0.625rem 0;
  }
}

@media (max-width: 980px) {
  .register-shell {
    grid-template-columns: 1fr;
    min-height: 0;
  }

  .register-brief {
    min-height: 0;
    order: 2;
  }

  .register-panel {
    order: 1;
  }

  .brief-flow {
    margin-top: 34px;
    padding-top: 0;
  }

  .brief-highlights {
    grid-template-columns: 1fr;
    margin-top: 28px;
  }

  .brief-checklist {
    margin-top: 20px;
  }
}

@media (max-width: 640px) {
  .register-topbar {
    width: calc(100% - 1.25rem);
    padding-top: 16px;
  }

  .brand-mark span:last-child {
    display: none;
  }

  .register-stage {
    padding: 12px 14px 28px;
  }

  .register-shell {
    width: 100%;
    border-radius: 0.875rem;
  }

  .register-brief,
  .register-panel {
    padding: 22px;
  }

  .register-brief {
    order: 2;
  }

  .register-panel {
    order: 1;
  }

  .window-strip {
    margin-bottom: 28px;
  }

  .register-brief h1 {
    font-size: 1.75rem;
  }

  .brief-highlights div {
    min-height: 0;
  }

  .role-switcher {
    grid-template-columns: 1fr;
    gap: 8px;
    margin-bottom: 20px;
  }

  .role-chip {
    min-height: 44px;
    padding: 0 10px;
  }

  .form-grid {
    grid-template-columns: 1fr;
  }

  .section-heading {
    align-items: flex-start;
    flex-direction: column;
  }

  .section-heading small {
    text-align: left;
  }

  .panel-footer {
    align-items: center;
    justify-content: space-between;
    flex-direction: row;
    flex-wrap: wrap;
    gap: 10px;
    font-size: 13px;

    a {
      white-space: nowrap;
    }
  }
}

/* visual refresh overrides */
.register-page {
  color: var(--cr-text);
  background:
    linear-gradient(135deg, rgba(15, 118, 110, 0.10), transparent 34%),
    linear-gradient(315deg, rgba(36, 84, 214, 0.10), transparent 40%),
    linear-gradient(90deg, rgba(36, 84, 214, 0.05) 1px, transparent 1px),
    linear-gradient(0deg, rgba(36, 84, 214, 0.05) 1px, transparent 1px),
    var(--cr-bg);
  font-family: "PingFang SC", "Microsoft YaHei", "Helvetica Neue", Arial, sans-serif;
}

.register-page::before {
  background:
    linear-gradient(90deg, rgba(255, 255, 255, 0.70), transparent 42%),
    linear-gradient(180deg, transparent 0%, rgba(36, 84, 214, 0.07) 100%);
}

.brand-icon,
.role-chip.active,
.primary-action {
  background: linear-gradient(135deg, var(--cr-primary), var(--cr-accent));
  border-color: var(--cr-primary);
}

.brand-icon,
.ghost-link,
.brief-kicker,
.brief-highlights div,
.brief-checklist,
.role-chip,
.register-form :deep(.el-input__wrapper),
.register-form :deep(.el-select__wrapper),
.form-section,
.primary-action {
  border-radius: var(--cr-radius-sm);
}

.register-shell {
  border-color: rgba(203, 216, 231, 0.9);
  border-radius: var(--cr-radius);
  box-shadow: 0 34px 70px rgba(16, 24, 39, 0.16), var(--cr-shadow-line);
}

.register-brief {
  background:
    var(--cr-noise-texture),
    linear-gradient(135deg, rgba(15, 118, 110, 0.24), transparent 34%),
    linear-gradient(90deg, rgba(255, 255, 255, 0.08) 1px, transparent 1px),
    linear-gradient(0deg, rgba(255, 255, 255, 0.06) 1px, transparent 1px),
    var(--cr-sidebar);
  background-size: 180px 180px, auto, 32px 32px, 32px 32px, auto;
  background-blend-mode: soft-light, normal, normal, normal, normal;
}

.register-panel {
  background:
    var(--cr-noise-texture),
    linear-gradient(180deg, #ffffff, #f8fbff);
  background-size: 180px 180px, auto;
  background-blend-mode: soft-light, normal;
}

.brief-kicker {
  background: #8de2db;
}

.role-chip,
.ghost-link,
.section-heading small,
.agree-field :deep(.el-checkbox),
.panel-footer {
  color: var(--cr-text-soft);
}

.register-form :deep(.el-form-item__label),
.register-form :deep(.el-input__inner),
.section-heading span {
  color: var(--cr-text);
}

.panel-footer a {
  color: var(--cr-primary);
}

.register-form :deep(.el-input__wrapper.is-focus),
.register-form :deep(.el-select__wrapper.is-focused) {
  box-shadow: inset 0 0 0 1px var(--cr-primary), var(--cr-ring);
}

.primary-action {
  min-height: 56px;
  padding: 0 20px 0 24px;
  border-radius: 12px;
  font-size: 16px;
  line-height: 1;
  box-shadow: 0 12px 26px rgba(36, 84, 214, 0.24);
}

.primary-action .el-icon {
  font-size: 18px;
}

.primary-action:hover:not(:disabled) {
  background: linear-gradient(135deg, var(--cr-primary-strong), var(--cr-accent));
  box-shadow: 0 16px 30px rgba(36, 84, 214, 0.28);
}

/* Material 3 inspired identity switch */
.role-switcher {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  align-items: stretch;
  gap: 4px;
  margin-bottom: 26px;
  padding: 4px;
  overflow: hidden;
  border: 1px solid rgba(36, 84, 214, 0.14);
  border-radius: 999px;
  background:
    linear-gradient(180deg, rgba(255, 255, 255, 0.92), rgba(239, 246, 255, 0.92)),
    rgba(232, 240, 253, 0.86);
  box-shadow:
    inset 0 1px 0 rgba(255, 255, 255, 0.86),
    inset 0 -1px 0 rgba(36, 84, 214, 0.08),
    0 10px 24px rgba(16, 24, 39, 0.07);
}

.role-chip {
  position: relative;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  min-width: 0;
  min-height: clamp(48px, 2.55vw, 56px);
  height: 100%;
  padding: 0 14px;
  overflow: hidden;
  color: #58677f;
  background: transparent;
  border: 1px solid transparent;
  border-radius: 999px;
  box-shadow: none;
  cursor: pointer;
  font-size: clamp(13px, 0.72vw, 15px);
  font-weight: 900;
  line-height: 1;
  white-space: nowrap;
  transition:
    background 0.2s ease,
    border-color 0.2s ease,
    box-shadow 0.2s ease,
    color 0.2s ease,
    transform 0.2s ease;

  svg {
    flex: 0 0 auto;
    width: 22px;
    height: 22px;
    padding: 3px;
    border-radius: 999px;
    background: rgba(36, 84, 214, 0.08);
    color: currentColor;
    box-sizing: border-box;
    transition: background 0.2s ease, transform 0.2s ease;
  }

  span {
    display: inline-block;
    min-width: 0;
    line-height: 1;
    transform: translateY(0.5px);
  }
}

.role-chip:hover {
  color: var(--cr-text);
  background: rgba(255, 255, 255, 0.72);
  border-color: rgba(36, 84, 214, 0.12);
  transform: translateY(0);
}

.role-chip.active {
  color: #ffffff;
  background:
    linear-gradient(180deg, rgba(255, 255, 255, 0.18), transparent 42%),
    linear-gradient(135deg, var(--cr-primary), var(--cr-accent));
  border-color: rgba(255, 255, 255, 0.36);
  box-shadow:
    inset 0 1px 0 rgba(255, 255, 255, 0.28),
    inset 0 -1px 0 rgba(7, 89, 133, 0.48),
    0 8px 18px rgba(36, 84, 214, 0.22);
}

.role-chip.active svg {
  background: rgba(255, 255, 255, 0.22);
  transform: scale(1.04);
}

.role-chip:active {
  transform: scale(0.985);
}

.role-chip:focus-visible {
  outline: none;
  box-shadow:
    0 0 0 2px #ffffff,
    0 0 0 5px rgba(36, 84, 214, 0.28);
}

@media (max-width: 640px) {
  .role-switcher {
    grid-template-columns: 1fr;
    gap: 6px;
    padding: 6px;
    border-radius: 18px;
  }

  .role-chip {
    min-height: 46px;
    justify-content: center;
  }
}

@media (prefers-reduced-motion: reduce) {
  .role-chip,
  .role-chip svg {
    transition: none;
  }
}
</style>

