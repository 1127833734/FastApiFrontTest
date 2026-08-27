<!--
  备件知识库 · 零件库 / 零件管理
  结构：顶部栏 + KPI 统计卡 + 分类/搜索过滤 + 左 BOM 树/右物料表格 + 底部来源卡
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

    <!-- 分类与搜索过滤栏 -->
    <div class="filter-wrapper">
      <el-space class="category-tags">
        <ElCheckTag
          v-for="c in categories"
          :key="c"
          :checked="activeCategory === c"
          @change="activeCategory = c"
        >
          {{ c }}
        </ElCheckTag>
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
          <ElTree :data="bomTreeData" node-key="id" default-expand-all highlight-current @node-click="handleNodeClick">
            <template #default="{ data }">
              <div class="tree-node">
                <span>{{ data.label }}</span>
                <span v-if="data.count" class="tree-badge">{{ data.count }}</span>
              </div>
            </template>
          </ElTree>
        </ElCard>
      </ElCol>

      <!-- 右：物料表格 -->
      <ElCol :span="18">
        <ElCard shadow="never" class="table-card">
          <!-- 当前位置 -->
          <ElBreadcrumb class="table-breadcrumb">
            <ElBreadcrumbItem>当前位置：{{ currentNode }}</ElBreadcrumbItem>
          </ElBreadcrumb>

          <!-- 物料表格 -->
          <ElTable :data="materialList" stripe>
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
            <ElText type="info">共 {{ materialList.length }} 条物料 / 当前节点共 {{ materialList.length }} 条</ElText>
            <ElPagination layout="prev, slot, next" :total="materialList.length" :page-size="materialList.length">
              <template #slot>
                <span class="page-info">1/1</span>
              </template>
            </ElPagination>
          </div>
        </ElCard>
      </ElCol>
    </ElRow>

    <!-- 底端可折叠/跳转卡片 -->
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
import { useRouter } from "vue-router";

defineOptions({ name: "KbPartList" });

const router = useRouter();

const activeUnit = ref("全部");
const activeCategory = ref("紧固件");
const search = ref("");
const currentNode = ref("核电站");

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
  count?: number;
  children?: BomNode[];
}

const bomTreeData: BomNode[] = [
  {
    id: "plant",
    label: "核电站",
    count: 81,
    children: [
      {
        id: "fw",
        label: "给水系统",
        children: [
          { id: "p101", label: "给水泵 P-101", count: 81 },
          { id: "fcv201", label: "给水调节阀 FCV-201", count: 16 },
        ],
      },
      {
        id: "steam",
        label: "蒸汽系统",
        children: [{ id: "mv201", label: "主汽阀 MV-201", count: 10 }],
      },
    ],
  },
];

interface Material {
  materialCode: string;
  location: string;
  specification: string;
  manufacturer: string;
  material: string;
  stock: number;
}

const materialList = ref<Material[]>([
  { materialCode: "M-001", location: "给水泵 P-101 · 泵壳组件", specification: "GB/T 5783-M16×60-8.8", manufacturer: "上海电气", material: "35CrMo", stock: 12 },
  { materialCode: "M-002", location: "给水泵 P-101 · 泵壳组件", specification: "GB/T 5783-M20×80-10.9", manufacturer: "东方电气", material: "45钢", stock: 8 },
  { materialCode: "M-003", location: "给水泵 P-101 · 泵壳组件", specification: "GB/T 6170-M16", manufacturer: "哈电集团", material: "35CrMo", stock: 16 },
  { materialCode: "M-004", location: "给水泵 P-101 · 轴封组件", specification: "GB/T 3452.1-Φ85×3.1", manufacturer: "Gore 中国", material: "NBR 丁腈橡胶", stock: 6 },
  { materialCode: "M-005", location: "给水泵 P-101 · 轴封组件", specification: "GB/T 3452.1-Φ120×3.5", manufacturer: "Gore 中国", material: "氟橡胶 FKM", stock: 4 },
  { materialCode: "M-006", location: "给水泵 P-101 · 联轴器组件", specification: "LZG-00 十字滑块联轴器", manufacturer: "沈阳鼓风机", material: "ZG310-570/45", stock: 1 },
  { materialCode: "M-007", location: "给水调节阀 FCV-201 · 阀体组件", specification: "A48Y-16C DN50", manufacturer: "哈电集团", material: "WCB", stock: 8 },
  { materialCode: "M-008", location: "给水调节阀 FCV-201 · 阀芯组件", specification: "JZF-0 DN50", manufacturer: "重庆川仪", material: "HT150/ZCuZn38", stock: 5 },
]);

function handleNodeClick(data: BomNode) {
  currentNode.value = data.label;
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
  router.push("/kb-parts/data-maintenance");
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
.tree-badge {
  font-size: 12px;
  color: #409eff;
  background: #ecf5ff;
  border-radius: 10px;
  padding: 0 8px;
  line-height: 18px;
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
