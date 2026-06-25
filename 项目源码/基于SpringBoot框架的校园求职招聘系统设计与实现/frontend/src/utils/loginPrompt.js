import { h } from 'vue'
import { ElNotification } from 'element-plus'

export const showLoginPrompt = (message = '请先登录后再使用该功能') => {
  let notice
  const goLogin = () => {
    notice?.close()
    window.location.href = '/login'
  }

  notice = ElNotification({
    title: '请先登录',
    message: h('div', { class: 'login-required-content' }, [
      h('div', { class: 'login-required-text' }, message),
      h('button', { class: 'login-required-action', type: 'button', onClick: goLogin }, '去登录')
    ]),
    type: 'warning',
    duration: 6000,
    showClose: true,
    customClass: 'login-required-notice',
    position: 'top-right'
  })
}
