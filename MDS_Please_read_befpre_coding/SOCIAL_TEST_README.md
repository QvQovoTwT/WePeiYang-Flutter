# 私信功能测试说明

## 文件说明

### 1. test_data_generator.dart
位置：`lib/social/model/test_data_generator.dart`

该文件提供了测试数据生成功能，包含：
- `generateTestUsers()` - 生成测试用户列表
- `generateTestConversations()` - 生成测试会话列表
- `generateTestMessages(targetUser, currentUserId)` - 生成测试消息列表
- `getTestUser([index])` - 获取单个测试用户

### 2. social_test_page.dart
位置：`lib/social/view/social_test_page.dart`

该文件是一个测试入口页面，提供测试用户列表，可以直接点击"测试私信"按钮进入聊天页面。

## 使用方法

### 方法一：直接使用 TestDataGenerator

在代码中直接调用 TestDataGenerator 的静态方法：

```dart
import 'package:we_pei_yang_flutter/social/model/test_data_generator.dart';

// 获取测试用户
final testUser = TestDataGenerator.getTestUser();

// 获取所有测试用户
final testUsers = TestDataGenerator.generateTestUsers();

// 导航到聊天页面
Navigator.pushNamed(
  context,
  SocialRouter.chat,
  arguments: testUser,
);
```

### 方法二：临时修改主页面进行测试

在开发时，可以临时修改某个页面（如首页）添加一个测试按钮：

```dart
import 'package:we_pei_yang_flutter/social/model/test_data_generator.dart';
import 'package:we_pei_yang_flutter/social/social_router.dart';

// 在某个页面中添加
ElevatedButton(
  onPressed: () {
    final testUser = TestDataGenerator.getTestUser();
    Navigator.pushNamed(
      context,
      SocialRouter.chat,
      arguments: testUser,
    );
  },
  child: Text('测试私信功能'),
),
```

## 测试数据内容

### 测试用户
- 小明同学 (ID: 1001) - 计算机科学与技术学院
- 小红 (ID: 1002) - 外国语学院
- 技术达人 (ID: 1003) - 电子信息工程学院
- 小萌新 (ID: 1004) - 理学院
- 学霸君 (ID: 1005) - 材料科学与工程学院

### 测试消息
- 包含问候、询问活动时间、回复等真实场景的对话
- 消息时间从几天前到几分钟前不等
- 包含已读和未读消息
