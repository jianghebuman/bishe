<template>
  <AdminBase title="学生中心" :menus="menus" />
</template>
<script setup>
import AdminBase from './AdminBase.vue'
import { Odometer, User, Aim, Document, Upload, Tickets, ChatLineRound, Medal, Star, Bell, EditPen, Lock } from '@element-plus/icons-vue'
const menus = [
  { path: '/student/dashboard', title: '个人中心', icon: Odometer },
  { path: '/student/profile', title: '个人信息', icon: User },
  { path: '/student/intention', title: '求职意向', icon: Aim },
  { path: '/student/resume', title: '在线简历', icon: Document },
  { path: '/student/attachment', title: '附件简历', icon: Upload },
  { path: '/student/apply', title: '投递记录', icon: Tickets },
  { path: '/student/interview', title: '面试通知', icon: ChatLineRound },
  { path: '/student/offer', title: 'Offer管理', icon: Medal },
  { path: '/student/favorite', title: '我的收藏', icon: Star },
  { path: '/student/notice', title: '消息中心', icon: Bell },
  { path: '/student/myposts', title: '我的帖子', icon: EditPen },
  { path: '/student/password', title: '修改密码', icon: Lock }
]
</script>
