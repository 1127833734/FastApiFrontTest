<!--
  备件知识库 · 零件库 / 备件管理（数据项维护）
  完全复刻原型 DataMaintenancePage：分类选择(增删) + 数据项展示/必填/字段名编辑
-->
<template>
  <div class="kb-dm page-container">
    <!-- 页头 -->
    <div class="kb-dm-title">数据项维护</div>

    <!-- 分类选择卡 -->
    <ElCard shadow="never" class="kb-dm-category">
      <div class="kb-dm-category-head">
        <div class="kb-dm-category-label">选择分类</div>
        <span class="kb-dm-category-hint">点击切换，编辑该分类下的数据项规则</span>
      </div>
      <div class="kb-dm-category-row">
        <div v-for="cat in categoryKeys" :key="cat" class="kb-dm-cat-item">
          <button
            class="kb-dm-cat-btn"
            :class="{ 'kb-dm-cat-btn--active': activeCategory === cat }"
            @click="activeCategory = cat"
          >
            {{ cat }}
          </button>
          <button
            v-if="!builtinCategories.includes(cat)"
            class="kb-dm-cat-del"
            title="删除分类"
            @click="deleteCategory(cat)"
          >
            <ElIcon :size="14"><Delete /></ElIcon>
          </button>
        </div>
        <div class="kb-dm-cat-add">
          <ElInput
            v-model="newCategoryName"
            placeholder="新增分类"
            style="width: 120px"
            @keyup.enter="addCategory"
          />
          <ElButton size="small" :icon="Plus" @click="addCategory">新增</ElButton>
        </div>
      </div>
    </ElCard>

    <!-- 数据项配置卡 -->
    <ElCard shadow="never">
      <div class="kb-dm-config-head">
        <span class="kb-dm-dot" />
        <div class="kb-dm-config-title">{{ activeCategory }} · 数据项</div>
        <span class="kb-dm-config-hint">
          共 {{ currentCategory.fields.length }} 项 · 展示 {{ visibleCount }} 项 · 必填 {{ requiredCount }} 项
        </span>
      </div>

      <ElTable :data="currentCategory.fields" style="width: 100%" table-layout="fixed">
        <ElTableColumn label="序号" width="90" align="center">
          <template #default="{ $index }">
            <span style="color: #9ca3af">{{ $index + 1 }}</span>
          </template>
        </ElTableColumn>
        <ElTableColumn label="数据项（字段名）" min-width="240">
          <template #default="{ row }">
            <ElInput
              v-if="editingField === row.field"
              :model-value="draft?.field"
              size="small"
              @update:model-value="(v) => (draft = { ...draft, field: v })"
            />
            <span v-else>{{ row.field }}</span>
          </template>
        </ElTableColumn>
        <ElTableColumn label="是否展示" width="130" align="center">
          <template #default="{ row }">
            <button
              class="kb-dm-pill"
              :class="row.visible ? 'kb-dm-pill--show' : ''"
              @click="toggleVisible(row.field)"
            >
              {{ row.visible ? "展示" : "隐藏" }}
            </button>
          </template>
        </ElTableColumn>
        <ElTableColumn label="是否必填" width="130" align="center">
          <template #default="{ row }">
            <button
              class="kb-dm-pill"
              :class="row.required ? 'kb-dm-pill--required' : ''"
              @click="toggleRequired(row.field)"
            >
              {{ row.required ? "必填" : "选填" }}
            </button>
          </template>
        </ElTableColumn>
        <ElTableColumn label="操作" width="110" align="center">
          <template #default="{ row }">
            <div class="kb-dm-ops">
              <template v-if="editingField === row.field">
                <ElButton link type="success" :icon="Select" @click="commitEdit" />
                <ElButton link :icon="Close" @click="cancelEdit" />
              </template>
              <ElTooltip v-else content="编辑字段名">
                <ElButton link type="primary" :icon="EditPen" @click="startEdit(row)" />
              </ElTooltip>
            </div>
          </template>
        </ElTableColumn>
      </ElTable>
    </ElCard>
  </div>
</template>

<script setup lang="ts">
import { Plus, Delete, Select, Close, EditPen } from "@element-plus/icons-vue";
import { reactive, computed } from "vue";

defineOptions({ name: "KbSpares" });

/** 复刻原型 BOM_HEADERS */
const BOM_HEADERS = [
  "序号", "物料名称", "名称", "公称直径(公制)", "螺距(公制)", "长度", "螺纹长度", "材质", "强度等级", "标准(公制)",
  "公称直径(英制)", "螺距(英制)", "强度", "标准(英制)", "内径", "丝径", "其他参数", "型号规格/图号",
  "名称(国标)", "类别(国标)", "连接方式(国标)", "结构形式(国标)", "密封面(国标)", "压力(国标)", "材质(国标)", "口径(国标)",
  "阀门形式(公制)", "进口压力等级(公制)", "进口连接形式(公制)", "出口压力等级(公制)", "出口连接形式(公制)",
  "进口口径(公制)", "喉径(公制)", "出口口径(公制)", "密封面(公制)", "型号", "电压等级", "外形", "颜色", "颈部尺寸",
  "额定电压", "额定容量", "结构类型", "表盘直径", "测量范围", "插入深度", "外保护套管形式", "外保护套管材质",
  "外保护套管外径", "过程连接", "测量精度",
];

const builtinCategories = ["紧固件", "密封件", "阀门", "传动件", "电气仪表"];

interface FieldItem {
  field: string;
  visible: boolean;
  required: boolean;
}
interface CategoryConfig {
  name: string;
  fields: FieldItem[];
}

const DEFAULT_REQUIRED = new Set(["物料名称", "型号规格/图号"]);

function buildConfig(): Record<string, CategoryConfig> {
  const config: Record<string, CategoryConfig> = {};
  builtinCategories.forEach((cat) => {
    config[cat] = {
      name: cat,
      fields: BOM_HEADERS.map((field) => ({
        field,
        visible: true,
        required: DEFAULT_REQUIRED.has(field),
      })),
    };
  });
  return config;
}

const config = reactive(buildConfig());
const activeCategory = ref(builtinCategories[0]);
const editingField = ref<string | null>(null);
const draft = ref<FieldItem | null>(null);
const newCategoryName = ref("");

const categoryKeys = computed(() => Object.keys(config));
const currentCategory = computed(() => config[activeCategory.value]);
const visibleCount = computed(() => currentCategory.value.fields.filter((f) => f.visible).length);
const requiredCount = computed(() => currentCategory.value.fields.filter((f) => f.required).length);

function startEdit(item: FieldItem) {
  editingField.value = item.field;
  draft.value = { ...item };
}
function cancelEdit() {
  editingField.value = null;
  draft.value = null;
}
function commitEdit() {
  if (!draft.value) return;
  const cat = config[activeCategory.value];
  const idx = cat.fields.findIndex((it) => it.field === editingField.value);
  if (idx >= 0) {
    cat.fields[idx] = { ...draft.value };
    // 若字段名变更，移除旧字段名避免残留（保持与原型一致：替换整项）
  }
  editingField.value = null;
  draft.value = null;
}
function toggleVisible(field: string) {
  const item = currentCategory.value.fields.find((it) => it.field === field);
  if (item) item.visible = !item.visible;
}
function toggleRequired(field: string) {
  const item = currentCategory.value.fields.find((it) => it.field === field);
  if (item) item.required = !item.required;
}
function addCategory() {
  const name = newCategoryName.value.trim();
  if (!name || config[name]) return;
  config[name] = {
    name,
    fields: BOM_HEADERS.map((field) => ({
      field,
      visible: true,
      required: DEFAULT_REQUIRED.has(field),
    })),
  };
  newCategoryName.value = "";
  activeCategory.value = name;
}
function deleteCategory(cat: string) {
  if (builtinCategories.includes(cat)) {
    ElMessage.warning("系统内置分类不允许删除");
    return;
  }
  delete config[cat];
  activeCategory.value = builtinCategories[0];
}
</script>

<style scoped>
.kb-dm {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.kb-dm-title {
  font-size: 18px;
  font-weight: 600;
  color: #111827;
}
/* 分类选择卡 */
.kb-dm-category {
  flex-shrink: 0;
  min-height: 110px;
}
.kb-dm-category-head {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
  flex-shrink: 0;
}
.kb-dm-category-label {
  font-size: 13px;
  font-weight: 600;
  color: #111827;
}
.kb-dm-category-hint {
  font-size: 12px;
  color: #6b7280;
}
.kb-dm-category-row {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
  min-height: 32px;
}
.kb-dm-cat-item {
  display: flex;
  align-items: center;
  gap: 4px;
}
.kb-dm-cat-btn {
  font-size: 13px;
  padding: 6px 14px;
  border-radius: 6px;
  border: 0.5px solid #e5e7eb;
  background: #ffffff;
  color: #374151;
  cursor: pointer;
}
.kb-dm-cat-btn--active {
  border-color: #4338ca;
  background: #eef2ff;
  color: #4338ca;
}
.kb-dm-cat-del {
  background: transparent;
  border: 0;
  cursor: pointer;
  color: #ef4444;
  padding: 4px;
  display: inline-flex;
  align-items: center;
}
.kb-dm-cat-add {
  display: flex;
  gap: 6px;
  align-items: center;
}
/* 数据项配置 */
.kb-dm-config-head {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 16px;
}
.kb-dm-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #3b82f6;
  flex: 0 0 auto;
}
.kb-dm-config-title {
  font-size: 14px;
  font-weight: 600;
  color: #111827;
}
.kb-dm-config-hint {
  font-size: 12px;
  color: #6b7280;
}
/* 展示/必填 胶囊 */
.kb-dm-pill {
  font-size: 12px;
  padding: 3px 10px;
  border-radius: 12px;
  border: 1px solid #e5e7eb;
  background: #ffffff;
  color: #6b7280;
  cursor: pointer;
}
.kb-dm-pill--show {
  border-color: #18a058;
  background: #f0fdf4;
  color: #166534;
}
.kb-dm-pill--required {
  border-color: #dc2626;
  background: #fef2f2;
  color: #dc2626;
}
.kb-dm-ops {
  display: flex;
  gap: 8px;
  justify-content: center;
}
</style>
