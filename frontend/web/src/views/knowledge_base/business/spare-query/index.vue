<!--
  备件知识库 · 业务场景 / 备件精准查询
  结构：页面标题 + 查询表单 + 零件档案（查询成功后）+ 可用备件清单（查询成功后）
-->
<template>
  <div class="kb-spq page-container">
    <!-- 页面标题 -->
    <div class="kb-spq-title">备件精准查询</div>

    <!-- 查询组件 -->
    <ElCard shadow="never" class="kb-spq-search">
      <ElForm inline>
        <ElFormItem label="零件编号 / 名称">
          <ElInput
            v-model="searchQuery"
            placeholder="输入零件编号或名称，例如：P101-001"
            clearable
            style="width: 320px"
            @keyup.enter="handleSearch"
          />
        </ElFormItem>
        <ElFormItem>
          <ElButton type="success" :icon="Search" @click="handleSearch">查询</ElButton>
        </ElFormItem>
      </ElForm>
    </ElCard>

    <!-- 零件档案（查询成功后显示） -->
    <ElCard v-if="searched" shadow="never" class="kb-spq-archive">
      <template #header>
        <span class="kb-spq-card-title">零件档案</span>
      </template>
      <ElDescriptions :column="4" border>
        <ElDescriptionsItem label="零件编号">{{ part.partNo }}</ElDescriptionsItem>
        <ElDescriptionsItem label="名称">{{ part.name }}</ElDescriptionsItem>
        <ElDescriptionsItem label="型号规格">{{ part.spec }}</ElDescriptionsItem>
        <ElDescriptionsItem label="材质">{{ part.material }}</ElDescriptionsItem>
        <ElDescriptionsItem label="所属机组">{{ part.unit }}</ElDescriptionsItem>
        <ElDescriptionsItem label="所属系统">{{ part.system }}</ElDescriptionsItem>
        <ElDescriptionsItem label="所属设备">{{ part.device }}</ElDescriptionsItem>
        <ElDescriptionsItem label="安装位置">{{ part.installLocation }}</ElDescriptionsItem>
      </ElDescriptions>
    </ElCard>

    <!-- 可用备件清单（查询成功后显示） -->
    <ElCard v-if="searched" shadow="never" class="kb-spq-spares">
      <template #header>
        <div class="kb-spq-spares-header">
          <span class="kb-spq-card-title">可用备件清单</span>
          <ElButton :icon="Download" @click="handleExport">导出</ElButton>
        </div>
      </template>
      <ElTable :data="spares" stripe>
        <ElTableColumn prop="spCode" label="备件编码" width="120" />
        <ElTableColumn prop="model" label="供货型号" min-width="180" show-overflow-tooltip />
        <ElTableColumn prop="supplier" label="供应商" width="140" />
        <ElTableColumn prop="leadTime" label="采购周期" width="120" align="center" />
        <ElTableColumn prop="stock" label="当前库存" width="110" align="center">
          <template #default="{ row }">
            <span :style="{ color: row.stock < 2 ? '#ef4444' : '#111827', fontWeight: 600 }">{{ row.stock }}</span>
          </template>
        </ElTableColumn>
      </ElTable>
    </ElCard>
  </div>
</template>

<script setup lang="ts">
import { Search, Download } from "@element-plus/icons-vue";

defineOptions({ name: "KbSpareQuery" });

const searchQuery = ref("");
const searched = ref(false);

const part = {
  partNo: "P101-001",
  name: "轴承",
  spec: "6208-2RS",
  material: "钢",
  unit: "1#机组",
  system: "给水系统",
  device: "泵 P-101",
  installLocation: "泵驱动端",
};

interface Spare {
  spCode: string;
  model: string;
  supplier: string;
  leadTime: string;
  stock: number;
}

const spares: Spare[] = [
  { spCode: "SP-001", model: "6208-2RS-SKF", supplier: "SKF", leadTime: "30 天", stock: 5 },
  { spCode: "SP-002", model: "6208-2RS-NSK", supplier: "NSK", leadTime: "25 天", stock: 1 },
  { spCode: "SP-003", model: "6208-2RS-HRB", supplier: "哈尔滨轴承", leadTime: "35 天", stock: 3 },
];

function handleSearch() {
  const q = searchQuery.value.trim();
  if (!q) {
    ElMessage.warning("请输入零件编号或名称");
    return;
  }
  searched.value = true;
}

function handleExport() {
  ElMessage.success("备件清单已导出（原型演示）");
}
</script>

<style scoped>
.kb-spq {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.kb-spq-title {
  font-size: 18px;
  font-weight: 600;
  color: #111827;
}
.kb-spq-card-title {
  font-size: 15px;
  font-weight: 600;
  color: #111827;
}
.kb-spq-spares-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
</style>
