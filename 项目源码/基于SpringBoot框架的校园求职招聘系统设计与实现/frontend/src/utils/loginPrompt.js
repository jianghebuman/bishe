import { h } from 'vue'
import { ElNotification } from 'element-plus'

const showPortalPrompt = ({ title, message, type = 'info', actionText, onAction }) => {
  let notice
  const children = [
    h('div', { class: 'login-required-kicker' }, type === 'success' ? '操作已完成' : '需要登录'),
    h('div', { class: 'login-required-text' }, message)
  ]
  if (actionText) {
    children.push(h('button', {
      class: 'login-required-action',
      type: 'button',
      onClick: () => {
        notice?.close()
        onAction?.()
      }
    }, actionText))
  }

  notice = ElNotification({
    title,
    message: h('div', { class: 'login-required-content' }, children),
    type,
    duration: 6000,
    showClose: true,
    customClass: `portal-notice login-required-notice is-${type} cr-border-beam-surface`,
    position: 'top-right'
  })
}

export const showLoginPrompt = (message = '请先登录后再使用该功能') => {
  showPortalPrompt({
    title: '请先登录',
    message,
    type: 'warning',
    actionText: '去登录',
    onAction: () => {
      window.location.href = '/login'
    }
  })
}

export const showSignupSuccessPrompt = (message = '报名成功，请准时参加') => {
  showPortalPrompt({
    title: '报名成功',
    message,
    type: 'success'
  })
}
