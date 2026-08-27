<!--
  备件知识库 · 知识库 / 文档查看器
  复刻原型 viewer 页：左侧文档画布（标注点）+ 右侧元数据与标注列表
-->
<template>
  <div class="kb-viewer">
    <!-- 文档画布 -->
    <ElCard shadow="never" class="kb-viewer-canvas">
      <template #header>
        <div class="kb-canvas-header">
          <span class="kb-card-title">{{ doc.title }}</span>
          <div>
            <ElButton size="small" :icon="ZoomOut" circle @click="zoomOut" />
            <ElButton size="small" :icon="ZoomIn" circle @click="zoomIn" />
            <ElButton size="small" :icon="FullScreen" circle @click="fullscreen" />
          </div>
        </div>
      </template>
      <div class="kb-canvas-body" :style="{ transform: `scale(${zoom})` }">
        <div v-for="line in docLines" :key="line.no" class="kb-canvas-line">
          <span class="kb-canvas-no">{{ line.no }}</span>
          <span>{{ line.text }}</span>
          <span
            v-if="line.annotation"
            class="kb-canvas-annotation"
            :style="{ left: line.annotation.x, top: line.annotation.y }"
          />
        </div>
        <div class="kb-canvas-tip">图中橙色标注点表示待复核位置，点击右侧标注列表可定位</div>
      </div>
    </ElCard>

    <!-- 右侧元数据 -->
    <div class="kb-viewer-side">
      <ElCard shadow="never">
        <template #header>
          <span class="kb-card-title">文档信息</span>
        </template>
        <ElDescriptions :column="1" size="small" border>
          <ElDescriptionsItem label="标题">{{ doc.title }}</ElDescriptionsItem>
          <ElDescriptionsItem label="文档编号">{{ doc.docNo }}</ElDescriptionsItem>
          <ElDescriptionsItem label="版本">{{ doc.version }}</ElDescriptionsItem>
          <ElDescriptionsItem label="来源部门">{{ doc.department }}</ElDescriptionsItem>
          <ElDescriptionsItem label="密级">
            <ElTag size="small" type="warning" effect="plain">{{ doc.secretLevel }}</ElTag>
          </ElDescriptionsItem>
          <ElDescriptionsItem label="页数">{{ doc.pageCount }} 页</ElDescriptionsItem>
          <ElDescriptionsItem label="生效日期">{{ doc.effectiveDate }}</ElDescriptionsItem>
        </ElDescriptions>
      </ElCard>

      <ElCard shadow="never">
        <template #header>
          <span class="kb-card-title">标注列表</span>
        </template>
        <div class="kb-annotations">
          <div v-for="a in annotations" :key="a.id" class="kb-annotation">
            <span class="kb-annotation-dot" :style="{ background: a.color }" />
            <div class="kb-annotation-body">
              <div class="kb-annotation-label">{{ a.label }}</div>
              <div class="kb-annotation-sub">{{ a.detail }}</div>
            </div>
            <ElButton link type="primary" size="small" @click="jumpTo(a)">定位</ElButton>
          </div>
        </div>
      </ElCard>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ZoomIn, ZoomOut, FullScreen } from "@element-plus/icons-vue";

defineOptions({ name: "KbViewer" });

const zoom = ref(1);
const doc = {
  title: "泵 P-101 维修手册",
  docNo: "DOC-2026-0087",
  version: "V2.1",
  department: "技术部",
  secretLevel: "内部",
  pageCount: 128,
  effectiveDate: "2026-06-15",
};

const docLines = [
  { no: 14, text: "4.3 轴承检查与更换", annotation: undefined },
  { no: 15, text: "泵 P-101 驱动端轴承型号为 6208-2RS，非驱动端为 6207-2RS。", annotation: { x: "30%", y: "10%" } },
  { no: 16, text: "拆卸泵联轴器护罩，拆除旧轴承，检查轴承座内孔。", annotation: undefined },
  { no: 17, text: "安装新轴承 6208-2RS，注意保持清洁并涂抹润滑脂。", annotation: { x: "55%", y: "12%" } },
  { no: 18, text: "回装联轴器，手动盘车确认转动灵活后试运行。", annotation: undefined },
  { no: 19, text: "安全提示：必须确认设备已断电并挂牌。", annotation: { x: "20%", y: "30%" } },
];

const annotations = [
  { id: "a1", label: "零件识别：轴承 6208-2RS", detail: "P101-001 · 驱动端", color: "#f59e0b" },
  { id: "a2", label: "零件识别：轴承 6207-2RS", detail: "非驱动端", color: "#f59e0b" },
  { id: "a3", label: "安全提示标注", detail: "断电挂牌", color: "#ef4444" },
];

function zoomIn() {
  zoom.value = Math.min(1.6, zoom.value + 0.1);
}
function zoomOut() {
  zoom.value = Math.max(0.6, zoom.value - 0.1);
}
function fullscreen() {
  zoom.value = 1;
}
function jumpTo(a: (typeof annotations)[number]) {
  ElMessage.info(`已定位到标注：${a.label}`);
}
</script>

<style scoped>
.kb-viewer {
  display: grid;
  grid-template-columns: 1fr 320px;
  gap: 12px;
  align-items: start;
}
.kb-canvas-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.kb-card-title {
  font-size: 15px;
  font-weight: 600;
  color: #111827;
}
.kb-canvas-body {
  background: #f8fafc;
  border-radius: 6px;
  padding: 24px;
  min-height: 480px;
  transform-origin: top left;
  position: relative;
}
.kb-canvas-line {
  position: relative;
  padding: 6px 0 6px 40px;
  font-size: 14px;
  line-height: 1.8;
  color: #1f2937;
  border-bottom: 1px dashed #e5e7eb;
}
.kb-canvas-no {
  position: absolute;
  left: 8px;
  color: #9ca3af;
  font-size: 12px;
  top: 10px;
}
.kb-canvas-annotation {
  position: absolute;
  width: 14px;
  height: 14px;
  border-radius: 50%;
  background: #f59e0b;
  border: 2px solid #fff;
  box-shadow: 0 0 0 2px #f59e0b;
  cursor: pointer;
}
.kb-canvas-tip {
  margin-top: 16px;
  font-size: 12px;
  color: #9ca3af;
}
.kb-viewer-side {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.kb-annotations {
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.kb-annotation {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  padding: 10px;
  background: #f9fafb;
  border-radius: 6px;
}
.kb-annotation-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  margin-top: 5px;
  flex: 0 0 auto;
}
.kb-annotation-body {
  flex: 1;
  min-width: 0;
}
.kb-annotation-label {
  font-size: 13px;
  color: #374151;
  font-weight: 500;
}
.kb-annotation-sub {
  font-size: 12px;
  color: #9ca3af;
  margin-top: 2px;
}
</style>
