<!--
  备件知识库 · 知识库 / 文档列表
  按原型 DocumentsPage 复刻：页头操作 / 5 统计卡 / 筛选区 / 11 列表格 / 分页
-->
<template>
  <div class="kb-documents">
    <!-- 页头操作 -->
    <div class="kb-page-header">
      <div class="kb-page-title">文档中心</div>
      <div class="kb-page-actions">
        <ElButton :icon="Refresh" @click="goLibrary">库对接</ElButton>
        <ElButton type="primary" :icon="Plus" @click="goUpload">上传文档</ElButton>
      </div>
    </div>

    <!-- 统计卡 -->
    <div class="kb-stat-grid">
      <ElCard v-for="s in statsList" :key="s.label" shadow="never" class="kb-stat-card">
        <div class="kb-stat-label">{{ s.label }}</div>
        <div class="kb-stat-value" :style="{ color: s.color }">{{ s.value }}</div>
      </ElCard>
    </div>

    <!-- 筛选区 -->
    <ElCard shadow="never">
      <div class="kb-filter" data-annotation-id="documents-filter">
        <div class="kb-filter-search">
          <ElIcon class="kb-filter-search-icon"><Search /></ElIcon>
          <ElInput
            v-model="query.search"
            placeholder="搜索文档名、编号、设备..."
            clearable
            style="width: 100%"
            @keyup.enter="doFilter"
          />
        </div>
        <ElSelect v-model="query.status" placeholder="全部状态" clearable style="width: 130px">
          <ElOption label="已解析" value="parsed" />
          <ElOption label="解析中" value="parsing" />
          <ElOption label="解析失败" value="failed" />
        </ElSelect>
        <ElSelect v-model="query.reviewStatus" placeholder="全部复核状态" clearable style="width: 150px">
          <ElOption label="未复核" value="unreviewed" />
          <ElOption label="复核中" value="reviewing" />
          <ElOption label="已复核" value="reviewed" />
          <ElOption label="信息不完整" value="incomplete" />
        </ElSelect>
        <ElSelect v-model="query.source" placeholder="全部来源" clearable style="width: 130px">
          <ElOption label="库对接" value="library" />
          <ElOption label="本地上传" value="upload" />
        </ElSelect>
        <ElButton :icon="Filter" @click="doFilter">筛选</ElButton>
      </div>

      <div class="kb-count-tip">共 {{ filteredDocs.length }} 条记录，当前第 {{ currentPage }} / {{ totalPages }} 页</div>

      <!-- 表格 -->
      <ElTable :data="pageDocs" style="width: 100%" table-layout="fixed" stripe>
        <ElTableColumn prop="filename" label="文件名" min-width="220" show-overflow-tooltip>
          <template #default="{ row }">
            <div class="kb-cell-filename">
              <ElIcon color="#6b7280"><Document /></ElIcon>
              <div class="kb-cell-filename-text">
                <div class="kb-cell-name">{{ row.filename }}</div>
                <div class="kb-cell-sub">{{ row.metadata.unit }} · {{ row.metadata.system }}</div>
              </div>
            </div>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="metadata.documentNo" label="文件编号" min-width="130" show-overflow-tooltip />
        <ElTableColumn prop="fileType" label="类型" width="70" />
        <ElTableColumn label="来源" width="90">
          <template #default="{ row }">{{ sourceText[row.source] }}</template>
        </ElTableColumn>
        <ElTableColumn prop="metadata.classification" label="密级" width="70" />
        <ElTableColumn prop="metadata.version" label="版本" width="70" />
        <ElTableColumn label="元数据完整度" width="130">
          <template #default="{ row }">
            <div class="kb-completeness">
              <div class="kb-completeness-bar">
                <div
                  class="kb-completeness-fill"
                  :style="{
                    width: `${row.metadata.completeness}%`,
                    background:
                      row.metadata.completeness >= 80
                        ? '#18a058'
                        : row.metadata.completeness >= 50
                          ? '#f59e0b'
                          : '#ef4444',
                  }"
                />
              </div>
              <span>{{ row.metadata.completeness }}%</span>
            </div>
          </template>
        </ElTableColumn>
        <ElTableColumn label="解析状态" width="100">
          <template #default="{ row }">
            <span class="kb-status-tag" :style="statusStyle[row.status]">{{ statusText[row.status] }}</span>
          </template>
        </ElTableColumn>
        <ElTableColumn label="复核状态" width="100">
          <template #default="{ row }">
            <span v-if="row.status === 'parsed'" class="kb-status-tag" :style="reviewStyle[row.reviewStatus]">
              {{ reviewText[row.reviewStatus] }}
            </span>
            <span v-else style="color: #9ca3af">—</span>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="createdBy" label="上传人" width="90" />
        <ElTableColumn label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <div class="kb-row-actions">
              <ElTooltip content="查看文档">
                <ElButton link :icon="View" circle @click="viewDoc" />
              </ElTooltip>
              <ElTooltip v-if="row.status === 'parsed' && reviewMap.get(row.id)" content="复核">
                <ElButton link type="primary" :icon="Checked" circle @click="goReview" />
              </ElTooltip>
              <ElTooltip v-if="row.status === 'failed'" content="重新解析">
                <ElButton link type="warning" :icon="Refresh" circle @click="reparse(row)" />
              </ElTooltip>
              <ElTooltip content="删除">
                <ElButton link type="danger" :icon="Delete" circle @click="removeDoc(row)" />
              </ElTooltip>
            </div>
          </template>
        </ElTableColumn>
      </ElTable>

      <!-- 分页 -->
      <div class="kb-pagination">
        <div class="kb-count-tip">显示 {{ pageDocs.length }} 条，共 {{ filteredDocs.length }} 条</div>
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
  </div>
</template>

<script setup lang="ts">
import {
  Search,
  Filter,
  Plus,
  Refresh,
  View,
  Delete,
  Checked,
  Document,
  ArrowLeft,
  ArrowRight,
} from "@element-plus/icons-vue";
import { useRouter } from "vue-router";

defineOptions({ name: "KbDocuments" });

const router = useRouter();
const PAGE_SIZE = 10;

interface KbDocument {
  id: string;
  filename: string;
  fileType: string;
  source: "library" | "upload";
  status: "parsed" | "parsing" | "failed";
  reviewStatus: "unreviewed" | "reviewing" | "reviewed" | "incomplete";
  createdBy: string;
  metadata: {
    documentNo: string;
    unit: string;
    system: string;
    device: string;
    classification: string;
    version: string;
    completeness: number;
  };
}

const mockDocuments: KbDocument[] = [
  { id: "d-001", filename: "泵 P-101 维修手册 V2.1.pdf", fileType: "PDF", source: "upload", status: "parsed", reviewStatus: "reviewing", createdBy: "技术部 · 王工", metadata: { documentNo: "DOC-2026-0087", unit: "1#机组", system: "给水系统", device: "泵 P-101", classification: "内部", version: "V2.1", completeness: 92 } },
  { id: "d-002", filename: "主汽阀 MV-201 总装图.dwg", fileType: "DWG", source: "upload", status: "parsed", reviewStatus: "reviewed", createdBy: "技术部 · 李工", metadata: { documentNo: "DWG-2026-0091", unit: "2#机组", system: "蒸汽系统", device: "主汽阀 MV-201", classification: "秘密", version: "V1.0", completeness: 85 } },
  { id: "d-003", filename: "密封垫 DN50 采购技术协议.docx", fileType: "DOCX", source: "library", status: "parsing", reviewStatus: "unreviewed", createdBy: "采购部 · 赵工", metadata: { documentNo: "DOC-2026-0095", unit: "1#机组", system: "通用", device: "密封垫 DN50", classification: "内部", version: "V1.2", completeness: 45 } },
  { id: "d-004", filename: "大修备件清单-2026 秋.xlsx", fileType: "XLSX", source: "library", status: "parsed", reviewStatus: "unreviewed", createdBy: "备件部 · 刘工", metadata: { documentNo: "DOC-LIB-0102", unit: "全部", system: "通用", device: "大修备件", classification: "内部", version: "V3.0", completeness: 78 } },
  { id: "d-005", filename: "轴承 6208-2RS 质量证明书.pdf", fileType: "PDF", source: "upload", status: "failed", reviewStatus: "unreviewed", createdBy: "备件部 · 刘工", metadata: { documentNo: "DOC-2026-0106", unit: "1#机组", system: "给水系统", device: "泵 P-101", classification: "机密", version: "V1.0", completeness: 30 } },
  { id: "d-006", filename: "电机 M-105 碳刷更换工艺.pdf", fileType: "PDF", source: "upload", status: "parsed", reviewStatus: "incomplete", createdBy: "维修部 · 陈工", metadata: { documentNo: "SOP-2026-0102", unit: "1#机组", system: "电气系统", device: "电机 M-105", classification: "内部", version: "V2.0", completeness: 62 } },
  { id: "d-007", filename: "给水系统 PID 图.dwg", fileType: "DWG", source: "library", status: "parsed", reviewStatus: "reviewed", createdBy: "技术部 · 李工", metadata: { documentNo: "DWG-LIB-0045", unit: "2#机组", system: "给水系统", device: "系统级", classification: "秘密", version: "V1.3", completeness: 88 } },
  { id: "d-008", filename: "辐射防护管理要求.docx", fileType: "DOCX", source: "library", status: "parsed", reviewStatus: "reviewed", createdBy: "安全部 · 周工", metadata: { documentNo: "SOP-LIB-0012", unit: "全部", system: "通用", device: "辐射防护", classification: "秘密", version: "V1.1", completeness: 95 } },
  { id: "d-009", filename: "1#机组汽轮机大修试验大纲.xlsx", fileType: "XLSX", source: "library", status: "parsing", reviewStatus: "unreviewed", createdBy: "技术部 · 郑工", metadata: { documentNo: "DOC-LIB-0118", unit: "1#机组", system: "汽轮机", device: "汽轮机", classification: "机密", version: "V0.9", completeness: 40 } },
  { id: "d-010", filename: "反应堆冷却剂泵运行规程.pdf", fileType: "PDF", source: "library", status: "parsed", reviewStatus: "reviewing", createdBy: "运行部 · 孙工", metadata: { documentNo: "PT-LIB-0023", unit: "2#机组", system: "一回路", device: "冷却剂泵", classification: "机密", version: "V4.2", completeness: 90 } },
  { id: "d-011", filename: "主汽阀 MV-201 检修工艺卡.pdf", fileType: "PDF", source: "upload", status: "parsed", reviewStatus: "unreviewed", createdBy: "维修部 · 陈工", metadata: { documentNo: "DOC-2026-0115", unit: "2#机组", system: "蒸汽系统", device: "主汽阀 MV-201", classification: "内部", version: "V1.5", completeness: 81 } },
  { id: "d-012", filename: "凝结水系统流程图.dwg", fileType: "DWG", source: "library", status: "failed", reviewStatus: "unreviewed", createdBy: "技术部 · 李工", metadata: { documentNo: "DWG-LIB-0057", unit: "1#机组", system: "凝结水", device: "系统级", classification: "秘密", version: "V2.0", completeness: 25 } },
];

const sourceText: Record<string, string> = { library: "库对接", upload: "本地上传" };
const statusText: Record<string, string> = { parsed: "已解析", parsing: "解析中", failed: "解析失败" };
const statusStyle: Record<string, { color: string; background: string }> = {
  parsed: { color: "#18a058", background: "#e1f5ee" },
  parsing: { color: "#f59e0b", background: "#faf0d8" },
  failed: { color: "#ef4444", background: "#fcebeb" },
};
const reviewText: Record<string, string> = {
  unreviewed: "未复核",
  reviewing: "复核中",
  reviewed: "已复核",
  incomplete: "信息不完整",
};
const reviewStyle: Record<string, { color: string; background: string }> = {
  unreviewed: { color: "#f59e0b", background: "#faf0d8" },
  reviewing: { color: "#3b82f6", background: "#e3effc" },
  reviewed: { color: "#18a058", background: "#e1f5ee" },
  incomplete: { color: "#ef4444", background: "#fcebeb" },
};

// 复核任务映射（文档 → 是否有复核任务）
const reviewMap = new Map([
  ["d-001", true],
  ["d-002", true],
  ["d-004", true],
  ["d-006", true],
  ["d-010", true],
  ["d-011", true],
]);

const query = ref({ search: "", status: "", reviewStatus: "", source: "" });
const currentPage = ref(1);

const stats = computed(() => {
  return {
    total: mockDocuments.length,
    parsed: mockDocuments.filter((d) => d.status === "parsed").length,
    parsing: mockDocuments.filter((d) => d.status === "parsing").length,
    failed: mockDocuments.filter((d) => d.status === "failed").length,
    withReview: reviewMap.size,
  };
});

const statsList = computed(() => [
  { label: "文档总数", value: stats.value.total, color: "#3b82f6" },
  { label: "已解析", value: stats.value.parsed, color: "#18a058" },
  { label: "解析中", value: stats.value.parsing, color: "#f59e0b" },
  { label: "解析失败", value: stats.value.failed, color: "#ef4444" },
  { label: "已生成复核", value: stats.value.withReview, color: "#8b5cf6" },
]);

const filteredDocs = computed(() => {
  const q = query.value.search.trim().toLowerCase();
  return mockDocuments.filter((d) => {
    const matchesSearch =
      !q ||
      d.filename.toLowerCase().includes(q) ||
      d.metadata.documentNo.toLowerCase().includes(q) ||
      d.metadata.device.toLowerCase().includes(q);
    const matchesStatus = !query.value.status || d.status === query.value.status;
    const matchesReview = !query.value.reviewStatus || d.reviewStatus === query.value.reviewStatus;
    const matchesSource = !query.value.source || d.source === query.value.source;
    return matchesSearch && matchesStatus && matchesReview && matchesSource;
  });
});

const totalPages = computed(() => Math.max(1, Math.ceil(filteredDocs.value.length / PAGE_SIZE)));
const pageDocs = computed(() =>
  filteredDocs.value.slice((currentPage.value - 1) * PAGE_SIZE, currentPage.value * PAGE_SIZE)
);

const pageNumbers = computed(() => {
  const total = totalPages.value;
  if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1);
  if (currentPage.value <= 4) return [1, 2, 3, 4, 5, 6, 7];
  if (currentPage.value >= total - 3) return Array.from({ length: 7 }, (_, i) => total - 6 + i);
  return Array.from({ length: 7 }, (_, i) => currentPage.value - 3 + i);
});

function doFilter() {
  currentPage.value = 1;
}
function changePage(p: number) {
  if (p < 1 || p > totalPages.value) return;
  currentPage.value = p;
}
function goUpload() {
  router.push("/kb-knowledge/upload?tab=upload");
}
function goLibrary() {
  router.push("/kb-knowledge/upload?tab=library");
}
function viewDoc() {
  router.push("/kb-knowledge/viewer");
}
function goReview() {
  router.push("/kb-knowledge/review");
}
function reparse(row: KbDocument) {
  ElMessage.success(`已重新提交解析：${row.filename}`);
}
function removeDoc(row: KbDocument) {
  ElMessage.warning(`删除文档：${row.filename}（原型演示）`);
}
</script>

<style scoped>
.kb-documents {
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
.kb-filter {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}
.kb-filter-search {
  position: relative;
  flex: 1;
  min-width: 200px;
}
.kb-filter-search-icon {
  position: absolute;
  left: 10px;
  top: 50%;
  transform: translateY(-50%);
  z-index: 1;
  pointer-events: none;
  color: #9ca3af;
}
.kb-filter-search :deep(.el-input__wrapper) {
  padding-left: 34px;
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
.kb-completeness {
  display: flex;
  align-items: center;
  gap: 8px;
}
.kb-completeness-bar {
  flex: 1;
  height: 6px;
  background: #e5e7eb;
  border-radius: 3px;
  overflow: hidden;
}
.kb-completeness-fill {
  height: 100%;
  border-radius: 3px;
}
.kb-completeness span {
  font-size: 12px;
  color: #6b7280;
  min-width: 32px;
}
.kb-status-tag {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  white-space: nowrap;
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
