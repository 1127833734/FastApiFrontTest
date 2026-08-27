<!--
  备件知识库 · 知识库 / 复核任务（列表视图）
  按原型 ReviewTasksPage 复刻：统计卡 / tab 筛选 / 6 列表格 / 分页
-->
<template>
  <div class="kb-review">
    <div class="kb-page-header">
      <div class="kb-page-title">复核任务</div>
    </div>

    <!-- 统计卡 -->
    <div class="kb-stat-grid">
      <ElCard v-for="s in statsList" :key="s.label" shadow="never" class="kb-stat-card">
        <div class="kb-stat-label">{{ s.label }}</div>
        <div class="kb-stat-value" :style="{ color: s.color }">{{ s.value }}</div>
      </ElCard>
    </div>

    <ElCard shadow="never">
      <!-- 标题 + 搜索 -->
      <div class="kb-list-head">
        <div class="kb-list-title">复核任务列表</div>
        <div class="kb-list-search">
          <ElIcon color="#9ca3af"><Search /></ElIcon>
          <ElInput v-model="search" placeholder="搜索文档名称 / 编号" clearable style="width: 300px" />
        </div>
      </div>

      <!-- tab 筛选 -->
      <div class="kb-tab-btns">
        <button
          v-for="t in tabOptions"
          :key="t.value"
          class="kb-tab-btn"
          :class="{ 'kb-tab-btn--active': activeTab === t.value }"
          @click="setTab(t.value)"
        >
          {{ t.label }}
        </button>
      </div>

      <div class="kb-count-tip">共 {{ filteredTasks.length }} 条任务，当前第 {{ currentPage }} / {{ totalPages }} 页</div>

      <!-- 表格 -->
      <ElTable :data="pageTasks" style="width: 100%" table-layout="fixed" stripe>
        <ElTableColumn label="来源文档" min-width="220" show-overflow-tooltip>
          <template #default="{ row }">
            <div class="kb-cell-filename">
              <ElIcon color="#6b7280"><Document /></ElIcon>
              <div class="kb-cell-filename-text">
                <div class="kb-cell-name">{{ row.documentName }}</div>
                <div class="kb-cell-sub">{{ row.fileType }} · {{ row.totalPages }} 页</div>
              </div>
            </div>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="documentNo" label="文档编号" min-width="130" show-overflow-tooltip />
        <ElTableColumn prop="fileType" label="文件类型" width="100" />
        <ElTableColumn label="复核进度" width="160">
          <template #default="{ row }">
            <div class="kb-progress">
              <div class="kb-progress-bar">
                <div class="kb-progress-fill" :style="{ width: `${progressOf(row)}%` }" />
              </div>
              <span>{{ progressOf(row) }}%</span>
            </div>
          </template>
        </ElTableColumn>
        <ElTableColumn label="待复核/总数" width="120">
          <template #default="{ row }">
            <span :style="{ color: pendingOf(row) > 0 ? '#f59e0b' : '#18a058', fontWeight: 600 }">{{ pendingOf(row) }}</span>
            <span style="color: #6b7280"> / {{ row.candidates.length }}</span>
          </template>
        </ElTableColumn>
        <ElTableColumn label="操作" width="110" fixed="right">
          <template #default="{ row }">
            <div class="kb-row-actions">
              <ElTooltip v-if="pendingOf(row) > 0" content="快速确认">
                <ElButton link type="success" :icon="Checked" circle @click="quickConfirm(row)" />
              </ElTooltip>
              <ElTooltip :content="pendingOf(row) > 0 ? '继续复核' : '查看复核'">
                <ElButton link type="primary" :icon="View" circle @click="openDetail(row)" />
              </ElTooltip>
            </div>
          </template>
        </ElTableColumn>
      </ElTable>

      <!-- 分页 -->
      <div class="kb-pagination">
        <div class="kb-count-tip">显示 {{ pageTasks.length }} 条，共 {{ filteredTasks.length }} 条</div>
        <div class="kb-pager">
          <ElButton size="small" :disabled="currentPage <= 1" @click="changePage(currentPage - 1)">
            <ElIcon><ArrowLeft /></ElIcon>上一页
          </ElButton>
          <button
            v-for="p in pageNumbers"
            :key="p"
            class="kb-page-btn"
            :class="{ 'kb-page-btn--active': p === currentPage }"
            @click="changePage(p)"
          >
            {{ p }}
          </button>
          <ElButton size="small" :disabled="currentPage >= totalPages" @click="changePage(currentPage + 1)">
            下一页<ElIcon><ArrowRight /></ElIcon>
          </ElButton>
        </div>
      </div>
    </ElCard>

    <!-- 详情视图 -->
    <ReviewDetail
      v-if="activeTask"
      :task="activeTask"
      @back="activeTaskId = null"
      @update-task="updateTask"
      @update-candidate="updateCandidate"
      @update-page="updateTaskPage"
      @update-page-candidates="updatePageCandidates"
    />
  </div>
</template>

<script setup lang="ts">
import { Search, View, Checked, Document, ArrowLeft, ArrowRight } from "@element-plus/icons-vue";
import ReviewDetail from "./ReviewDetail.vue";
import { mockReviewTasks } from "./mock";
import type { ReviewTask } from "./types";

defineOptions({ name: "KbReview" });

const PAGE_SIZE = 8;
const tabOptions = [
  { value: "all", label: "全部" },
  { value: "pending", label: "待复核" },
  { value: "confirmed", label: "已确认" },
  { value: "rejected", label: "已驳回" },
  { value: "skipped", label: "已跳过" },
];

const tasks = ref<ReviewTask[]>([]);
const activeTaskId = ref<string | null>(null);
const activeTab = ref("all");
const search = ref("");
const currentPage = ref(1);

// 初始化 mock 数据
tasks.value = mockReviewTasks;

const activeTask = computed(() => tasks.value.find((t) => t.id === activeTaskId.value) || null);

const allCandidates = computed(() => tasks.value.flatMap((t) => t.candidates));
const statsList = computed(() => {
  const c = allCandidates.value;
  return [
    { label: "任务总数", value: tasks.value.length, color: "#3b82f6" },
    { label: "待复核", value: c.filter((x) => x.status === "pending").length, color: "#f59e0b" },
    { label: "已确认", value: c.filter((x) => x.status === "confirmed").length, color: "#18a058" },
    { label: "已驳回", value: c.filter((x) => x.status === "rejected").length, color: "#ef4444" },
    { label: "已跳过", value: c.filter((x) => x.status === "skipped").length, color: "#6b7280" },
  ];
});

const filteredTasks = computed(() => {
  const q = search.value.trim().toLowerCase();
  return tasks.value.filter((t) => {
    const matchesStatus = activeTab.value === "all" || t.candidates.some((c) => c.status === activeTab.value);
    const matchesSearch = !q || t.documentName.toLowerCase().includes(q) || t.documentNo.toLowerCase().includes(q);
    return matchesStatus && matchesSearch;
  });
});

const totalPages = computed(() => Math.max(1, Math.ceil(filteredTasks.value.length / PAGE_SIZE)));
const pageTasks = computed(() =>
  filteredTasks.value.slice((currentPage.value - 1) * PAGE_SIZE, currentPage.value * PAGE_SIZE)
);
const pageNumbers = computed(() => {
  const total = totalPages.value;
  if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1);
  if (currentPage.value <= 4) return [1, 2, 3, 4, 5, 6, 7];
  if (currentPage.value >= total - 3) return Array.from({ length: 7 }, (_, i) => total - 6 + i);
  return Array.from({ length: 7 }, (_, i) => currentPage.value - 3 + i);
});

function pendingOf(task: ReviewTask) {
  return task.candidates.filter((c) => c.status === "pending").length;
}
function progressOf(task: ReviewTask) {
  if (task.candidates.length === 0) return 100;
  return Math.round(
    (task.candidates.filter((c) => c.status !== "pending").length / task.candidates.length) * 100
  );
}

function setTab(v: string) {
  activeTab.value = v;
  currentPage.value = 1;
}
function changePage(p: number) {
  if (p < 1 || p > totalPages.value) return;
  currentPage.value = p;
}
function openDetail(task: ReviewTask) {
  activeTaskId.value = task.id;
}
function quickConfirm(task: ReviewTask) {
  task.candidates.forEach((c) => {
    if (c.status === "pending") c.status = "confirmed";
  });
  ElMessage.success(`已快速确认「${task.documentName}」全部待复核项`);
}

// ---- 详情视图回写 ----
function updateTask(id: string, patch: Partial<ReviewTask>) {
  const t = tasks.value.find((x) => x.id === id);
  if (t) Object.assign(t, patch);
}
function updateCandidate(taskId: string, candidateId: string, patch: Record<string, unknown>) {
  const t = tasks.value.find((x) => x.id === taskId);
  if (!t) return;
  const c = t.candidates.find((x) => x.id === candidateId);
  if (c) Object.assign(c, patch);
}
function updateTaskPage(taskId: string, pageNo: number) {
  const t = tasks.value.find((x) => x.id === taskId);
  if (t) t.currentPage = pageNo;
}
function updatePageCandidates(taskId: string, pageNo: number, patch: Record<string, unknown>) {
  const t = tasks.value.find((x) => x.id === taskId);
  if (!t) return;
  t.candidates.forEach((c) => {
    if (c.pageNo === pageNo && c.status === "pending") Object.assign(c, patch);
  });
}
</script>

<style scoped>
.kb-review {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.kb-page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.kb-page-title {
  font-size: 18px;
  font-weight: 600;
  color: #111827;
}
.kb-stat-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(110px, 1fr));
  gap: 10px;
}
.kb-stat-card {
  text-align: center;
  padding: 12px 8px;
}
.kb-stat-label {
  font-size: 11px;
  color: #6b7280;
  margin-bottom: 4px;
  line-height: 1.2;
}
.kb-stat-value {
  font-size: 20px;
  font-weight: 700;
}
.kb-list-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
  margin-bottom: 14px;
}
.kb-list-title {
  font-size: 16px;
  font-weight: 600;
  color: #111827;
}
.kb-list-search {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: 1;
  justify-content: flex-end;
  min-width: 240px;
}
.kb-tab-btns {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  margin-bottom: 14px;
}
.kb-tab-btn {
  padding: 7px 18px;
  border-radius: 6px;
  border: 1px solid #d1d5db;
  background: #fff;
  color: #374151;
  font-size: 13px;
  cursor: pointer;
  white-space: nowrap;
}
.kb-tab-btn--active {
  background: #18a058;
  color: #fff;
  border-color: #18a058;
}
.kb-count-tip {
  font-size: 13px;
  color: #6b7280;
  margin-bottom: 12px;
}
.kb-cell-filename {
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 0;
}
.kb-cell-filename-text {
  min-width: 0;
  overflow: hidden;
}
.kb-cell-name {
  font-weight: 500;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.kb-cell-sub {
  font-size: 12px;
  color: #9ca3af;
  white-space: nowrap;
}
.kb-progress {
  display: flex;
  align-items: center;
  gap: 10px;
}
.kb-progress-bar {
  flex: 1;
  height: 6px;
  background: #e5e7eb;
  border-radius: 3px;
  overflow: hidden;
}
.kb-progress-fill {
  height: 100%;
  background: #18a058;
  border-radius: 3px;
}
.kb-progress span {
  font-size: 13px;
  color: #6b7280;
  min-width: 40px;
}
.kb-row-actions {
  display: flex;
  gap: 2px;
  align-items: center;
}
.kb-pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 16px;
}
.kb-pagination .kb-count-tip {
  margin-bottom: 0;
}
.kb-pager {
  display: flex;
  align-items: center;
  gap: 8px;
}
.kb-page-btn {
  padding: 6px 12px;
  border-radius: 6px;
  border: 1px solid #d1d5db;
  background: #fff;
  color: #374151;
  font-size: 13px;
  cursor: pointer;
  min-width: 36px;
}
.kb-page-btn--active {
  background: #18a058;
  color: #fff;
  border-color: #18a058;
}
</style>
