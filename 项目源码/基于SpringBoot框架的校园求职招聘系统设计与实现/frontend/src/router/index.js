import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/store/user'
import { ElMessage } from 'element-plus'

const routes = [
  // 前台门户（公共）
  {
    path: '/',
    component: () => import('@/layout/PortalLayout.vue'),
    children: [
      { path: '', name: 'Home', component: () => import('@/views/portal/Home.vue'), meta: { title: '首页' } },
      { path: 'jobs', name: 'JobList', component: () => import('@/views/portal/JobList.vue'), meta: { title: '职位搜索' } },
      { path: 'job/:id', name: 'JobDetail', component: () => import('@/views/portal/JobDetail.vue'), meta: { title: '职位详情' } },
      { path: 'enterprises', name: 'EnterpriseList', component: () => import('@/views/portal/EnterpriseList.vue'), meta: { title: '名企推荐' } },
      { path: 'enterprise/:id', name: 'EnterpriseDetail', component: () => import('@/views/portal/EnterpriseDetail.vue'), meta: { title: '企业详情' } },
      { path: 'talks', name: 'TalkList', component: () => import('@/views/portal/TalkList.vue'), meta: { title: '宣讲会' } },
      { path: 'fairs', name: 'FairList', component: () => import('@/views/portal/FairList.vue'), meta: { title: '招聘会' } },
      { path: 'news', name: 'NewsList', component: () => import('@/views/portal/NewsList.vue'), meta: { title: '就业资讯' } },
      { path: 'news/:id', name: 'NewsDetail', component: () => import('@/views/portal/NewsDetail.vue'), meta: { title: '资讯详情' } },
      { path: 'forum', name: 'Forum', component: () => import('@/views/portal/Forum.vue'), meta: { title: '求职社区' } },
      { path: 'forum/:id', name: 'ForumDetail', component: () => import('@/views/portal/ForumDetail.vue'), meta: { title: '帖子详情' } }
    ]
  },
  // 登录 / 注册
  { path: '/login', name: 'Login', component: () => import('@/views/Login.vue'), meta: { title: '登录' } },
  { path: '/register', name: 'Register', component: () => import('@/views/Register.vue'), meta: { title: '注册' } },

  // 学生中心
  {
    path: '/student',
    component: () => import('@/layout/StudentLayout.vue'),
    meta: { requiresAuth: true, role: 'STUDENT' },
    children: [
      { path: '', redirect: '/student/dashboard' },
      { path: 'dashboard', component: () => import('@/views/student/Dashboard.vue'), meta: { title: '个人中心' } },
      { path: 'profile', component: () => import('@/views/student/Profile.vue'), meta: { title: '个人信息' } },
      { path: 'intention', component: () => import('@/views/student/Intention.vue'), meta: { title: '求职意向' } },
      { path: 'resume', component: () => import('@/views/student/Resume.vue'), meta: { title: '在线简历' } },
      { path: 'attachment', component: () => import('@/views/student/Attachment.vue'), meta: { title: '附件简历' } },
      { path: 'apply', component: () => import('@/views/student/ApplyRecord.vue'), meta: { title: '投递记录' } },
      { path: 'interview', component: () => import('@/views/student/Interview.vue'), meta: { title: '面试通知' } },
      { path: 'offer', component: () => import('@/views/student/Offer.vue'), meta: { title: 'Offer管理' } },
      { path: 'favorite', component: () => import('@/views/student/Favorite.vue'), meta: { title: '我的收藏' } },
      { path: 'notice', component: () => import('@/views/student/Notice.vue'), meta: { title: '消息中心' } },
      { path: 'myposts', component: () => import('@/views/student/MyPosts.vue'), meta: { title: '我的帖子' } },
      { path: 'password', component: () => import('@/views/common/Password.vue'), meta: { title: '修改密码' } }
    ]
  },

  // 企业中心
  {
    path: '/enterprise',
    component: () => import('@/layout/EnterpriseLayout.vue'),
    meta: { requiresAuth: true, role: 'ENTERPRISE' },
    children: [
      { path: '', redirect: '/enterprise/dashboard' },
      { path: 'dashboard', component: () => import('@/views/enterprise/Dashboard.vue'), meta: { title: '数据看板' } },
      { path: 'profile', component: () => import('@/views/enterprise/Profile.vue'), meta: { title: '企业资料' } },
      { path: 'audit', component: () => import('@/views/enterprise/Audit.vue'), meta: { title: '企业认证' } },
      { path: 'job', component: () => import('@/views/enterprise/JobManage.vue'), meta: { title: '职位管理' } },
      { path: 'apply', component: () => import('@/views/enterprise/ApplyManage.vue'), meta: { title: '简历筛选' } },
      { path: 'interview', component: () => import('@/views/enterprise/InterviewManage.vue'), meta: { title: '面试管理' } },
      { path: 'offer', component: () => import('@/views/enterprise/OfferManage.vue'), meta: { title: 'Offer管理' } },
      { path: 'talent', component: () => import('@/views/enterprise/Talent.vue'), meta: { title: '人才库' } },
      { path: 'notice', component: () => import('@/views/enterprise/Notice.vue'), meta: { title: '消息中心' } },
      { path: 'password', component: () => import('@/views/common/Password.vue'), meta: { title: '修改密码' } }
    ]
  },

  // 管理后台
  {
    path: '/admin',
    component: () => import('@/layout/AdminLayout.vue'),
    meta: { requiresAuth: true, role: 'ADMIN' },
    children: [
      { path: '', redirect: '/admin/dashboard' },
      { path: 'dashboard', component: () => import('@/views/admin/Dashboard.vue'), meta: { title: '数据统计' } },
      { path: 'student', component: () => import('@/views/admin/StudentManage.vue'), meta: { title: '学生管理' } },
      { path: 'enterprise', component: () => import('@/views/admin/EnterpriseManage.vue'), meta: { title: '企业管理' } },
      { path: 'job', component: () => import('@/views/admin/JobAudit.vue'), meta: { title: '岗位审核' } },
      { path: 'category', component: () => import('@/views/admin/Category.vue'), meta: { title: '分类管理' } },
      { path: 'dict', component: () => import('@/views/admin/Dict.vue'), meta: { title: '字典管理' } },
      { path: 'announcement', component: () => import('@/views/admin/Announcement.vue'), meta: { title: '公告资讯' } },
      { path: 'banner', component: () => import('@/views/admin/Banner.vue'), meta: { title: '轮播图' } },
      { path: 'talk', component: () => import('@/views/admin/Talk.vue'), meta: { title: '宣讲会' } },
      { path: 'fair', component: () => import('@/views/admin/Fair.vue'), meta: { title: '招聘会' } },
      { path: 'forum', component: () => import('@/views/admin/ForumManage.vue'), meta: { title: '论坛管理' } },
      { path: 'feedback', component: () => import('@/views/admin/Feedback.vue'), meta: { title: '留言反馈' } },
      { path: 'log', component: () => import('@/views/admin/Log.vue'), meta: { title: '系统日志' } },
      { path: 'password', component: () => import('@/views/common/Password.vue'), meta: { title: '修改密码' } }
    ]
  },

  { path: '/:pathMatch(.*)*', redirect: '/' }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 全局前置守卫：登录与角色校验
router.beforeEach((to, from, next) => {
  document.title = to.meta.title ? to.meta.title + ' - 校园求职招聘系统' : '校园求职招聘系统'
  const userStore = useUserStore()
  if (to.meta.requiresAuth) {
    if (!userStore.isLogin) {
      ElMessage.warning('请先登录')
      next('/login')
      return
    }
    if (to.meta.role && to.meta.role !== userStore.role) {
      ElMessage.error('无权访问该页面')
      next('/')
      return
    }
  }
  next()
})

export default router
