<template>
  <AdminBase title="管理后台" :menus="menus" />
</template>
<script setup>
import AdminBase from './AdminBase.vue'
import {
  Bell,
  Calendar,
  ChatDotRound,
  DataLine,
  DocumentChecked,
  Grid,
  Headset,
  Histogram,
  Key,
  Microphone,
  Notebook,
  OfficeBuilding,
  SuitcaseLine,
  UserFilled
} from '@element-plus/icons-vue'

const menus = [
  { path: '/admin/dashboard', title: '数据统计', icon: Histogram },
  { path: '/admin/student', title: '学生管理', icon: UserFilled },
  { path: '/admin/enterprise', title: '企业管理', icon: OfficeBuilding },
  { path: '/admin/job', title: '岗位审核', icon: DocumentChecked },
  { path: '/admin/category', title: '岗位类别', icon: Grid },
  { path: '/admin/dict', title: '字典管理', icon: Notebook },
  { path: '/admin/announcement', title: '公告资讯', icon: Bell },
  { path: '/admin/talk', title: '宣讲会', icon: Microphone },
  { path: '/admin/fair', title: '招聘会', icon: Calendar },
  { path: '/admin/forum', title: '论坛管理', icon: ChatDotRound },
  { path: '/admin/feedback', title: '留言反馈', icon: Headset },
  { path: '/admin/seeker-post', title: '求职信息管理', icon: SuitcaseLine },
  { path: '/admin/log', title: '系统日志', icon: DataLine },
  { path: '/admin/password', title: '修改密码', icon: Key }
]
</script>
