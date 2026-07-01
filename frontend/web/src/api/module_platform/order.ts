import { request } from "@utils";

// ─── 平台订单 ──────────────────────────────────────────
const API_PATH = "/platform/order";

const OrderAPI = {
  // ─── 订单管理 ───
  listOrders(query?: OrderPageQuery) {
    return request<ApiResponse<{ items: OrderTable[]; total: number }>>({
      url: `${API_PATH}/list`,
      method: "get",
      params: query,
    });
  },

  detailOrder(orderId: number) {
    return request<ApiResponse<OrderTable>>({
      url: `${API_PATH}/detail/${orderId}`,
      method: "get",
    });
  },

  createOrder(body: OrderCreateForm) {
    return request<ApiResponse<{ id: number; order_no: string }>>({
      url: `${API_PATH}/create`,
      method: "post",
      data: body,
    });
  },

  cancelOrder(orderId: number) {
    return request<ApiResponse<{ message: string }>>({
      url: `${API_PATH}/cancel/${orderId}`,
      method: "post",
    });
  },

  // ─── 支付操作 ───
  payOrder(orderId: number, method?: string) {
    return request<
      ApiResponse<{ order_no: string; amount: number; qr_code_url?: string; pay_url?: string }>
    >({
      url: `${API_PATH}/pay/${orderId}`,
      method: "post",
      params: method ? { method } : undefined,
    });
  },

  queryPaymentStatus(orderId: number) {
    return request<ApiResponse<{ paid: boolean; order_no?: string; amount?: number }>>({
      url: `${API_PATH}/status/${orderId}`,
      method: "get",
    });
  },

  mockPaymentCallback(orderId: number) {
    return request<ApiResponse>({
      url: `${API_PATH}/mock/callback`,
      method: "post",
      data: { order_id: orderId },
    });
  },

  // ─── 支付记录 ───
  listPaymentRecords(query?: PageQuery) {
    return request<ApiResponse<{ items: PaymentRecordTable[]; total: number }>>({
      url: `${API_PATH}/record/list`,
      method: "get",
      params: query,
    });
  },

  // ─── 退款管理 ───
  listRefunds(query?: RefundPageQuery) {
    return request<ApiResponse<{ items: RefundTable[]; total: number }>>({
      url: `${API_PATH}/refund/list`,
      method: "get",
      params: query,
    });
  },

  approveRefund(refundId: number) {
    return request<ApiResponse<{ message: string }>>({
      url: `${API_PATH}/approve/${refundId}`,
      method: "put",
    });
  },

  rejectRefund(refundId: number, body: { reject_reason?: string }) {
    return request<ApiResponse<{ message: string }>>({
      url: `${API_PATH}/reject/${refundId}`,
      method: "put",
      data: body,
    });
  },

  // ─── 租户端 ───
  tenantCreateOrder(body: {
    tenant_id: number;
    package_id?: number;
    plugin_id?: number;
    order_type: string;
    pay_method?: string;
  }) {
    return request<ApiResponse<{ id: number; order_no: string }>>({
      url: `${API_PATH}/tenant/create`,
      method: "post",
      data: body,
    });
  },

  tenantApplyRefund(orderId: number, body: { reason: string }) {
    return request<ApiResponse<{ id: number }>>({
      url: `${API_PATH}/tenant/refund/apply/${orderId}`,
      method: "post",
      data: body,
    });
  },
};

export default OrderAPI;

// ─── Order 类型 ──────────────────────────────────────────

export interface OrderPageQuery extends PageQuery, TenantByQueryParams {
  order_type?: string;
  status?: number;
}

export interface OrderTable {
  id: number;
  order_no: string;
  tenant_id: number;
  package_id?: number;
  plugin_id?: number;
  order_type: string;
  amount: number;
  period_count: number;
  status: number;
  pay_method?: string;
  pay_time?: string;
  expire_time: string;
  created_time?: string;
}

export interface OrderCreateForm {
  tenant_id: number;
  package_id?: number;
  plugin_id?: number;
  order_type: "new" | "renew" | "upgrade" | "downgrade" | "plugin";
  pay_method?: string;
}

// ─── Payment 类型 ────────────────────────────────────────

export interface PaymentRecordTable {
  id: number;
  order_id: number;
  transaction_id?: string;
  pay_method: string;
  amount: number;
  status: number;
  pay_time?: string;
  created_time?: string;
}

// ─── Refund 类型 ─────────────────────────────────────────

export interface RefundPageQuery extends PageQuery, UserByQueryParams, TenantByQueryParams {
  status?: number;
}

export interface RefundTable {
  id: number;
  order_id: number;
  refund_no: string;
  amount: number;
  reason: string;
  status: number;
  refund_transaction_id?: string;
  reviewer_id?: number;
  review_time?: string;
  reject_reason?: string;
  created_time?: string;
}
