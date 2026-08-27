<!--
  备件知识库 · 知识库 / 复核任务
  复刻原型 review 页：工作流状态统计 / 筛选 / 候选复核表格
-->
<template>
  <div class="kb-review">
    <!-- 工作流状态统计 -->
    <div class="kb-review-stats">
      <ElCard v-for="s in workflowStats" :key="s.label" shadow="never" class="kb-review-stat">
        <div class="kb-review-stat-value" :style="{ color: s.color }">{{ s.count }}</div>
        <div class="kb-review-stat-label">{{ s.label }}</div>
      </ElCard>
    </div>

    <ElCard shadow="never" class="kb-filter">
      <ElForm inline>
        <ElFormItem label="复核状态">
          <ElSelect v-model="query.status" placeholder="全部复核状态" clearable style="width: 150px">
            <ElOption v-for="s in statusOptions" :key="s.value" :label="s.label" :value="s.value" />
          </ElSelect>
        </ElFormItem>
        <ElFormItem label="文档">
          <ElInput v-model="query.keyword" placeholder="文档名称 / 编号" clearable style="width: 220px" />
        </ElFormItem>
        <ElFormItem>
          <ElButton type="primary" :icon="Search" @click="search">查询</ElButton>
          <ElButton :icon="RefreshLeft" @click="reset">重置</ElButton>
        </ElFormItem>
      </ElForm>
    </ElCard>

    <ElCard shadow="never">
      <template #header>
        <div class="kb-card-header">
          <span class="kb-card-title">候选复核列表</span>
          <ElButton :icon="Checked" @click="confirmAll">本页全部确认</ElButton>
          <ElButton :icon="Close" @click="skipAll">本页全部跳过</ElButton>
        </div>
      </template>
      <ElTable :data="filteredTasks" stripe>
        <ElTableColumn type="index" label="序号" width="60" />
        <ElTableColumn prop="label" label="复核项" min-width="180" show-overflow-tooltip />
        <ElTableColumn prop="documentName" label="来源文档" min-width="200" show-overflow-tooltip />
        <ElTableColumn prop="pageNo" label="页码" width="80" align="center" />
        <ElTableColumn label="状态" width="110">
          <template #default="{ row }">
            <ElTag :type="workflowColor[row.status]">{{ row.status }}</ElTag>
          </template>
        </ElTableColumn>
        <ElTableColumn label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <ElButton link type="primary" @click="openReview(row)">查看复核</ElButton>
            <ElButton link type="success" @click="confirmOne(row)">通过</ElButton>
            <ElButton link type="danger" @click="rejectOne(row)">驳回</ElButton>
          </template>
        </ElTableColumn>
      </ElTable>
    </ElCard>
  </div>
</template>

<script setup lang="ts">
import { Search, RefreshLeft, Checked, Close } from "@element-plus/icons-vue";

defineOptions({ name: "KbReview" });

const workflowStats = [
  { label: "待初审", count: 12, color: "#f59e0b" },
  { label: "初审通过", count: 28, color: "#18a058" },
  { label: "初审驳回", count: 3, color: "#ef4444" },
  { label: "待复审", count: 6, color: "#3b82f6" },
  { label: "复审通过", count: 41, color: "#18a058" },
  { label: "复审驳回", count: 2, color: "#ef4444" },
];

const statusOptions = [
  { label: "待初审", value: "待初审" },
  { label: "初审通过", value: "初审通过" },
  { label: "初审驳回", value: "初审驳回" },
  { label: "待复审", value: "待复审" },
  { label: "复审通过", value: "复审通过" },
  { label: "复审驳回", value: "复审驳回" },
];

const workflowColor: Record<string, "warning" | "success" | "danger" | "primary" | "info"> = {
  待初审: "warning",
  初审通过: "success",
  初审驳回: "danger",
  待复审: "primary",
  复审通过: "success",
  复审驳回: "danger",
};

const query = ref({ status: "", keyword: "" });

const allTasks = [
  { id: "c-001", label: "零件/非零件判定确认", documentName: "泵 P-101 维修手册（DOC-2026-0087）", pageNo: 15, status: "待初审" },
  { id: "c-002", label: "零件属性补充", documentName: "泵 P-101 维修手册（DOC-2026-0087）", pageNo: 16, status: "待初审" },
  { id: "c-003", label: "零件/非零件判定确认", documentName: "主汽阀 MV-201 总装图（DOC-2026-0091）", pageNo: 3, status: "初审通过" },
  { id: "c-004", label: "OCR 文本核对", documentName: "密封垫 DN50 采购技术协议（DOC-2026-0095）", pageNo: 2, status: "待复审" },
  { id: "c-005", label: "BOM 父件/子件关系校验", documentName: "泵 P-101 维修手册（DOC-2026-0087）", pageNo: 18, status: "复审通过" },
  { id: "c-006", label: "零件属性完整且无冲突", documentName: "电机 M-105 碳刷更换工艺（DOC-2026-0102）", pageNo: 9, status: "初审驳回" },
  { id: "c-007", label: "零件/非零件判定确认", documentName: "给水系统 PID 图（DOC-2026-0104）", pageNo: 5, status: "待初审" },
];

const filteredTasks = computed(() =>
  allTasks.filter((t) => {
    if (query.value.status && t.status !== query.value.status) return false;
    if (query.value.keyword && !t.documentName.includes(query.value.keyword)) return false;
    return true;
  })
);

function search() {}
function reset() {
  query.value = { status: "", keyword: "" };
}
function openReview(row: (typeof allTasks)[number]) {
  ElMessage.info(`打开复核：${row.label}（第 ${row.pageNo} 页）`);
}
function confirmOne(row: (typeof allTasks)[number]) {
  row.status = "初审通过";
  ElMessage.success(`已通过「${row.label}」`);
}
function rejectOne(row: (typeof allTasks)[number]) {
  row.status = "初审驳回";
  ElMessage.warning(`已驳回「${row.label}」`);
}
function confirmAll() {
  ElMessage.success("本页候选已全部确认");
}
function skipAll() {
  ElMessage.info("本页候选已全部跳过");
}
</script>

<style scoped>
.kb-review {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.kb-review-stats {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 12px;
}
.kb-review-stat {
  text-align: center;
}
.kb-review-stat-value {
  font-size: 24px;
  font-weight: 700;
}
.kb-review-stat-label {
  font-size: 13px;
  color: #6b7280;
  margin-top: 4px;
}
.kb-filter {
  padding: 16px;
}
.kb-card-header {
  display: flex;
  align-items: center;
  gap: 8px;
}
.kb-card-title {
  font-size: 15px;
  font-weight: 600;
  color: #111827;
  margin-right: auto;
}
@media (max-width: 1400px) {
  .kb-review-stats {
    grid-template-columns: repeat(3, 1fr);
  }
}
</style>
