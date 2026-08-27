<!--
  复核候选详情面板（原型 ReviewPanel）：零件/非零件判定 + 属性编辑 + 确认/跳过/驳回
-->
<template>
  <ElCard shadow="never" class="kb-panel">
    <div class="kb-panel-head">
      <div class="kb-panel-title">{{ candidate.label }}</div>
      <span class="kb-status-tag" :style="statusStyle[candidate.status]">{{ statusText[candidate.status] }}</span>
    </div>
    <div class="kb-panel-sub">{{ candidate.candidateType || "候选" }} · 第 {{ candidate.pageNo }} 页</div>

    <!-- 零件判定 -->
    <div class="kb-panel-section">
      <div class="kb-panel-section-title">此处是否为零件</div>
      <ElRadioGroup v-model="isPart" @change="onIsPartChange">
        <ElRadio :value="true">是</ElRadio>
        <ElRadio :value="false">否</ElRadio>
      </ElRadioGroup>
    </div>

    <!-- 零件属性 -->
    <div v-if="isPart" class="kb-panel-section">
      <div class="kb-panel-section-title">零件属性</div>
      <div class="kb-panel-form">
        <div v-for="field in partFields" :key="field.key" class="kb-panel-field">
          <label class="kb-panel-label">{{ field.label }}</label>
          <ElInput
            size="small"
            :model-value="candidate.partAttributes[field.key]"
            :placeholder="field.placeholder"
            @update:model-value="(v) => updateAttr(field.key, v)"
          />
        </div>
      </div>
    </div>
    <div v-else class="kb-panel-notpart">
      <ElAlert type="info" :closable="false" show-icon title="该候选为非零件内容（操作步骤 / 安全提示等），确认后不会进入零件库。" />
    </div>

    <!-- 操作 -->
    <div class="kb-panel-actions">
      <ElButton type="primary" :icon="CircleCheck" @click="confirmNext">确认并下一个</ElButton>
      <ElButton :icon="DArrowRight" @click="skip">跳过</ElButton>
      <ElButton type="danger" plain :icon="CircleClose" @click="reject">驳回</ElButton>
    </div>
  </ElCard>
</template>

<script setup lang="ts">
import { CircleCheck, DArrowRight, CircleClose } from "@element-plus/icons-vue";
import type { ReviewCandidate, PartAttributes } from "./types";

defineOptions({ name: "KbReviewPanel" });

const props = defineProps<{ candidate: ReviewCandidate }>();
const emit = defineEmits<{
  change: [patch: Record<string, unknown>];
  confirmNext: [];
  skip: [];
  reject: [];
}>();

const statusText: Record<string, string> = {
  pending: "待复核",
  confirmed: "已确认",
  rejected: "已驳回",
  skipped: "已跳过",
};
const statusStyle: Record<string, { color: string; background: string }> = {
  pending: { color: "#f59e0b", background: "#faf0d8" },
  confirmed: { color: "#18a058", background: "#e1f5ee" },
  rejected: { color: "#ef4444", background: "#fcebeb" },
  skipped: { color: "#6b7280", background: "#f1efee" },
};

const isPart = ref(props.candidate.isPart);

const partFields: { key: keyof PartAttributes; label: string; placeholder: string }[] = [
  { key: "partNo", label: "零件编号", placeholder: "如 P101-001" },
  { key: "name", label: "名称", placeholder: "如 轴承" },
  { key: "spec", label: "型号规格", placeholder: "如 6208-2RS" },
  { key: "material", label: "材质", placeholder: "如 GCr15" },
  { key: "unit", label: "所属机组", placeholder: "如 1#机组" },
  { key: "system", label: "所属系统", placeholder: "如 给水系统" },
  { key: "device", label: "所属设备", placeholder: "如 泵 P-101" },
  { key: "installLocation", label: "安装位置", placeholder: "如 泵驱动端" },
  { key: "category", label: "分类", placeholder: "机械/电气" },
  { key: "level", label: "级别", placeholder: "A级/B级/C级" },
  { key: "importance", label: "重要度", placeholder: "关键/重要/一般" },
  { key: "radiationRisk", label: "辐射风险", placeholder: "低/中/高" },
];

function onIsPartChange(v: string | number | boolean) {
  emit("change", { isPart: Boolean(v) });
}

function updateAttr(key: keyof PartAttributes, value: string) {
  emit("change", { partAttributes: { ...props.candidate.partAttributes, [key]: value } });
}

function confirmNext() {
  emit("confirmNext");
}
function skip() {
  emit("skip");
}
function reject() {
  emit("reject");
}
</script>

<style scoped>
.kb-panel {
  max-height: 760px;
  overflow: auto;
}
.kb-panel-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}
.kb-panel-title {
  font-size: 15px;
  font-weight: 600;
  color: #111827;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.kb-status-tag {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  white-space: nowrap;
}
.kb-panel-sub {
  font-size: 12px;
  color: #9ca3af;
  margin-top: 4px;
}
.kb-panel-section {
  margin-top: 16px;
}
.kb-panel-section-title {
  font-size: 13px;
  font-weight: 600;
  color: #374151;
  margin-bottom: 10px;
}
.kb-panel-form {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}
.kb-panel-field {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.kb-panel-label {
  font-size: 12px;
  color: #6b7280;
}
.kb-panel-notpart {
  margin-top: 4px;
}
.kb-panel-actions {
  margin-top: 20px;
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}
</style>
