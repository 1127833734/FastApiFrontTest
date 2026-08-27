<!--
  备件知识库 · 业务场景 / 备件精准查询
  完全复刻原型 spare-query 页（CapabilityChatShell + ChatMessage + 备件档案表格）
-->
<template>
  <div class="kb-spq">
    <!-- 左栏：新会话 + 能力示例 -->
    <div class="kb-spq-side">
      <div class="kb-spq-side-new">
        <ElButton type="primary" style="width: 100%">+ 新会话</ElButton>
      </div>
      <div class="kb-spq-side-list">
        <div class="kb-spq-side-title">能力示例</div>
        <div v-for="s in suggestions" :key="s" class="kb-spq-side-item">{{ s }}</div>
      </div>
    </div>

    <!-- 右栏：聊天区 -->
    <div class="kb-spq-main" data-annotation-id="spare-precise-query">
      <!-- 头部 -->
      <div class="kb-spq-head">
        <SparklesIcon :size="18" color="#3b82f6" />
        <span class="kb-spq-title">备件精准查询</span>
        <span class="kb-spq-role">角色：备件档案查询 Agent</span>
      </div>

      <!-- 能力说明 -->
      <div class="kb-spq-capability">
        <SparklesIcon :size="18" color="#3b82f6" style="flex-shrink: 0; margin-top: 2px" />
        <div>
          <strong>能力说明：</strong>支持通过零件编号、物料名称、设备编号、规格型号等多维度查询，自动聚合技术参数、库存、替代件、供应商、采购周期及关联文档，实现"一问即得"的完整备件档案。
          <div class="kb-spq-demo-tip">⚠ 演示态：当前为示例数据，未连接真实零件库 / 库存 / 文档系统。</div>
        </div>
      </div>

      <!-- 消息流 -->
      <div ref="bodyRef" class="kb-spq-body">
        <div v-for="msg in messages" :key="msg.id" :class="['kb-msg', msg.role === 'user' ? 'kb-msg--user' : '']">
          <!-- 用户消息 -->
          <div v-if="msg.role === 'user'" class="kb-bubble-user">{{ msg.content }}</div>

          <!-- 助手消息 -->
          <template v-else>
            <div class="kb-ai-avatar">AI</div>
            <div class="kb-ai-body">
              <div class="kb-bubble-ai">{{ msg.content }}</div>
              <div v-if="msg.sources?.length" class="kb-refs">
                <span class="kb-refs-label">参考文件：</span>
                <span v-for="s in msg.sources" :key="s.documentName" class="kb-ref" :class="s.reviewStatus === 'reviewed' ? 'kb-ref--ok' : 'kb-ref--warn'">
                  <ElIcon :size="12"><Document /></ElIcon>
                  {{ s.documentName }} 第{{ s.pageNo }}页
                </span>
              </div>
              <!-- 备件档案表格 -->
              <div v-if="msg.id === 'assistant-1'" class="kb-archive">
                <table class="kb-archive-table">
                  <tbody>
                    <tr v-for="row in archiveRows" :key="row.label">
                      <th :style="row.label === '物料号' ? { width: '28%' } : {}">{{ row.label }}</th>
                      <td>{{ row.value }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <!-- 反馈按钮 -->
              <div class="kb-feedback">
                <button class="kb-feedback-btn">有用</button>
                <button class="kb-feedback-btn">无用</button>
                <button class="kb-feedback-btn">纠错</button>
              </div>
            </div>
          </template>
        </div>
      </div>

      <!-- 输入区 -->
      <div class="kb-spq-input">
        <div class="kb-spq-input-row">
          <input
            v-model="input"
            type="text"
            class="kb-spq-input-field"
            placeholder="请输入问题..."
            @keydown.enter="send"
          />
          <button class="kb-spq-send" style="background: #3b82f6; border-color: #3b82f6" @click="send">
            <ElIcon :size="18"><Promotion /></ElIcon>
          </button>
        </div>
        <div class="kb-spq-input-tip">AI 回答基于授权知识库生成，请结合原文出处进行核实。</div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Document, Promotion } from "@element-plus/icons-vue";
import { h } from "vue";

defineOptions({ name: "KbSpareQuery" });

/** Sparkles 图标（feather 风格，EP 无对应图标） */
const SparklesIcon = (props: { size?: number; color?: string; style?: Record<string, unknown> }) =>
  h(
    "svg",
    {
      xmlns: "http://www.w3.org/2000/svg",
      width: props.size || 18,
      height: props.size || 18,
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: props.color || "#3b82f6",
      "stroke-width": 2,
      "stroke-linecap": "round",
      "stroke-linejoin": "round",
      style: props.style,
    },
    [
      h("path", { d: "M12 3l1.9 5.7a2 2 0 0 0 1.3 1.3L21 12l-5.8 1.9a2 2 0 0 0-1.3 1.3L12 21l-1.9-5.8a2 2 0 0 0-1.3-1.3L3 12l5.8-1.9a2 2 0 0 0 1.3-1.3L12 3z" }),
      h("path", { d: "M5 3v4" }),
      h("path", { d: "M19 17v4" }),
      h("path", { d: "M3 5h4" }),
      h("path", { d: "M17 19h4" }),
    ]
  );

interface ChatSource {
  documentName: string;
  pageNo: number;
  reviewStatus: "reviewed" | "unreviewed";
}
interface ChatMessage {
  id: string;
  role: "user" | "assistant";
  content: string;
  sources?: ChatSource[];
}

const bodyRef = ref<HTMLElement | null>(null);
const input = ref("");
const suggestions = [
  "查询泵 P-101 联轴器档案",
  "按设备号 MV-201 查全部安全阀",
  "六角螺栓 M16×60 的供应商是谁",
  "O型密封圈 Φ85×3.1 的库存和替代件",
];

const messages = ref<ChatMessage[]>([
  {
    id: "welcome",
    role: "assistant",
    content:
      "您好，我是备件精准查询 Agent。您可以通过零件编号、名称、设备编号或规格型号，一键查询完整备件档案，包括技术参数、替代件、供应商及采购周期等信息。",
  },
  {
    id: "user-1",
    role: "user",
    content: "查询主汽阀 MV-201 的安全阀 A48Y-16C DN50 的完整档案",
  },
  {
    id: "assistant-1",
    role: "assistant",
    content:
      "已为您定位到 1 条精准匹配记录，物料号 M-009。以下是该安全阀的完整档案，数据来自工业物料清单及厂家技术资料：",
    sources: [
      { documentName: "工业物料清单", pageNo: 9, reviewStatus: "reviewed" },
      { documentName: "A48Y 安全阀技术规格书", pageNo: 3, reviewStatus: "reviewed" },
    ],
  },
]);

const archiveRows = [
  { label: "物料号", value: "M-009" },
  { label: "物料名称", value: "安全阀" },
  { label: "规格型号/图号", value: "A48Y-16C DN50" },
  { label: "材质", value: "WCB" },
  { label: "压力等级", value: "PN16" },
  { label: "口径", value: "DN50" },
  { label: "密封面", value: "堆焊硬质合金" },
  { label: "连接方式", value: "法兰" },
  { label: "厂家/供应商", value: "哈电集团" },
  { label: "当前库存", value: "8 件" },
  { label: "所属系统/设备", value: "蒸汽系统 / 主汽阀 MV-201" },
  { label: "替代件", value: "A48Y-16C DN50（WCB 本体）、A48Y-16C DN50（06Cr18Ni11Ti 阀芯）" },
  { label: "采购周期", value: "45 天（国产）/ 90 天（进口）" },
  { label: "关联文档", value: "《A48Y 安全阀技术规格书》《主汽阀 MV-201 维修规程》" },
];

function send() {
  const text = input.value.trim();
  if (!text) return;
  messages.value.push({ id: `u-${Date.now()}`, role: "user", content: text });
  messages.value.push({
    id: `a-${Date.now()}`,
    role: "assistant",
    content:
      `已收到查询“${text}”。在当前演示数据中，我为您匹配到相近结果。实际落地后，系统会基于统一物料编码、设备 KKS 编码及知识库文档进行多源融合检索。`,
    sources: [{ documentName: "工业物料清单", pageNo: 1, reviewStatus: "reviewed" }],
  });
  input.value = "";
  nextTick(() => {
    bodyRef.value?.scrollTo({ top: bodyRef.value.scrollHeight, behavior: "smooth" });
  });
}
</script>

<style scoped>
.kb-spq {
  display: flex;
  height: calc(100vh - 140px);
  gap: 16px;
}
/* 左栏 */
.kb-spq-side {
  width: 280px;
  flex: 0 0 auto;
  background: #fff;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.kb-spq-side-new {
  padding: 16px;
  border-bottom: 1px solid #e5e7eb;
}
.kb-spq-side-list {
  flex: 1;
  overflow: auto;
  padding: 12px;
}
.kb-spq-side-title {
  font-size: 12px;
  color: #9ca3af;
  margin-bottom: 8px;
  padding-left: 8px;
}
.kb-spq-side-item {
  padding: 10px 12px;
  border-radius: 6px;
  font-size: 13px;
  color: #374151;
  cursor: pointer;
  margin-bottom: 4px;
  background: #f9fafb;
}
/* 右栏 */
.kb-spq-main {
  flex: 1;
  min-width: 0;
  background: #fff;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.kb-spq-head {
  padding: 12px 20px;
  border-bottom: 1px solid #e5e7eb;
  display: flex;
  align-items: center;
  gap: 8px;
}
.kb-spq-title {
  font-weight: 600;
  color: #111827;
  font-size: 14px;
}
.kb-spq-role {
  margin-left: auto;
  font-size: 12px;
  color: #6b7280;
}
.kb-spq-capability {
  margin: 16px;
  padding: 12px 14px;
  background: #eff6ff;
  border: 1px solid #bfdbfe;
  border-radius: 8px;
  display: flex;
  gap: 8px;
  font-size: 13px;
  color: #1e40af;
  line-height: 1.6;
}
.kb-spq-demo-tip {
  margin-top: 6px;
  font-size: 12px;
  color: #b45309;
}
.kb-spq-body {
  flex: 1;
  overflow: auto;
  padding: 20px;
}
.kb-msg {
  display: flex;
  gap: 12px;
  margin-bottom: 24px;
}
.kb-msg--user {
  justify-content: flex-end;
}
.kb-bubble-user {
  max-width: 70%;
  background: #3b82f6;
  color: #fff;
  padding: 12px 16px;
  border-radius: 12px 12px 4px 12px;
  font-size: 14px;
  line-height: 1.6;
}
.kb-ai-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: linear-gradient(135deg, #3b82f6 0%, #b0b0b0 100%);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  font-size: 13px;
  font-weight: 600;
}
.kb-ai-body {
  flex: 1;
  max-width: calc(100% - 60px);
}
.kb-bubble-ai {
  background: #f9fafb;
  border: 1px solid #e5e7eb;
  padding: 14px 16px;
  border-radius: 12px 12px 12px 4px;
  font-size: 14px;
  line-height: 1.7;
  color: #374151;
  white-space: pre-wrap;
}
.kb-refs {
  margin-top: 10px;
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
}
.kb-refs-label {
  font-size: 12px;
  color: #9ca3af;
}
.kb-ref {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  padding: 4px 8px;
  border-radius: 4px;
  cursor: pointer;
}
.kb-ref--ok {
  color: #18a058;
  background: #f0fdf4;
}
.kb-ref--warn {
  color: #f59e0b;
  background: #fef3c7;
}
.kb-archive {
  margin-top: 12px;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  overflow: hidden;
}
.kb-archive-table {
  width: 100%;
  border-collapse: collapse;
  table-layout: fixed;
  font-size: 14px;
}
.kb-archive-table th {
  width: auto;
  background: #f9fafb;
  color: #374151;
  font-weight: 600;
  text-align: left;
  padding: 10px 12px;
  border-bottom: 1px solid #e5e7eb;
  border-right: 1px solid #e5e7eb;
  white-space: nowrap;
}
.kb-archive-table td {
  padding: 10px 12px;
  border-bottom: 1px solid #e5e7eb;
  color: #111827;
  word-break: break-all;
}
.kb-archive-table tr:last-child th,
.kb-archive-table tr:last-child td {
  border-bottom: 0;
}
.kb-feedback {
  margin-top: 10px;
  display: flex;
  gap: 8px;
}
.kb-feedback-btn {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  color: #6b7280;
  background: transparent;
  border: 0;
  cursor: pointer;
  padding: 2px 4px;
}
.kb-spq-input {
  padding: 16px;
  border-top: 1px solid #e5e7eb;
}
.kb-spq-input-row {
  display: flex;
  gap: 10px;
}
.kb-spq-input-field {
  flex: 1;
  padding: 12px 16px;
  border-radius: 8px;
  border: 1px solid #d1d5db;
  font-size: 14px;
  outline: none;
}
.kb-spq-input-field:focus {
  border-color: #3b82f6;
}
.kb-spq-send {
  width: 46px;
  border-radius: 8px;
  color: #fff;
  border: 1px solid;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}
.kb-spq-input-tip {
  margin-top: 8px;
  font-size: 12px;
  color: #9ca3af;
}
</style>
