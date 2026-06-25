<template>
  <AdminBase title="管理后台" :menus="menus" />
</template>
<script setup>
import AdminBase from './AdminBase.vue'
import { DataAnalysis, User, OfficeBuilding, Briefcase, Menu, Collection, Document, Picture, ChatRound, Calendar, ChatDotRound, Service, Memo, Lock, Tickets } from '@element-plus/icons-vue'
const menus = [
  { path: '/admin/dashboard', title: '数据统计', icon: DataAnalysis },
  { path: '/admin/student', title: '学生管理', icon: User },
  { path: '/admin/enterprise', title: '企业管理', icon: OfficeBuilding },
  { path: '/admin/job', title: '岗位审核', icon: Briefcase },
  { path: '/admin/category', title: '岗位类别', icon: Menu },
  { path: '/admin/dict', title: '字典管理', icon: Collection },
  { path: '/admin/announcement', title: '公告资讯', icon: Document },
  { path: '/admin/banner', title: '轮播图', icon: Picture },
  { path: '/admin/talk', title: '宣讲会', icon: ChatRound },
  { path: '/admin/fair', title: '招聘会', icon: Calendar },
  { path: '/admin/forum', title: '论坛管理', icon: ChatDotRound },
  { path: '/admin/feedback', title: '留言反馈', icon: Service },
  { path: '/admin/seeker-post', title: '求职信息管理', icon: Tickets },
  { path: '/admin/log', title: '系统日志', icon: Memo },
  { path: '/admin/password', title: '修改密码', icon: Lock }
]
</script>
