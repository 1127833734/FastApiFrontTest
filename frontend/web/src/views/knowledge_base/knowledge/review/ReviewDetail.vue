<!--
  文档逐页复核（原型 PageReviewView）：候选列表 / 文档预览标注 / 复核面板 三栏
-->
<template>
  <div class="kb-detail" data-annotation-id="review-detail-page">
    <!-- 页头 -->
    <div class="kb-detail-header">
      <div class="kb-detail-header-left">
        <ElButton :icon="ArrowLeft" circle @click="emit('back')" />
        <div class="kb-detail-title">文档逐页复核</div>
      </div>
      <div class="kb-detail-doc">{{ task.documentName }}（{{ task.documentNo }}）</div>
    </div>

    <div class="kb-detail-grid">
      <!-- 左栏：候选列表 -->
      <ElCard shadow="never" class="kb-candidate-list">
        <div class="kb-candidate-head">
          <span class="kb-candidate-title">候选列表</span>
          <select v-model="groupBy" class="kb-group-select">
            <option value="page">按页</option>
            <option value="status">按状态</option>
          </select>
        </div>
        <div class="kb-candidate-groups">
          <div v-for="group in groupedCandidates" :key="group.key" class="kb-candidate-group">
            <div class="kb-candidate-group-title">{{ group.key }}</div>
            <div
              v-for="c in group.candidates"
              :key="c.id"
              class="kb-candidate-item"
              :class="{ 'kb-candidate-item--active': c.id === activeCandidate?.id }"
              @click="selectCandidate(c)"
            >
              <span class="kb-candidate-dot" :style="{ background: dotColor(c.status) }" />
              <span class="kb-candidate-label">{{ c.label }}</span>
              <span class="kb-candidate-page">P{{ c.pageNo }}</span>
            </div>
          </div>
        </div>
      </ElCard>

      <!-- 中栏：文档预览 -->
      <ElCard shadow="never" class="kb-preview">
        <div class="kb-preview-head">
          <span class="kb-preview-title">文档预览</span>
          <div class="kb-preview-nav">
            <ElButton size="small" :disabled="currentPage <= 1" @click="changePage(currentPage - 1)">
              <ElIcon><ArrowLeft /></ElIcon>上一页
            </ElButton>
            <span class="kb-preview-page">第 {{ currentPage }} / {{ task.totalPages }} 页</span>
            <ElButton size="small" :disabled="currentPage >= task.totalPages" @click="changePage(currentPage + 1)">
              下一页<ElIcon><ArrowRight /></ElIcon>
            </ElButton>
          </div>
        </div>

        <div class="kb-paper-wrap">
          <div class="kb-paper">
            <div class="kb-paper-placeholder">
              <ElIcon :size="48" color="#9ca3af" class="kb-paper-icon"><Document /></ElIcon>
              <div>{{ task.fileType }} 文档预览区</div>
              <div class="kb-paper-page">第 {{ currentPage }} 页</div>
            </div>
            <div
              v-for="c in pageCandidates"
              :key="c.id"
              class="kb-hotspot"
              :class="{ 'kb-hotspot--active': c.id === activeCandidate?.id }"
              :style="{ left: `${c.bbox.x}%`, top: `${c.bbox.y}%` }"
              :title="c.label"
              @click="activeCandidateId = c.id"
            >
              {{ c.id.split("-")[1] }}
            </div>
          </div>
        </div>

        <div class="kb-page-candidates">
          <button
            v-for="c in pageCandidates"
            :key="c.id"
            class="kb-page-cand"
            :class="{ 'kb-page-cand--active': c.id === activeCandidate?.id }"
            @click="activeCandidateId = c.id"
          >
            <span class="kb-page-cand-dot" :style="{ background: dotColor(c.status) }" />
            {{ c.label }}
          </button>
          <div v-if="pageCandidates.length === 0" class="kb-page-empty">本页暂无候选复核项</div>
        </div>

        <div class="kb-preview-actions">
          <ElButton size="small" :icon="CircleCheck" @click="confirmPage">本页全部确认</ElButton>
          <ElButton size="small" :icon="DArrowRight" @click="skipPage">本页全部跳过</ElButton>
          <div class="kb-preview-actions-spacer" />
          <div class="kb-shortcut-tip">
            <ElIcon><InfoFilled /></ElIcon>
            快捷键：Enter 确认 · Esc 跳过 · ←/→ 翻页
          </div>
        </div>
      </ElCard>

      <!-- 右栏：复核面板 -->
      <ReviewPanel
        v-if="activeCandidate"
        :candidate="activeCandidate"
        @change="(patch) => emit('update-candidate', activeCandidate.id, patch)"
        @confirm-next="confirmAndNext"
        @skip="skipCurrent"
        @reject="rejectCurrent"
      />
      <ElCard v-else shadow="never" class="kb-no-candidate">
        <ElIcon :size="40" color="#9ca3af" style="margin-bottom: 12px; opacity: 0.5"><Document /></ElIcon>
        <div>本页暂无候选复核项</div>
        <div class="kb-no-candidate-sub">可切换页码继续复核</div>
      </ElCard>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ArrowLeft, ArrowRight, CircleCheck, DArrowRight, InfoFilled, Document } from "@element-plus/icons-vue";
import ReviewPanel from "./ReviewPanel.vue";
import type { ReviewCandidate, ReviewTask } from "./types";

defineOptions({ name: "KbReviewDetail" });

const props = defineProps<{ task: ReviewTask }>();
const emit = defineEmits<{
  back: [];
  "update-task": [patch: Partial<ReviewTask>];
  "update-candidate": [candidateId: string, patch: Record<string, unknown>];
  "update-page": [pageNo: number];
  "update-page-candidates": [pageNo: number, patch: Record<string, unknown>];
}>();

const currentPage = ref(props.task.currentPage);
const groupBy = ref("page");
const activeCandidateId = ref("");

const pageCandidates = computed(() => props.task.candidates.filter((c) => c.pageNo === currentPage.value));
const activeCandidate = computed(
  () =>
    pageCandidates.value.find((c) => c.id === activeCandidateId.value) || pageCandidates.value[0] || null
);

// 同步激活候选（页码切换时默认第一个）
watch(currentPage, () => {
  activeCandidateId.value = pageCandidates.value[0]?.id || "";
});

const groupedCandidates = computed(() => {
  if (groupBy.value === "page") {
    const pages = Array.from(new Set(props.task.candidates.map((c) => c.pageNo))).sort((a, b) => a - b);
    return pages.map((p) => ({
      key: `第 ${p} 页`,
      candidates: props.task.candidates.filter((c) => c.pageNo === p),
    }));
  }
  const order: ReviewCandidate["status"][] = ["pending", "confirmed", "rejected", "skipped"];
  return order
    .map((s) => ({
      key: statusText[s],
      candidates: props.task.candidates.filter((c) => c.status === s),
    }))
    .filter((g) => g.candidates.length > 0);
});

const statusText: Record<string, string> = {
  pending: "待复核",
  confirmed: "已确认",
  rejected: "已驳回",
  skipped: "已跳过",
};

function dotColor(status: string) {
  if (status === "pending") return "#f59e0b";
  if (status === "confirmed") return "#18a058";
  if (status === "rejected") return "#ef4444";
  return "#6b7280";
}

function changePage(next: number) {
  if (next < 1 || next > props.task.totalPages) return;
  currentPage.value = next;
  emit("update-page", next);
}

function selectCandidate(c: ReviewCandidate) {
  currentPage.value = c.pageNo;
  emit("update-page", c.pageNo);
  activeCandidateId.value = c.id;
}

function confirmAndNext() {
  if (!activeCandidate.value) return;
  emit("update-candidate", activeCandidate.value.id, { status: "confirmed" });
  const list = pageCandidates.value;
  const idx = list.findIndex((c) => c.id === activeCandidate.value?.id);
  if (idx < list.length - 1) {
    activeCandidateId.value = list[idx + 1].id;
  } else if (currentPage.value < props.task.totalPages) {
    changePage(currentPage.value + 1);
  }
}

function skipCurrent() {
  if (!activeCandidate.value) return;
  emit("update-candidate", activeCandidate.value.id, { status: "skipped" });
}
function rejectCurrent() {
  if (!activeCandidate.value) return;
  emit("update-candidate", activeCandidate.value.id, { status: "rejected" });
}

function confirmPage() {
  emit("update-page-candidates", currentPage.value, { status: "confirmed" });
}
function skipPage() {
  emit("update-page-candidates", currentPage.value, { status: "skipped" });
}
</script>

<style scoped>
.kb-detail {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.kb-detail-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
}
.kb-detail-header-left {
  display: flex;
  align-items: center;
  gap: 10px;
}
.kb-detail-title {
  font-size: 18px;
  font-weight: 600;
  color: #111827;
}
.kb-detail-doc {
  font-size: 14px;
  color: #6b7280;
}
.kb-detail-grid {
  display: grid;
  grid-template-columns: 240px minmax(0, 1fr) 400px;
  gap: 16px;
  align-items: start;
}
.kb-candidate-list {
  max-height: 760px;
  overflow: auto;
}
.kb-candidate-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
.kb-candidate-title {
  font-size: 14px;
  font-weight: 600;
  color: #111827;
}
.kb-group-select {
  padding: 4px 8px;
  border-radius: 4px;
  border: 1px solid #d1d5db;
  font-size: 12px;
}
.kb-candidate-groups {
  display: grid;
  gap: 12px;
}
.kb-candidate-group-title {
  font-size: 12px;
  color: #9ca3af;
  margin-bottom: 6px;
}
.kb-candidate-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 10px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 13px;
  color: #374151;
}
.kb-candidate-item:hover {
  background: #f1f5f9;
}
.kb-candidate-item--active {
  background: #eff6ff;
  border: 1px solid #3b82f6;
}
.kb-candidate-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex: 0 0 auto;
}
.kb-candidate-label {
  flex: 1;
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.kb-candidate-page {
  font-size: 11px;
  color: #9ca3af;
}
.kb-preview-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  gap: 8px;
  flex-wrap: wrap;
}
.kb-preview-title {
  font-size: 16px;
  font-weight: 600;
  color: #111827;
}
.kb-preview-nav {
  display: flex;
  align-items: center;
  gap: 8px;
}
.kb-preview-page {
  font-size: 14px;
  color: #374151;
  min-width: 80px;
  text-align: center;
}
.kb-paper-wrap {
  position: relative;
  height: 520px;
  background: #f3f4f6;
  border-radius: 8px;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
}
.kb-paper {
  width: 420px;
  height: 560px;
  background: #fff;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
}
.kb-paper-placeholder {
  text-align: center;
  color: #9ca3af;
}
.kb-paper-icon {
  margin-bottom: 12px;
}
.kb-paper-page {
  font-size: 12px;
  margin-top: 8px;
}
.kb-hotspot {
  position: absolute;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: #3b82f6;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
  cursor: pointer;
  transform: translate(-50%, -50%);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}
.kb-hotspot--active {
  background: #ef4444;
  border: 2px solid #fff;
}
.kb-page-candidates {
  margin-top: 16px;
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}
.kb-page-cand {
  padding: 6px 12px;
  border-radius: 6px;
  border: 1px solid #e5e7eb;
  background: #fff;
  color: #374151;
  font-size: 13px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 6px;
}
.kb-page-cand--active {
  border-color: #3b82f6;
  background: #eff6ff;
  color: #1d4ed8;
}
.kb-page-cand-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}
.kb-page-empty {
  color: #9ca3af;
  font-size: 13px;
}
.kb-preview-actions {
  margin-top: 16px;
  display: flex;
  gap: 10px;
  align-items: center;
}
.kb-preview-actions-spacer {
  flex: 1;
}
.kb-shortcut-tip {
  font-size: 12px;
  color: #6b7280;
  display: flex;
  align-items: center;
  gap: 6px;
}
.kb-no-candidate {
  padding: 40px;
  text-align: center;
  color: #9ca3af;
}
.kb-no-candidate-sub {
  font-size: 13px;
  margin-top: 8px;
}
</style>
