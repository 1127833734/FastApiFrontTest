<!--
  备件知识库 · 零件库 / 备件管理
  复刻原型 spares 页：备件表格 / 低库存标记 / 库存操作
-->
<template>
  <div class="kb-spares">
    <ElCard shadow="never" class="kb-filter">
      <ElForm inline>
        <ElFormItem label="关键词">
          <ElInput v-model="query.keyword" placeholder="备件编码 / 供应型号" clearable style="width: 220px" />
        </ElFormItem>
        <ElFormItem label="供应商">
          <ElSelect v-model="query.supplier" placeholder="全部供应商" clearable style="width: 140px">
            <ElOption v-for="s in suppliers" :key="s" :label="s" :value="s" />
          </ElSelect>
        </ElFormItem>
        <ElFormItem label="库存状态">
          <ElSelect v-model="query.stockStatus" placeholder="全部" clearable style="width: 130px">
            <ElOption label="低库存" value="low" />
            <ElOption label="正常" value="ok" />
          </ElSelect>
        </ElFormItem>
        <ElFormItem>
          <ElButton type="primary" :icon="Search" @click="search">查询</ElButton>
          <ElButton :icon="RefreshLeft" @click="reset">重置</ElButton>
        </ElFormItem>
      </ElForm>
    </ElCard>

    <ElCard shadow="never">
      <template #header>
        <div class="kb-card-header">
          <span class="kb-card-title">备件清单</span>
          <div>
            <ElButton :icon="Bell" @click="checkLowStock">低库存提醒</ElButton>
            <ElButton type="primary" :icon="Plus" @click="addSpare">新增备件</ElButton>
          </div>
        </div>
      </template>
      <ElTable :data="filteredSpares" stripe>
        <ElTableColumn type="index" label="序号" width="60" />
        <ElTableColumn prop="spareNo" label="备件编码" width="100" />
        <ElTableColumn prop="partNo" label="关联零件" width="100" />
        <ElTableColumn prop="partName" label="零件名称" min-width="120" show-overflow-tooltip />
        <ElTableColumn prop="supplyModel" label="供应型号" min-width="150" show-overflow-tooltip />
        <ElTableColumn prop="supplier" label="供应商" width="110" />
        <ElTableColumn prop="procurementCycle" label="采购周期(天)" width="110" align="center" />
        <ElTableColumn prop="minStock" label="最低库存" width="90" align="center" />
        <ElTableColumn label="当前库存" width="100" align="center">
          <template #default="{ row }">
            <span :style="{ color: row.currentStock < row.minStock ? '#ef4444' : '#111827', fontWeight: 600 }">
              {{ row.currentStock }}
            </span>
          </template>
        </ElTableColumn>
        <ElTableColumn label="库存状态" width="100">
          <template #default="{ row }">
            <ElTag v-if="row.currentStock < row.minStock" type="danger" size="small">低库存</ElTag>
            <ElTag v-else type="success" size="small">正常</ElTag>
          </template>
        </ElTableColumn>
        <ElTableColumn label="操作" width="140" fixed="right">
          <template #default>
            <ElButton link type="primary">入库</ElButton>
            <ElButton link type="warning">出库</ElButton>
          </template>
        </ElTableColumn>
      </ElTable>
    </ElCard>
  </div>
</template>

<script setup lang="ts">
import { Search, RefreshLeft, Plus, Bell } from "@element-plus/icons-vue";

defineOptions({ name: "KbSpares" });

const suppliers = ["SKF", "NSK", "哈尔滨轴承", "南方密封"];
const query = ref({ keyword: "", supplier: "", stockStatus: "" });

interface Spare {
  spareNo: string;
  partNo: string;
  partName: string;
  supplyModel: string;
  supplier: string;
  procurementCycle: number;
  minStock: number;
  currentStock: number;
}

const allSpares: Spare[] = [
  { spareNo: "SP-001", partNo: "P101-001", partName: "轴承", supplyModel: "6208-2RS-SKF", supplier: "SKF", procurementCycle: 30, minStock: 2, currentStock: 5 },
  { spareNo: "SP-002", partNo: "P101-001", partName: "轴承", supplyModel: "6208-2RS-NSK", supplier: "NSK", procurementCycle: 25, minStock: 2, currentStock: 1 },
  { spareNo: "SP-003", partNo: "V201-005", partName: "密封垫", supplyModel: "DN50-PN16-G", supplier: "南方密封", procurementCycle: 20, minStock: 4, currentStock: 6 },
  { spareNo: "SP-004", partNo: "M105-012", partName: "碳刷", supplyModel: "D374N-25×32×60", supplier: "哈尔滨轴承", procurementCycle: 15, minStock: 5, currentStock: 12 },
  { spareNo: "SP-005", partNo: "V201-006", partName: "L型密封圈", supplyModel: "Φ140×Φ160-F", supplier: "南方密封", procurementCycle: 20, minStock: 3, currentStock: 2 },
  { spareNo: "SP-006", partNo: "C001-020", partName: "滤芯", supplyModel: "5μm-25×600", supplier: "哈尔滨轴承", procurementCycle: 35, minStock: 2, currentStock: 4 },
];

const filteredSpares = computed(() =>
  allSpares.filter((s) => {
    if (query.value.keyword) {
      const kw = query.value.keyword;
      if (!s.spareNo.includes(kw) && !s.supplyModel.includes(kw)) return false;
    }
    if (query.value.supplier && s.supplier !== query.value.supplier) return false;
    if (query.value.stockStatus === "low" && s.currentStock >= s.minStock) return false;
    if (query.value.stockStatus === "ok" && s.currentStock < s.minStock) return false;
    return true;
  })
);

function search() {}
function reset() {
  query.value = { keyword: "", supplier: "", stockStatus: "" };
}
function addSpare() {
  ElMessage.info("新增备件（原型演示）");
}
function checkLowStock() {
  const low = allSpares.filter((s) => s.currentStock < s.minStock);
  ElMessage.warning(`当前有 ${low.length} 项低库存备件需要补货`);
}
</script>

<style scoped>
.kb-spares {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.kb-filter {
  padding: 16px;
}
.kb-card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.kb-card-title {
  font-size: 15px;
  font-weight: 600;
  color: #111827;
}
</style>
