import 'social_models.dart';

/// 测试数据生成器
///
/// 该类用于生成虚拟的测试数据，方便测试私信功能
class TestDataGenerator {
  /// 本地头像图片列表
  static final List<String> _localAvatars = [
    'assets/images/my.png',
    'assets/images/home.png',
    'assets/images/lake.png',
    'assets/images/mymsg.png',
    'assets/images/myfav.png',
  ];

  /// 生成测试用户列表
  ///
  /// 返回一个包含多个测试用户的列表
  static List<SocialUser> generateTestUsers() {
    return [
      SocialUser(
        id: 1001,
        nickname: '小明同学',
        avatar: _localAvatars[0],
        level: 15,
        department: '计算机科学与技术学院',
        major: '软件工程',
        visible: true,
        identification: VerificationBadge.yellow,
      ),
      SocialUser(
        id: 1002,
        nickname: '小红',
        avatar: _localAvatars[1],
        level: 12,
        department: '外国语学院',
        major: '英语',
        visible: true,
        identification: VerificationBadge.blue,
      ),
      SocialUser(
        id: 1003,
        nickname: '技术达人',
        avatar: _localAvatars[2],
        level: 20,
        department: '电子信息工程学院',
        major: '通信工程',
        visible: true,
        identification: VerificationBadge.blue,
      ),
      SocialUser(
        id: 1004,
        nickname: '小萌新',
        avatar: _localAvatars[3],
        level: 3,
        department: '理学院',
        major: '数学与应用数学',
        visible: true,
        identification: VerificationBadge.blue,
      ),
      SocialUser(
        id: 1005,
        nickname: '学霸君',
        avatar: _localAvatars[4],
        level: 25,
        department: '材料科学与工程学院',
        major: '材料化学',
        visible: true,
        identification: VerificationBadge.blue,
      ),
    ];
  }

  /// 生成测试会话列表
  ///
  /// 返回一个包含多个测试会话的列表
  static List<Conversation> generateTestConversations() {
    final testUsers = generateTestUsers();
    final now = DateTime.now();

    return [
      Conversation(
        id: 1,
        targetUser: testUsers[0],
        lastMessage: '好的，明天见！',
        lastMessageTime: now.subtract(const Duration(minutes: 5)),
        unreadCount: 2,
      ),
      Conversation(
        id: 2,
        targetUser: testUsers[1],
        lastMessage: '收到你的消息了',
        lastMessageTime: now.subtract(const Duration(hours: 1)),
        unreadCount: 0,
      ),
      Conversation(
        id: 3,
        targetUser: testUsers[2],
        lastMessage: '那个问题解决了吗？',
        lastMessageTime: now.subtract(const Duration(hours: 3)),
        unreadCount: 1,
      ),
      Conversation(
        id: 4,
        targetUser: testUsers[3],
        lastMessage: '学长好，想问个问题',
        lastMessageTime: now.subtract(const Duration(days: 1)),
        unreadCount: 0,
      ),
      Conversation(
        id: 5,
        targetUser: testUsers[4],
        lastMessage: '这道题我有更好的解法',
        lastMessageTime: now.subtract(const Duration(days: 2)),
        unreadCount: 3,
      ),
    ];
  }

  /// 生成测试消息列表
  ///
  /// [targetUser] 目标用户
  /// [currentUserId] 当前用户ID
  ///
  /// 返回一个包含多条测试消息的列表
  static List<ChatMessage> generateTestMessages(
      SocialUser targetUser, int currentUserId) {
    final now = DateTime.now();
    final messages = <ChatMessage>[];

    // 生成一些历史消息
    messages.add(ChatMessage(
      id: 1,
      senderId: targetUser.id,
      receiverId: currentUserId,
      content: '你好！',
      createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      isRead: true,
      type: MessageType.text,
    ));

    messages.add(ChatMessage(
      id: 2,
      senderId: currentUserId,
      receiverId: targetUser.id,
      content: '你好，有什么事吗？',
      createdAt: now.subtract(const Duration(days: 1, hours: 1, minutes: 55)),
      isRead: true,
      type: MessageType.text,
    ));

    messages.add(ChatMessage(
      id: 3,
      senderId: targetUser.id,
      receiverId: currentUserId,
      content: '想问一下明天的活动是什么时候开始？',
      createdAt: now.subtract(const Duration(days: 1, hours: 1, minutes: 50)),
      isRead: true,
      type: MessageType.text,
    ));

    messages.add(ChatMessage(
      id: 4,
      senderId: currentUserId,
      receiverId: targetUser.id,
      content: '明天下午2点在大学生活动中心',
      createdAt: now.subtract(const Duration(days: 1, hours: 1, minutes: 45)),
      isRead: true,
      type: MessageType.text,
    ));

    messages.add(ChatMessage(
      id: 5,
      senderId: targetUser.id,
      receiverId: currentUserId,
      content: '好的，谢谢！',
      createdAt: now.subtract(const Duration(days: 1, hours: 1, minutes: 40)),
      isRead: true,
      type: MessageType.text,
    ));

    // 最近的消息
    messages.add(ChatMessage(
      id: 6,
      senderId: targetUser.id,
      receiverId: currentUserId,
      content: '对了，需要带什么东西吗？',
      createdAt: now.subtract(const Duration(minutes: 30)),
      isRead: false,
      type: MessageType.text,
    ));

    messages.add(ChatMessage(
      id: 7,
      senderId: currentUserId,
      receiverId: targetUser.id,
      content: '带学生证和笔记本就可以了',
      createdAt: now.subtract(const Duration(minutes: 25)),
      isRead: true,
      type: MessageType.text,
    ));

    messages.add(ChatMessage(
      id: 8,
      senderId: targetUser.id,
      receiverId: currentUserId,
      content: '好的，明天见！',
      createdAt: now.subtract(const Duration(minutes: 5)),
      isRead: false,
      type: MessageType.text,
    ));

    return messages;
  }

  /// 获取单个测试用户
  ///
  /// [index] 用户索引，默认为0
  ///
  /// 返回一个测试用户
  static SocialUser getTestUser([int index = 0]) {
    final users = generateTestUsers();
    return users[index % users.length];
  }
}
