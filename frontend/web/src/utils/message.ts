/**
 * Element Plus 消息组件封装工具
 *
 * 所有 Element Plus 消息组件（ElMessage、ElNotification、ElMessageBox、ElLoading）
 * 通过此模块统一导出，避免直接从 element-plus 导入导致全量打包。
 *
 * 使用方式：
 * ```typescript
 * import { ElMessage, ElNotification, ElMessageBox, ElLoading } from "@/utils/message";
 *
 * ElMessage.success("操作成功");
 * ElNotification.info({ title: "提示", message: "消息内容" });
 * ElMessageBox.confirm("确定删除吗？");
 * ElLoading.service({ fullscreen: true });
 * ```
 */

// 使用 element-plus/es/components/*/index 路径单独导入，避免全量打包
import { ElMessage } from "element-plus/es/components/message/index";
import { ElNotification } from "element-plus/es/components/notification/index";
import { ElMessageBox } from "element-plus/es/components/message-box/index";
import { ElLoading } from "element-plus/es/components/loading/index";

export { ElMessage, ElNotification, ElMessageBox, ElLoading };
