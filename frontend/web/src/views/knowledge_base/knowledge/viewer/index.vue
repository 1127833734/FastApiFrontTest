<!--
  备件知识库 · 知识库 / 文档查看器
  按原型 ViewerPage 复刻：文档列表 / 画布热区 / 元数据标注 三栏
-->
<template>
  <div class="kb-viewer" data-annotation-id="document-page">
    <!-- 页头 -->
    <div class="kb-viewer-header">
      <div class="kb-viewer-title">文档查看器</div>
      <div class="kb-viewer-actions">
        <ElInput
          v-model="search"
          placeholder="搜索文档编号/设备名称..."
          clearable
          style="width: 260px"
          @keyup.enter="searchDocs"
        />
        <ElSelect v-model="filterType" placeholder="全部类型" clearable style="width: 130px" @change="searchDocs">
          <ElOption v-for="t in fileTypes" :key="t" :label="t" :value="t" />
        </ElSelect>
        <ElButton :icon="Search" @click="searchDocs">搜索</ElButton>
      </div>
    </div>

    <div class="kb-viewer-grid">
      <!-- 左栏：文档列表 -->
      <ElCard shadow="never" class="kb-doc-list" data-annotation-id="document-list">
        <div class="kb-side-title">
          <ElIcon :size="18"><Collection /></ElIcon>
          文档列表
        </div>
        <div class="kb-doc-items">
          <div
            v-for="d in filteredDocs"
            :key="d.id"
            class="kb-doc-item"
            :class="{ 'kb-doc-item--active': selectedId === d.id }"
            @click="selectDoc(d)"
          >
            <div class="kb-doc-item-head">
              <span class="kb-filetype-tag" :style="{ color: fileTypeColor[d.fileType], background: fileTypeColor[d.fileType] + '15' }">
                {{ d.fileType }}
              </span>
              <span class="kb-doc-item-name">{{ d.name }}</span>
            </div>
            <div class="kb-doc-item-sub">{{ d.documentNo }} · {{ d.pageCount }} 页 · {{ d.source === "library" ? "库对接" : "本地上传" }}</div>
            <span class="kb-status-tag" :style="docStatusStyle[d.status]">{{ docStatusText[d.status] }}</span>
          </div>
          <ElEmpty v-if="filteredDocs.length === 0" description="无匹配文档" :image-size="60" />
        </div>
      </ElCard>

      <!-- 中栏：画布 -->
      <ElCard shadow="never" class="kb-canvas" data-annotation-id="document-canvas">
        <div class="kb-canvas-head">
          <div>
            <div class="kb-canvas-name">{{ document.name }}</div>
            <div class="kb-canvas-sub">{{ document.documentNo }} · {{ document.fileType }} · 共 {{ document.pageCount }} 页</div>
          </div>
          <div class="kb-canvas-toolbar">
            <template v-if="document.pageCount > 1">
              <ElButton size="small" :disabled="currentPage <= 1" @click="currentPage--">
                <ElIcon><ArrowLeft /></ElIcon>
              </ElButton>
              <span class="kb-canvas-page">第 {{ currentPage }} 页</span>
              <ElButton size="small" :disabled="currentPage >= document.pageCount" @click="currentPage++">
                <ElIcon><ArrowRight /></ElIcon>
              </ElButton>
            </template>
            <ElButton size="small" @click="zoomOut"><ElIcon><ZoomOut /></ElIcon></ElButton>
            <span class="kb-canvas-zoom">{{ Math.round(scale * 100) }}%</span>
            <ElButton size="small" @click="zoomIn"><ElIcon><ZoomIn /></ElIcon></ElButton>
            <ElButton size="small" @click="rotate"><ElIcon><RefreshRight /></ElIcon></ElButton>
          </div>
        </div>

        <div
          v-if="document.status === 'parsed' && document.reviewStatus !== 'reviewed'"
          class="kb-unreviewed-tip"
        >
          <ElIcon color="#f59e0b"><WarningFilled /></ElIcon>
          本文档包含未复核数据，进入关键决策场景前请复核。
        </div>

        <div class="kb-paper-wrap">
          <div class="kb-paper" :style="{ transform: `scale(${scale}) rotate(${rotateDeg}deg)` }">
            <div class="kb-paper-placeholder">
              <ElIcon :size="48" color="#9ca3af" class="kb-paper-icon"><Document /></ElIcon>
              <div>{{ document.fileType }} 文档预览区</div>
              <div class="kb-paper-sub">{{ document.documentNo }} · 第 {{ currentPage }} 页</div>
            </div>
            <div
              v-for="h in document.hotspots"
              :key="h.id"
              class="kb-hotspot"
              :class="{ 'kb-hotspot--active': selectedHotspot === h.id }"
              :style="{ left: `${h.x}%`, top: `${h.y}%` }"
              :title="h.label"
              @click="selectedHotspot = h.id"
            >
              {{ h.id.split("-")[1] }}
            </div>
          </div>
        </div>

        <div class="kb-canvas-footer">
          <div class="kb-canvas-tip">支持 PDF、DOCX、XLSX、JPG/PNG、DWG 等格式在线预览，OCR 识别结果以高亮标注呈现。</div>
          <ElButton
            type="primary"
            :icon="EditPen"
            :style="{ opacity: document.reviewStatus === 'reviewed' ? 0.6 : 1 }"
            @click="goReview"
          >
            {{ document.reviewStatus === "reviewed" ? "已复核" : "进入复核" }}
          </ElButton>
        </div>
      </ElCard>

      <!-- 右栏：元数据 -->
      <ElCard shadow="never" class="kb-meta" data-annotation-id="document-metadata">
        <div class="kb-meta-head">
          <div class="kb-side-title">
            <ElIcon :size="18"><InfoFilled /></ElIcon>
            文档信息
          </div>
          <span class="kb-status-tag" :style="metaStatusStyle">{{ metaStatusText }}</span>
        </div>
        <div class="kb-meta-body">
          <div class="kb-meta-section-title">元数据</div>
          <div class="kb-meta-grid">
            <div v-for="(value, key) in document.metadata" :key="key" class="kb-meta-row">
              <span class="kb-meta-key">{{ key }}</span>
              <span class="kb-meta-value">{{ value }}</span>
            </div>
          </div>

          <div class="kb-ocr-head">
            <span class="kb-ocr-title">OCR 识别结果</span>
            <span v-if="document.status === 'parsed'" class="kb-ocr-count">{{ document.hotspots.length }} 处标注</span>
          </div>
          <div v-if="document.status === 'parsed'" class="kb-ocr-list">
            <div
              v-for="h in document.hotspots"
              :key="h.id"
              class="kb-ocr-item"
              :class="{ 'kb-ocr-item--active': selectedHotspot === h.id }"
              @click="selectedHotspot = h.id"
            >
              <span class="kb-ocr-dot" :class="{ 'kb-ocr-dot--active': selectedHotspot === h.id }">
                {{ h.id.split("-")[1] }}
              </span>
              <span class="kb-ocr-label">{{ h.label }}</span>
            </div>
          </div>
          <div v-else class="kb-ocr-empty">
            {{ document.status === "parsing" ? "文档解析中，请稍后..." : "文档解析失败，请重新上传" }}
          </div>
        </div>
      </ElCard>
    </div>
  </div>
</template>

<script setup lang="ts">
import {
  Search,
  Collection,
  InfoFilled,
  ArrowLeft,
  ArrowRight,
  ZoomIn,
  ZoomOut,
  RefreshRight,
  WarningFilled,
  Document,
  EditPen,
} from "@element-plus/icons-vue";
import { useRouter } from "vue-router";

defineOptions({ name: "KbViewer" });

const router = useRouter();

interface Hotspot {
  id: string;
  x: number;
  y: number;
  label: string;
}

interface KbViewerDoc {
  id: string;
  name: string;
  documentNo: string;
  fileType: string;
  pageCount: number;
  source: "library" | "upload";
  status: "parsed" | "parsing" | "failed";
  reviewStatus: "unreviewed" | "reviewing" | "reviewed" | "incomplete";
  device: string;
  hotspots: Hotspot[];
  metadata: Record<string, string>;
}

const fileTypes = ["PDF", "DOCX", "XLSX", "JPG", "PNG", "DWG"];
const fileTypeColor: Record<string, string> = {
  PDF: "#ef4444",
  DOCX: "#3b82f6",
  XLSX: "#18a058",
  JPG: "#8b5cf6",
  PNG: "#8b5cf6",
  DWG: "#f59e0b",
};
const docStatusText: Record<string, string> = { parsed: "已解析", parsing: "解析中", failed: "解析失败" };
const docStatusStyle: Record<string, { color: string; background: string }> = {
  parsed: { color: "#18a058", background: "#e1f5ee" },
  parsing: { color: "#f59e0b", background: "#faf0d8" },
  failed: { color: "#ef4444", background: "#fcebeb" },
};

const mockDocs: KbViewerDoc[] = [
  {
    id: "docv-001",
    name: "泵 P-101 维修手册",
    documentNo: "DOC-2026-0087",
    fileType: "PDF",
    pageCount: 12,
    source: "upload",
    status: "parsed",
    reviewStatus: "reviewing",
    device: "泵 P-101",
    hotspots: [
      { id: "h-01", x: 30, y: 25, label: "驱动端轴承 6208-2RS" },
      { id: "h-02", x: 62, y: 38, label: "非驱动端轴承 6207-2RS" },
      { id: "h-03", x: 20, y: 70, label: "安全提示：断电挂牌" },
      { id: "h-04", x: 75, y: 55, label: "检查周期 8000 小时" },
    ],
    metadata: {
      文件编号: "DOC-2026-0087",
      密级: "内部",
      版本: "V2.1",
      生效日期: "2026-06-15",
      所属机组: "1#机组",
      所属系统: "给水系统",
      所属设备: "泵 P-101",
      页数: "128",
      来源部门: "技术部",
    },
  },
  {
    id: "docv-002",
    name: "主汽阀 MV-201 总装图",
    documentNo: "DWG-2026-0091",
    fileType: "DWG",
    pageCount: 1,
    source: "upload",
    status: "parsed",
    reviewStatus: "reviewed",
    device: "主汽阀 MV-201",
    hotspots: [
      { id: "h-05", x: 40, y: 30, label: "阀盖密封圈 Φ140×Φ160" },
      { id: "h-06", x: 65, y: 55, label: "阀杆材质 17-4PH" },
    ],
    metadata: {
      文件编号: "DWG-2026-0091",
      密级: "秘密",
      版本: "V1.0",
      生效日期: "2026-04-02",
      所属机组: "2#机组",
      所属系统: "蒸汽系统",
      所属设备: "主汽阀 MV-201",
      页数: "24",
      来源部门: "技术部",
    },
  },
  {
    id: "docv-003",
    name: "电机 M-105 碳刷更换工艺",
    documentNo: "SOP-2026-0102",
    fileType: "PDF",
    pageCount: 6,
    source: "upload",
    status: "parsed",
    reviewStatus: "incomplete",
    device: "电机 M-105",
    hotspots: [
      { id: "h-07", x: 30, y: 40, label: "碳刷 D374N 25×32×60" },
    ],
    metadata: {
      文件编号: "SOP-2026-0102",
      密级: "内部",
      版本: "V2.0",
      生效日期: "2026-01-20",
      所属机组: "1#机组",
      所属系统: "电气系统",
      所属设备: "电机 M-105",
      页数: "32",
      来源部门: "维修部",
    },
  },
  {
    id: "docv-004",
    name: "给水系统 PID 图",
    documentNo: "DWG-LIB-0045",
    fileType: "DWG",
    pageCount: 1,
    source: "library",
    status: "parsing",
    reviewStatus: "unreviewed",
    device: "系统级",
    hotspots: [],
    metadata: {
      文件编号: "DWG-LIB-0045",
      密级: "秘密",
      版本: "V1.3",
      生效日期: "2025-11-08",
      所属机组: "2#机组",
      所属系统: "给水系统",
      所属设备: "系统级",
      页数: "18",
      来源部门: "技术部",
    },
  },
];

const selectedId = ref("docv-001");
const scale = ref(1);
const rotateDeg = ref(0);
const selectedHotspot = ref<string | null>(null);
const currentPage = ref(1);
const filterType = ref("");
const search = ref("");

const document = computed(() => mockDocs.find((d) => d.id === selectedId.value) || mockDocs[0]);

const filteredDocs = computed(() => {
  const kw = search.value.trim().toLowerCase();
  return mockDocs.filter((d) => {
    const matchesType = !filterType.value || d.fileType === filterType.value;
    const matchesSearch =
      !kw ||
      d.documentNo.toLowerCase().includes(kw) ||
      d.device.toLowerCase().includes(kw) ||
      d.name.toLowerCase().includes(kw);
    return matchesType && matchesSearch;
  });
});

const reviewStatusText: Record<string, string> = {
  unreviewed: "未复核",
  reviewing: "复核中",
  reviewed: "已复核",
  incomplete: "信息不完整",
};
const reviewStatusColor: Record<string, { color: string; background: string }> = {
  unreviewed: { color: "#f59e0b", background: "#faf0d8" },
  reviewing: { color: "#3b82f6", background: "#e3effc" },
  reviewed: { color: "#18a058", background: "#e1f5ee" },
  incomplete: { color: "#ef4444", background: "#fcebeb" },
};

const metaStatusText = computed(() => {
  const d = document.value;
  if (d.status === "parsed") return reviewStatusText[d.reviewStatus];
  return docStatusText[d.status];
});
const metaStatusStyle = computed(() => {
  const d = document.value;
  if (d.status === "parsed") return reviewStatusColor[d.reviewStatus];
  return docStatusStyle[d.status];
});

function selectDoc(d: KbViewerDoc) {
  selectedId.value = d.id;
  selectedHotspot.value = null;
  currentPage.value = 1;
}
function zoomIn() {
  scale.value = Math.min(2, scale.value + 0.1);
}
function zoomOut() {
  scale.value = Math.max(0.5, scale.value - 0.1);
}
function rotate() {
  rotateDeg.value = (rotateDeg.value + 90) % 360;
}
function searchDocs() {
  // 前端过滤即时生效
}
function goReview() {
  router.push("/kb-knowledge/review");
}
</script>

<style scoped>
.kb-viewer {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.kb-viewer-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
}
.kb-viewer-title {
  font-size: 18px;
  font-weight: 600;
  color: #111827;
}
.kb-viewer-actions {
  display: flex;
  gap: 12px;
  align-items: center;
}
.kb-viewer-grid {
  display: grid;
  grid-template-columns: 240px minmax(0, 1fr) 360px;
  gap: 16px;
  align-items: start;
}
.kb-side-title {
  font-size: 16px;
  font-weight: 600;
  color: #111827;
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
}
.kb-doc-items {
  display: grid;
  gap: 10px;
}
.kb-doc-item {
  padding: 12px;
  border-radius: 6px;
  cursor: pointer;
  background: #f9fafb;
  border: 1px solid #e5e7eb;
}
.kb-doc-item--active {
  background: #dbeafe;
  border-color: #3b82f6;
}
.kb-doc-item-head {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 4px;
}
.kb-filetype-tag {
  font-size: 11px;
  padding: 2px 6px;
  border-radius: 4px;
  font-weight: 600;
  flex: 0 0 auto;
}
.kb-doc-item-name {
  font-weight: 600;
  font-size: 14px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.kb-doc-item-sub {
  font-size: 12px;
  color: #6b7280;
  margin-bottom: 6px;
}
.kb-status-tag {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  white-space: nowrap;
}
.kb-canvas-head {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
  gap: 8px;
  flex-wrap: wrap;
}
.kb-canvas-name {
  font-weight: 600;
  font-size: 15px;
  color: #111827;
}
.kb-canvas-sub {
  font-size: 12px;
  color: #6b7280;
  margin-top: 2px;
}
.kb-canvas-toolbar {
  display: flex;
  gap: 8px;
  align-items: center;
}
.kb-canvas-page {
  font-size: 13px;
  color: #6b7280;
  min-width: 60px;
  text-align: center;
}
.kb-canvas-zoom {
  font-size: 13px;
  color: #6b7280;
  min-width: 50px;
  text-align: center;
}
.kb-unreviewed-tip {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
  padding: 10px 12px;
  background: #fef3c7;
  border-radius: 6px;
  color: #92400e;
  font-size: 13px;
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
  width: 320px;
  height: 420px;
  background: #fff;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  transform-origin: center;
  transition: transform 0.1s;
}
.kb-paper-placeholder {
  text-align: center;
  color: #9ca3af;
}
.kb-paper-icon {
  margin-bottom: 12px;
}
.kb-paper-sub {
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
.kb-canvas-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 16px;
  gap: 12px;
}
.kb-canvas-tip {
  font-size: 13px;
  color: #6b7280;
}
.kb-meta {
  display: flex;
  flex-direction: column;
  max-height: 700px;
  overflow: hidden;
  padding: 0;
}
.kb-meta-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 16px 12px;
  border-bottom: 1px solid #f3f4f6;
}
.kb-meta-head .kb-side-title {
  margin-bottom: 0;
}
.kb-meta-body {
  flex: 1;
  overflow: auto;
  padding: 16px;
}
.kb-meta-section-title {
  font-size: 13px;
  color: #6b7280;
  margin-bottom: 8px;
}
.kb-meta-grid {
  display: grid;
  gap: 8px;
  margin-bottom: 20px;
  padding: 12px;
  background: #f9fafb;
  border-radius: 6px;
}
.kb-meta-row {
  display: flex;
  justify-content: space-between;
  font-size: 13px;
}
.kb-meta-key {
  color: #6b7280;
}
.kb-meta-value {
  font-weight: 500;
  color: #111827;
}
.kb-ocr-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}
.kb-ocr-title {
  font-size: 13px;
  color: #6b7280;
}
.kb-ocr-count {
  font-size: 12px;
  color: #9ca3af;
}
.kb-ocr-list {
  display: grid;
  gap: 6px;
}
.kb-ocr-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px;
  border-radius: 6px;
  cursor: pointer;
  background: #f9fafb;
  border: 1px solid #e5e7eb;
}
.kb-ocr-item--active {
  background: #dbeafe;
  border-color: #3b82f6;
}
.kb-ocr-dot {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  flex-shrink: 0;
  background: #3b82f6;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
}
.kb-ocr-dot--active {
  background: #ef4444;
}
.kb-ocr-label {
  font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
  font-size: 13px;
  color: #374151;
  word-break: break-all;
}
.kb-ocr-empty {
  padding: 20px;
  text-align: center;
  color: #9ca3af;
  background: #f9fafb;
  border-radius: 6px;
}
</style>
