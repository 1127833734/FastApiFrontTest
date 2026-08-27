<!--
  备件知识库 · 业务场景 / 备件合规比对
  结构：页面标题 + 居中查询组件 +（检查后）结果汇总 + 检查项列表 + 导出栏
-->
<template>
  <div class="kb-cc page-container">
    <!-- 页面标题 -->
    <el-text class="page-title">备件合规比对</el-text>

    <!-- 居中查询组件 -->
    <div class="search-box-wrapper">
      <ElForm inline class="centered-search-form">
        <ElFormItem>
          <ElInput
            v-model="searchQuery"
            placeholder="输入零件编号/型号"
            clearable
            style="width: 260px"
            @keyup.enter="handleComplianceCheck"
          />
        </ElFormItem>
        <ElFormItem>
          <ElSelect v-model="standardFilter" style="width: 140px">
            <ElOption v-for="opt in standards" :key="opt.value" :label="opt.label" :value="opt.value" />
          </ElSelect>
        </ElFormItem>
        <ElFormItem>
          <ElButton type="success" :icon="Search" @click="handleComplianceCheck">合规检查</ElButton>
        </ElFormItem>
      </ElForm>
    </div>

    <!-- 检查结果（成功后方显示） -->
    <template v-if="checked">
      <!-- 总体结果汇总 -->
      <div class="result-summary">
        <ElIcon color="#67C23A" :size="24"><CircleCheck /></ElIcon>
        <div class="result-summary-text">
          <ElText size="large" class="result-title">合规检查结果：通过</ElText>
          <ElText type="info">零件编号 P101-001 · 供货型号 6208-2RS-SKF · 供应商 SKF</ElText>
        </div>
      </div>

      <!-- 合规检查项列表 -->
      <el-space direction="vertical" fill style="width: 100%">
        <el-card v-for="item in checkItems" :key="item.title" shadow="never" class="check-item-card" :class="{ 'warning-bg': item.level === 'warning' }">
          <div class="check-item-head">
            <div class="check-item-title">
              <ElIcon :size="18" :color="item.level === 'pass' ? '#67C23A' : '#E6A23C'">
                <CircleCheck v-if="item.level === 'pass'" />
                <WarningFilled v-else />
              </ElIcon>
              <span>{{ item.title }}</span>
            </div>
            <ElTag :type="item.level === 'pass' ? 'success' : 'warning'">{{ item.level === 'pass' ? '符合' : '警告' }}</ElTag>
          </div>
          <div class="check-item-content">
            <div>{{ item.content }}</div>
            <div v-if="item.source" class="check-item-source">{{ item.source }}</div>
          </div>
        </el-card>
      </el-space>

      <!-- 底部操作栏 -->
      <div class="bottom-action-bar">
        <ElButton :icon="Document" @click="handleExportReport">导出合规报告</ElButton>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { Search, CircleCheck, WarningFilled, Document } from "@element-plus/icons-vue";

defineOptions({ name: "KbCompliance" });

const searchQuery = ref("");
const standardFilter = ref("all");
const checked = ref(false);

const standards = [{ label: "全部标准", value: "all" }];

const checkItems = [
  {
    level: "pass" as const,
    title: "GB/T 297 滚动轴承",
    content: "检查项：尺寸公差、游隙、材质",
    source: "依据文件：《轴承技术规格书》V1.3",
  },
  {
    level: "pass" as const,
    title: "NB/T 20037 核电厂备件管理",
    content: "检查项：质量等级、可追溯性",
    source: "依据文件：《轴承技术规格书》V1.3",
  },
  {
    level: "pass" as const,
    title: "ASME B16.20 垫片标准",
    content: "检查项：密封性能、耐辐射",
    source: "依据文件：《轴承技术规格书》V1.3",
  },
  {
    level: "warning" as const,
    title: "采购周期检查",
    content: "该备件采购周期为 30 天，当前库存 5 件，低于安全库存 2 件，建议提前发起采购。",
    source: "",
  },
];

function handleComplianceCheck() {
  const q = searchQuery.value.trim();
  if (!q) {
    ElMessage.warning("请输入零件编号/型号");
    return;
  }
  checked.value = true;
}

function handleExportReport() {
  ElMessage.success("合规报告已导出（原型演示）");
}
</script>

<style scoped>
.kb-cc {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #111827;
  display: block;
  width: 100%;
  text-align: left;
}
/* 居中查询组件 */
.search-box-wrapper {
  display: flex;
  justify-content: center;
  padding: 24px 0;
}
.centered-search-form {
  display: flex;
  align-items: center;
  padding: 20px 28px;
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
}
/* 结果汇总 */
.result-summary {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 20px 24px;
  background: #f0fdf4;
  border: 1px solid #bbf7d0;
  border-radius: 8px;
}
.result-summary-text {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.result-title {
  font-weight: 700;
  color: #111827;
}
/* 检查项卡片 */
.check-item-card {
  width: 100%;
}
.check-item-card.warning-bg {
  background: #fef7ec;
  border-color: #f5dab1;
}
.check-item-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 10px;
}
.check-item-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 15px;
  font-weight: 600;
  color: #111827;
}
.check-item-content {
  font-size: 13px;
  color: #374151;
  line-height: 1.8;
}
.check-item-source {
  color: #6b7280;
}
/* 底部操作栏 */
.bottom-action-bar {
  display: flex;
  justify-content: flex-end;
}
</style>
