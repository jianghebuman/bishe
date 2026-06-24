<template>
  <div class="page-container"><div class="page-card"><div class="header"><div><h2>{{ title }}</h2><p>{{ desc }}</p></div><slot name="actions"><el-button v-if="showAdd" type="primary" @click="open()">新增</el-button></slot></div><el-divider/>
    <div class="toolbar"><slot name="toolbar"></slot></div>
    <el-table :data="list" stripe v-loading="loading"><slot name="columns"></slot><el-table-column v-if="$slots.rowActions" label="操作" :width="actionWidth" fixed="right"><template #default="scope"><slot name="rowActions" v-bind="scope"></slot></template></el-table-column></el-table>
    <div class="pagination-wrap"><el-pagination v-model:current-page="query.pageNum" v-model:page-size="query.pageSize" :total="total" background layout="total,prev,pager,next" @current-change="load"/></div>
    <slot name="dialogs"></slot>
  </div></div>
</template>
<script setup>defineProps({title:String,desc:String,list:Array,total:Number,loading:Boolean,query:Object,showAdd:{type:Boolean,default:true},actionWidth:{type:Number,default:220}});const emit=defineEmits(['load','open']);const load=()=>emit('load');const open=()=>emit('open')</script>
<style scoped>.header{display:flex;justify-content:space-between;align-items:center}.header h2{margin-bottom:6px}.header p{color:#909399}.toolbar{margin-bottom:16px}</style>
