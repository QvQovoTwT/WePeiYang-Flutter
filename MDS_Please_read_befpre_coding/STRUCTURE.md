# 项目结构文档

## Message（消息中心）

### 目录结构
```
lib/message/
├── model/
│   ├── message_model.dart      # 消息数据模型
│   └── message_provider.dart   # 消息状态管理
├── network/
│   └── message_service.dart    # 消息网络请求服务
├── feedback_badge_widget.dart  # 消息徽章组件
├── feedback_banner_widget.dart # 消息横幅组件
├── feedback_message_page.dart  # 消息中心主页面
└── feedback_notice_page.dart   # 湖底通知页面
```

### 功能说明
- **消息中心主页面** (feedback_message_page.dart)：整合各类消息，包含私信、评论、校务回复、点赞、湖底通知五个标签页
- **消息类型**：通过 MessageType 枚举定义，当前顺序为：
  - privateChat（私信）
  - floor（评论）
  - reply（校务回复）
  - like（点赞）
  - lake（湖底通知）
- **状态管理**：使用 Provider 模式管理消息状态
- **网络服务**：处理消息的获取、标记已读等操作

---

## Private Chat（新私信系统）

### 目录结构
```
lib/private_chat/
├── model/
│   ├── private_chat_model.dart       # 私信数据模型
│   └── private_chat_provider.dart    # 私信状态管理
├── network/
│   ├── private_chat_service.dart     # 私信网络服务
│   └── private_chat_websocket_service.dart  # WebSocket实时通信
├── view/
│   ├── page/
│   │   ├── private_chat_api_test_page.dart    # API测试页面
│   │   ├── private_chat_conversation_page.dart # 聊天详情页面
│   │   ├── private_chat_home_page.dart        # 私信首页
│   │   ├── private_chat_log_page.dart         # 日志页面
│   │   └── private_chat_settings_page.dart    # 私信设置页面
│   └── widget/
│       ├── chat_input_widget.dart              # 聊天输入组件
│       ├── contact_tile_widget.dart            # 联系人列表项
│       ├── message_bubble_widget.dart          # 消息气泡
│       └── private_chat_session_list_widget.dart # 会话列表
├── private_chat_router.dart          # 私信路由配置
└── 私信功能接口文档.md
```

### 功能说明
- **聊天详情页面** (private_chat_conversation_page.dart)：显示与特定联系人的聊天记录，支持发送和接收消息
- **会话列表** (private_chat_session_list_widget.dart)：显示所有私信会话，集成在消息中心页面的"私信"标签中
- **实时通信**：使用 WebSocket 实现消息的实时推送
- **状态管理**：使用 Provider 管理私信状态，包括未读消息计数、当前联系人等
- **设置功能**：支持私信总开关和接收陌生人私信开关
- **路由管理**：独立的路由配置，支持页面跳转

---

## Social（社交模块）

### 目录结构
```
lib/social/
├── model/
│   ├── social_models.dart       # 社交数据模型
│   ├── social_provider.dart     # 社交状态管理
│   └── test_data_generator.dart # 测试数据生成
├── network/
│   └── social_service.dart      # 社交网络服务
├── view/
│   ├── friend/
│   │   └── friend_page.dart     # 好友页面
│   ├── profile/
│   │   └── profile_page.dart    # 个人资料页面
│   ├── social_page.dart         # 社交主页面
│   └── social_test_page.dart    # 社交测试页面
└── social_router.dart            # 社交路由配置
```

### 功能说明
- **好友页面** (friend_page.dart)：显示好友列表，支持点击头像跳转到私信聊天
- **个人资料页面** (profile_page.dart)：显示用户详细信息，包含认证标识、私信按钮等
- **社交主页面** (social_page.dart)：社交模块的入口页面
- **状态管理**：使用 Provider 管理社交状态
- **网络服务**：处理社交相关的网络请求
- **路由管理**：独立的路由配置，支持页面跳转

---

## 模块关系说明

1. **Message 模块**：作为消息中心，整合了私信、评论、校务回复、点赞、湖底通知等多种消息类型
2. **Private Chat 模块**：新私信系统，提供完整的聊天功能，通过 `PrivateChatSessionListWidget` 集成到消息中心的"私信"标签页
3. **Social 模块**：社交功能模块，好友页面和个人资料页面的私信按钮会跳转到 `PrivateChatConversationPage`

## 最近修改记录

