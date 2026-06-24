import request from '@/utils/request'

// ==================== 认证 ====================
export const authApi = {
  login: (data) => request.post('/auth/login', data),
  registerStudent: (data) => request.post('/auth/register/student', data),
  registerEnterprise: (data) => request.post('/auth/register/enterprise', data),
  logout: () => request.post('/auth/logout'),
  changePassword: (data) => request.post('/account/password', data),
  info: () => request.get('/account/info')
}

// ==================== 公共（无需登录） ====================
export const publicApi = {
  home: () => request.get('/public/home'),
  banners: () => request.get('/public/banners'),
  jobs: (params) => request.get('/public/jobs', { params }),
  jobDetail: (id) => request.get(`/public/jobs/${id}`),
  jobCategories: () => request.get('/public/job-categories'),
  dict: (type) => request.get(`/public/dict/${type}`),
  enterprises: (params) => request.get('/public/enterprises', { params }),
  enterpriseDetail: (id) => request.get(`/public/enterprises/${id}`),
  announcements: (params) => request.get('/public/announcements', { params }),
  announcementDetail: (id) => request.get(`/public/announcements/${id}`),
  talks: (params) => request.get('/public/talks', { params }),
  fairs: (params) => request.get('/public/fairs', { params }),
  forumPosts: (params) => request.get('/public/forum/posts', { params }),
  forumPostDetail: (id) => request.get(`/public/forum/posts/${id}`),
  forumComments: (id) => request.get(`/public/forum/posts/${id}/comments`),
  feedback: (data) => request.post('/public/feedback', data)
}

// ==================== 消息中心（通用） ====================
export const noticeApi = {
  list: (params) => request.get('/notice/list', { params }),
  unread: () => request.get('/notice/unread-count'),
  read: (id) => request.post(`/notice/${id}/read`),
  readAll: () => request.post('/notice/read-all')
}

// ==================== 学生端 ====================
export const studentApi = {
  profile: () => request.get('/student/profile'),
  updateProfile: (data) => request.put('/student/profile', data),
  uploadAvatar: (formData) => request.post('/student/avatar', formData),
  getIntention: () => request.get('/student/intention'),
  saveIntention: (data) => request.post('/student/intention', data),
  // 简历
  getResume: () => request.get('/student/resume'),
  saveResume: (data) => request.post('/student/resume', data),
  listEducation: (resumeId) => request.get('/student/resume/education', { params: { resumeId } }),
  saveEducation: (data) => request.post('/student/resume/education', data),
  delEducation: (id) => request.delete(`/student/resume/education/${id}`),
  listProject: (resumeId) => request.get('/student/resume/project', { params: { resumeId } }),
  saveProject: (data) => request.post('/student/resume/project', data),
  delProject: (id) => request.delete(`/student/resume/project/${id}`),
  listExperience: (resumeId) => request.get('/student/resume/experience', { params: { resumeId } }),
  saveExperience: (data) => request.post('/student/resume/experience', data),
  delExperience: (id) => request.delete(`/student/resume/experience/${id}`),
  // 附件
  attachments: () => request.get('/student/resume/attachment'),
  uploadAttachment: (formData) => request.post('/student/resume/attachment', formData),
  delAttachment: (id) => request.delete(`/student/resume/attachment/${id}`),
  // 收藏
  favorites: (params) => request.get('/student/favorite', { params }),
  addFavorite: (jobId) => request.post(`/student/favorite/${jobId}`),
  delFavorite: (jobId) => request.delete(`/student/favorite/${jobId}`),
  checkFavorite: (jobId) => request.get(`/student/favorite/check/${jobId}`),
  // 投递
  apply: (data) => request.post('/student/apply', data),
  applyList: (params) => request.get('/student/apply', { params }),
  cancelApply: (id) => request.delete(`/student/apply/${id}`),
  // 面试
  interviews: (params) => request.get('/student/interview', { params }),
  confirmInterview: (id, status) => request.put(`/student/interview/${id}/confirm`, null, { params: { status } }),
  // offer
  offers: (params) => request.get('/student/offer', { params }),
  handleOffer: (id, status) => request.put(`/student/offer/${id}/handle`, null, { params: { status } })
}

// ==================== 学生社区 ====================
export const forumApi = {
  publish: (data) => request.post('/forum/posts', data),
  delPost: (id) => request.post(`/forum/posts/${id}/delete`),
  myPosts: (params) => request.get('/forum/my-posts', { params }),
  comment: (postId, data) => request.post(`/forum/posts/${postId}/comments`, data),
  like: (id) => request.post(`/forum/posts/${id}/like`)
}

// ==================== 企业端 ====================
export const enterpriseApi = {
  profile: () => request.get('/enterprise/profile'),
  updateProfile: (data) => request.put('/enterprise/profile', data),
  uploadLogo: (formData) => request.post('/enterprise/logo', formData),
  submitAudit: (data) => request.post('/enterprise/audit', null, { params: data }),
  uploadAuditMaterial: (formData) => request.post('/enterprise/audit/upload', formData),
  auditStatus: () => request.get('/enterprise/audit'),
  dashboard: () => request.get('/enterprise/dashboard'),
  // 职位
  jobList: (params) => request.get('/enterprise/job', { params }),
  jobDetail: (id) => request.get(`/enterprise/job/${id}`),
  saveJob: (data) => request.post('/enterprise/job', data),
  updateJob: (data) => request.put('/enterprise/job', data),
  delJob: (id) => request.delete(`/enterprise/job/${id}`),
  toggleJob: (id, status) => request.put(`/enterprise/job/${id}/status`, null, { params: { status } }),
  refreshJob: (id) => request.put(`/enterprise/job/${id}/refresh`),
  // 收到的简历
  applyList: (params) => request.get('/enterprise/apply', { params }),
  applyDetail: (id) => request.get(`/enterprise/apply/${id}`),
  updateApplyStatus: (id, status, hrRemark) => request.put(`/enterprise/apply/${id}/status`, null, { params: { status, hrRemark } }),
  // 面试
  sendInterview: (data) => request.post('/enterprise/interview', data),
  interviewList: (params) => request.get('/enterprise/interview', { params }),
  updateInterview: (data) => request.put('/enterprise/interview', data),
  feedback: (data) => request.post('/enterprise/interview/feedback', data),
  // offer
  sendOffer: (data) => request.post('/enterprise/offer', data),
  offerList: (params) => request.get('/enterprise/offer', { params }),
  revokeOffer: (id) => request.put(`/enterprise/offer/${id}/revoke`),
  // 人才库
  talentList: (params) => request.get('/enterprise/talent', { params }),
  addTalent: (data) => request.post('/enterprise/talent', data),
  delTalent: (id) => request.delete(`/enterprise/talent/${id}`),
  searchTalent: (params) => request.get('/enterprise/talent/search', { params })
}

// ==================== 管理端 ====================
export const adminApi = {
  statistics: () => request.get('/admin/statistics'),
  // 学生管理
  students: (params) => request.get('/admin/student', { params }),
  saveStudent: (data) => request.post('/admin/student', data),
  updateStudent: (data) => request.put('/admin/student', data),
  toggleStudent: (id, status) => request.put(`/admin/student/${id}/status`, null, { params: { status } }),
  resetStudentPwd: (id) => request.put(`/admin/student/${id}/reset`),
  // 企业管理
  enterprises: (params) => request.get('/admin/enterprise', { params }),
  toggleEnterprise: (id, status) => request.put(`/admin/enterprise/${id}/status`, null, { params: { status } }),
  auditList: (params) => request.get('/admin/enterprise/audit', { params }),
  auditEnterprise: (id, status, remark) => request.put(`/admin/enterprise/audit/${id}`, null, { params: { status, remark } }),
  // 岗位审核
  jobAuditList: (params) => request.get('/admin/job', { params }),
  auditJob: (id, status, remark) => request.put(`/admin/job/${id}/audit`, null, { params: { status, remark } }),
  offlineJob: (id) => request.put(`/admin/job/${id}/offline`),
  // 分类/字典
  categories: () => request.get('/admin/category'),
  saveCategory: (data) => request.post('/admin/category', data),
  delCategory: (id) => request.delete(`/admin/category/${id}`),
  dicts: (params) => request.get('/admin/dict', { params }),
  saveDict: (data) => request.post('/admin/dict', data),
  delDict: (id) => request.delete(`/admin/dict/${id}`),
  // 公告
  announcements: (params) => request.get('/admin/announcement', { params }),
  saveAnnouncement: (data) => request.post('/admin/announcement', data),
  updateAnnouncement: (data) => request.put('/admin/announcement', data),
  delAnnouncement: (id) => request.delete(`/admin/announcement/${id}`),
  // 轮播图
  banners: () => request.get('/admin/banner'),
  saveBanner: (data) => request.post('/admin/banner', data),
  delBanner: (id) => request.delete(`/admin/banner/${id}`),
  // 宣讲会/招聘会
  talks: (params) => request.get('/admin/talk', { params }),
  saveTalk: (data) => request.post('/admin/talk', data),
  delTalk: (id) => request.delete(`/admin/talk/${id}`),
  fairs: (params) => request.get('/admin/fair', { params }),
  saveFair: (data) => request.post('/admin/fair', data),
  delFair: (id) => request.delete(`/admin/fair/${id}`),
  // 论坛
  forumPosts: (params) => request.get('/admin/forum/posts', { params }),
  auditPost: (id, status) => request.put(`/admin/forum/posts/${id}/audit`, null, { params: { status } }),
  delPost: (id) => request.delete(`/admin/forum/posts/${id}`),
  // 反馈
  feedbacks: (params) => request.get('/admin/feedback', { params }),
  replyFeedback: (id, reply) => request.put(`/admin/feedback/${id}/reply`, null, { params: { reply } }),
  // 日志
  logs: (params) => request.get('/admin/log', { params }),
  // 导出
  exportStudents: () => request.get('/admin/export/student', { responseType: 'blob' }),
  exportEnterprises: () => request.get('/admin/export/enterprise', { responseType: 'blob' }),
  exportJobs: () => request.get('/admin/export/job', { responseType: 'blob' }),
  exportApplies: () => request.get('/admin/export/apply', { responseType: 'blob' })
}
