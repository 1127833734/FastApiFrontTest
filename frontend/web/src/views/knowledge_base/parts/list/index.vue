<!--
  备件知识库 · 零件库 / 零件管理
  结构：顶部栏 + KPI 统计卡 + 分类过滤栏(含清除) + 左 BOM 树(叶子类型标签)/右物料表格 + 底部来源卡
-->
<template>
  <div class="kb-pm page-container">
    <!-- 顶部栏 -->
    <div class="page-header">
      <el-text class="page-title">零件管理</el-text>
      <ElRadioGroup v-model="activeUnit">
        <ElRadioButton value="全部">全部</ElRadioButton>
        <ElRadioButton value="1#机组">1#机组</ElRadioButton>
        <ElRadioButton value="2#机组">2#机组</ElRadioButton>
      </ElRadioGroup>
      <el-space class="header-actions">
        <ElButton :icon="Download" @click="handleExport">导出</ElButton>
        <ElButton type="success" :icon="Plus" @click="handleAdd">新增</ElButton>
      </el-space>
    </div>

    <!-- 指标卡片统计组 -->
    <ElRow :gutter="16" class="stat-row">
      <ElCol v-for="s in stats" :key="s.title" :span="6">
        <ElCard shadow="never" class="stat-card">
          <ElStatistic :title="s.title" :value="s.value" :value-style="{ color: s.color }" />
        </ElCard>
      </ElCol>
    </ElRow>

    <!-- 分类与搜索过滤栏（带选中与清除状态） -->
    <div class="filter-wrapper">
      <el-space class="category-tags">
        <ElCheckTag
          v-for="c in categories"
          :key="c"
          :checked="activeCategory === c"
          :type="activeCategory === c ? 'primary' : undefined"
          @change="selectCategory(c)"
        >
          {{ c }}
        </ElCheckTag>
        <ElButton type="text" class="clear-btn" @click="clearFilter">清除筛选</ElButton>
      </el-space>
      <ElInput
        v-model="search"
        placeholder="搜索物料号、规格型号、厂家、材质、零件名称..."
        :prefix-icon="Search"
        clearable
        class="search-input"
      />
    </div>

    <!-- 左右双栏主体 -->
    <ElRow :gutter="16" class="main-row">
      <!-- 左：BOM 树 -->
      <ElCol :span="6">
        <ElCard shadow="never" class="bom-tree-card">
          <template #header>
            <div class="bom-tree-title">
              <ElIcon><Collection /></ElIcon>
              <span>BOM 主树</span>
            </div>
          </template>
          <ElTree
            :data="bomTreeData"
            node-key="id"
            :default-expanded-keys="defaultExpandedKeys"
            :current-node-key="currentNodeKey"
            highlight-current
            @node-click="handleNodeClick"
          >
            <template #default="{ data }">
              <div class="tree-node">
                <span class="tree-label">{{ data.label }}</span>
                <span
                  v-if="data.type"
                  class="tree-type-badge"
                  :class="data.type === '其他' ? 'tree-type-badge--info' : 'tree-type-badge--primary'"
                >
                  {{ data.type }} {{ data.count }}
                </span>
              </div>
            </template>
          </ElTree>
        </ElCard>
      </ElCol>

      <!-- 右：物料表格 -->
      <ElCol :span="18">
        <ElCard shadow="never" class="table-card">
          <!-- 当前位置 -->
          <ElBreadcrumb separator=">" class="table-breadcrumb">
            <ElBreadcrumbItem v-for="(p, i) in breadcrumb" :key="i">{{ p }}</ElBreadcrumbItem>
          </ElBreadcrumb>

          <!-- 物料表格 -->
          <ElTable :data="filteredMaterialList" stripe>
            <ElTableColumn prop="materialCode" label="物料号" width="100" />
            <ElTableColumn prop="location" label="安装位置" min-width="200" show-overflow-tooltip />
            <ElTableColumn prop="specification" label="规格型号" min-width="200" show-overflow-tooltip />
            <ElTableColumn prop="manufacturer" label="厂家" width="120" />
            <ElTableColumn prop="material" label="材质" width="100" />
            <ElTableColumn label="库存" width="150" align="center">
              <template #default="{ row }">
                <ElInputNumber v-model="row.stock" :min="0" size="small" controls-position="right" style="width: 90px" />
              </template>
            </ElTableColumn>
            <ElTableColumn label="操作" width="70" align="center">
              <template #default="{ row }">
                <ElButton link :icon="View" circle @click="handleView(row)" />
              </template>
            </ElTableColumn>
          </ElTable>

          <!-- 表格底部与分页 -->
          <div class="table-footer">
            <ElText type="info">共 {{ filteredMaterialList.length }} 条物料 / 当前节点共 {{ filteredMaterialList.length }} 条</ElText>
            <ElPagination layout="prev, slot, next" :total="filteredMaterialList.length" :page-size="Math.max(filteredMaterialList.length, 1)">
              <template #slot>
                <span class="page-info">1/1</span>
              </template>
            </ElPagination>
          </div>
        </ElCard>
      </ElCol>
    </ElRow>

    <!-- 底端辅助说明卡片 -->
    <ElCard shadow="never" class="footer-info-card" @click="goDataMaintenance">
      <div class="footer-info">
        <div>
          <div class="footer-info-title">字段维护来源</div>
          <div class="footer-info-sub">物料各字段在系统中的来源与维护位置</div>
        </div>
        <ElIcon><ArrowRight /></ElIcon>
      </div>
    </ElCard>
  </div>
</template>

<script setup lang="ts">
import { Download, Plus, Search, View, Collection, ArrowRight } from "@element-plus/icons-vue";

defineOptions({ name: "KbPartList" });

const activeUnit = ref("全部");
const activeCategory = ref<string | null>("传动件");
const search = ref("");

const stats = [
  { title: "替代建议·非等效", value: 46, color: "#E6A23C" },
  { title: "寿期预警", value: 6, color: "#E6A23C" },
  { title: "数据完整率", value: "19%", color: "#409EFF" },
  { title: "待复核", value: 0, color: "#909399" },
];

const categories = ["紧固件", "密封件", "阀门", "传动件", "电气仪表"];

interface BomNode {
  id: string;
  label: string;
  type?: string;
  count?: number;
  children?: BomNode[];
}

const bomTreeData: BomNode[] = [
  {
    id: "node-plant",
    label: "核电站",
    children: [
      {
        id: "node-fw",
        label: "给水系统",
        children: [
          {
            id: "node-pump",
            label: "给水泵 P-101",
            children: [
              {
                id: "node-pump-shell",
                label: "泵壳组件",
                children: [
                  { id: "leaf-bolt", label: "六角螺…", type: "紧固件", count: 2 },
                  { id: "leaf-gasket", label: "密封垫…", type: "密封件", count: 1 },
                  { id: "leaf-o-ring", label: "O型密…", type: "密封件", count: 2 },
                  { id: "leaf-mech", label: "机械密封…", type: "其他", count: 1 },
                ],
              },
              { id: "node-pump-seal", label: "轴封组件" },
              { id: "node-pump-coup", label: "联轴器组件" },
            ],
          },
          { id: "node-fcv", label: "给水调节阀 FCV-201" },
        ],
      },
      {
        id: "node-steam",
        label: "蒸汽系统",
        children: [{ id: "node-mv", label: "主汽阀 MV-201" }],
      },
    ],
  },
];

const defaultExpandedKeys = ["node-plant", "node-fw", "node-pump", "node-pump-shell"];
const currentNodeKey = "node-pump-shell";
const breadcrumb = ref(["核电站", "给水系统", "给水泵 P-101", "泵壳组件"]);

/** 树节点完整路径（供面包屑） */
function collectPath(id: string): string[] {
  const walk = (nodes: BomNode[], trail: string[]): string[] | null => {
    for (const n of nodes) {
      const next = [...trail, n.label];
      if (n.id === id) return next;
      if (n.children) {
        const r = walk(n.children, next);
        if (r) return r;
      }
    }
    return null;
  };
  return walk(bomTreeData, []) || [];
}

interface Material {
  materialCode: string;
  location: string;
  specification: string;
  manufacturer: string;
  material: string;
  stock: number;
  category: string;
}

const materials: Material[] = [
  { materialCode: "M-001", location: "给水泵 P-101 · 泵壳组件", specification: "GB/T 5783-M16×60-8.8", manufacturer: "上海电气", material: "35CrMo", stock: 12, category: "紧固件" },
  { materialCode: "M-002", location: "给水泵 P-101 · 泵壳组件", specification: "GB/T 5783-M20×80-10.9", manufacturer: "东方电气", material: "45钢", stock: 8, category: "紧固件" },
  { materialCode: "M-003", location: "给水泵 P-101 · 泵壳组件", specification: "GB/T 6170-M16", manufacturer: "哈电集团", material: "35CrMo", stock: 16, category: "紧固件" },
  { materialCode: "M-004", location: "给水泵 P-101 · 泵壳组件", specification: "DN100 PN16 缠绕垫", manufacturer: "南方密封", material: "柔性石墨+不锈钢", stock: 9, category: "密封件" },
  { materialCode: "M-005", location: "给水泵 P-101 · 泵壳组件", specification: "Φ85×3.1 NBR", manufacturer: "Gore 中国", material: "NBR 丁腈橡胶", stock: 6, category: "密封件" },
  { materialCode: "M-006", location: "给水泵 P-101 · 泵壳组件", specification: "Φ120×3.5 FKM", manufacturer: "Gore 中国", material: "氟橡胶 FKM", stock: 4, category: "密封件" },
  { materialCode: "M-007", location: "给水泵 P-101 · 泵壳组件", specification: "MG1-45 机械密封", manufacturer: "沈阳鼓风机", material: "碳化硅/石墨", stock: 2, category: "其他" },
  { materialCode: "M-008", location: "给水泵 P-101 · 联轴器组件", specification: "LZG-00 十字滑块联轴器", manufacturer: "沈阳鼓风机", material: "ZG310-570/45", stock: 1, category: "传动件" },
  { materialCode: "M-009", location: "给水泵 P-101 · 联轴器组件", specification: "WXLZQ-01 万向联轴器", manufacturer: "瓦房店轴承", material: "20Cr/40Cr", stock: 1, category: "传动件" },
  { materialCode: "M-010", location: "给水泵 P-101 · 轴封组件", specification: "Φ60×Φ80 密封圈", manufacturer: "南方密封", material: "氟橡胶", stock: 7, category: "密封件" },
  { materialCode: "M-011", location: "给水调节阀 FCV-201 · 阀体组件", specification: "A48Y-16C DN50", manufacturer: "哈电集团", material: "WCB", stock: 8, category: "阀门" },
  { materialCode: "M-012", location: "给水调节阀 FCV-201 · 阀芯组件", specification: "JZF-0 DN50", manufacturer: "重庆川仪", material: "HT150/ZCuZn38", stock: 5, category: "阀门" },
  { materialCode: "M-013", location: "给水调节阀 FCV-201 · 阀芯组件", specification: "Φ32 阀瓣密封面", manufacturer: "重庆川仪", material: "堆焊硬质合金", stock: 3, category: "阀门" },
  { materialCode: "M-014", location: "主汽阀 MV-201 · 阀体组件", specification: "Φ140×Φ160 密封圈", manufacturer: "南方密封", material: "氟橡胶 FKM", stock: 4, category: "密封件" },
  { materialCode: "M-015", location: "主汽阀 MV-201 · 执行机构", specification: "Φ100×5.3 O型圈", manufacturer: "Gore 中国", material: "NBR", stock: 10, category: "密封件" },
  { materialCode: "M-016", location: "主汽阀 MV-201 · 阀盖", specification: "M16×70 8.8级", manufacturer: "东方电气", material: "合金钢", stock: 14, category: "紧固件" },
  { materialCode: "M-017", location: "送风机 F-201 · 转子组件", specification: "6208-2RS", manufacturer: "SKF 中国", material: "GCr15", stock: 5, category: "传动件" },
  { materialCode: "M-018", location: "送风机 F-201 · 转子组件", specification: "6207-2RS", manufacturer: "SKF 中国", material: "GCr15", stock: 3, category: "传动件" },
  { materialCode: "M-019", location: "应急照明盘 LP-301 · 电气柜组件", specification: "D374N 25×32×60 碳刷", manufacturer: "哈尔滨轴承", material: "电化石墨", stock: 12, category: "电气仪表" },
  { materialCode: "M-020", location: "控制柜 CP-401 · 仪表组件", specification: "双金属温度计 WSS-411", manufacturer: "重庆川仪", material: "不锈钢", stock: 6, category: "电气仪表" },
  { materialCode: "M-021", location: "控制柜 CP-401 · 仪表组件", specification: "压力计 Y-100", manufacturer: "艾默生过程控制", material: "黄铜", stock: 9, category: "电气仪表" },
];

const filteredMaterialList = computed(() => {
  const q = search.value.trim().toLowerCase();
  return materials.filter((m) => {
    if (activeCategory.value && m.category !== activeCategory.value) return false;
    if (q) {
      return (
        m.materialCode.toLowerCase().includes(q) ||
        m.specification.toLowerCase().includes(q) ||
        m.manufacturer.toLowerCase().includes(q) ||
        m.material.toLowerCase().includes(q) ||
        m.location.toLowerCase().includes(q)
      );
    }
    return true;
  });
});

function selectCategory(c: string) {
  activeCategory.value = activeCategory.value === c ? null : c;
}

function clearFilter() {
  activeCategory.value = null;
  search.value = "";
}

function handleNodeClick(data: BomNode) {
  breadcrumb.value = collectPath(data.id);
}

function handleExport() {
  ElMessage.success("物料数据已导出（原型演示）");
}

function handleAdd() {
  ElMessage.info("新增物料（原型演示）");
}

function handleView(row: Material) {
  ElMessage.info(`查看物料详情：${row.materialCode}`);
}

function goDataMaintenance() {
  ElMessage.info("字段维护来源（原型演示）");
}
</script>

<style scoped>
.kb-pm {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
/* 顶部栏 */
.page-header {
  display: flex;
  align-items: center;
  gap: 20px;
  flex-wrap: wrap;
}
.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #111827;
  margin-right: auto;
}
.header-actions {
  margin-left: auto;
}
/* 统计卡 */
.stat-row {
  width: 100%;
}
.stat-card {
  text-align: center;
}
/* 分类与搜索 */
.filter-wrapper {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.category-tags {
  flex-wrap: wrap;
  align-items: center;
}
.clear-btn {
  color: #409eff;
}
.search-input {
  width: 100%;
}
/* 主体 */
.main-row {
  width: 100%;
}
.bom-tree-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 15px;
  font-weight: 600;
  color: #111827;
}
.tree-node {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex: 1;
  min-width: 0;
  padding-right: 6px;
}
.tree-label {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.tree-type-badge {
  flex: 0 0 auto;
  font-size: 11px;
  border-radius: 10px;
  padding: 0 7px;
  line-height: 18px;
}
.tree-type-badge--primary {
  color: #409eff;
  background: #ecf5ff;
}
.tree-type-badge--info {
  color: #909399;
  background: #f4f4f5;
}
.table-breadcrumb {
  margin-bottom: 12px;
}
.table-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 16px;
}
.page-info {
  font-size: 13px;
  color: #6b7280;
}
/* 底部来源卡 */
.footer-info-card {
  cursor: pointer;
}
.footer-info {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.footer-info-title {
  font-size: 15px;
  font-weight: 600;
  color: #111827;
}
.footer-info-sub {
  font-size: 13px;
  color: #6b7280;
  margin-top: 4px;
}
</style>
