<!--
  备件知识库 · 业务场景 / 维修资源清单
  复刻原型 maintenance-resources 页：工器具 / 备件 / 人员 / 文档四类资源
-->
<template>
  <div class="kb-resources">
    <ElTabs v-model="activeTab">
      <ElTabPane label="工器具" name="tools">
        <ElTable :data="tools" stripe>
          <ElTableColumn type="index" label="序号" width="60" />
          <ElTableColumn prop="name" label="工器具名称" min-width="180" />
          <ElTableColumn prop="spec" label="规格" min-width="140" />
          <ElTableColumn prop="location" label="存放位置" width="140" />
          <ElTableColumn prop="status" label="状态" width="100">
            <template #default="{ row }">
              <ElTag :type="row.status === '可用' ? 'success' : 'warning'" size="small">{{ row.status }}</ElTag>
            </template>
          </ElTableColumn>
        </ElTable>
      </ElTabPane>
      <ElTabPane label="备件" name="spares">
        <ElTable :data="spares" stripe>
          <ElTableColumn type="index" label="序号" width="60" />
          <ElTableColumn prop="name" label="备件名称" min-width="160" />
          <ElTableColumn prop="spec" label="规格" min-width="140" />
          <ElTableColumn prop="quantity" label="库存" width="80" align="center" />
          <ElTableColumn prop="note" label="用途" min-width="180" show-overflow-tooltip />
        </ElTable>
      </ElTabPane>
      <ElTabPane label="人员" name="staff">
        <ElTable :data="staff" stripe>
          <ElTableColumn type="index" label="序号" width="60" />
          <ElTableColumn prop="name" label="姓名" width="110" />
          <ElTableColumn prop="dept" label="部门" width="110" />
          <ElTableColumn prop="role" label="角色" min-width="160" />
          <ElTableColumn prop="phone" label="联系电话" width="140" />
        </ElTable>
      </ElTabPane>
      <ElTabPane label="文档" name="docs">
        <ElTable :data="docs" stripe>
          <ElTableColumn type="index" label="序号" width="60" />
          <ElTableColumn prop="name" label="文档名称" min-width="220" />
          <ElTableColumn prop="type" label="类型" width="90" />
          <ElTableColumn prop="version" label="版本" width="90" />
        </ElTable>
      </ElTabPane>
    </ElTabs>
  </div>
</template>

<script setup lang="ts">
defineOptions({ name: "KbMaintenanceResources" });

const activeTab = ref("tools");

const tools = [
  { name: "轴承拉拔器", spec: "三爪 5T", location: "工具间 B-03", status: "可用" },
  { name: "轴承加热器", spec: "感应式 220V", location: "工具间 B-03", status: "可用" },
  { name: "扭矩扳手", spec: "50-350N·m", location: "工具间 B-01", status: "校验中" },
  { name: "机械密封安装套", spec: "定制", location: "工具间 B-02", status: "可用" },
];
const spares = [
  { name: "轴承 6208-2RS", spec: "SKF", quantity: 5, note: "泵 P-101 驱动端" },
  { name: "机械密封", spec: "50-80", quantity: 2, note: "泵 P-101 轴封" },
  { name: "密封垫 DN50 PN16", spec: "石墨", quantity: 6, note: "主汽阀 MV-201" },
];
const staff = [
  { name: "王工", dept: "维修部", role: "工作负责人", phone: "138****0021" },
  { name: "陈工", dept: "维修部", role: "检修作业人", phone: "138****0076" },
  { name: "李工", dept: "技术部", role: "技术支持", phone: "139****0158" },
  { name: "刘工", dept: "备件部", role: "备件保障", phone: "137****0302" },
];
const docs = [
  { name: "泵 P-101 维修手册", type: "PDF", version: "V2.1" },
  { name: "泵 P-101 总装图", type: "DWG", version: "V1.0" },
  { name: "轴承更换工艺卡", type: "PDF", version: "V3.0" },
];
</script>

<style scoped>
.kb-resources {
  padding: 0;
}
</style>
