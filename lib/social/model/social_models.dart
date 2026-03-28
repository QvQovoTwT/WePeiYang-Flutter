/// 个人主页可见性枚举
///
/// 控制用户的主页是否允许他人查看。
enum ProfilePrivacy {
  /// 关闭（他人无法进入主页）
  private,

  /// 公开（默认，允许访问）
  public;

  /// 获取枚举对应的数值
  int get value {
    switch (this) {
      case ProfilePrivacy.private:
        return 0;
      case ProfilePrivacy.public:
        return 1;
    }
  }

  /// 从数值创建枚举
  factory ProfilePrivacy.fromInt(int value) {
    switch (value) {
      case 0:
        return ProfilePrivacy.private;
      case 1:
        return ProfilePrivacy.public;
      default:
        return ProfilePrivacy.public;
    }
  }
}

/// 私信权限枚举
///
/// 控制谁可以发起私信。
enum MessagePrivacy {
  /// 关闭（不接收任何私信）
  close,

  /// 开启（允许所有人私信）
  all;

  /// 获取枚举对应的数值
  int get value {
    switch (this) {
      case MessagePrivacy.close:
        return 0;
      case MessagePrivacy.all:
        return 1;
    }
  }

  /// 从数值创建枚举
  factory MessagePrivacy.fromInt(int value) {
    switch (value) {
      case 0:
        return MessagePrivacy.close;
      case 1:
        return MessagePrivacy.all;
      default:
        return MessagePrivacy.all;
    }
  }
}

/// 关注权限枚举
///
/// 控制该用户是否允许被他人关注。
enum FollowPrivacy {
  /// 不可关注
  close,

  /// 可关注
  open;

  /// 获取枚举对应的数值
  int get value {
    switch (this) {
      case FollowPrivacy.close:
        return 0;
      case FollowPrivacy.open:
        return 1;
    }
  }

  /// 从数值创建枚举
  factory FollowPrivacy.fromInt(int value) {
    switch (value) {
      case 0:
        return FollowPrivacy.close;
      case 1:
        return FollowPrivacy.open;
      default:
        return FollowPrivacy.open;
    }
  }
}

/// 封禁/限制类型枚举
///
/// 由管理员触发，影响用户的特定社交功能。
enum RestrictionType {
  /// 全功能封禁（禁止关注、私信等所有社交行为）
  limitAll,

  /// 禁止关注
  limitFollow,

  /// 禁止私信
  limitMessage;

  /// 获取枚举对应的数值
  int get value {
    switch (this) {
      case RestrictionType.limitAll:
        return 0;
      case RestrictionType.limitFollow:
        return 1;
      case RestrictionType.limitMessage:
        return 2;
    }
  }

  /// 从数值创建枚举
  factory RestrictionType.fromInt(int value) {
    switch (value) {
      case 0:
        return RestrictionType.limitAll;
      case 1:
        return RestrictionType.limitFollow;
      case 2:
        return RestrictionType.limitMessage;
      default:
        return RestrictionType.limitAll;
    }
  }
}

/// 认证图标枚举
///
/// 用户的认证类型枚举。
enum VerificationBadge {
  /// 没有认证
  none,

  /// 优质用户（蓝色）
  blue,

  /// 权威用户（金色）
  yellow;

  /// 获取枚举对应的数值
  int get value {
    switch (this) {
      case VerificationBadge.none:
        return 0;
      case VerificationBadge.blue:
        return 1;
      case VerificationBadge.yellow:
        return 2;
    }
  }

  /// 从数值创建枚举
  factory VerificationBadge.fromInt(int value) {
    switch (value) {
      case 0:
        return VerificationBadge.none;
      case 1:
        return VerificationBadge.blue;
      case 2:
        return VerificationBadge.yellow;
      default:
        return VerificationBadge.none;
    }
  }
}

/// 社交错误码
///
/// 定义了社交模块的所有错误码和对应的提示信息。
class SocialErrorCode {
  /// 由于对方隐私设置无法访问
  static const int privacyBlocked = 10201;

  /// 该用户被封禁或禁止操作
  static const int userBanned = 10202;

  /// 你被封禁或禁止该功能
  static const int selfBanned = 10203;

  /// 你关闭了该功能
  static const int selfFeatureDisabled = 10204;

  /// 你已关注该用户
  static const int alreadyFollowing = 10205;

  /// 关注不存在
  static const int followNotExists = 10206;

  /// 不能对自己操作
  static const int cannotOperateSelf = 10207;

  /// 该帖子不存在
  static const int postNotExists = 10208;

  /// 无有效期内封禁记录
  static const int noActiveBan = 10209;

  /// 关注记录不存在
  static const int followRecordNotExists = 10210;

  /// 获取错误码对应的提示信息
  static String getErrorMessage(int errorCode) {
    switch (errorCode) {
      case privacyBlocked:
        return '由于对方隐私设置无法访问';
      case userBanned:
        return '该用户被封禁或禁止操作';
      case selfBanned:
        return '你被封禁或禁止该功能';
      case selfFeatureDisabled:
        return '你关闭了该功能';
      case alreadyFollowing:
        return '你已关注该用户';
      case followNotExists:
        return '关注不存在';
      case cannotOperateSelf:
        return '不能对自己操作';
      case postNotExists:
        return '该帖子不存在';
      case noActiveBan:
        return '无有效期内封禁记录';
      case followRecordNotExists:
        return '关注记录不存在';
      default:
        return '操作失败，请稍后重试';
    }
  }
}

/// 社交用户模型
///
/// 用于表示社交模块中的用户信息，包括用户的基本资料、
/// 个人信息以及主页可见性设置等。
class SocialUser {
  /// 用户唯一标识ID
  int id;

  /// 用户昵称
  String nickname;

  /// 用户头像URL地址
  String avatar;

  /// 用户头像框装饰URL地址
  String avatarBox;

  /// 用户等级
  int level;

  /// 用户学号（可选）
  String? userNumber;

  /// 用户所在学院（可选）
  String? department;

  /// 用户专业（可选）
  String? major;

  /// 用户主页是否可见
  /// true: 主页公开可见
  /// false: 主页仅自己可见
  bool visible;

  /// 用户认证类型
  /// VerificationBadge.none: 没有认证 (0)
  /// VerificationBadge.blue: 优质用户认证 (1)
  /// VerificationBadge.yellow: 权威用户认证 (2)
  VerificationBadge identification;

  /// 构造函数
  ///
  /// [id] 用户ID，默认为0
  /// [nickname] 用户昵称，默认为空字符串
  /// [avatar] 头像URL，默认为空字符串
  /// [avatarBox] 头像框URL，默认为空字符串
  /// [level] 用户等级，默认为0
  /// [userNumber] 学号，可选参数
  /// [department] 学院，可选参数
  /// [major] 专业，可选参数
  /// [visible] 主页可见性，默认为true
  /// [identification] 认证类型，默认为VerificationBadge.none
  SocialUser({
    this.id = 0,
    this.nickname = '',
    this.avatar = '',
    this.avatarBox = '',
    this.level = 0,
    this.userNumber,
    this.department,
    this.major,
    this.visible = true,
    this.identification = VerificationBadge.none,
  });

  /// 从JSON数据创建SocialUser实例
  ///
  /// [json] 包含用户信息的JSON对象
  ///
  /// 返回一个新的SocialUser实例
  ///
  /// JSON字段映射：
  /// - 'id' -> id
  /// - 'nickname' -> nickname
  /// - 'avatar' -> avatar
  /// - 'avatar_frame' -> avatarBox
  /// - 'level' -> level
  /// - 'user_number' -> userNumber
  /// - 'department' -> department
  /// - 'major' -> major
  /// - 'visible' -> visible
  /// - 'identification' -> identification
  SocialUser.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        nickname = json['nickname'] ?? '',
        avatar = json['avatar'] ?? '',
        avatarBox = json['avatar_frame'] ?? '',
        level = json['level'] ?? 0,
        userNumber = json['user_number'],
        department = json['department'],
        major = json['major'],
        visible = json['visible'] ?? true,
        identification = VerificationBadge.fromInt(json['identification'] ?? 0);

  /// 将SocialUser实例转换为JSON对象
  ///
  /// 返回包含用户信息的Map对象
  ///
  /// JSON字段映射：
  /// - id -> 'id'
  /// - nickname -> 'nickname'
  /// - avatar -> 'avatar'
  /// - avatarBox -> 'avatar_frame'
  /// - level -> 'level'
  /// - userNumber -> 'user_number'
  /// - department -> 'department'
  /// - major -> 'major'
  /// - visible -> 'visible'
  /// - identification -> 'identification'
  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'avatar': avatar,
        'avatar_frame': avatarBox,
        'level': level,
        'user_number': userNumber,
        'department': department,
        'major': major,
        'visible': visible,
        'identification': identification.value,
      };
}

/// 好友关系模型
///
/// 用于表示用户之间的关注关系，包括用户信息、
/// 关注状态以及关系建立时间等。
class Friend {
  /// 好友用户信息
  SocialUser user;

  /// 当前用户是否关注了该好友
  /// true: 已关注
  /// false: 未关注
  bool isFollowing;

  /// 该好友是否关注了当前用户
  /// true: 已被关注
  /// false: 未被关注
  bool isFollowed;

  /// 关注关系建立时间（可选）
  DateTime? createdAt;

  /// 构造函数
  ///
  /// [user] 好友用户信息，必填参数
  /// [isFollowing] 是否关注，默认为false
  /// [isFollowed] 是否被关注，默认为false
  /// [createdAt] 关系建立时间，可选参数
  Friend({
    required this.user,
    this.isFollowing = false,
    this.isFollowed = false,
    this.createdAt,
  });

  /// 从JSON数据创建Friend实例
  ///
  /// [json] 包含好友关系信息的JSON对象
  ///
  /// 返回一个新的Friend实例
  ///
  /// JSON字段映射：
  /// - 'user' -> user (SocialUser对象)
  /// - 'is_following' -> isFollowing
  /// - 'is_followed' -> isFollowed
  /// - 'created_at' -> createdAt (DateTime对象)
  Friend.fromJson(Map<String, dynamic> json)
      : user = SocialUser.fromJson(json['user'] ?? {}),
        isFollowing = json['is_following'] ?? false,
        isFollowed = json['is_followed'] ?? false,
        createdAt = json['created_at'] == null
            ? null
            : DateTime.tryParse(json['created_at']);

  /// 将Friend实例转换为JSON对象
  ///
  /// 返回包含好友关系信息的Map对象
  ///
  /// JSON字段映射：
  /// - user -> 'user'
  /// - isFollowing -> 'is_following'
  /// - isFollowed -> 'is_followed'
  /// - createdAt -> 'created_at' (ISO8601格式字符串)
  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'is_following': isFollowing,
        'is_followed': isFollowed,
        'created_at': createdAt?.toIso8601String(),
      };
}

/// 会话模型
///
/// 用于表示私信会话，包括会话ID、目标用户、
/// 最后一条消息以及未读消息数量等。
class Conversation {
  /// 会话唯一标识ID
  int id;

  /// 会话目标用户信息
  SocialUser targetUser;

  /// 最后一条消息内容
  String lastMessage;

  /// 最后一条消息时间（可选）
  DateTime? lastMessageTime;

  /// 未读消息数量
  int unreadCount;

  /// 构造函数
  ///
  /// [id] 会话ID，默认为0
  /// [targetUser] 目标用户信息，必填参数
  /// [lastMessage] 最后消息内容，默认为空字符串
  /// [lastMessageTime] 最后消息时间，可选参数
  /// [unreadCount] 未读消息数，默认为0
  Conversation({
    this.id = 0,
    required this.targetUser,
    this.lastMessage = '',
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  /// 从JSON数据创建Conversation实例
  ///
  /// [json] 包含会话信息的JSON对象
  ///
  /// 返回一个新的Conversation实例
  ///
  /// JSON字段映射：
  /// - 'id' -> id
  /// - 'target_user' -> targetUser (SocialUser对象)
  /// - 'last_message' -> lastMessage
  /// - 'last_message_time' -> lastMessageTime (DateTime对象)
  /// - 'unread_count' -> unreadCount
  Conversation.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        targetUser = SocialUser.fromJson(json['target_user'] ?? {}),
        lastMessage = json['last_message'] ?? '',
        lastMessageTime = json['last_message_time'] == null
            ? null
            : DateTime.tryParse(json['last_message_time']),
        unreadCount = json['unread_count'] ?? 0;

  /// 将Conversation实例转换为JSON对象
  ///
  /// 返回包含会话信息的Map对象
  ///
  /// JSON字段映射：
  /// - id -> 'id'
  /// - targetUser -> 'target_user'
  /// - lastMessage -> 'last_message'
  /// - lastMessageTime -> 'last_message_time' (ISO8601格式字符串)
  /// - unreadCount -> 'unread_count'
  Map<String, dynamic> toJson() => {
        'id': id,
        'target_user': targetUser.toJson(),
        'last_message': lastMessage,
        'last_message_time': lastMessageTime?.toIso8601String(),
        'unread_count': unreadCount,
      };
}

/// 聊天消息模型
///
/// 用于表示私信消息，包括消息ID、发送者、接收者、
/// 消息内容、发送时间、已读状态以及消息类型等。
class ChatMessage {
  /// 消息唯一标识ID
  int id;

  /// 消息发送者ID
  int senderId;

  /// 消息接收者ID
  int receiverId;

  /// 消息内容
  String content;

  /// 消息创建时间（可选）
  DateTime? createdAt;

  /// 消息是否已读
  /// true: 已读
  /// false: 未读
  bool isRead;

  /// 消息类型
  MessageType type;

  /// 构造函数
  ///
  /// [id] 消息ID，默认为0
  /// [senderId] 发送者ID，默认为0
  /// [receiverId] 接收者ID，默认为0
  /// [content] 消息内容，默认为空字符串
  /// [createdAt] 创建时间，可选参数
  /// [isRead] 是否已读，默认为false
  /// [type] 消息类型，默认为文本消息
  ChatMessage({
    this.id = 0,
    this.senderId = 0,
    this.receiverId = 0,
    this.content = '',
    this.createdAt,
    this.isRead = false,
    this.type = MessageType.text,
  });

  /// 从JSON数据创建ChatMessage实例
  ///
  /// [json] 包含消息信息的JSON对象
  ///
  /// 返回一个新的ChatMessage实例
  ///
  /// JSON字段映射：
  /// - 'id' -> id
  /// - 'sender_id' -> senderId
  /// - 'receiver_id' -> receiverId
  /// - 'content' -> content
  /// - 'created_at' -> createdAt (DateTime对象)
  /// - 'is_read' -> isRead
  /// - 'type' -> type (MessageType枚举)
  ChatMessage.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        senderId = json['sender_id'] ?? 0,
        receiverId = json['receiver_id'] ?? 0,
        content = json['content'] ?? '',
        createdAt = json['created_at'] == null
            ? null
            : DateTime.tryParse(json['created_at']),
        isRead = json['is_read'] ?? false,
        type = MessageType.fromInt(json['type'] ?? 0);

  /// 将ChatMessage实例转换为JSON对象
  ///
  /// 返回包含消息信息的Map对象
  ///
  /// JSON字段映射：
  /// - id -> 'id'
  /// - senderId -> 'sender_id'
  /// - receiverId -> 'receiver_id'
  /// - content -> 'content'
  /// - createdAt -> 'created_at' (ISO8601格式字符串)
  /// - isRead -> 'is_read'
  /// - type -> 'type' (整数值)
  Map<String, dynamic> toJson() => {
        'id': id,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'content': content,
        'created_at': createdAt?.toIso8601String(),
        'is_read': isRead,
        'type': type.value,
      };
}

/// 消息类型枚举
///
/// 定义了支持的消息类型，包括文本消息、图片消息和系统消息。
enum MessageType {
  /// 文本消息
  text,

  /// 图片消息
  image,

  /// 系统消息
  system;

  /// 从整数值创建MessageType枚举实例
  ///
  /// [value] 消息类型的整数值
  /// - 0: 文本消息
  /// - 1: 图片消息
  /// - 2: 系统消息
  ///
  /// 返回对应的MessageType枚举值
  factory MessageType.fromInt(int value) {
    switch (value) {
      case 1:
        return MessageType.image;
      case 2:
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  /// 获取消息类型对应的整数值
  ///
  /// 返回值：
  /// - text: 0
  /// - image: 1
  /// - system: 2
  int get value {
    switch (this) {
      case MessageType.image:
        return 1;
      case MessageType.system:
        return 2;
      default:
        return 0;
    }
  }
}

/// 列表响应模型
///
/// 用于表示分页列表响应，包括列表数据和总数。
class ListResponse<T> {
  /// 数据列表
  List<T> list;

  /// 总数
  int total;

  /// 构造函数
  ///
  /// [list] 数据列表，默认为空列表
  /// [total] 总数，默认为0
  ListResponse({
    this.list = const [],
    this.total = 0,
  });

  /// 从JSON数据创建ListResponse实例
  ///
  /// [json] 包含列表响应的JSON对象
  /// [itemFromJson] 单个元素的JSON解析函数
  ///
  /// 返回一个新的ListResponse实例
  factory ListResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) itemFromJson) {
    var listJson = json['list'] as List? ?? [];
    return ListResponse(
      list: listJson.map((e) => itemFromJson(e)).toList(),
      total: json['total'] ?? 0,
    );
  }

  /// 将ListResponse实例转换为JSON对象
  ///
  /// [itemToJson] 单个元素的JSON转换函数
  ///
  /// 返回包含列表响应的Map对象
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) itemToJson) => {
        'list': list.map((e) => itemToJson(e)).toList(),
        'total': total,
      };

  /// 获取列表长度
  int get length => list.length;

  /// 检查列表是否为空
  bool get isEmpty => list.isEmpty;

  /// 检查列表是否不为空
  bool get isNotEmpty => list.isNotEmpty;

  /// 按索引获取元素
  T operator [](int index) => list[index];

  /// 按索引设置元素
  void operator []=(int index, T value) => list[index] = value;

  /// 迭代器
  Iterator<T> get iterator => list.iterator;

  /// 转换为可迭代对象
  Iterable<T> get asIterable => list;

  /// 折叠操作
  R fold<R>(R initialValue, R Function(R, T) combine) =>
      list.fold(initialValue, combine);

  /// 检查是否存在满足条件的元素
  bool any(bool Function(T) test) => list.any(test);

  /// 排序
  void sort([int Function(T, T)? compare]) => list.sort(compare);

  /// 添加元素
  void add(T element) => list.add(element);

  /// 添加多个元素
  void addAll(Iterable<T> iterable) => list.addAll(iterable);

  /// 移除元素
  bool remove(Object? element) => list.remove(element);

  /// 按索引移除元素
  T removeAt(int index) => list.removeAt(index);

  /// 清空列表
  void clear() => list.clear();
}

/// 关注/粉丝列表中的用户模型
///
/// 用于表示关注列表或粉丝列表中的用户信息。
class FollowUser {
  /// 用户ID
  int uid;

  /// 用户昵称
  String nickname;

  /// 用户头像URL
  String avatarUrl;

  /// 构造函数
  ///
  /// [uid] 用户ID，默认为0
  /// [nickname] 用户昵称，默认为空字符串
  /// [avatarUrl] 头像URL，默认为空字符串
  FollowUser({
    this.uid = 0,
    this.nickname = '',
    this.avatarUrl = '',
  });

  /// 从JSON数据创建FollowUser实例
  ///
  /// [json] 包含用户信息的JSON对象
  ///
  /// 返回一个新的FollowUser实例
  FollowUser.fromJson(Map<String, dynamic> json)
      : uid = json['uid'] ?? 0,
        nickname = json['nickname'] ?? '',
        avatarUrl = json['avatarUrl'] ?? '';

  /// 将FollowUser实例转换为JSON对象
  ///
  /// 返回包含用户信息的Map对象
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'nickname': nickname,
        'avatarUrl': avatarUrl,
      };
}

/// 用户个人资料模型
///
/// 用于表示用户的完整个人资料，包括用户基本信息、
/// 粉丝列表、关注列表以及统计数据等。
class UserProfile {
  /// 用户基本信息
  SocialUser user;

  /// 粉丝列表
  List<Friend> followers;

  /// 关注列表
  List<Friend> following;

  /// 粉丝总数
  int followerCount;

  /// 关注总数
  int followingCount;

  /// 动态发布总数
  int postCount;

  /// 构造函数
  ///
  /// [user] 用户基本信息，必填参数
  /// [followers] 粉丝列表，默认为空列表
  /// [following] 关注列表，默认为空列表
  /// [followerCount] 粉丝总数，默认为0
  /// [followingCount] 关注总数，默认为0
  /// [postCount] 动态总数，默认为0
  UserProfile({
    required this.user,
    this.followers = const [],
    this.following = const [],
    this.followerCount = 0,
    this.followingCount = 0,
    this.postCount = 0,
  });

  /// 从JSON数据创建UserProfile实例
  ///
  /// [json] 包含用户个人资料的JSON对象
  ///
  /// 返回一个新的UserProfile实例
  ///
  /// JSON字段映射：
  /// - 'user' -> user (SocialUser对象)
  /// - 'followers' -> followers (Friend对象列表)
  /// - 'following' -> following (Friend对象列表)
  /// - 'follower_count' -> followerCount
  /// - 'following_count' -> followingCount
  /// - 'post_count' -> postCount
  UserProfile.fromJson(Map<String, dynamic> json)
      : user = SocialUser.fromJson(json['user'] ?? {}),
        followers = (json['followers'] as List?)
                ?.map((e) => Friend.fromJson(e))
                .toList() ??
            [],
        following = (json['following'] as List?)
                ?.map((e) => Friend.fromJson(e))
                .toList() ??
            [],
        followerCount = json['follower_count'] ?? 0,
        followingCount = json['following_count'] ?? 0,
        postCount = json['post_count'] ?? 0;

  /// 将UserProfile实例转换为JSON对象
  ///
  /// 返回包含用户个人资料的Map对象
  ///
  /// JSON字段映射：
  /// - user -> 'user'
  /// - followers -> 'followers'
  /// - following -> 'following'
  /// - followerCount -> 'follower_count'
  /// - followingCount -> 'following_count'
  /// - postCount -> 'post_count'
  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'followers': followers.map((e) => e.toJson()).toList(),
        'following': following.map((e) => e.toJson()).toList(),
        'follower_count': followerCount,
        'following_count': followingCount,
        'post_count': postCount,
      };
}
