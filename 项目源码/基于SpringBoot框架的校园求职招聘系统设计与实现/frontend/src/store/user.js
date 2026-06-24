import { defineStore } from 'pinia'

// 用户登录状态
export const useUserStore = defineStore('user', {
  state: () => ({
    token: localStorage.getItem('token') || '',
    userId: localStorage.getItem('userId') || '',
    username: localStorage.getItem('username') || '',
    name: localStorage.getItem('name') || '',
    role: localStorage.getItem('role') || '',
    avatar: localStorage.getItem('avatar') || '',
    auditStatus: localStorage.getItem('auditStatus') || ''
  }),
  getters: {
    isLogin: (state) => !!state.token
  },
  actions: {
    setUser(data) {
      this.token = data.token
      this.userId = data.userId
      this.username = data.username
      this.name = data.name
      this.role = data.role
      this.avatar = data.avatar || ''
      this.auditStatus = data.auditStatus != null ? data.auditStatus : ''
      localStorage.setItem('token', data.token)
      localStorage.setItem('userId', data.userId)
      localStorage.setItem('username', data.username)
      localStorage.setItem('name', data.name || '')
      localStorage.setItem('role', data.role)
      localStorage.setItem('avatar', data.avatar || '')
      localStorage.setItem('auditStatus', data.auditStatus != null ? data.auditStatus : '')
    },
    setAvatar(avatar) {
      this.avatar = avatar
      localStorage.setItem('avatar', avatar)
    },
    logout() {
      this.token = ''
      this.userId = ''
      this.username = ''
      this.name = ''
      this.role = ''
      this.avatar = ''
      this.auditStatus = ''
      localStorage.clear()
    }
  }
})
