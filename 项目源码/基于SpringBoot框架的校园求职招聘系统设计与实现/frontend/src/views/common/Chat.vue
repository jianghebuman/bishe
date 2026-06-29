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
            <p>{{ previewText(item.lastMessage?.content) }}</p>
          </div>
          <el-badge v-if="item.unread" :value="item.unread" />
        </div>
        <el-empty v-if="conversations.length===0" description="暂无会话" />
      </aside>
      <section class="chat-main">
        <template v-if="peer.peerId">
          <div class="chat-title">
            <div>
              <h3>{{ peerLabel }}</h3>
              <span>{{ peer.peerRole === 'STUDENT' ? '求职者' : 'HR/企业' }}</span>
            </div>
            <div class="chat-actions">
              <el-dropdown v-if="userStore.role === 'STUDENT' && peer.peerRole === 'ENTERPRISE'" trigger="click" @visible-change="loadStudentResumeResources" @command="sendResumeCommand">
                <el-button type="primary" plain :icon="Document">
                  发送简历<el-icon class="el-icon--right"><ArrowDown /></el-icon>
                </el-button>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item command="online">在线简历完整版</el-dropdown-item>
                    <el-dropdown-item v-for="file in myAttachments" :key="file.id" :command="`attachment:${file.id}`">附件：{{ file.fileName }}</el-dropdown-item>
                    <el-dropdown-item v-if="myAttachments.length === 0" disabled>暂无附件简历</el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
              <el-button v-if="userStore.role === 'ENTERPRISE' && peer.peerRole === 'STUDENT'" :icon="View" @click="sendResumeRequest">请求查看简历</el-button>
            </div>
          </div>
          <div ref="messageBox" class="messages">
            <div v-for="m in messages" :key="m.id || `${m.createTime}-${m.content}`" class="msg" :class="{mine:m.fromRole===userStore.role && Number(m.fromUserId)===Number(userStore.userId)}">
              <div class="bubble">
                <template v-if="isResumeCard(m.content)">
                  <div class="resume-card-msg">
                    <el-icon><Document /></el-icon>
                    <div class="resume-card-body">
                      <b>{{ cardMeta(m.content).title }}</b>
                      <p>{{ cardMeta(m.content).text }}</p>
                      <div class="resume-card-actions">
                        <el-button v-if="cardMeta(m.content).url" size="small" type="primary" @click="openCard(cardMeta(m.content))">{{ cardMeta(m.content).button || '查看' }}</el-button>
                        <el-button v-if="canRespondResumeRequest(m)" size="small" type="primary" plain @click="sendOnlineResume">发送在线简历</el-button>
                      </div>
                    </div>
                  </div>
                </template>
                <p v-else>{{ m.content }}</p>
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
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowDown, Document, View } from '@element-plus/icons-vue'
import { chatApi, studentApi } from '@/api'
import { useUserStore } from '@/store/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const conversations = ref([])
const messages = ref([])
const content = ref('')
const sending = ref(false)
const messageBox = ref(null)
const peer = reactive({ peerRole: '', peerId: '', peerName: '', seekerPostId: '', jobId: '' })
const mySeekerPost = ref(null)
const myAttachments = ref([])
const autoActionDone = ref(false)
const activeKey = computed(() => peer.peerId ? `${peer.peerRole}:${peer.peerId}` : '')
const fallbackPeerName = (role, id) => role === 'STUDENT' ? `学生 ${id}` : `企业 ${id}`
const peerLabel = computed(() => peer.peerName || fallbackPeerName(peer.peerRole, peer.peerId))
let ws
const CARD_PREFIX = '[resume-card]'
const makeCardContent = (card) => CARD_PREFIX + JSON.stringify(card)
const cardMeta = (content) => {
  if (!String(content || '').startsWith(CARD_PREFIX)) return {}
  try { return JSON.parse(String(content).slice(CARD_PREFIX.length)) } catch (e) { return {} }
}
const isResumeCard = (content) => !!cardMeta(content).type
const previewText = (content) => {
  const card = cardMeta(content)
  if (card.type === 'RESUME_REQUEST') return '请求查看简历'
  if (card.type === 'ONLINE_RESUME') return '已发送在线简历'
  if (card.type === 'ATTACHMENT_RESUME') return '已发送附件简历'
  return content || ''
}
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
  if (!peer.seekerPostId) {
    const linked = [...messages.value].reverse().find(item => item.seekerPostId)
    if (linked) peer.seekerPostId = linked.seekerPostId
  }
  await chatApi.read(peer.peerRole, peer.peerId)
  clearPeerUnread()
  scrollBottom()
}
const loadStudentResumeResources = async () => {
  if (userStore.role !== 'STUDENT') return
  const [postRes, attachRes] = await Promise.all([studentApi.seekerPost(), studentApi.attachments()])
  mySeekerPost.value = postRes.data
  myAttachments.value = attachRes.data || []
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
const sendPayload = async (payload) => {
  if (ws && ws.readyState === WebSocket.OPEN) ws.send(JSON.stringify(payload))
  else {
    const res = await chatApi.send(payload)
    messages.value.push(res.data)
  }
  scrollBottom()
  await loadConversations()
}
const send = async () => {
  if (!peer.peerId) return
  if (!content.value.trim()) { ElMessage.warning('请输入消息内容'); return }
  sending.value = true
  try {
    const payload = { toRole: peer.peerRole, toUserId: Number(peer.peerId), content: content.value.trim(), seekerPostId: peer.seekerPostId || null, jobId: peer.jobId || null }
    await sendPayload(payload)
    content.value = ''
  } finally { sending.value = false }
}
const sendResumeRequest = async () => {
  if (!peer.peerId) return
  sending.value = true
  try {
    await sendPayload({
      toRole: peer.peerRole,
      toUserId: Number(peer.peerId),
      seekerPostId: peer.seekerPostId || null,
      jobId: peer.jobId || null,
      content: makeCardContent({ type: 'RESUME_REQUEST', title: '请求查看简历', text: 'HR 请求查看你的在线简历或附件简历。' })
    })
    ElMessage.success('已发送查看简历请求')
  } finally { sending.value = false }
}
const sendOnlineResume = async () => {
  await loadStudentResumeResources()
  const post = mySeekerPost.value
  if (!post?.id || Number(post.status) !== 1) {
    ElMessage.warning('请先在求职栏发布展示中的求职信息')
    return
  }
  sending.value = true
  try {
    peer.seekerPostId = post.id
    await sendPayload({
      toRole: peer.peerRole,
      toUserId: Number(peer.peerId),
      seekerPostId: post.id,
      jobId: peer.jobId || null,
      content: makeCardContent({ type: 'ONLINE_RESUME', title: post.title || '在线简历完整版', text: '已发送在线简历完整版，点击即可查看。', url: `/seeker/${post.id}`, button: '查看完整版' })
    })
    ElMessage.success('已发送在线简历')
  } finally { sending.value = false }
}
const sendAttachmentResume = async (id) => {
  await loadStudentResumeResources()
  const file = myAttachments.value.find(item => Number(item.id) === Number(id))
  if (!file) { ElMessage.warning('附件简历不存在'); return }
  sending.value = true
  try {
    await sendPayload({
      toRole: peer.peerRole,
      toUserId: Number(peer.peerId),
      seekerPostId: peer.seekerPostId || mySeekerPost.value?.id || null,
      jobId: peer.jobId || null,
      content: makeCardContent({ type: 'ATTACHMENT_RESUME', title: file.fileName || '附件简历', text: '已发送附件简历，点击即可预览或下载。', url: file.fileUrl, button: '预览/下载' })
    })
    ElMessage.success('已发送附件简历')
  } finally { sending.value = false }
}
const sendResumeCommand = (command) => {
  if (command === 'online') sendOnlineResume()
  else if (String(command).startsWith('attachment:')) sendAttachmentResume(String(command).split(':')[1])
}
const canRespondResumeRequest = (message) => userStore.role === 'STUDENT'
  && message.toRole === 'STUDENT'
  && Number(message.toUserId) === Number(userStore.userId)
  && cardMeta(message.content).type === 'RESUME_REQUEST'
const openCard = (card) => {
  if (!card.url) return
  window.open(card.url, '_blank')
}
const runRouteAction = async () => {
  if (autoActionDone.value || route.query.action !== 'requestResume' || userStore.role !== 'ENTERPRISE' || !peer.peerId) return
  autoActionDone.value = true
  await sendResumeRequest()
  const query = { ...route.query }
  delete query.action
  router.replace({ path: route.path, query })
}
const scrollBottom = () => nextTick(() => { if (messageBox.value) messageBox.value.scrollTop = messageBox.value.scrollHeight })

onMounted(async () => {
  applyRoutePeer()
  connect()
  await loadPeerName()
  await loadConversations()
  await loadMessages()
  await loadStudentResumeResources()
  await runRouteAction()
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
.chat-title { padding:1rem; border-bottom:1px solid var(--cr-border-soft); display:flex; align-items:center; justify-content:space-between; gap:1rem; h3{font-size:1rem;margin-bottom:.25rem;} span{font-size:.8125rem;color:var(--cr-text-muted);} }
.chat-actions { display:flex; align-items:center; gap:.5rem; flex-wrap:wrap; justify-content:flex-end; }
.messages { flex:1; overflow:auto; padding:1rem; background:linear-gradient(180deg,#fff,var(--cr-surface-soft)); }
.msg { display:flex; margin-bottom:.75rem; .bubble{max-width:min(70%,36rem); background:#fff; border:1px solid var(--cr-border-soft); border-radius:.5rem; padding:.625rem .75rem; box-shadow:var(--cr-shadow-soft);} p{line-height:1.6;white-space:pre-wrap;} span{display:block;margin-top:.375rem;color:var(--cr-text-muted);font-size:.75rem;} }
.msg.mine { justify-content:flex-end; .bubble{background:var(--cr-primary-soft); border-color:#d5e3ff;} }
.resume-card-msg { display:flex; gap:.625rem; align-items:flex-start; min-width:min(20rem,100%); }
.resume-card-msg :deep(.el-icon) { color:var(--cr-primary); font-size:1.25rem; margin-top:.125rem; }
.resume-card-body { min-width:0; b{display:block;margin-bottom:.25rem;color:var(--cr-text);} p{color:var(--cr-text-soft);white-space:normal;} }
.resume-card-actions { display:flex; flex-wrap:wrap; gap:.5rem; margin-top:.625rem; }
.composer { border-top:1px solid var(--cr-border-soft); padding:1rem; display:flex; gap:.75rem; align-items:flex-end; }
.composer :deep(.el-textarea){flex:1;}
@media (max-width:56rem){.chat-shell{height:auto;grid-template-columns:1fr}.conversation-list{max-height:16rem;border-right:0;border-bottom:1px solid var(--cr-border-soft)}.chat-main{min-height:28rem}.chat-title{align-items:flex-start;flex-direction:column}.chat-actions{justify-content:flex-start}.composer{flex-direction:column}.composer :deep(.el-button){width:100%;}.msg .bubble{max-width:86%;}}
</style>
