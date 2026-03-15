# Social 模块改动记录

## 已完成的改动

### 1. 红点重新生成问题修复
**日期**: 2026-03-15

**修改文件**:
- `lib/home/view/home_page.dart`
- `lib/social/model/social_provider.dart`
- `lib/social/view/message/conversation_list_page.dart`
- `lib/social/view/message/chat_page.dart`

**问题描述**:
- 点进去消息页面消掉红点之后，再点击私信UI回到私信页面发现红点又重新生成了

**解决方案**:
1. 移除了 `home_page.dart` 中点击社交按钮时调用 `clearUnreadCount()` 的逻辑
2. 在 `social_provider.dart` 中新增了 `setUnreadCount()` 方法
3. 在 `conversation_list_page.dart` 中，点击会话进入聊天时，只清除该会话的未读计数
4. 移除了 `chat_page.dart` 中 `dispose()` 时调用 `refreshUnreadCount()` 的逻辑，避免红点重新生成

---

### 2. 个人主页加载失败问题修复
**日期**: 2026-03-15

**修改文件**:
- `lib/social/view/profile/profile_page.dart`

**问题描述**:
- 在私聊页面点进去自己的个人主页，结果显示加载失败
- 点进测试样例的主页仍然如此

**解决方案**:
1. 修改了判断自己主页的逻辑，使用 `CommonPreferences.lakeUid` 而非 `CommonPreferences.userNumber`
2. 新增了 `_isTestUser` 判断方法
3. 修改了 `_loadProfile()` 方法，对于测试用户使用测试数据，对于自己的主页使用本地存储的用户信息
4. 添加了 fallback 机制，即使出错也能显示默认数据

---

### 3. 历史发帖显示开关功能
**日期**: 2026-03-15

**修改文件**:
- `lib/social/network/social_service.dart`
- `lib/commons/preferences/common_prefs.dart`
- `lib/social/view/profile/profile_page.dart`

**功能描述**:
- 用户可以在个人主页中设置是否展示历史发帖
- 默认为关闭状态
- 开关状态会保存到本地存储中

**具体改动**:
1. 在 `social_service.dart` 中添加了 `getPublicPosts()` 和 `getMyPosts()` API
2. 在 `common_prefs.dart` 中添加了 `showHistoryPosts` 配置项
3. 在 `profile_page.dart` 中添加了 `_showHistoryPosts` 状态变量
4. 添加了 `_toggleShowHistoryPosts()` 方法
5. 添加了 `_buildHistoryPostsSetting()` 方法，构建开关UI

---

### 4. 用户认证功能实现
**日期**: 2026-03-15

**修改文件**:
- `lib/social/model/social_models.dart`
- `lib/social/model/test_data_generator.dart`
- `lib/social/view/profile/profile_page.dart`

**新增文件**:
- `assets/svg_pics/social_icons/identification_gold.svg`
- `assets/svg_pics/social_icons/identification_blue.svg`

**功能描述**:
- 金色认证图标代表权威用户（老师、管理者等）
- 蓝色认证图标代表优质用户
- 两个都认证优先显示金色用户
- 认证机制由后台管理，前端提供API

**具体改动**:
1. 在 `SocialUser` 模型中添加了 `identification` 字段
2. 创建了两个认证SVG图标：金底白色对勾和蓝底白色对勾
3. 在测试数据中为小明设置金色认证，其他测试用户设置蓝色认证
4. 在 `profile_page.dart` 的 `_buildHeader()` 方法中添加了认证图标的显示逻辑

---

### 5. 关注和粉丝显示问题修复
**日期**: 2026-03-15

**修改文件**:
- `lib/social/view/friend/friend_page.dart`

**问题描述**:
- 关注和粉丝页面没有显示测试用户

**解决方案**:
1. 添加了 `_getTestFollowUsers()` 辅助函数，将测试用户转换为 `FollowUser`
2. 修改了 `_FollowingTab` 和 `_FollowersTab` 的 `_onRefresh()` 方法，当后端请求失败时使用测试数据
3. 修改了 `_onLoading()` 方法，加载失败时停止加载更多

---

### 6. 聊天消息已读状态显示功能
**日期**: 2026-03-15

**修改文件**:
- `lib/social/view/message/chat_page.dart`

**功能描述**:
- 在聊天界面中，对于自己发送的最新消息，显示"已读"两个字
- 仅在最新消息显示已读，旧消息不显示
- 打开聊天页面时，自动标记对方发送的所有消息为已读
- 对于测试用户，模拟对方在2秒后将消息标记为已读

**具体改动**:
1. 在 `_MessageItem` 组件中新增 `isLatestMessage` 参数，用于判断是否为最新消息
2. 修改消息时间显示区域，增加已读状态显示（仅在最新消息且自己发送时显示）
3. 修改 ChatPage 中的 ListView.builder，为最后一条消息传入 `isLatestMessage: true`
4. 修改 `_loadMessageHistory()` 方法，打开聊天时标记对方发送的消息为已读
5. 对于测试用户，发送消息2秒后模拟对方已读

---

## 需要与后端沟通的API

### 1. 用户认证API
- `GET /api/v1/b/users/{userId}/identification` - 获取用户认证状态
  - 返回: `{ identification: 'gold' | 'blue' | null }`
- `PUT /api/v1/b/users/{userId}/identification` - 设置用户认证状态（仅管理员）
  - 请求参数: `{ identification: 'gold' | 'blue' | null }`

### 2. 会话未读消息API
- `POST /api/v1/b/conversations/{id}/read` - 标记指定会话为已读
  - 请求参数: 无

### 3. 消息已读状态API
- 需要后端在消息模型中支持 `isRead` 字段
- 当接收方查看消息时，通过API标记消息为已读
- 实时同步双方的消息已读状态（可考虑使用WebSocket或轮询）

### 4. 用户历史发帖API（已有接口文档）
参考: `MDS_Please_read_befpre_coding/个人主页接口-v0.0.1_1.md`
