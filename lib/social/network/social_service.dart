import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/social/model/social_models.dart';

/// 社交模块网络请求Dio实例
///
/// 继承自DioAbstract，用于处理社交模块的所有网络请求。
/// 配置了基础URL、请求头、拦截器以及错误处理逻辑。
///
/// 主要功能：
/// - 配置API基础URL
/// - 设置请求头（DOMAIN、ticket、token）
/// - 处理响应错误码
/// - 提供统一的错误信息转换
class SocialDio extends DioAbstract {
  /// API基础URL
  ///
  /// 所有社交模块的API请求都基于此URL
  String baseUrl = "https://api.twt.edu.cn/api/v1/b/";

  /// 请求头配置
  ///
  /// 包含必要的认证信息：
  /// - DOMAIN: 域名标识，用于服务器识别应用
  /// - ticket: 应用票据，用于服务器验证应用合法性
  Map<String, String>? headers = {
    "DOMAIN": AuthDio.DOMAIN,
    "ticket": AuthDio.ticket,
  };

  /// 拦截器列表
  ///
  /// 当前为空列表，可根据需要添加日志、缓存等拦截器
  List<Interceptor> interceptors = [];

  /// 错误拦截器
  ///
  /// 用于在请求前添加token，并在响应后处理错误码。
  ///
  /// 请求拦截：
  /// - 自动在请求头中添加token，用于用户身份验证
  ///
  /// 响应拦截：
  /// - 解析响应数据中的code
  /// - 根据错误码转换为用户友好的错误信息
  /// - 如果有错误，拒绝请求并抛出WpyDioException
  ///
  /// 支持的错误码：
  /// - 21001: Not Followable
  /// - 21002: Banned
  /// - 21003: repeat follow
  /// - 21004: You are not following this user
  /// - 21005: The user is not your follower
  InterceptorsWrapper? get errorInterceptor =>
      InterceptorsWrapper(onRequest: (options, handler) {
        // 在请求头中添加token，用于用户身份验证
        options.headers['token'] = CommonPreferences.token.value;
        return handler.next(options);
      }, onResponse: (response, handler) {
        // 解析响应数据中的错误码
        var code = response.data['code'] ?? 200;
        var error = "";
        var msg = response.data['msg'] ?? "";

        // 根据错误码转换为用户友好的错误信息
        if (code != 200) {
          switch (code) {
            case 21001:
              error = msg.isNotEmpty ? msg : "Not Followable";
              break;
            case 21002:
              error = msg.isNotEmpty ? msg : "Banned";
              break;
            case 21003:
              error = msg.isNotEmpty ? msg : "repeat follow";
              break;
            case 21004:
              error = msg.isNotEmpty ? msg : "You are not following this user";
              break;
            case 21005:
              error = msg.isNotEmpty ? msg : "The user is not your follower";
              break;
            default:
              error = msg.isNotEmpty ? msg : "请求失败";
          }
        }

        // 如果有错误，拒绝请求并抛出异常
        if (error.isEmpty)
          return handler.next(response);
        else
          return handler.reject(WpyDioException(error: error), true);
      });
}

/// 社交模块Dio实例
///
/// 全局唯一的SocialDio实例，用于所有社交模块的网络请求
final socialDio = SocialDio();

/// 社交服务类
///
/// 提供社交模块的所有网络请求方法，包括：
/// - 好友关系管理（关注、取消关注、移除粉丝）
/// - 会话管理（获取会话列表）
/// - 消息管理（获取消息、发送消息、标记已读）
/// - 用户资料管理（获取用户资料、设置主页可见性）
///
/// 该类使用AsyncTimer混入，防止重复提交请求。
///
/// 使用示例：
/// ```dart
/// // 获取粉丝列表
/// var followers = await SocialService.getFollowers();
///
/// // 关注用户
/// SocialService.followUser(userId, onSuccess: () {
///   print('关注成功');
/// }, onFailure: (e) {
///   print('关注失败: ${e.error}');
/// });
/// ```
class SocialService with AsyncTimer {
  /// 获取关注列表
  ///
  /// 获取当前用户关注的所有用户信息，支持分页查询。
  ///
  /// 参数：
  /// - [pageDisable]: 是否取消分页，默认为0（不取消）
  /// - [page]: 页码，默认为1
  /// - [pageSize]: 每页数量，默认为10
  /// - [offset]: 页偏移，默认为0
  ///
  /// 返回值：
  /// - 成功：返回ListResponse<FollowUser>对象
  /// - 失败：抛出DioException异常
  ///
  /// API端点：GET /following/all
  static Future<ListResponse<FollowUser>> getFollowing({
    int pageDisable = 0,
    int page = 1,
    int pageSize = 10,
    int offset = 0,
  }) async {
    try {
      var rsp = await socialDio.get("following/all", queryParameters: {
        "page_disable": pageDisable,
        "page": page,
        "page_size": pageSize,
        "offset": offset,
      });
      var data = rsp.data['data'] ?? {};
      return ListResponse<FollowUser>.fromJson(
          data, (json) => FollowUser.fromJson(json));
    } on DioException {
      rethrow;
    }
  }

  /// 获取粉丝列表
  ///
  /// 获取当前用户的所有粉丝信息，支持分页查询。
  ///
  /// 参数：
  /// - [pageDisable]: 是否取消分页，默认为0（不取消）
  /// - [page]: 页码，默认为1
  /// - [pageSize]: 每页数量，默认为10
  /// - [offset]: 页偏移，默认为0
  ///
  /// 返回值：
  /// - 成功：返回ListResponse<FollowUser>对象
  /// - 失败：抛出DioException异常
  ///
  /// API端点：GET /followers/all
  static Future<ListResponse<FollowUser>> getFollowers({
    int pageDisable = 0,
    int page = 1,
    int pageSize = 10,
    int offset = 0,
  }) async {
    try {
      var rsp = await socialDio.get("followers/all", queryParameters: {
        "page_disable": pageDisable,
        "page": page,
        "page_size": pageSize,
        "offset": offset,
      });
      var data = rsp.data['data'] ?? {};
      return ListResponse<FollowUser>.fromJson(
          data, (json) => FollowUser.fromJson(json));
    } on DioException {
      rethrow;
    }
  }

  /// 关注用户
  ///
  /// 关注指定用户，建立关注关系。
  /// 使用AsyncTimer防止重复提交。
  ///
  /// 参数：
  /// - [uid]: 要关注的用户ID
  /// - [onSuccess]: 成功回调函数
  /// - [onFailure]: 失败回调函数，接收DioException参数
  ///
  /// API端点：POST /following/{uid}
  static void followUser(int uid,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('followUser_$uid', () async {
      try {
        await socialDio.post("following/$uid");
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 取消关注用户
  ///
  /// 取消关注指定用户，解除关注关系。
  /// 使用AsyncTimer防止重复提交。
  ///
  /// 参数：
  /// - [uid]: 要取消关注的用户ID
  /// - [onSuccess]: 成功回调函数
  /// - [onFailure]: 失败回调函数，接收DioException参数
  ///
  /// API端点：DELETE /following/{uid}
  static void unfollowUser(int uid,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('unfollowUser_$uid', () async {
      try {
        await socialDio.delete("following/$uid");
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 移除粉丝
  ///
  /// 将指定用户从粉丝列表中移除，解除粉丝关系。
  /// 使用AsyncTimer防止重复提交。
  ///
  /// 参数：
  /// - [uid]: 要移除的粉丝用户ID
  /// - [onSuccess]: 成功回调函数
  /// - [onFailure]: 失败回调函数，接收DioException参数
  ///
  /// API端点：DELETE /followers/{uid}
  static void removeFollower(int uid,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('removeFollower_$uid', () async {
      try {
        await socialDio.delete("followers/$uid");
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 获取会话列表
  ///
  /// 获取当前用户的所有私信会话，支持分页查询。
  /// 每个会话包含目标用户、最后一条消息、未读消息数等信息。
  ///
  /// 参数：
  /// - [pageDisable]: 是否取消分页，默认为0（不取消）
  /// - [page]: 页码，默认为1
  /// - [pageSize]: 每页数量，默认为10
  /// - [offset]: 页偏移，默认为0
  ///
  /// 返回值：
  /// - 成功：返回ListResponse<Conversation>对象
  /// - 失败：抛出DioException异常
  ///
  /// API端点：GET /conversations
  static Future<ListResponse<Conversation>> getConversations({
    int pageDisable = 0,
    int page = 1,
    int pageSize = 10,
    int offset = 0,
  }) async {
    try {
      var rsp = await socialDio.get("conversations", queryParameters: {
        "page_disable": pageDisable,
        "page": page,
        "page_size": pageSize,
        "offset": offset,
      });
      var data = rsp.data['data'] ?? {};
      return ListResponse<Conversation>.fromJson(
          data, (json) => Conversation.fromJson(json));
    } on DioException {
      rethrow;
    }
  }

  /// 获取聊天消息
  ///
  /// 获取与指定用户的聊天消息记录，支持分页查询。
  /// 消息按时间倒序排列，最新的消息在列表末尾。
  ///
  /// 参数：
  /// - [uid]: 目标用户ID
  /// - [pageDisable]: 是否取消分页，默认为0（不取消）
  /// - [page]: 页码，默认为1
  /// - [pageSize]: 每页数量，默认为10
  /// - [offset]: 页偏移，默认为0
  ///
  /// 返回值：
  /// - 成功：返回ListResponse<ChatMessage>对象
  /// - 失败：抛出DioException异常
  ///
  /// API端点：GET /messages/{uid}
  static Future<ListResponse<ChatMessage>> getMessages(
    int uid, {
    int pageDisable = 0,
    int page = 1,
    int pageSize = 10,
    int offset = 0,
  }) async {
    try {
      var rsp = await socialDio.get("messages/$uid", queryParameters: {
        "page_disable": pageDisable,
        "page": page,
        "page_size": pageSize,
        "offset": offset,
      });
      var data = rsp.data['data'] ?? {};
      return ListResponse<ChatMessage>.fromJson(
          data, (json) => ChatMessage.fromJson(json));
    } on DioException {
      rethrow;
    }
  }

  /// 发送消息
  ///
  /// 向指定用户发送私信消息。
  /// 使用AsyncTimer防止重复提交。
  ///
  /// 参数：
  /// - [targetUserId]: 目标用户ID
  /// - [content]: 消息内容
  /// - [onResult]: 成功回调函数，接收ChatMessage参数
  /// - [onFailure]: 失败回调函数，接收DioException参数
  ///
  /// API端点：POST /messages/{uid}
  static void sendMessage(int targetUserId, String content,
      {required OnResult<ChatMessage> onResult,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('sendMessage', () async {
      try {
        var rsp = await socialDio.post("messages/$targetUserId", data: {
          "content": content,
        });
        var result = ChatMessage.fromJson(rsp.data['data']);
        onResult(result);
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 设置帖子可见性
  ///
  /// 设置指定帖子的可见性。
  /// 使用AsyncTimer防止重复提交。
  ///
  /// 参数：
  /// - [id]: 帖子ID
  /// - [visibility]: 可见性，0不可见，1可见
  /// - [onSuccess]: 成功回调函数
  /// - [onFailure]: 失败回调函数，接收DioException参数
  ///
  /// API端点：PUT /profiles/{id}/visibility
  static void setPostVisibility(int id, int visibility,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('setPostVisibility_$id', () async {
      try {
        await socialDio.put("profiles/$id/visibility", data: {
          "visibility": visibility,
        });
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 获取隐私设置
  ///
  /// 获取当前用户的隐私设置。
  ///
  /// 返回值：
  /// - 成功：返回包含隐私设置的Map
  /// - 失败：抛出DioException异常
  ///
  /// API端点：GET /privacy-settings
  static Future<Map<String, dynamic>> getPrivacySettings() async {
    try {
      var rsp = await socialDio.get("privacy-settings");
      return rsp.data['data'] ?? {};
    } on DioException {
      rethrow;
    }
  }

  /// 更新隐私设置
  ///
  /// 更新当前用户的隐私设置。
  /// 使用AsyncTimer防止重复提交。
  ///
  /// 参数：
  /// - [profileVisibility]: 主页可见性，0不可见，1可见
  /// - [followable]: 是否可关注，0不可关注，1可关注
  /// - [messagePermission]: 私信权限，0不可私信，1可私信
  /// - [onSuccess]: 成功回调函数
  /// - [onFailure]: 失败回调函数，接收DioException参数
  ///
  /// API端点：PUT /privacy-settings
  static void updatePrivacySettings({
    required int profileVisibility,
    required int followable,
    required int messagePermission,
    required OnSuccess onSuccess,
    required OnFailure onFailure,
  }) async {
    AsyncTimer.runRepeatChecked('updatePrivacySettings', () async {
      try {
        await socialDio.put("privacy-settings", data: {
          "profile_visibility": profileVisibility,
          "followable": followable,
          "message_permission": messagePermission,
        });
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 获取关注通知
  ///
  /// 获取当前用户的关注通知列表，支持分页查询。
  ///
  /// 参数：
  /// - [pageDisable]: 是否取消分页，默认为0（不取消）
  /// - [page]: 页码，默认为1
  /// - [pageSize]: 每页数量，默认为10
  /// - [offset]: 页偏移，默认为0
  /// - [unreadOnly]: 是否只查询未读信息，默认为false
  ///
  /// 返回值：
  /// - 成功：返回ListResponse<Map<String, dynamic>>对象
  /// - 失败：抛出DioException异常
  ///
  /// API端点：GET /f/message/follower
  static Future<ListResponse<Map<String, dynamic>>> getFollowNotifications({
    int pageDisable = 0,
    int page = 1,
    int pageSize = 10,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    try {
      var rsp = await socialDio.get("f/message/follower", queryParameters: {
        "page_disable": pageDisable,
        "page": page,
        "page_size": pageSize,
        "offset": offset,
        "unread_only": unreadOnly,
      });
      var data = rsp.data['data'] ?? {};
      return ListResponse<Map<String, dynamic>>.fromJson(
          data, (json) => json as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  /// 标记关注通知为已读
  ///
  /// 标记指定用户的关注通知为已读。
  /// 使用AsyncTimer防止重复提交。
  ///
  /// 参数：
  /// - [uid]: 关注者ID
  /// - [onSuccess]: 成功回调函数
  /// - [onFailure]: 失败回调函数，接收DioException参数
  ///
  /// API端点：POST /f/message/follower/read/{uid}
  static void markFollowNotificationAsRead(int uid,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('markFollowNotificationAsRead_$uid', () async {
      try {
        await socialDio.post("f/message/follower/read/$uid");
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 获取用户个人主页
  ///
  /// 获取指定用户的个人主页信息。
  ///
  /// 参数：
  /// - [uid]: 用户ID
  ///
  /// 返回值：
  /// - 成功：返回包含用户主页信息的Map
  /// - 失败：抛出DioException异常
  ///
  /// API端点：GET /profiles/{uid}
  static Future<Map<String, dynamic>> getUserProfile(int uid) async {
    try {
      var rsp = await socialDio.get("profiles/$uid");
      return rsp.data['data'] ?? {};
    } on DioException {
      rethrow;
    }
  }

  /// 获取用户公开发布的帖子（访客视角）
  ///
  /// 根据用户ID查询发布过的帖子，默认依据时间排序，支持分页。
  /// 会判断并返回主页可见性，过滤校务和主人设置的不可见帖子。
  ///
  /// 参数：
  /// - [uid]: 用户ID
  /// - [pageDisable]: 是否取消分页，默认为0（不取消）
  /// - [page]: 页码，默认为1
  /// - [pageSize]: 每页数量，默认为10
  /// - [offset]: 页偏移，默认为0
  ///
  /// 返回值：
  /// - 成功：返回ListResponse<Map<String, dynamic>>对象
  /// - 失败：抛出DioException异常
  ///
  /// API端点：GET /profiles/{uid}/public-posts
  static Future<ListResponse<Map<String, dynamic>>> getPublicPosts(
    int uid, {
    int pageDisable = 0,
    int page = 1,
    int pageSize = 10,
    int offset = 0,
  }) async {
    try {
      var rsp = await socialDio.get("profiles/$uid/public-posts", queryParameters: {
        "page_disable": pageDisable,
        "page": page,
        "page_size": pageSize,
        "offset": offset,
      });
      var data = rsp.data['data'] ?? {};
      return ListResponse<Map<String, dynamic>>.fromJson(
          data, (json) => json as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  /// 获取用户自己发布的帖子（自己视角）
  ///
  /// 查询自己发布过的帖子，默认依据时间排序，支持分页。
  /// 会过滤校务帖子。
  ///
  /// 参数：
  /// - [pageDisable]: 是否取消分页，默认为0（不取消）
  /// - [page]: 页码，默认为1
  /// - [pageSize]: 每页数量，默认为10
  /// - [offset]: 页偏移，默认为0
  ///
  /// 返回值：
  /// - 成功：返回ListResponse<Map<String, dynamic>>对象
  /// - 失败：抛出DioException异常
  ///
  /// API端点：GET /profiles/{uid}/me-posts
  static Future<ListResponse<Map<String, dynamic>>> getMyPosts({
    int pageDisable = 0,
    int page = 1,
    int pageSize = 10,
    int offset = 0,
  }) async {
    try {
      var rsp = await socialDio.get("profiles/me/me-posts", queryParameters: {
        "page_disable": pageDisable,
        "page": page,
        "page_size": pageSize,
        "offset": offset,
      });
      var data = rsp.data['data'] ?? {};
      return ListResponse<Map<String, dynamic>>.fromJson(
          data, (json) => json as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  /// 设置主页可见性
  ///
  /// 设置当前用户的主页可见性。
  /// 使用AsyncTimer防止重复提交。
  ///
  /// 参数：
  /// - [visible]: 是否可见
  /// - [onSuccess]: 成功回调函数
  /// - [onFailure]: 失败回调函数，接收DioException参数
  ///
  /// API端点：PUT /privacy-settings
  static void setVisible(bool visible,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('setVisible', () async {
      try {
        await socialDio.put("privacy-settings", data: {
          "profile_visibility": visible ? 1 : 0,
        });
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }
}
