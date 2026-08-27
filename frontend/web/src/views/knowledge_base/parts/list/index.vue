<!--
  备件知识库 · 零件库 / 零件列表
  复刻原型 parts 页：筛选区 / 零件表格 / 新增零件
-->
<template>
  <div class="kb-parts">
    <ElCard shadow="never" class="kb-filter">
      <ElForm inline>
        <ElFormItem label="关键词">
          <ElInput v-model="query.keyword" placeholder="零件编号或名称" clearable style="width: 220px" />
        </ElFormItem>
        <ElFormItem label="机组">
          <ElSelect v-model="query.unit" placeholder="全部机组" clearable style="width: 120px">
            <ElOption label="1#机组" value="1#机组" />
            <ElOption label="2#机组" value="2#机组" />
          </ElSelect>
        </ElFormItem>
        <ElFormItem label="系统">
          <ElSelect v-model="query.system" placeholder="全部系统" clearable style="width: 130px">
            <ElOption v-for="s in systems" :key="s" :label="s" :value="s" />
          </ElSelect>
        </ElFormItem>
        <ElFormItem label="分类">
          <ElSelect v-model="query.category" placeholder="全部专业" clearable style="width: 120px">
            <ElOption label="机械" value="机械" />
            <ElOption label="电气" value="电气" />
          </ElSelect>
        </ElFormItem>
        <ElFormItem label="级别">
          <ElSelect v-model="query.level" placeholder="全部级别" clearable style="width: 120px">
            <ElOption v-for="l in levels" :key="l" :label="l" :value="l" />
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
          <span class="kb-card-title">零件列表</span>
          <ElButton type="primary" :icon="Plus" @click="addPart">新增零件</ElButton>
        </div>
      </template>
      <ElTable :data="filteredParts" stripe>
        <ElTableColumn type="index" label="序号" width="60" />
        <ElTableColumn prop="partNo" label="零件编号" width="110" />
        <ElTableColumn prop="name" label="名称" width="100" />
        <ElTableColumn prop="spec" label="型号规格" min-width="140" show-overflow-tooltip />
        <ElTableColumn prop="material" label="材质" width="110" />
        <ElTableColumn prop="unit" label="所属机组" width="100" />
        <ElTableColumn prop="system" label="所属系统" width="110" />
        <ElTableColumn prop="device" label="所属设备" min-width="130" show-overflow-tooltip />
        <ElTableColumn prop="installLocation" label="安装位置" min-width="130" show-overflow-tooltip />
        <ElTableColumn prop="category" label="分类" width="80" />
        <ElTableColumn label="级别" width="80">
          <template #default="{ row }">
            <ElTag :type="levelColor[row.level]" size="small">{{ row.level }}</ElTag>
          </template>
        </ElTableColumn>
        <ElTableColumn label="操作" width="130" fixed="right">
          <template #default="{ row }">
            <ElButton link type="primary" @click="viewPart(row)">详情</ElButton>
            <ElButton link type="warning" @click="editPart(row)">编辑</ElButton>
          </template>
        </ElTableColumn>
      </ElTable>
    </ElCard>
  </div>
</template>

<script setup lang="ts">
import { Search, RefreshLeft, Plus } from "@element-plus/icons-vue";

defineOptions({ name: "KbPartList" });

const systems = ["给水系统", "蒸汽系统", "电气系统", "冷却系统"];
const levels = ["A级", "B级", "C级"];
const levelColor: Record<string, "danger" | "warning" | "info"> = {
  A级: "danger",
  B级: "warning",
  C级: "info",
};

const query = ref({ keyword: "", unit: "", system: "", category: "", level: "" });

interface Part {
  partNo: string;
  name: string;
  spec: string;
  material: string;
  unit: string;
  system: string;
  device: string;
  installLocation: string;
  category: string;
  level: string;
  importance: string;
}

const allParts: Part[] = [
  { partNo: "P101-001", name: "轴承", spec: "6208-2RS", material: "钢", unit: "1#机组", system: "给水系统", device: "泵 P-101", installLocation: "泵驱动端", category: "机械", level: "A级", importance: "关键" },
  { partNo: "P101-002", name: "轴承", spec: "6207-2RS", material: "钢", unit: "1#机组", system: "给水系统", device: "泵 P-101", installLocation: "泵非驱动端", category: "机械", level: "A级", importance: "关键" },
  { partNo: "V201-005", name: "密封垫", spec: "DN50 PN16", material: "石墨", unit: "2#机组", system: "蒸汽系统", device: "主汽阀 MV-201", installLocation: "阀盖连接处", category: "机械", level: "B级", importance: "重要" },
  { partNo: "M105-012", name: "碳刷", spec: "D374N 25×32×60", material: "电化石墨", unit: "1#机组", system: "电气系统", device: "电机 M-105", installLocation: "集电环", category: "电气", level: "C级", importance: "一般" },
  { partNo: "V201-006", name: "L型密封圈", spec: "Φ140×Φ160", material: "氟橡胶", unit: "2#机组", system: "蒸汽系统", device: "主汽阀 MV-201", installLocation: "阀杆密封", category: "机械", level: "B级", importance: "重要" },
  { partNo: "C001-020", name: "滤芯", spec: "5μm 25×600", material: "不锈钢", unit: "1#机组", system: "冷却系统", device: "循环水泵", installLocation: "冷却水管路", category: "机械", level: "C级", importance: "一般" },
];

const filteredParts = computed(() =>
  allParts.filter((p) => {
    if (query.value.keyword) {
      const kw = query.value.keyword;
      if (!p.partNo.includes(kw) && !p.name.includes(kw) && !p.spec.includes(kw)) return false;
    }
    if (query.value.unit && p.unit !== query.value.unit) return false;
    if (query.value.system && p.system !== query.value.system) return false;
    if (query.value.category && p.category !== query.value.category) return false;
    if (query.value.level && p.level !== query.value.level) return false;
    return true;
  })
);

function search() {}
function reset() {
  query.value = { keyword: "", unit: "", system: "", category: "", level: "" };
}
function addPart() {
  ElMessage.info("新增零件（原型演示）");
}
function viewPart(row: Part) {
  ElMessage.info(`查看零件详情：${row.partNo} ${row.name}`);
}
function editPart(row: Part) {
  ElMessage.info(`编辑零件：${row.partNo}`);
}
</script>

<style scoped>
.kb-parts {
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
