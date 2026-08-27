<!--
  备件知识库 · 零件库 / 零件管理
  完全复刻原型 PartsPage：机组筛选 + KPI 统计 + 分类筛选(树联动高亮) + BOM 树 + 物料表格(库存行内编辑) + 字段来源折叠卡
-->
<template>
  <div class="kb-pm page-container">
    <!-- 页头 -->
    <div class="kb-pm-header">
      <div class="kb-pm-header-title">零件管理</div>
      <div class="kb-pm-header-actions">
        <ElButton :icon="Download" @click="handleExport">导出</ElButton>
        <ElButton type="primary" :icon="Plus" @click="handleAdd">新增</ElButton>
      </div>
    </div>

    <!-- 机组筛选 -->
    <div class="kb-pm-unit-filter">
      <span class="kb-pm-filter-label">机组：</span>
      <button
        v-for="u in unitOptions"
        :key="u || 'all'"
        class="kb-pm-pill"
        :class="{ 'kb-pm-pill--active': unitFilter === u }"
        @click="unitFilter = u"
      >
        {{ u || "全部" }}
      </button>
    </div>

    <!-- KPI 统计卡 -->
    <div class="kb-pm-stats">
      <ElCard v-for="s in stats" :key="s.label" shadow="never" class="kb-pm-stat">
        <div class="kb-pm-stat-label">{{ s.label }}</div>
        <div class="kb-pm-stat-value" :style="{ color: s.color }">{{ s.value }}</div>
      </ElCard>
    </div>

    <!-- 分类筛选 + 搜索 -->
    <ElCard shadow="never" class="kb-pm-filter">
      <div class="kb-pm-filter-row">
        <button
          v-for="cat in categories"
          :key="cat"
          class="kb-pm-pill"
          :class="{ 'kb-pm-pill--active': selectedCategories.has(cat) }"
          @click="toggleCategory(cat)"
        >
          {{ cat }}
        </button>
        <button v-if="selectedCategories.size > 0" class="kb-pm-clear" @click="clearCategories">清除筛选</button>
      </div>
      <ElInput
        v-model="search"
        placeholder="搜索物料号、规格型号、厂家、材质、零件名称..."
        :prefix-icon="Search"
        clearable
        class="kb-pm-search"
      />
    </ElCard>

    <!-- 左右双栏 -->
    <div class="kb-pm-main">
      <!-- 左：BOM 主树 -->
      <div class="kb-pm-tree">
        <div class="kb-pm-tree-head">
          <FaSvgIcon icon="ri:git-branch-line" style="color: #4338ca" />
          <span>BOM 主树</span>
        </div>
        <div class="kb-pm-tree-body">
          <BomTreeNode
            v-for="node in tree"
            :key="node.key"
            :node="node"
            :depth="0"
            :expanded="expanded"
            :selected-key="selectedKey"
            :highlighted="highlightedKeys"
            @select="handleTreeSelect"
            @toggle="toggleExpand"
          />
        </div>
      </div>

      <!-- 右：物料表格 -->
      <div class="kb-pm-table-card">
        <div class="kb-pm-location">当前位置：<strong>{{ breadcrumb }}</strong></div>

        <ElTable :data="filteredMaterials" style="width: 100%" table-layout="fixed" @row-click="viewPart">
          <ElTableColumn prop="materialNo" label="物料号" width="130">
            <template #default="{ row }">
              <span>{{ row.materialNo || "-" }}</span>
              <span v-if="isDuplicate(row)" class="kb-pm-duplicate">疑似重复</span>
            </template>
          </ElTableColumn>
          <ElTableColumn label="安装位置" min-width="150" show-overflow-tooltip>
            <template #default="{ row }">{{ row.installLocation || "-" }}</template>
          </ElTableColumn>
          <ElTableColumn label="规格型号" min-width="180" show-overflow-tooltip>
            <template #default="{ row }">{{ row.spec || "-" }}</template>
          </ElTableColumn>
          <ElTableColumn label="厂家" min-width="110" show-overflow-tooltip>
            <template #default="{ row }">{{ row.manufacturer || "-" }}</template>
          </ElTableColumn>
          <ElTableColumn label="材质" width="100">
            <template #default="{ row }">{{ row.material || "-" }}</template>
          </ElTableColumn>
          <ElTableColumn label="库存" width="140" align="center">
            <template #default="{ row }">
              <div v-if="editingStockId === row.id" class="kb-pm-stock-edit">
                <ElInput
                  v-model="editingStockValue"
                  type="number"
                  min="0"
                  size="small"
                  style="width: 72px"
                  @keydown.enter="commitEditStock(row.id)"
                  @keydown.esc="cancelEditStock"
                />
                <ElButton link type="success" :icon="Select" @click.stop="commitEditStock(row.id)" />
                <ElButton link :icon="Close" @click.stop="cancelEditStock" />
              </div>
              <div v-else class="kb-pm-stock" @click.stop="startEditStock(row)">
                <span>{{ row.stock ?? "-" }}</span>
                <ElIcon :size="12" color="#9ca3af"><EditPen /></ElIcon>
              </div>
            </template>
          </ElTableColumn>
          <ElTableColumn label="操作" width="70" align="center">
            <template #default="{ row }">
              <ElTooltip content="查看">
                <ElButton link type="primary" :icon="View" circle @click.stop="viewPart(row)" />
              </ElTooltip>
            </template>
          </ElTableColumn>
          <template #empty>
            <div class="kb-pm-empty">没有匹配的物料</div>
          </template>
        </ElTable>

        <!-- 表格底部 -->
        <div class="kb-pm-footer">
          <div class="kb-pm-footer-count">
            共 {{ filteredMaterials.length }} 条物料 / 当前节点共 {{ selectedNode?.count ?? materialCount }} 条
          </div>
          <div class="kb-pm-pager">
            <ElButton size="small">上一页</ElButton>
            <span class="kb-pm-page">1 / 1</span>
            <ElButton size="small">下一页</ElButton>
          </div>
        </div>
      </div>
    </div>

    <!-- 字段维护来源（折叠卡） -->
    <div class="kb-pm-source">
      <div class="kb-pm-source-head" @click="showSourceNote = !showSourceNote">
        <div>
          <strong>字段维护来源</strong>
          <span class="kb-pm-source-sub">物料各字段在系统中的来源与维护位置</span>
        </div>
        <ElIcon color="#6b7280"><CaretBottom v-if="showSourceNote" /><CaretRight v-else /></ElIcon>
      </div>
      <ElTable v-if="showSourceNote" :data="sourceRows" size="small">
        <ElTableColumn prop="field" label="字段" min-width="180" />
        <ElTableColumn prop="module" label="维护模块" width="140" />
        <ElTableColumn prop="owner" label="维护责任方" width="160" />
        <ElTableColumn prop="method" label="维护方式" min-width="240" />
      </ElTable>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Download, Plus, Search, View, Select, Close, EditPen, CaretBottom, CaretRight } from "@element-plus/icons-vue";
import FaSvgIcon from "@/components/base/fa-svg-icon/index.vue";
import BomTreeNode, { type BomNode } from "./BomTreeNode.vue";

defineOptions({ name: "KbPartList" });

// ---------- 物料数据 ----------
interface Material {
  id: string;
  materialNo: string;
  name: string;
  partNo: string;
  partName: string;
  spec: string;
  material: string;
  manufacturer: string;
  stock: number;
  unit: string;
  system: string;
  systemCode: string;
  device: string;
  equipmentCode: string;
  component: string;
  componentCode: string;
  installLocation: string;
  category: string;
  importance: string;
}

const materials: Material[] = [
  { id: "m-001", materialNo: "M-001", name: "六角螺栓", partNo: "P-001", partName: "六角螺栓", spec: "GB/T 5783-M16×60-8.8", material: "35CrMo", manufacturer: "上海电气", stock: 12, unit: "1#机组", system: "给水系统", systemCode: "SYS-001", device: "给水泵 P-101", equipmentCode: "EQ-001", component: "泵壳组件", componentCode: "C-001", installLocation: "给水泵 P-101 · 泵壳组件", category: "紧固件", importance: "关键" },
  { id: "m-002", materialNo: "M-002", name: "六角螺栓", partNo: "P-001", partName: "六角螺栓", spec: "GB/T 5783-M20×80-10.9", material: "45钢", manufacturer: "东方电气", stock: 8, unit: "1#机组", system: "给水系统", systemCode: "SYS-001", device: "给水泵 P-101", equipmentCode: "EQ-001", component: "泵壳组件", componentCode: "C-001", installLocation: "给水泵 P-101 · 泵壳组件", category: "紧固件", importance: "关键" },
  { id: "m-003", materialNo: "M-003", name: "密封垫", partNo: "P-013", partName: "密封垫", spec: "DN100 PN16 缠绕垫", material: "柔性石墨+不锈钢", manufacturer: "南方密封", stock: 9, unit: "1#机组", system: "给水系统", systemCode: "SYS-001", device: "给水泵 P-101", equipmentCode: "EQ-001", component: "泵壳组件", componentCode: "C-001", installLocation: "给水泵 P-101 · 泵壳组件", category: "密封件", importance: "重要" },
  { id: "m-004", materialNo: "M-004", name: "O型密封圈", partNo: "P-003", partName: "O型密封圈", spec: "Φ85×3.1 NBR", material: "NBR 丁腈橡胶", manufacturer: "Gore 中国", stock: 6, unit: "1#机组", system: "给水系统", systemCode: "SYS-001", device: "给水泵 P-101", equipmentCode: "EQ-001", component: "轴封组件", componentCode: "C-002", installLocation: "给水泵 P-101 · 轴封组件", category: "密封件", importance: "重要" },
  { id: "m-005", materialNo: "M-005", name: "机械密封", partNo: "P-014", partName: "机械密封", spec: "MG1-45 机械密封", material: "碳化硅/石墨", manufacturer: "沈阳鼓风机", stock: 2, unit: "1#机组", system: "给水系统", systemCode: "SYS-001", device: "给水泵 P-101", equipmentCode: "EQ-001", component: "轴封组件", componentCode: "C-002", installLocation: "给水泵 P-101 · 轴封组件", category: "其他", importance: "关键" },
  { id: "m-006", materialNo: "M-006", name: "联轴器", partNo: "P-004", partName: "联轴器", spec: "LZG-00 十字滑块联轴器", material: "ZG310-570/45", manufacturer: "沈阳鼓风机", stock: 1, unit: "1#机组", system: "给水系统", systemCode: "SYS-001", device: "给水泵 P-101", equipmentCode: "EQ-001", component: "联轴器组件", componentCode: "C-003", installLocation: "给水泵 P-101 · 联轴器组件", category: "传动件", importance: "关键" },
  { id: "m-007", materialNo: "M-007", name: "安全阀", partNo: "P-005", partName: "安全阀", spec: "A48Y-16C DN50", material: "WCB", manufacturer: "哈电集团", stock: 8, unit: "2#机组", system: "给水系统", systemCode: "SYS-001", device: "给水调节阀 FCV-201", equipmentCode: "EQ-002", component: "阀体组件", componentCode: "C-004", installLocation: "给水调节阀 FCV-201 · 阀体组件", category: "阀门", importance: "关键" },
  { id: "m-008", materialNo: "M-008", name: "截止阀", partNo: "P-006", partName: "截止阀", spec: "JZF-0 DN50", material: "HT150/ZCuZn38", manufacturer: "重庆川仪", stock: 5, unit: "2#机组", system: "给水系统", systemCode: "SYS-001", device: "给水调节阀 FCV-201", equipmentCode: "EQ-002", component: "阀芯组件", componentCode: "C-005", installLocation: "给水调节阀 FCV-201 · 阀芯组件", category: "阀门", importance: "重要" },
  { id: "m-009", materialNo: "M-009", name: "L型密封圈", partNo: "P-006", partName: "L型密封圈", spec: "Φ140×Φ160 FKM", material: "氟橡胶 FKM", manufacturer: "南方密封", stock: 4, unit: "2#机组", system: "蒸汽系统", systemCode: "SYS-002", device: "主汽阀 MV-201", equipmentCode: "EQ-003", component: "阀体组件", componentCode: "C-006", installLocation: "主汽阀 MV-201 · 阀体组件", category: "密封件", importance: "重要" },
  { id: "m-010", materialNo: "M-010", name: "O型圈", partNo: "P-008", partName: "O型圈", spec: "Φ100×5.3 NBR", material: "NBR", manufacturer: "Gore 中国", stock: 10, unit: "2#机组", system: "蒸汽系统", systemCode: "SYS-002", device: "主汽阀 MV-201", equipmentCode: "EQ-003", component: "执行机构组件", componentCode: "C-007", installLocation: "主汽阀 MV-201 · 执行机构", category: "密封件", importance: "一般" },
  { id: "m-011", materialNo: "M-011", name: "轴承", partNo: "P-015", partName: "轴承", spec: "6208-2RS", material: "GCr15", manufacturer: "SKF 中国", stock: 5, unit: "1#机组", system: "电气系统", systemCode: "SYS-003", device: "电机 M-105", equipmentCode: "EQ-004", component: "转子组件", componentCode: "C-008", installLocation: "电机 M-105 · 转子组件", category: "传动件", importance: "关键" },
  { id: "m-012", materialNo: "M-012", name: "碳刷", partNo: "P-009", partName: "碳刷", spec: "D374N 25×32×60", material: "电化石墨", manufacturer: "哈尔滨轴承", stock: 12, unit: "1#机组", system: "电气系统", systemCode: "SYS-003", device: "电机 M-105", equipmentCode: "EQ-004", component: "电气柜组件", componentCode: "C-009", installLocation: "电机 M-105 · 电气柜组件", category: "电气仪表", importance: "一般" },
  { id: "m-013", materialNo: "M-013", name: "双金属温度计", partNo: "P-011", partName: "双金属温度计", spec: "WSS-411", material: "不锈钢", manufacturer: "重庆川仪", stock: 6, unit: "2#机组", system: "仪控系统", systemCode: "SYS-004", device: "控制柜 CP-401", equipmentCode: "EQ-005", component: "仪表组件", componentCode: "C-010", installLocation: "控制柜 CP-401 · 仪表组件", category: "电气仪表", importance: "一般" },
  { id: "m-014", materialNo: "M-014", name: "压力计", partNo: "P-012", partName: "压力计", spec: "Y-100", material: "黄铜", manufacturer: "艾默生过程控制", stock: 9, unit: "2#机组", system: "仪控系统", systemCode: "SYS-004", device: "控制柜 CP-401", equipmentCode: "EQ-005", component: "仪表组件", componentCode: "C-010", installLocation: "控制柜 CP-401 · 仪表组件", category: "电气仪表", importance: "一般" },
];

// ---------- 状态 ----------
const unitFilter = ref("");
const search = ref("");
const selectedKey = ref("plant::核电站");
const expanded = ref<Set<string>>(
  new Set(["plant::核电站", "system::SYS-001", "system::SYS-002", "system::SYS-003", "system::SYS-004"])
);
const selectedCategories = ref<Set<string>>(new Set());
const editingStockId = ref<string | null>(null);
const editingStockValue = ref("");
const showSourceNote = ref(false);

const categories = ["紧固件", "密封件", "阀门", "传动件", "电气仪表"];

const unitOptions = computed(() => {
  const set = new Set(materials.map((m) => m.unit).filter(Boolean));
  return ["", ...Array.from(set)];
});

const partsForView = computed(() =>
  unitFilter.value ? materials.filter((m) => m.unit === unitFilter.value) : materials
);

const materialCount = computed(() => partsForView.value.length);

const stats = computed(() => [
  { label: "替代建议·非等效", value: 46, color: "#f97316" },
  { label: "寿期预警", value: 6, color: "#f59e0b" },
  { label: "数据完整率", value: "19%", color: "#3b82f6" },
  { label: "待复核", value: 0, color: "#8b5cf6" },
]);

// ---------- BOM 树构建（复刻原型 buildBomTree） ----------
function buildBomTree(parts: Material[]): BomNode[] {
  const plant: BomNode = { key: "plant::核电站", type: "plant", label: "核电站", count: 0, materials: [], children: [] };
  parts.forEach((p) => {
    let systemNode = plant.children!.find((n) => n.key === `system::${p.systemCode}`);
    if (!systemNode) {
      systemNode = { key: `system::${p.systemCode}`, type: "system", label: p.system, code: p.systemCode, count: 0, materials: [], children: [] };
      plant.children!.push(systemNode);
    }
    let equipNode = systemNode.children!.find((n) => n.key === `equipment::${p.equipmentCode}`);
    if (!equipNode) {
      equipNode = { key: `equipment::${p.equipmentCode}`, type: "equipment", label: p.device, code: p.equipmentCode, count: 0, materials: [], children: [] };
      systemNode.children!.push(equipNode);
    }
    let compNode = equipNode.children!.find((n) => n.key === `component::${p.componentCode}`);
    if (!compNode) {
      compNode = { key: `component::${p.componentCode}`, type: "component", label: p.component, code: p.componentCode, count: 0, materials: [], children: [] };
      equipNode.children!.push(compNode);
    }
    let partNode = compNode.children!.find((n) => n.key === `part::${p.partNo}`);
    if (!partNode) {
      partNode = { key: `part::${p.partNo}`, type: "part", label: `${p.partName} ${p.partNo}`, code: p.partNo, count: 0, category: p.category, materials: [] };
      compNode.children!.push(partNode);
    }
    partNode.materials!.push(p);
  });
  const sortByCode = (a: BomNode, b: BomNode) => (a.code || "").localeCompare(b.code || "");
  plant.children!.sort(sortByCode).forEach((sys) => {
    sys.children!.sort(sortByCode).forEach((eq) => {
      eq.children!.sort(sortByCode).forEach((comp) => {
        comp.children!.sort(sortByCode).forEach((part) => {
          part.count = part.materials!.length;
        });
        comp.count = comp.children!.reduce((s, c) => s + c.count, 0);
        comp.materials = comp.children!.flatMap((c) => c.materials || []);
      });
      eq.count = eq.children!.reduce((s, c) => s + c.count, 0);
      eq.materials = eq.children!.flatMap((c) => c.materials || []);
    });
    sys.count = sys.children!.reduce((s, c) => s + c.count, 0);
    sys.materials = sys.children!.flatMap((c) => c.materials || []);
  });
  plant.count = plant.children!.reduce((s, c) => s + c.count, 0);
  plant.materials = plant.children!.flatMap((c) => c.materials || []);
  return [plant];
}

const tree = computed(() => buildBomTree(partsForView.value));

function findNodeByKey(nodes: BomNode[], key: string): BomNode | null {
  for (const n of nodes) {
    if (n.key === key) return n;
    if (n.children) {
      const r = findNodeByKey(n.children, key);
      if (r) return r;
    }
  }
  return null;
}

function getNodePath(nodes: BomNode[], key: string): BomNode[] {
  for (const n of nodes) {
    if (n.key === key) return [n];
    if (n.children) {
      const sub = getNodePath(n.children, key);
      if (sub.length) return [n, ...sub];
    }
  }
  return [];
}

const selectedNode = computed(() => findNodeByKey(tree.value, selectedKey.value));
const breadcrumb = computed(() => getNodePath(tree.value, selectedKey.value).map((n) => n.label).join(" > "));

// 分类命中 → 树节点绿底高亮（祖先链）
const highlightedKeys = computed(() => {
  if (selectedCategories.value.size === 0) return new Set<string>();
  const set = new Set<string>();
  const walk = (node: BomNode, parentPath: BomNode[]) => {
    let hit = false;
    if (node.type === "part" && node.category && selectedCategories.value.has(node.category)) hit = true;
    for (const child of node.children || []) {
      if (walk(child, [...parentPath, node])) hit = true;
    }
    if (hit) {
      [...parentPath, node].forEach((n) => set.add(n.key));
    }
    return hit;
  };
  tree.value.forEach((root) => walk(root, []));
  return set;
});

function toggleExpand(key: string) {
  expanded.value = new Set(expanded.value);
  if (expanded.value.has(key)) expanded.value.delete(key);
  else expanded.value.add(key);
}

function handleTreeSelect(node: BomNode) {
  selectedKey.value = node.key;
  if (node.children && node.children.length > 0) {
    expanded.value = new Set(expanded.value).add(node.key);
  }
}

function toggleCategory(cat: string) {
  const next = new Set(selectedCategories.value);
  if (next.has(cat)) next.delete(cat);
  else next.add(cat);
  selectedCategories.value = next;
}

function clearCategories() {
  selectedCategories.value = new Set();
}

// 疑似重复
const duplicateIds = computed(() => {
  const cnt = new Map<string, number>();
  partsForView.value.forEach((p) => {
    const k = `${p.name}|${p.spec}`;
    cnt.set(k, (cnt.get(k) || 0) + 1);
  });
  const set = new Set<string>();
  partsForView.value.forEach((p) => {
    if ((cnt.get(`${p.name}|${p.spec}`) || 0) > 1) set.add(p.id);
  });
  return set;
});
function isDuplicate(m: Material) {
  return duplicateIds.value.has(m.id);
}

// 表格筛选：当前节点 + 搜索
const filteredMaterials = computed(() => {
  const base = selectedNode.value?.materials?.length
    ? (selectedNode.value.materials as Material[])
    : partsForView.value;
  const lower = search.value.toLowerCase();
  if (!lower) return base;
  return base.filter(
    (m) =>
      (m.materialNo || "").toLowerCase().includes(lower) ||
      (m.spec || "").toLowerCase().includes(lower) ||
      (m.manufacturer || "").toLowerCase().includes(lower) ||
      (m.material || "").toLowerCase().includes(lower) ||
      (m.partName || "").toLowerCase().includes(lower) ||
      (m.name || "").toLowerCase().includes(lower) ||
      (m.installLocation || "").toLowerCase().includes(lower)
  );
});

// 库存行内编辑
function startEditStock(m: Material) {
  editingStockId.value = m.id;
  editingStockValue.value = String(m.stock ?? 0);
}
function cancelEditStock() {
  editingStockId.value = null;
  editingStockValue.value = "";
}
function commitEditStock(id: string) {
  const value = Number(editingStockValue.value);
  if (!Number.isFinite(value) || value < 0) return;
  const m = materials.find((x) => x.id === id);
  if (m) m.stock = Math.floor(value);
  editingStockId.value = null;
  editingStockValue.value = "";
  ElMessage.success("库存已更新");
}

function viewPart(row: Material) {
  ElMessage.info(`查看物料详情：${row.materialNo}（原型演示）`);
}

function handleExport() {
  ElMessage.success("物料数据已导出（原型演示）");
}
function handleAdd() {
  ElMessage.info("新增物料（原型演示）");
}

const sourceRows = [
  { field: "物料号 / 名称 / 规格型号", module: "物料主数据", owner: "物资编码管理员", method: "物料新增/变更流程" },
  { field: "当前库存", module: "库存管理", owner: "仓库管理员", method: "入库/出库/盘点，已支持列表页直接修改" },
  { field: "建议采购数量", module: "采购辅助算法", owner: "系统自动生成", method: "BOM 消耗定额 × 计划数量 − 库存 − 安全库存" },
  { field: "采购周期", module: "采购主数据", owner: "采购员 / 供应商管理员", method: "按供应商协议或历史交期维护" },
  { field: "推荐供应商", module: "合格供方名录", owner: "采购部 / QA", method: "综合资质、交期、单价推荐" },
  { field: "预计到货时间", module: "采购辅助算法", owner: "系统自动计算", method: "建议采购日期 + 采购周期" },
];
</script>

<style scoped>
.kb-pm {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
/* 页头 */
.kb-pm-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.kb-pm-header-title {
  font-size: 18px;
  font-weight: 600;
  color: #111827;
}
.kb-pm-header-actions {
  display: flex;
  gap: 8px;
}
/* 机组筛选 */
.kb-pm-unit-filter {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
}
.kb-pm-filter-label {
  font-size: 12px;
  color: #6b7280;
}
/* 胶囊 */
.kb-pm-pill {
  font-size: 12px;
  padding: 4px 12px;
  border-radius: 12px;
  border: 0.5px solid #e5e7eb;
  background: #ffffff;
  color: #374151;
  cursor: pointer;
}
.kb-pm-pill--active {
  border-color: #4338ca;
  background: #eef2ff;
  color: #4338ca;
}
/* 统计卡 */
.kb-pm-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
  gap: 12px;
}
.kb-pm-stat {
  text-align: center;
  padding: 12px 8px;
}
.kb-pm-stat-label {
  font-size: 11px;
  color: #6b7280;
  margin-bottom: 4px;
}
.kb-pm-stat-value {
  font-size: 20px;
  font-weight: 700;
}
/* 分类 + 搜索 */
.kb-pm-filter {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.kb-pm-filter-row {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
}
.kb-pm-clear {
  font-size: 12px;
  color: #6b7280;
  background: transparent;
  border: 0;
  cursor: pointer;
  padding: 4px 6px;
}
.kb-pm-search {
  width: 100%;
}
/* 主体双栏 */
.kb-pm-main {
  display: grid;
  grid-template-columns: 300px 1fr;
  gap: 16px;
  align-items: start;
}
.kb-pm-tree {
  position: sticky;
  top: 16px;
  max-height: calc(100vh - 120px);
  display: flex;
  flex-direction: column;
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  overflow: hidden;
}
.kb-pm-tree-head {
  padding: 12px 14px;
  border-bottom: 1px solid #eef0f3;
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
  font-size: 13px;
  color: #111827;
}
.kb-pm-tree-body {
  overflow-y: auto;
  padding: 8px 4px;
  flex: 1;
}
.kb-pm-table-card {
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 16px;
}
.kb-pm-location {
  padding: 8px 12px;
  background: #f9fafb;
  border-radius: 6px;
  margin-bottom: 12px;
  font-size: 12px;
  color: #374151;
}
.kb-pm-duplicate {
  display: inline-block;
  font-size: 9px;
  padding: 0 5px;
  border-radius: 6px;
  background: #fefce8;
  color: #a16207;
  border: 0.5px solid #fde68a;
  margin-left: 6px;
}
.kb-pm-stock {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 4px 8px;
  border-radius: 4px;
  cursor: pointer;
  background: #f9fafb;
  border: 0.5px solid #e5e7eb;
  min-width: 60px;
  justify-content: space-between;
}
.kb-pm-stock-edit {
  display: inline-flex;
  gap: 6px;
  align-items: center;
}
.kb-pm-empty {
  text-align: center;
  color: #9ca3af;
  padding: 40px 0;
}
.kb-pm-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 16px;
  flex-wrap: wrap;
  gap: 12px;
}
.kb-pm-footer-count {
  font-size: 12px;
  color: #6b7280;
}
.kb-pm-pager {
  display: flex;
  gap: 8px;
  align-items: center;
}
.kb-pm-page {
  padding: 6px 12px;
  font-size: 13px;
  color: #6b7280;
}
/* 字段来源卡 */
.kb-pm-source {
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  overflow: hidden;
}
.kb-pm-source-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 12px;
  background: #f9fafb;
  cursor: pointer;
  font-size: 13px;
  color: #374151;
}
.kb-pm-source-sub {
  margin-left: 10px;
  color: #6b7280;
  font-size: 12px;
}
</style>
