import { ElNotification } from 'element-plus'

export const showLoginPrompt = (message = '请先登录后再使用该功能') => {
  ElNotification({
    title: '请先登录',
    message,
    type: 'warning',
    duration: 6000,
    showClose: true,
    customClass: 'login-required-notice',
    position: 'top-right'
  })
}
