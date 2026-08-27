<!--
  BOM 树递归节点（复刻原型 PartsPage renderNode）
  - 展开箭头 / 类型图标 / 标签 / part 分类标签 / 计数
  - 交互：选中(紫底) / hover(灰底) / 分类命中(绿底绿边)
-->
<template>
  <div>
    <div
      class="bom-row"
      :class="{ 'bom-row--active': isActive, 'bom-row--highlighted': isHighlighted }"
      :style="{ paddingLeft: `${8 + depth * 16}px` }"
      @click="emit('select', node)"
      @mouseenter="hover = true"
      @mouseleave="hover = false"
    >
      <span
        v-if="hasChildren"
        class="bom-arrow"
        @click.stop="emit('toggle', node.key)"
      >
        <ElIcon :size="14"><CaretBottom v-if="isOpen" /><CaretRight v-else /></ElIcon>
      </span>
      <span v-else class="bom-arrow-placeholder" />
      <FaSvgIcon :icon="iconMap[node.type]" :style="{ color: iconColor[node.type] }" class="bom-icon" />
      <span class="bom-label">{{ node.label }}</span>
      <span v-if="node.type === 'part' && node.category" class="bom-cat">{{ node.category }}</span>
      <span class="bom-count" :class="{ 'bom-count--active': isActive }">{{ node.count }}</span>
    </div>
    <template v-if="hasChildren && isOpen">
      <BomTreeNode
        v-for="c in node.children"
        :key="c.key"
        :node="c"
        :depth="depth + 1"
        :expanded="expanded"
        :selected-key="selectedKey"
        :highlighted="highlighted"
        @select="emit('select', $event)"
        @toggle="emit('toggle', $event)"
      />
    </template>
  </div>
</template>

<script setup lang="ts">
import { CaretBottom, CaretRight } from "@element-plus/icons-vue";
import FaSvgIcon from "@/components/base/fa-svg-icon/index.vue";

defineOptions({ name: "BomTreeNode" });

export interface BomNode {
  key: string;
  type: "plant" | "system" | "equipment" | "component" | "part";
  label: string;
  code?: string;
  category?: string;
  count: number;
  materials?: unknown[];
  children?: BomNode[];
}

const props = defineProps<{
  node: BomNode;
  depth: number;
  expanded: Set<string>;
  selectedKey: string;
  highlighted: Set<string>;
}>();

const emit = defineEmits<{
  select: [node: BomNode];
  toggle: [key: string];
}>();

const hover = ref(false);

const hasChildren = computed(() => !!(props.node.children && props.node.children.length > 0));
const isOpen = computed(() => props.expanded.has(props.node.key));
const isActive = computed(() => props.selectedKey === props.node.key);
const isHighlighted = computed(() => props.highlighted.has(props.node.key));

const iconMap: Record<string, string> = {
  plant: "ri:building-2-line",
  system: "ri:git-branch-line",
  equipment: "ri:settings-3-line",
  component: "ri:layers-line",
  part: "ri:puzzle-2-line",
};
const iconColor: Record<string, string> = {
  plant: "#4338ca",
  system: "#4338ca",
  equipment: "#3b82f6",
  component: "#0891b2",
  part: "#6b7280",
};
</script>

<style scoped>
.bom-row {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 8px;
  cursor: pointer;
  border-radius: 4px;
  font-size: 13px;
  color: #374151;
  border: 0.5px solid transparent;
}
.bom-row:hover {
  background: #f3f4f6;
}
.bom-row--active {
  color: #4338ca;
  font-weight: 500;
  background: #eef2ff;
}
.bom-row--highlighted {
  background: #ecfdf5;
  border-color: #18a058;
}
.bom-arrow {
  display: inline-flex;
  align-items: center;
  color: #9ca3af;
  cursor: pointer;
}
.bom-arrow-placeholder {
  width: 14px;
  display: inline-block;
}
.bom-icon {
  flex: 0 0 auto;
}
.bom-label {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.bom-cat {
  font-size: 10px;
  padding: 1px 6px;
  border-radius: 8px;
  background: #eef2ff;
  color: #4338ca;
  white-space: nowrap;
}
.bom-count {
  font-size: 11px;
  color: #9ca3af;
  background: #f3f4f6;
  padding: 1px 6px;
  border-radius: 8px;
  white-space: nowrap;
}
.bom-count--active {
  color: #4338ca;
  background: #e0e7ff;
}
</style>
