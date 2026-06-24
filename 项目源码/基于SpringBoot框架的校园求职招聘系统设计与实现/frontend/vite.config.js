import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath, URL } from 'node:url'

// Vite 配置
export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  server: {
    port: 8080,
    open: false,
    proxy: {
      // 后端接口代理，前端统一以 /api 开头
      '/api': {
        target: 'http://localhost:8081',
        changeOrigin: true
      },
      // 上传图片访问代理，数据库中保存的 /upload/** 可在开发环境直接显示
      '/upload': {
        target: 'http://localhost:8081/api',
        changeOrigin: true
      }
    }
  }
})
