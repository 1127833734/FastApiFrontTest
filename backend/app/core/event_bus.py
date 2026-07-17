"""异步事件总线 — SSE 通知推送的核心组件

职责：
- 维护每个用户的 asyncio.Queue（用户退出后自动清理）
- 提供 publish / subscribe / unsubscribe 接口

使用方：
- SSE 端点 → subscribe / unsubscribe
- 各业务服务 → publish
"""

import asyncio
import json
from datetime import datetime
from typing import Any

from app.core.logger import logger


class EventBus:
    """异步事件总线（全局单例）"""

    _subscribers: dict[int, asyncio.Queue[str]] = {}

    @classmethod
    def subscribe(cls, user_id: int) -> asyncio.Queue[str]:
        """为用户创建一个事件队列（已存在则返回现有队列）"""
        queue = cls._subscribers.get(user_id)
        if queue:
            return queue
        queue = asyncio.Queue(maxsize=256)
        cls._subscribers[user_id] = queue
        logger.debug(f"SSE 订阅: user_id={user_id}")
        return queue

    @classmethod
    def unsubscribe(cls, user_id: int) -> None:
        """移除用户的事件队列"""
        cls._subscribers.pop(user_id, None)
        logger.debug(f"SSE 取消订阅: user_id={user_id}")

    @classmethod
    async def publish(cls, user_id: int, event: dict[str, Any]) -> None:
        """向指定用户推送事件（用户不在线则静默丢弃）"""
        queue = cls._subscribers.get(user_id)
        if queue is None:
            return
        payload = _build_sse_payload(event)
        try:
            await asyncio.wait_for(queue.put(payload), timeout=2)
        except (TimeoutError, asyncio.QueueFull):
            logger.warning(f"SSE 推送超时或队列满: user_id={user_id}, event={event.get('type')}")


def _build_sse_payload(event: dict[str, Any]) -> str:
    """将事件字典序列化为 SSE data 行"""
    event.setdefault("timestamp", datetime.now().isoformat())
    return json.dumps(event, ensure_ascii=False)


