<template>
  <div class="page-container admin-table-page"><div class="page-card page-flex-card compact-list-card admin-table-card"><div class="header"><div><h2>{{ title }}</h2><p>{{ desc }}</p></div><slot name="actions"><el-button v-if="showAdd" type="primary" @click="open()">新增</el-button></slot></div><el-divider/>
    <div class="toolbar"><slot name="toolbar"></slot></div>
    <el-table :data="list" stripe v-loading="loading"><slot name="columns"></slot><el-table-column v-if="$slots.rowActions" label="操作" :width="actionWidth" :fixed="actionFixed"><template #default="scope"><slot name="rowActions" v-bind="scope"></slot></template></el-table-column></el-table>
    <div class="pagination-wrap"><el-pagination v-model:current-page="query.pageNum" v-model:page-size="query.pageSize" :total="total" background layout="total,prev,pager,next" @current-change="load"/></div>
    <slot name="dialogs"></slot>
  </div></div>
</template>
<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
defineProps({title:String,desc:String,list:Array,total:Number,loading:Boolean,query:Object,showAdd:{type:Boolean,default:true},actionWidth:{type:Number,default:220}})
const emit=defineEmits(['load','open'])
const windowWidth=ref(window.innerWidth)
const actionFixed=computed(()=>windowWidth.value>=768?'right':false)
const onResize=()=>{windowWidth.value=window.innerWidth}
const load=()=>emit('load')
const open=()=>emit('open')
onMounted(()=>window.addEventListener('resize',onResize))
onBeforeUnmount(()=>window.removeEventListener('resize',onResize))
</script>
<style scoped>
.header {
  position: relative;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 0.875rem;
  flex-wrap: wrap;
  padding: 0.125rem 0 0;
}
.header h2 {
  margin-bottom: 0.375rem;
  color: var(--cr-text);
  font-size: clamp(1.35rem, 1.8vw, 1.625rem);
  font-weight: 850;
  line-height: 1.2;
}
.header p {
  color: var(--cr-text-muted);
  line-height: 1.6;
}
.toolbar {
  padding: 0.875rem;
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.625rem;
  margin-bottom: 1rem;
  border: 0.0625rem solid var(--cr-border-soft);
  border-radius: var(--cr-radius-sm);
  background: rgba(247, 251, 255, 0.78);
}
.toolbar :deep(.el-input),
.toolbar :deep(.el-select) {
  flex: 1 1 clamp(10rem, 28vw, 16rem);
  min-width: min(100%, 10rem);
  width: auto !important;
  max-width: 100%;
}
.header :deep(.el-button),
.toolbar :deep(.el-button) {
  min-width: 5.5rem;
}
.admin-table-card :deep(.el-table) {
  flex: 1;
  min-height: 18rem;
  font-size: 0.9375rem;
}
.admin-table-card :deep(.el-table__inner-wrapper) {
  height: 100%;
}
.admin-table-card :deep(.el-table .cell) {
  line-height: 1.6;
}
@media (max-width: 40rem) {
  .header :deep(.el-button),
  .toolbar :deep(.el-button),
  .toolbar :deep(.el-input),
  .toolbar :deep(.el-select) {
    width: 100%;
  }
}
</style>
