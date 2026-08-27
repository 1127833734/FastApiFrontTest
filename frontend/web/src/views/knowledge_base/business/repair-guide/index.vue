<!--
  备件知识库 · 业务场景 / 维修流程指引
  复刻原型 repair-guide 页：流程搜索 / 步骤化渲染 / 安全提示
-->
<template>
  <div class="kb-repair-guide">
    <ElCard shadow="never">
      <template #header>
        <span class="kb-card-title">维修流程指引</span>
      </template>
      <ElForm inline>
        <ElFormItem label="检索维修流程">
          <ElInput v-model="keyword" placeholder="例如：泵 P-101 轴承更换" clearable style="width: 280px" @keyup.enter="search" />
        </ElFormItem>
        <ElFormItem>
          <ElButton type="primary" :icon="Search" @click="search">检索</ElButton>
        </ElFormItem>
      </ElForm>
      <ElAlert type="warning" :closable="false" show-icon title="安全提示：检修作业前必须确认设备已断电并挂牌，办理工作票。" class="kb-safety-tip" />
    </ElCard>

    <ElCard shadow="never" v-if="matched">
      <template #header>
        <div class="kb-card-header">
          <span class="kb-card-title">{{ guide.title }}</span>
          <ElTag type="primary" effect="plain">{{ guide.source }}</ElTag>
        </div>
      </template>
      <ElSteps direction="vertical" :active="guide.steps.length" space="60px">
        <ElStep v-for="(step, i) in guide.steps" :key="i" :title="step.title">
          <template #description>
            <div class="kb-step-desc">{{ step.desc }}</div>
          </template>
        </ElStep>
      </ElSteps>
      <div class="kb-guide-tools">
        <div class="kb-guide-tools-title">所需工器具 / 备件</div>
        <div class="kb-guide-tools-tags">
          <ElTag v-for="t in guide.tools" :key="t" size="small" effect="plain">{{ t }}</ElTag>
        </div>
      </div>
    </ElCard>

    <ElCard shadow="never" v-else>
      <ElEmpty description="输入关键词检索知识库中的维修流程文档" />
    </ElCard>
  </div>
</template>

<script setup lang="ts">
import { Search } from "@element-plus/icons-vue";

defineOptions({ name: "KbRepairGuide" });

const keyword = ref("");
const matched = ref(false);

const guide = ref({
  title: "泵 P-101 驱动端轴承更换流程",
  source: "《泵 P-101 维修手册》V2.1 第 15-19 页",
  tools: ["扳手", "撬棍", "轴承加热器", "润滑脂", "新轴承 6208-2RS"],
  steps: [
    { title: "办理工作票并断电挂牌", desc: "确认设备已断电，挂禁止操作牌，执行隔离程序" },
    { title: "拆卸泵联轴器护罩", desc: "拆除联轴器护罩及连接螺栓，做好标记" },
    { title: "拆除旧轴承", desc: "使用专用拉拔工具拆除旧轴承 6208-2RS，检查轴承座内孔" },
    { title: "安装新轴承 6208-2RS", desc: "轴承加热至 80-100℃ 后安装，涂抹润滑脂，确认到位" },
    { title: "回装并试运行", desc: "回装联轴器，手动盘车确认转动灵活，点动试运行" },
  ],
});

function search() {
  matched.value = true;
}
</script>

<style scoped>
.kb-repair-guide {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.kb-safety-tip {
  margin-top: 4px;
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
.kb-step-desc {
  font-size: 13px;
  color: #6b7280;
}
.kb-guide-tools {
  margin-top: 20px;
  padding-top: 16px;
  border-top: 1px solid #f3f4f6;
}
.kb-guide-tools-title {
  font-size: 13px;
  font-weight: 600;
  color: #374151;
  margin-bottom: 8px;
}
.kb-guide-tools-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}
</style>
