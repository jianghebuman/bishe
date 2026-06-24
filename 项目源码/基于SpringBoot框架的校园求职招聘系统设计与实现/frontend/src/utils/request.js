import axios from 'axios'
import { ElMessage } from 'element-plus'
import router from '@/router'
import { useUserStore } from '@/store/user'

// 创建 axios 实例，baseURL 指向后端 context-path
const request = axios.create({
  baseURL: '/api',
  timeout: 15000
})

// 请求拦截：携带 token
request.interceptors.request.use(
  (config) => {
    const userStore = useUserStore()
    if (userStore.token) {
      config.headers['Authorization'] = 'Bearer ' + userStore.token
    }
    return config
  },
  (error) => Promise.reject(error)
)

// 响应拦截：统一处理 Result
request.interceptors.response.use(
  (response) => {
    const res = response.data
    // 文件流（导出）直接返回
    if (response.config.responseType === 'blob') {
      return response
    }
    if (res.code === 200) {
      return res
    }
    // 401 未登录 / 403 无权限
    if (res.code === 401) {
      ElMessage.error(res.message || '登录已过期')
      const userStore = useUserStore()
      userStore.logout()
      router.push('/login')
      return Promise.reject(res)
    }
    ElMessage.error(res.message || '请求失败')
    return Promise.reject(res)
  },
  (error) => {
    if (error.response && error.response.status === 401) {
      const userStore = useUserStore()
      userStore.logout()
      router.push('/login')
    }
    ElMessage.error(error.message || '网络异常')
    return Promise.reject(error)
  }
)

export default request
