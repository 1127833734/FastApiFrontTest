<!--
  备件知识库 · 知识库 / 上传文档
  按原型 DocumentUploadPage 复刻：双 Tab（本地上传 3 步流程 / 库对接同步）
-->
<template>
  <div class="kb-upload">
    <div class="kb-page-header">
      <div class="kb-page-title">上传文档</div>
    </div>

    <ElCard shadow="never">
      <div class="kb-tabs">
        <div
          v-for="t in tabs"
          :key="t.value"
          class="kb-tab"
          :class="{ 'kb-tab--active': source === t.value }"
          @click="switchTab(t.value)"
        >
          {{ t.label }}
        </div>
      </div>

      <!-- ============ 本地上传 3 步流程 ============ -->
      <template v-if="source === 'upload'">
        <!-- 步骤条 -->
        <div class="kb-steps">
          <div v-for="(label, idx) in stepLabels" :key="label" class="kb-step" :class="{ 'kb-step--active': step >= idx + 1 }">
            <div class="kb-step-badge" :class="{ 'kb-step-badge--done': step >= idx + 1 }">{{ idx + 1 }}</div>
            <div class="kb-step-label">{{ label }}</div>
            <div v-if="idx < 2" class="kb-step-line" :class="{ 'kb-step-line--done': step > idx + 1 }" />
          </div>
        </div>

        <!-- step1 选择文件 -->
        <div v-if="step === 1" data-annotation-id="document-upload-batch">
          <div
            class="kb-dropzone"
            :class="{ 'kb-dropzone--over': dragOver }"
            @dragover.prevent="dragOver = true"
            @dragleave="dragOver = false"
            @drop.prevent="dragOver = false"
          >
            <ElIcon :size="48" color="#18a058" class="kb-dropzone-icon"><UploadFilled /></ElIcon>
            <div class="kb-dropzone-title">点击上传或拖拽文件到此处</div>
            <div class="kb-dropzone-sub">支持 PDF、DOCX、XLSX、图片批量上传，单个最大 500MB</div>
          </div>

          <div class="kb-file-list">
            <div class="kb-file-toolbar">
              <div class="kb-file-select-all">
                <ElCheckbox v-model="allSelected" @change="toggleSelectAll">全选</ElCheckbox>
              </div>
              <div class="kb-file-count">
                已选择 <strong style="color: #18a058">{{ selectedCount }}</strong> / {{ files.length }} 个文件
              </div>
            </div>
            <div class="kb-files">
              <div
                v-for="f in files"
                :key="f.id"
                class="kb-file-row"
                :class="{ 'kb-file-row--fail': f.status === 'precheck-fail' }"
              >
                <ElCheckbox
                  :model-value="f.selected"
                  :disabled="f.status === 'precheck-fail'"
                  @change="toggleSelect(f.id)"
                />
                <ElIcon :size="18" :color="fileIconColor(f.type)"><component :is="fileIcon(f.type)" /></ElIcon>
                <div class="kb-file-info">
                  <div class="kb-file-name">{{ f.name }}</div>
                  <div class="kb-file-size">{{ f.size }}</div>
                </div>
                <span
                  class="kb-precheck-tag"
                  :class="f.status === 'precheck-fail' ? 'kb-precheck-tag--fail' : 'kb-precheck-tag--pass'"
                >
                  {{ f.statusText }}
                </span>
              </div>
            </div>
            <div class="kb-flow-actions">
              <ElButton type="primary" :disabled="selectedCount === 0" @click="step = 2">下一步</ElButton>
            </div>
          </div>
        </div>

        <!-- step2 填写元数据 -->
        <div v-else-if="step === 2">
          <div class="kb-meta-grid">
            <div v-for="field in metaFields1" :key="field.label" class="kb-meta-item">
              <label class="kb-meta-label">{{ field.label }}</label>
              <ElSelect v-if="field.type === 'select'" v-model="field.value" :placeholder="field.placeholder" style="width: 100%">
                <ElOption v-for="o in field.options" :key="o" :label="o" :value="o" />
              </ElSelect>
              <ElInput v-else v-model="field.value" :placeholder="field.placeholder" />
            </div>
            <div v-for="field in metaFields2" :key="field.label" class="kb-meta-item">
              <label class="kb-meta-label">{{ field.label }}</label>
              <ElSelect v-if="field.type === 'select'" v-model="field.value" :placeholder="field.placeholder" style="width: 100%">
                <ElOption v-for="o in field.options" :key="o" :label="o" :value="o" />
              </ElSelect>
              <ElInput v-else v-model="field.value" :placeholder="field.placeholder" />
            </div>
          </div>
          <div class="kb-flow-actions">
            <ElButton @click="step = 1">上一步</ElButton>
            <ElButton type="primary" @click="step = 3">下一步</ElButton>
          </div>
        </div>

        <!-- step3 解析设置 -->
        <div v-else>
          <div class="kb-parse-title">请选择解析选项</div>
          <div class="kb-parse-options">
            <label v-for="opt in parseOptions" :key="opt" class="kb-parse-option">
              <ElCheckbox v-model="parseChecked" :label="opt" />
              <span>{{ opt }}</span>
            </label>
          </div>
          <div class="kb-parse-tip">
            <ElIcon color="#f59e0b"><WarningFilled /></ElIcon>
            大文件解析可能需要几分钟，请耐心等待。
          </div>
          <div class="kb-flow-actions">
            <ElButton @click="step = 2">上一步</ElButton>
            <ElButton type="primary" @click="startUpload">开始上传并解析</ElButton>
          </div>
        </div>
      </template>

      <!-- ============ 库对接 ============ -->
      <template v-else>
        <div class="kb-lib-tip">从文件服务器按机组目录同步文档至知识库，自动比对已存在文件与版本。</div>
        <div class="kb-lib-units">
          <ElCard v-for="u in units" :key="u.name" shadow="never" class="kb-lib-unit">
            <div class="kb-lib-unit-head">
              <span class="kb-lib-unit-name">{{ u.name }}机组</span>
              <span class="kb-lib-unit-count">{{ u.done }} / {{ u.total }}</span>
            </div>
            <ElProgress
              :percentage="u.total ? Math.round((u.done / u.total) * 100) : 0"
              :status="syncRunning ? undefined : u.done >= u.total && u.total > 0 ? 'success' : undefined"
              :stroke-width="8"
            />
            <div class="kb-lib-unit-sub">{{ u.name }} · 文档库目录</div>
          </ElCard>
        </div>

        <div class="kb-lib-config">
          <div class="kb-lib-config-title">同步配置</div>
          <ElForm label-width="90px" label-position="left">
            <ElFormItem label="冲突策略">
              <ElRadioGroup v-model="conflictPolicy">
                <ElRadio value="skip">跳过</ElRadio>
                <ElRadio value="overwrite">覆盖</ElRadio>
                <ElRadio value="ask">询问</ElRadio>
              </ElRadioGroup>
            </ElFormItem>
            <ElFormItem label="执行模式">
              <ElRadioGroup v-model="execMode">
                <ElRadio value="background">后台执行</ElRadio>
                <ElRadio value="foreground">前台执行</ElRadio>
              </ElRadioGroup>
            </ElFormItem>
          </ElForm>
        </div>

        <div class="kb-flow-actions">
          <ElButton :icon="Refresh" :loading="syncRunning" @click="startSync">开始同步</ElButton>
          <span v-if="syncFailed > 0" class="kb-lib-failed">同步失败 {{ syncFailed }} 项</span>
        </div>
      </template>
    </ElCard>
  </div>
</template>

<script setup lang="ts">
import { UploadFilled, Refresh, WarningFilled, Files, Document, Picture } from "@element-plus/icons-vue";
import { useRoute, useRouter } from "vue-router";

defineOptions({ name: "KbUpload" });

const route = useRoute();
const router = useRouter();

const tabs = [
  { value: "upload", label: "本地上传" },
  { value: "library", label: "库对接" },
];
const source = ref((route.query.tab as string) || "upload");
const step = ref(1);
const dragOver = ref(false);
const stepLabels = ["选择文件", "填写元数据", "解析设置"];

function switchTab(v: string) {
  source.value = v;
  router.replace({ query: { ...route.query, tab: v } });
}

// ---- step1 文件预检 ----
interface PrecheckFile {
  id: string;
  name: string;
  size: string;
  type: string;
  status: "precheck-pass" | "precheck-fail";
  statusText: string;
  selected: boolean;
}
const files = ref<PrecheckFile[]>([
  { id: "f-001", name: "泵 P-101 维修手册.pdf", size: "15.2 MB", type: "PDF", status: "precheck-pass", statusText: "预检通过", selected: true },
  { id: "f-002", name: "阀门备件清单.xlsx", size: "0.3 MB", type: "XLSX", status: "precheck-pass", statusText: "预检通过", selected: true },
  { id: "f-003", name: "电机图纸.jpg", size: "8.5 MB", type: "图片", status: "precheck-fail", statusText: "格式不兼容", selected: false },
  { id: "f-004", name: "主汽阀 MV-201 维修规程.pdf", size: "6.8 MB", type: "PDF", status: "precheck-pass", statusText: "预检通过", selected: true },
]);

const allSelected = computed(() => files.value.length > 0 && files.value.every((f) => f.selected));
const selectedCount = computed(() => files.value.filter((f) => f.selected && f.status !== "precheck-fail").length);

function toggleSelectAll() {
  const next = !allSelected.value;
  files.value.forEach((f) => {
    if (f.status !== "precheck-fail") f.selected = next;
  });
}
function toggleSelect(id: string) {
  const f = files.value.find((x) => x.id === id);
  if (f && f.status !== "precheck-fail") f.selected = !f.selected;
}
function fileIcon(type: string) {
  if (type === "XLSX") return Files;
  if (type === "图片") return Picture;
  return Document;
}
function fileIconColor(type: string) {
  if (type === "XLSX") return "#18a058";
  if (type === "图片") return "#3b82f6";
  return "#18a058";
}

// ---- step2 元数据 ----
interface MetaField {
  label: string;
  value: string;
  placeholder: string;
  type?: "select";
  options?: string[];
}
const metaFields1 = ref<MetaField[]>([
  { label: "文件编号 *", value: "", placeholder: "DOC-2026-XXX" },
  { label: "密级", value: "内部", placeholder: "", type: "select", options: ["内部", "秘密", "机密"] },
  { label: "生效日期", value: "", placeholder: "YYYY-MM-DD" },
]);
const metaFields2 = ref<MetaField[]>([
  { label: "所属机组", value: "1#机组", placeholder: "", type: "select", options: ["1#机组", "2#机组"] },
  { label: "所属系统", value: "给水系统", placeholder: "", type: "select", options: ["给水系统", "蒸汽系统", "电气系统"] },
  { label: "所属设备", value: "", placeholder: "泵 P-101" },
]);

// ---- step3 解析设置 ----
const parseOptions = ["自动 OCR 识别", "提取零件实体", "生成向量索引", "识别表格结构"];
const parseChecked = ref<string[]>([...parseOptions]);

function startUpload() {
  const count = selectedCount.value;
  if (count === 0) return;
  ElMessage.success(`已提交 ${count} 个文件开始上传并解析`);
  step.value = 1;
  files.value.forEach((f) => {
    if (f.selected) f.selected = false;
  });
}

// ---- 库对接 ----
const units = ref([
  { name: "1#", done: 0, total: 0 },
  { name: "2#", done: 0, total: 0 },
  { name: "3#", done: 0, total: 0 },
  { name: "4#", done: 0, total: 0 },
]);
const syncRunning = ref(false);
const syncFailed = ref(0);
const conflictPolicy = ref("skip");
const execMode = ref("background");

function startSync() {
  const perUnit = [286, 301, 254, 265];
  units.value.forEach((u, i) => {
    u.total = perUnit[i];
    u.done = 0;
  });
  syncFailed.value = 0;
  syncRunning.value = true;
  const timer = setInterval(() => {
    let finished = true;
    units.value.forEach((u) => {
      if (u.done < u.total) {
        u.done = Math.min(u.total, u.done + 4 + Math.round(Math.random() * 6));
        if (u.done < u.total) finished = false;
      }
    });
    if (finished) {
      clearInterval(timer);
      syncRunning.value = false;
      syncFailed.value = Math.floor(Math.random() * 4);
      ElMessage.success("库对接同步完成");
    }
  }, 220);
}
</script>

<style scoped>
.kb-upload {
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
.kb-tabs {
  display: flex;
  gap: 4px;
  border-bottom: 1px solid #e5e7eb;
  margin-bottom: 20px;
}
.kb-tab {
  padding: 10px 18px;
  cursor: pointer;
  font-size: 14px;
  color: #6b7280;
  border-bottom: 2px solid transparent;
  margin-bottom: -1px;
}
.kb-tab--active {
  color: #18a058;
  border-bottom-color: #18a058;
  font-weight: 600;
}
.kb-steps {
  display: flex;
  margin-bottom: 32px;
}
.kb-step {
  flex: 1;
  display: flex;
  align-items: center;
}
.kb-step-badge {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #e5e7eb;
  color: #9ca3af;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 600;
  flex: 0 0 auto;
}
.kb-step-badge--done {
  background: #18a058;
  color: #fff;
}
.kb-step-label {
  font-size: 12px;
  color: #6b7280;
  margin-top: 6px;
  text-align: center;
}
.kb-step--active .kb-step-label {
  color: #18a058;
}
.kb-step-line {
  flex: 1;
  height: 2px;
  background: #e5e7eb;
  margin: 0 12px;
  margin-top: -18px;
}
.kb-step-line--done {
  background: #18a058;
}
.kb-dropzone {
  border: 2px dashed #d1d5db;
  border-radius: 12px;
  padding: 48px 24px;
  text-align: center;
  background: #fafafa;
  transition: border-color 0.15s, background 0.15s;
}
.kb-dropzone--over {
  border-color: #18a058;
  background: #f0fdf4;
}
.kb-dropzone-icon {
  margin-bottom: 16px;
}
.kb-dropzone-title {
  font-size: 16px;
  color: #374151;
  font-weight: 500;
  margin-bottom: 8px;
}
.kb-dropzone-sub {
  font-size: 13px;
  color: #9ca3af;
}
.kb-file-list {
  margin-top: 20px;
}
.kb-file-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}
.kb-file-count {
  font-size: 13px;
  color: #6b7280;
}
.kb-files {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.kb-file-row {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px;
  border-radius: 6px;
  background: #f0fdf4;
  border: 1px solid #bbf7d0;
}
.kb-file-row--fail {
  background: #fef2f2;
  border-color: #fecaca;
}
.kb-file-info {
  flex: 1;
  min-width: 0;
}
.kb-file-name {
  font-size: 14px;
  color: #374151;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.kb-file-size {
  font-size: 12px;
  color: #9ca3af;
}
.kb-precheck-tag {
  font-size: 12px;
  padding: 2px 8px;
  border-radius: 4px;
  white-space: nowrap;
}
.kb-precheck-tag--pass {
  color: #3b6d11;
  background: #eaf3de;
}
.kb-precheck-tag--fail {
  color: #a32d2d;
  background: #fcebeb;
}
.kb-flow-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 24px;
  gap: 12px;
}
.kb-meta-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  margin-bottom: 16px;
}
.kb-meta-item {
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.kb-meta-label {
  font-size: 13px;
  color: #374151;
}
.kb-parse-title {
  font-size: 14px;
  color: #374151;
  margin-bottom: 16px;
}
.kb-parse-options {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.kb-parse-option {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  color: #374151;
}
.kb-parse-tip {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 16px;
  padding: 12px;
  background: #fffbeb;
  border-radius: 6px;
  color: #92400e;
  font-size: 13px;
}
.kb-lib-tip {
  font-size: 13px;
  color: #6b7280;
  margin-bottom: 16px;
}
.kb-lib-units {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 12px;
  margin-bottom: 16px;
}
.kb-lib-unit-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}
.kb-lib-unit-name {
  font-size: 14px;
  font-weight: 600;
  color: #374151;
}
.kb-lib-unit-count {
  font-size: 13px;
  color: #6b7280;
}
.kb-lib-unit-sub {
  font-size: 12px;
  color: #9ca3af;
  margin-top: 8px;
}
.kb-lib-config {
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 16px;
}
.kb-lib-config-title {
  font-size: 14px;
  font-weight: 600;
  color: #374151;
  margin-bottom: 12px;
}
.kb-lib-failed {
  font-size: 13px;
  color: #ef4444;
  align-self: center;
}
</style>
