<template>
  <div class="page-container">
    <div class="chat-shell page-card">
      <aside class="conversation-list">
        <div class="chat-head">
          <h2>在线沟通</h2>
          <el-button text type="primary" @click="loadConversations">刷新</el-button>
        </div>
        <div class="conv" v-for="item in conversations" :key="`${item.peerRole}:${item.peerId}`" :class="{active: activeKey===`${item.peerRole}:${item.peerId}`}" @click="select(item)">
          <div>
            <h3>{{ item.peerName || fallbackPeerName(item.peerRole, item.peerId) }}</h3>
            <p>{{ item.lastMessage?.content || '' }}</p>
          </div>
          <el-badge v-if="item.unread" :value="item.unread" />
        </div>
        <el-empty v-if="conversations.length===0" description="暂无会话" />
      </aside>
      <section class="chat-main">
        <template v-if="peer.peerId">
          <div class="chat-title">
            <h3>{{ peerLabel }}</h3>
            <span>{{ peer.peerRole === 'STUDENT' ? '求职者' : 'HR/企业' }}</span>
          </div>
          <div ref="messageBox" class="messages">
            <div v-for="m in messages" :key="m.id || `${m.createTime}-${m.content}`" class="msg" :class="{mine:m.fromRole===userStore.role && Number(m.fromUserId)===Number(userStore.userId)}">
              <div class="bubble">
                <p>{{ m.content }}</p>
                <span>{{ m.createTime || '' }}</span>
              </div>
            </div>
          </div>
          <div class="composer">
            <el-input v-model="content" type="textarea" :rows="3" maxlength="1000" show-word-limit placeholder="输入消息" @keydown.ctrl.enter.prevent="send" />
            <el-button type="primary" :loading="sending" @click="send">发送</el-button>
          </div>
        </template>
        <el-empty v-else description="请选择或发起一个会话" />
      </section>
    </div>
  </div>
</template>

<script setup>
import { nextTick, onBeforeUnmount, onMounted, reactive, ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { chatApi } from '@/api'
import { useUserStore } from '@/store/user'

const route = useRoute()
const userStore = useUserStore()
const conversations = ref([])
const messages = ref([])
const content = ref('')
const sending = ref(false)
const messageBox = ref(null)
const peer = reactive({ peerRole: '', peerId: '', peerName: '', seekerPostId: '', jobId: '' })
const activeKey = computed(() => peer.peerId ? `${peer.peerRole}:${peer.peerId}` : '')
const fallbackPeerName = (role, id) => role === 'STUDENT' ? `学生 ${id}` : `企业 ${id}`
const peerLabel = computed(() => peer.peerName || fallbackPeerName(peer.peerRole, peer.peerId))
let ws
const syncChatUnread = () => {
  const total = conversations.value.reduce((sum, item) => sum + Number(item.unread || 0), 0)
  userStore.setUnreadCounts(userStore.unreadNoticeCount, total)
}
const clearPeerUnread = () => {
  const found = conversations.value.find(i => i.peerRole === peer.peerRole && Number(i.peerId) === Number(peer.peerId))
  if (found) {
    found.unread = 0
    syncChatUnread()
  }
}

const wsUrl = () => {
  const protocol = location.protocol === 'https:' ? 'wss:' : 'ws:'
  return `${protocol}//${location.host}/api/ws/chat?token=${encodeURIComponent(userStore.token)}`
}
const connect = () => {
  if (!userStore.token || ws) return
  ws = new WebSocket(wsUrl())
  ws.onmessage = async (event) => {
    const msg = JSON.parse(event.data)
    const hit = peer.peerId && ((msg.fromRole === peer.peerRole && Number(msg.fromUserId) === Number(peer.peerId)) || (msg.toRole === peer.peerRole && Number(msg.toUserId) === Number(peer.peerId)))
    if (hit) { messages.value.push(msg); scrollBottom(); await chatApi.read(peer.peerRole, peer.peerId) }
    loadConversations()
  }
  ws.onclose = () => { ws = null }
}
const loadConversations = async () => {
  const res = await chatApi.conversations()
  conversations.value = res.data || []
  if (peer.peerId) {
    const found = conversations.value.find(i => i.peerRole === peer.peerRole && Number(i.peerId) === Number(peer.peerId))
    if (found?.peerName) peer.peerName = found.peerName
    else {
      if (!peer.peerName) peer.peerName = fallbackPeerName(peer.peerRole, peer.peerId)
      conversations.value.unshift({ peerRole: peer.peerRole, peerId: peer.peerId, peerName: peer.peerName, lastMessage: null, unread: 0 })
    }
  }
  syncChatUnread()
}
const loadMessages = async () => {
  if (!peer.peerId) return
  const res = await chatApi.messages({ peerRole: peer.peerRole, peerId: peer.peerId })
  messages.value = res.data || []
  await chatApi.read(peer.peerRole, peer.peerId)
  clearPeerUnread()
  scrollBottom()
}
const loadPeerName = async () => {
  if (!peer.peerId || peer.peerName) return
  try {
    const res = await chatApi.peerName({ peerRole: peer.peerRole, peerId: peer.peerId })
    peer.peerName = res.data || fallbackPeerName(peer.peerRole, peer.peerId)
  } catch (e) {
    peer.peerName = fallbackPeerName(peer.peerRole, peer.peerId)
  }
}
const select = async (item) => {
  Object.assign(peer, { peerRole: item.peerRole, peerId: item.peerId, peerName: item.peerName || fallbackPeerName(item.peerRole, item.peerId), seekerPostId: '', jobId: '' })
  await loadMessages()
  await loadConversations()
}
const applyRoutePeer = () => {
  if (route.query.peerRole && route.query.peerId) {
    Object.assign(peer, {
      peerRole: String(route.query.peerRole),
      peerId: String(route.query.peerId),
      peerName: route.query.peerName ? String(route.query.peerName) : '',
      seekerPostId: route.query.seekerPostId || '',
      jobId: route.query.jobId || ''
    })
  }
}
const send = async () => {
  if (!peer.peerId) return
  if (!content.value.trim()) { ElMessage.warning('请输入消息内容'); return }
  sending.value = true
  try {
    const payload = { toRole: peer.peerRole, toUserId: Number(peer.peerId), content: content.value.trim(), seekerPostId: peer.seekerPostId || null, jobId: peer.jobId || null }
    if (ws && ws.readyState === WebSocket.OPEN) ws.send(JSON.stringify(payload))
    else {
      const res = await chatApi.send(payload)
      messages.value.push(res.data)
    }
    content.value = ''
    scrollBottom()
    await loadConversations()
  } finally { sending.value = false }
}
const scrollBottom = () => nextTick(() => { if (messageBox.value) messageBox.value.scrollTop = messageBox.value.scrollHeight })

onMounted(async () => {
  applyRoutePeer()
  connect()
  await loadPeerName()
  await loadConversations()
  await loadMessages()
})
onBeforeUnmount(() => { if (ws) ws.close() })
</script>

<style scoped lang="scss">
.chat-shell { height:calc(100dvh - 10rem); min-height:32rem; display:grid; grid-template-columns:18rem minmax(0,1fr); padding:0; overflow:hidden; }
.conversation-list { border-right:1px solid var(--cr-border-soft); overflow:auto; background:var(--cr-surface-soft); }
.chat-head { display:flex; align-items:center; justify-content:space-between; padding:1rem; border-bottom:1px solid var(--cr-border-soft); h2{font-size:1.125rem;} }
.conv { display:flex; justify-content:space-between; gap:.75rem; padding:.875rem 1rem; cursor:pointer; border-bottom:1px solid var(--cr-border-soft);
  h3{font-size:.9375rem;margin-bottom:.25rem;color:var(--cr-text);} p{color:var(--cr-text-muted);font-size:.8125rem;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:12rem;}
  &.active,&:hover{background:#fff;}
}
.chat-main { min-width:0; display:flex; flex-direction:column; background:#fff; }
.chat-title { padding:1rem; border-bottom:1px solid var(--cr-border-soft); h3{font-size:1rem;margin-bottom:.25rem;} span{font-size:.8125rem;color:var(--cr-text-muted);} }
.messages { flex:1; overflow:auto; padding:1rem; background:linear-gradient(180deg,#fff,var(--cr-surface-soft)); }
.msg { display:flex; margin-bottom:.75rem; .bubble{max-width:min(70%,36rem); background:#fff; border:1px solid var(--cr-border-soft); border-radius:.5rem; padding:.625rem .75rem; box-shadow:var(--cr-shadow-soft);} p{line-height:1.6;white-space:pre-wrap;} span{display:block;margin-top:.375rem;color:var(--cr-text-muted);font-size:.75rem;} }
.msg.mine { justify-content:flex-end; .bubble{background:var(--cr-primary-soft); border-color:#d5e3ff;} }
.composer { border-top:1px solid var(--cr-border-soft); padding:1rem; display:flex; gap:.75rem; align-items:flex-end; }
.composer :deep(.el-textarea){flex:1;}
@media (max-width:56rem){.chat-shell{height:auto;grid-template-columns:1fr}.conversation-list{max-height:16rem;border-right:0;border-bottom:1px solid var(--cr-border-soft)}.chat-main{min-height:28rem}.composer{flex-direction:column}.composer :deep(.el-button){width:100%;}.msg .bubble{max-width:86%;}}
</style>
