# Social 模块项目结构

## 目录结构

```
lib/social/
├── model/
│   ├── social_models.dart          # 社交模块数据模型定义
│   ├── social_provider.dart        # 社交模块状态管理
│   └── test_data_generator.dart    # 测试数据生成器
├── network/
│   └── social_service.dart         # 社交模块API服务
├── view/
│   ├── friend/
│   │   └── friend_page.dart        # 好友/关注/粉丝页面
│   ├── message/
│   │   ├── chat_page.dart          # 聊天页面
│   │   └── conversation_list_page.dart  # 会话列表页面
│   ├── profile/
│   │   └── profile_page.dart       # 个人主页
│   ├── social_page.dart            # 社交主页
│   └── social_test_page.dart       # 测试页面
└── social_router.dart              # 社交模块路由定义
```

## 数据模型说明

### SocialUser (社交用户模型)
- **字段**:
  - `id`: 用户唯一标识
  - `nickname`: 用户昵称
  - `avatar`: 用户头像URL
  - `avatarBox`: 头像框装饰
  - `level`: 用户等级
  - `userNumber`: 用户学号
  - `department`: 学院
  - `major`: 专业
  - `visible`: 主页可见性
  - `identification`: 用户认证类型 ('gold'金色, 'blue'蓝色, null未认证)

### 其他模型
- `Friend`: 好友关系模型
- `Conversation`: 会话模型
- `ChatMessage`: 聊天消息模型
- `FollowUser`: 关注用户模型
- `UserProfile`: 用户个人资料模型
- `ListResponse<T>`: 列表响应通用模型

## 功能模块

### 1. 会话列表页面 (conversation_list_page.dart)
- 展示所有私信会话
- 支持下拉刷新和上拉加载
- 点击会话进入聊天页面
- 显示未读消息数红点

### 2. 聊天页面 (chat_page.dart)
- 展示和发送私信消息
- 支持发送文本消息
- 显示用户认证标识
- 支持消息分页加载

### 3. 个人主页 (profile_page.dart)
- 展示用户基本信息
- 显示粉丝数、关注数、动态数
- 关注/取消关注功能
- 发送私信功能
- 主页可见性设置
- 历史发帖显示开关
- 用户认证标识显示

### 4. 好友页面 (friend_page.dart)
- 关注列表标签页
- 粉丝列表标签页
- 点击用户头像进入个人主页
- 发送私信功能
- 移除粉丝功能

## 资源文件

### SVG 图标
```
assets/svg_pics/social_icons/
├── identification_gold.svg     # 金色认证图标（权威用户）
├── identification_blue.svg     # 蓝色认证图标（优质用户）
├── friends.svg
└── my_friends.svg
```

## 测试数据

测试用户ID范围: 1001-1005
- 小明同学 (1001): 金色认证
- 小红 (1002): 蓝色认证
- 技术达人 (1003): 蓝色认证
- 小萌新 (1004): 蓝色认证
- 学霸君 (1005): 蓝色认证

## API 接口

### 用户认证相关
- 后端需提供: `GET /api/v1/b/users/{userId}/identification` - 获取用户认证状态
- 后端需提供: `PUT /api/v1/b/users/{userId}/identification` - 设置用户认证状态

### 用户历史发帖相关
- `GET /api/v1/b/profiles/{userId}/public-posts` - 获取用户公开发布的帖子
- `GET /api/v1/b/profiles/{uid}/me-posts` - 获取用户自己发布的帖子
- `PUT /api/v1/b/profiles/{id}/visibility` - 设置帖子可见性

### 会话未读相关
- 后端需提供: `POST /api/v1/b/conversations/{id}/read` - 标记会话为已读
