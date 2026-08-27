<!--
  备件知识库 · AI 备件助手
  复刻原型 assistant 页：会话历史 / 对话消息流 / 输入框
-->
<template>
  <div class="kb-assistant">
    <!-- 会话历史 -->
    <ElCard shadow="never" class="kb-assistant-history">
      <div class="kb-history-new">
        <ElButton type="primary" style="width: 100%" @click="newSession">+ 新会话</ElButton>
      </div>
      <div class="kb-history-list">
        <div class="kb-history-group" v-for="group in historyGroups" :key="group.label">
          <div class="kb-history-group-label">{{ group.label }}</div>
          <div
            v-for="title in group.items"
            :key="title"
            class="kb-history-item"
            :class="{ 'kb-history-item--active': title === activeSession }"
            @click="activeSession = title"
          >
            {{ title }}
          </div>
        </div>
      </div>
    </ElCard>

    <!-- 对话区 -->
    <ElCard shadow="never" class="kb-assistant-chat">
      <div ref="chatBodyRef" class="kb-chat-body">
        <div v-for="msg in messages" :key="msg.id" class="kb-msg" :class="`kb-msg--${msg.role}`">
          <div class="kb-msg-bubble">
            <div class="kb-msg-content">{{ msg.content }}</div>
            <div v-if="msg.sources?.length" class="kb-msg-sources">
              <ElTag v-for="s in msg.sources" :key="s.documentName" size="small" type="primary" effect="plain">
                {{ s.documentName }} · 第 {{ s.pageNo }} 页
              </ElTag>
            </div>
            <div v-if="msg.matchedParts?.length" class="kb-msg-parts">
              <div class="kb-msg-parts-label">关联零件</div>
              <div v-for="p in msg.matchedParts" :key="p.partNo" class="kb-msg-part">
                {{ p.partNo }} · {{ p.name }} {{ p.spec }}
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="kb-chat-input">
        <ElInput
          v-model="input"
          type="textarea"
          :rows="2"
          placeholder="输入问题，例如：泵 P-101 的轴承型号是什么？"
          @keydown.enter.exact.prevent="send"
        />
        <ElButton type="primary" :icon="Promotion" @click="send">发送</ElButton>
      </div>
    </ElCard>
  </div>
</template>

<script setup lang="ts">
import { Promotion } from "@element-plus/icons-vue";

defineOptions({ name: "KbAssistant" });

const activeSession = ref("泵 P-101 轴承查询");
const input = ref("");
const chatBodyRef = ref<HTMLElement | null>(null);

const historyGroups = [
  {
    label: "今天",
    items: ["泵 P-101 轴承查询", "阀门密封垫替代件", "维修工具清单"],
  },
  {
    label: "昨天",
    items: ["电机碳刷规格", "BOM 结构查询"],
  },
];

interface ChatMessage {
  id: string;
  role: "user" | "assistant";
  content: string;
  sources?: { documentName: string; pageNo: number }[];
  matchedParts?: { partNo: string; name: string; spec: string }[];
}

const messages = ref<ChatMessage[]>([
  {
    id: "msg-001",
    role: "user",
    content: "泵 P-101 的轴承型号是什么？",
  },
  {
    id: "msg-002",
    role: "assistant",
    content:
      "根据《泵 P-101 维修手册》V2.1 第 15 页，泵 P-101 驱动端轴承型号为 6208-2RS，非驱动端轴承型号为 6207-2RS。建议每 8000 运行小时检查一次轴承磨损情况。",
    sources: [{ documentName: "泵 P-101 维修手册", pageNo: 15 }],
    matchedParts: [{ partNo: "P101-001", name: "轴承", spec: "6208-2RS" }],
  },
]);

function newSession() {
  messages.value = [];
  input.value = "";
}

function send() {
  const text = input.value.trim();
  if (!text) return;
  messages.value.push({ id: `u-${Date.now()}`, role: "user", content: text });
  messages.value.push({
    id: `a-${Date.now()}`,
    role: "assistant",
    content: `已为您检索到与"${text}"相关的资料。根据知识库内容，建议查看《泵 P-101 维修手册》相关章节。`,
    sources: [{ documentName: "泵 P-101 维修手册", pageNo: 15 }],
  });
  input.value = "";
  nextTick(() => {
    chatBodyRef.value?.scrollTo({ top: chatBodyRef.value.scrollHeight, behavior: "smooth" });
  });
}
</script>

<style scoped>
.kb-assistant {
  display: flex;
  gap: 16px;
  height: calc(100vh - 140px);
}
.kb-assistant-history {
  width: 260px;
  display: flex;
  flex-direction: column;
  padding: 0;
  overflow: hidden;
  flex: 0 0 auto;
}
.kb-history-new {
  padding: 16px;
  border-bottom: 1px solid #e5e7eb;
}
.kb-history-list {
  flex: 1;
  overflow: auto;
  padding: 12px;
}
.kb-history-group-label {
  font-size: 12px;
  color: #9ca3af;
  margin-bottom: 8px;
  padding-left: 8px;
}
.kb-history-item {
  padding: 10px 12px;
  border-radius: 6px;
  font-size: 13px;
  color: #374151;
  cursor: pointer;
  margin-bottom: 4px;
}
.kb-history-item:hover {
  background: #f1f5f9;
}
.kb-history-item--active {
  background: #e8f0ff;
  color: #0f172a;
}
.kb-assistant-chat {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding: 0;
  overflow: hidden;
  min-width: 0;
}
.kb-chat-body {
  flex: 1;
  overflow: auto;
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.kb-msg {
  display: flex;
}
.kb-msg--user {
  justify-content: flex-end;
}
.kb-msg--assistant {
  justify-content: flex-start;
}
.kb-msg-bubble {
  max-width: 75%;
  padding: 12px 16px;
  border-radius: 10px;
  font-size: 14px;
  line-height: 1.7;
  color: #1f2937;
  background: #f3f4f6;
}
.kb-msg--user .kb-msg-bubble {
  background: #18a058;
  color: #fff;
}
.kb-msg-content {
  white-space: pre-wrap;
  word-break: break-word;
}
.kb-msg-sources {
  margin-top: 10px;
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}
.kb-msg-parts {
  margin-top: 10px;
  padding-top: 10px;
  border-top: 1px dashed #d1d5db;
}
.kb-msg-parts-label {
  font-size: 12px;
  color: #9ca3af;
  margin-bottom: 6px;
}
.kb-msg-part {
  font-size: 13px;
  color: #374151;
  background: #fff;
  border-radius: 4px;
  padding: 4px 8px;
  margin-bottom: 4px;
  display: inline-block;
  margin-right: 6px;
}
.kb-chat-input {
  padding: 12px 16px;
  border-top: 1px solid #e5e7eb;
  display: flex;
  gap: 12px;
  align-items: flex-end;
}
</style>
