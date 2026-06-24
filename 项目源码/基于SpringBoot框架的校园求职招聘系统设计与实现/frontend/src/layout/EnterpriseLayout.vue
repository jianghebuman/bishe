<template>
  <AdminBase title="企业中心" :menus="menus" />
</template>
<script setup>
import AdminBase from './AdminBase.vue'
import { Odometer, OfficeBuilding, CircleCheck, Briefcase, Tickets, ChatLineRound, Medal, UserFilled, Bell, Lock } from '@element-plus/icons-vue'
const menus = [
  { path: '/enterprise/dashboard', title: '数据看板', icon: Odometer },
  { path: '/enterprise/profile', title: '企业资料', icon: OfficeBuilding },
  { path: '/enterprise/audit', title: '企业认证', icon: CircleCheck },
  { path: '/enterprise/job', title: '职位管理', icon: Briefcase },
  { path: '/enterprise/apply', title: '简历筛选', icon: Tickets },
  { path: '/enterprise/interview', title: '面试管理', icon: ChatLineRound },
  { path: '/enterprise/offer', title: 'Offer管理', icon: Medal },
  { path: '/enterprise/talent', title: '人才库', icon: UserFilled },
  { path: '/enterprise/notice', title: '消息中心', icon: Bell },
  { path: '/enterprise/password', title: '修改密码', icon: Lock }
]
</script>
