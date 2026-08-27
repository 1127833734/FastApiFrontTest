<!--
  备件知识库 · 工作台
  复刻原型 dashboard 页：快捷入口 / 最近访问 / 待办复核 / 统计卡片
-->
<template>
  <div class="kb-dashboard">
    <!-- 快捷入口 -->
    <div class="kb-grid-4">
      <ElCard
        v-for="item in shortcuts"
        :key="item.label"
        shadow="hover"
        class="kb-shortcut-card"
        @click="onShortcut(item)"
      >
        <div class="kb-shortcut">
          <div class="kb-shortcut-icon" :style="{ background: `${item.color}15`, color: item.color }">
            <ElIcon :size="20"><component :is="item.icon" /></ElIcon>
          </div>
          <span class="kb-shortcut-label">{{ item.label }}</span>
        </div>
      </ElCard>
    </div>

    <!-- 最近访问 + 待办复核 -->
    <div class="kb-grid-main">
      <ElCard shadow="never">
        <template #header>
          <span class="kb-card-title">最近访问</span>
        </template>
        <ElTable :data="recentDocs" stripe>
          <ElTableColumn prop="filename" label="文档名" min-width="220" show-overflow-tooltip />
          <ElTableColumn prop="fileType" label="类型" width="100" />
          <ElTableColumn prop="createdAt" label="访问时间" width="170" />
          <ElTableColumn label="状态" width="110">
            <template #default="{ row }">
              <ElTag :type="statusColor[row.status]">{{ statusText[row.status] }}</ElTag>
            </template>
          </ElTableColumn>
        </ElTable>
      </ElCard>

      <ElCard shadow="never">
        <template #header>
          <span class="kb-card-title">待办复核</span>
        </template>
        <div class="kb-pending-list">
          <div v-for="item in pendingItems" :key="item.id" class="kb-pending-item">
            <ElIcon color="#f59e0b" :size="18" class="kb-pending-icon">
              <WarningFilled />
            </ElIcon>
            <div>
              <div class="kb-pending-label">{{ item.label }}</div>
              <div class="kb-pending-sub">
                {{ item.documentName }}（{{ item.documentNo }}）· 第 {{ item.pageNo }} 页
              </div>
            </div>
          </div>
          <ElButton class="kb-pending-more" text type="primary" @click="routerPush('/kb-knowledge/review')">
            查看全部复核任务
          </ElButton>
        </div>
      </ElCard>
    </div>

    <!-- 统计卡片 -->
    <div class="kb-grid-3">
      <ElCard v-for="s in stats" :key="s.label" shadow="never" class="kb-stat-card">
        <div class="kb-stat">
          <div class="kb-stat-icon" :style="{ background: s.bg, color: s.color }">
            <ElIcon :size="20"><component :is="s.icon" /></ElIcon>
          </div>
          <div>
            <div class="kb-stat-value">{{ s.value }}</div>
            <div class="kb-stat-label">{{ s.label }}</div>
          </div>
        </div>
      </ElCard>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Document, Search, ChatDotRound, Files } from "@element-plus/icons-vue";
import { WarningFilled } from "@element-plus/icons-vue";
import { useRouter } from "vue-router";

defineOptions({ name: "KbDashboard" });

const router = useRouter();

const shortcuts = [
  { label: "上传文档", color: "#18a058", icon: Document, path: "/kb-knowledge/upload" },
  { label: "查询零件", color: "#3b82f6", icon: Search, path: "/kb-parts/list" },
  { label: "开始问答", color: "#aa3bff", icon: ChatDotRound, path: "/kb-assistant" },
  { label: "导出台账", color: "#f59e0b", icon: Files, path: "/kb-business/ledger" },
];

const statusText: Record<string, string> = {
  parsed: "已解析",
  pending: "待处理",
  running: "运行中",
  success: "成功",
  failed: "解析失败",
};
const statusColor: Record<string, "success" | "warning" | "primary" | "info" | "danger"> = {
  parsed: "success",
  pending: "warning",
  running: "primary",
  success: "success",
  failed: "danger",
};

const recentDocs = [
  { id: 1, filename: "泵 P-101 维修手册 V2.1.pdf", fileType: "PDF", createdAt: "2026-08-03 09:12", status: "parsed" },
  { id: 2, filename: "主汽阀 MV-201 总装图.dwg", fileType: "DWG", createdAt: "2026-08-03 08:45", status: "parsed" },
  { id: 3, filename: "密封垫 DN50 采购技术协议.docx", fileType: "DOCX", createdAt: "2026-08-02 16:20", status: "pending" },
  { id: 4, filename: "大修备件清单-2026 秋.xlsx", fileType: "XLSX", createdAt: "2026-08-02 14:03", status: "parsed" },
  { id: 5, filename: "轴承 6208-2RS 质量证明书.pdf", fileType: "PDF", createdAt: "2026-08-01 11:30", status: "failed" },
];

const pendingItems = [
  { id: "c-001", label: "零件/非零件判定确认", documentName: "泵 P-101 维修手册", documentNo: "DOC-2026-0087", pageNo: 15 },
  { id: "c-002", label: "零件属性补充", documentName: "泵 P-101 维修手册", documentNo: "DOC-2026-0087", pageNo: 16 },
  { id: "c-003", label: "零件/非零件判定确认", documentName: "主汽阀 MV-201 总装图", documentNo: "DOC-2026-0091", pageNo: 3 },
  { id: "c-004", label: "OCR 文本核对", documentName: "密封垫 DN50 采购技术协议", documentNo: "DOC-2026-0095", pageNo: 2 },
];

const stats = [
  { label: "知识库文档", value: "1,248", color: "#3b82f6", bg: "#dbeafe", icon: Files },
  { label: "零件档案", value: "8,932", color: "#18a058", bg: "#dcfce7", icon: Search },
  { label: "累计问答", value: "15,672", color: "#aa3bff", bg: "#f3e8ff", icon: ChatDotRound },
];

function onShortcut(item: (typeof shortcuts)[number]) {
  router.push(item.path);
}

function routerPush(path: string) {
  router.push(path);
}
</script>

<style scoped>
.kb-dashboard {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.kb-grid-4 {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
}
.kb-grid-3 {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}
.kb-grid-main {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 16px;
}
.kb-shortcut-card {
  cursor: pointer;
  transition: transform 0.15s, box-shadow 0.15s;
}
.kb-shortcut-card:hover {
  transform: translateY(-2px);
}
.kb-shortcut {
  display: flex;
  align-items: center;
  gap: 12px;
}
.kb-shortcut-icon {
  width: 44px;
  height: 44px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex: 0 0 auto;
}
.kb-shortcut-label {
  font-size: 15px;
  font-weight: 600;
  color: #111827;
}
.kb-card-title {
  font-size: 15px;
  font-weight: 600;
  color: #111827;
}
.kb-pending-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.kb-pending-item {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  padding: 12px;
  border-radius: 6px;
  background: #f9fafb;
}
.kb-pending-icon {
  margin-top: 2px;
}
.kb-pending-label {
  font-size: 14px;
  color: #374151;
  font-weight: 500;
}
.kb-pending-sub {
  font-size: 12px;
  color: #9ca3af;
  margin-top: 4px;
}
.kb-pending-more {
  margin-top: 4px;
  justify-content: flex-start;
  width: fit-content;
}
.kb-stat {
  display: flex;
  align-items: center;
  gap: 12px;
}
.kb-stat-icon {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex: 0 0 auto;
}
.kb-stat-value {
  font-size: 24px;
  font-weight: 700;
  color: #111827;
  line-height: 1.2;
}
.kb-stat-label {
  font-size: 13px;
  color: #6b7280;
}
@media (max-width: 1200px) {
  .kb-grid-4 {
    grid-template-columns: repeat(2, 1fr);
  }
  .kb-grid-main {
    grid-template-columns: 1fr;
  }
}
</style>
