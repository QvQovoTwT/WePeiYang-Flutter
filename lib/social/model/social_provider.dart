import 'package:flutter/foundation.dart';
import 'package:we_pei_yang_flutter/social/network/social_service.dart';

/// 社交模块状态管理类
///
/// 该类继承自ChangeNotifier，用于管理社交模块的全局状态，
/// 主要负责跟踪和更新未读消息数量，以便在主页底部导航栏显示红点提示。
///
/// 主要功能：
/// - 获取并统计所有会话的未读消息总数
/// - 提供未读消息状态的实时更新
/// - 支持清除、增加、减少未读消息计数
///
/// 使用方式：
/// ```dart
/// // 在MultiProvider中注册
/// ChangeNotifierProvider(create: (_) => SocialProvider())
///
/// // 在Widget中监听状态变化
/// Consumer<SocialProvider>(
///   builder: (context, socialProvider, child) {
///     return socialProvider.hasUnreadMessages ? RedDot() : Container();
///   },
/// )
///
/// // 更新未读消息数
/// context.read<SocialProvider>().refreshUnreadCount();
/// ```
class SocialProvider extends ChangeNotifier {
  /// 未读消息总数
  ///
  /// 统计所有会话中未读消息的总数量，用于在主页底部导航栏显示红点提示
  int _totalUnreadCount = 0;

  /// 是否正在加载未读消息数据
  ///
  /// 用于防止重复请求，当正在加载时不会发起新的请求
  bool _isLoading = false;

  /// 获取未读消息总数
  ///
  /// 返回当前所有会话的未读消息总数
  int get totalUnreadCount => _totalUnreadCount;

  /// 获取加载状态
  ///
  /// 返回是否正在加载未读消息数据
  bool get isLoading => _isLoading;

  /// 判断是否有未读消息
  ///
  /// 返回是否存在未读消息，用于控制红点显示
  /// true: 有未读消息，显示红点
  /// false: 无未读消息，隐藏红点
  bool get hasUnreadMessages => _totalUnreadCount > 0;

  /// 构造函数
  ///
  /// 创建SocialProvider实例时自动刷新未读消息数量
  SocialProvider() {
    refreshUnreadCount();
  }

  /// 刷新未读消息数量
  ///
  /// 从服务器获取所有会话列表，统计未读消息总数并更新状态。
  /// 该方法会自动处理加载状态，防止重复请求。
  ///
  /// 工作流程：
  /// 1. 检查是否正在加载，如果是则直接返回
  /// 2. 设置加载状态为true
  /// 3. 调用SocialService.getConversations()获取会话列表
  /// 4. 遍历所有会话，累加未读消息数量
  /// 5. 更新_totalUnreadCount并通知监听者
  ///
  /// 异常处理：
  /// - 如果请求失败，会打印错误日志但不影响当前状态
  /// - 无论成功或失败，最终都会重置加载状态
  ///
  /// 使用示例：
  /// ```dart
  /// // 在进入会话列表页面时刷新
  /// context.read<SocialProvider>().refreshUnreadCount();
  /// ```
  Future<void> refreshUnreadCount() async {
    // 防止重复请求
    if (_isLoading) return;

    // 设置加载状态
    _isLoading = true;
    notifyListeners();

    try {
      // 获取所有会话列表
      final conversationsResponse = await SocialService.getConversations();

      // 统计未读消息总数
      // 使用fold方法遍历所有会话，累加每个会话的unreadCount
      _totalUnreadCount = conversationsResponse.list.fold(
        0,
        (sum, conversation) => sum + conversation.unreadCount,
      );
    } catch (e) {
      // 请求失败时打印错误日志
      debugPrint('获取未读消息失败: $e');
    } finally {
      // 无论成功或失败，都重置加载状态
      _isLoading = false;
      // 通知所有监听者状态已更新
      notifyListeners();
    }
  }

  /// 清除未读消息计数
  ///
  /// 将未读消息总数重置为0，通常在用户点击社交按钮进入社交页面时调用。
  /// 该方法会立即更新状态并通知监听者，从而隐藏红点提示。
  ///
  /// 使用示例：
  /// ```dart
  /// // 用户点击社交按钮时清除红点
  /// onPressed: () {
  ///   context.read<SocialProvider>().clearUnreadCount();
  ///   Navigator.pushNamed(context, SocialRouter.social);
  /// }
  /// ```
  void clearUnreadCount() {
    _totalUnreadCount = 0;
    notifyListeners();
  }

  /// 设置未读消息计数
  ///
  /// 直接设置未读消息总数，通常在处理单个会话的未读消息时使用
  ///
  /// 使用示例：
  /// ```dart
  /// context.read<SocialProvider>().setUnreadCount(5);
  /// ```
  void setUnreadCount(int count) {
    _totalUnreadCount = count;
    notifyListeners();
  }

  /// 增加未读消息计数
  ///
  /// 将未读消息总数加1，通常在收到新消息时调用。
  /// 该方法会立即更新状态并通知监听者，从而显示红点提示。
  ///
  /// 使用示例：
  /// ```dart
  /// // 收到新消息时增加计数
  /// context.read<SocialProvider>().incrementUnreadCount();
  /// ```
  void incrementUnreadCount() {
    _totalUnreadCount++;
    notifyListeners();
  }

  /// 减少未读消息计数
  ///
  /// 将未读消息总数减1，通常在用户阅读消息时调用。
  /// 该方法会检查计数是否大于0，防止出现负数。
  ///
  /// 使用示例：
  /// ```dart
  /// // 用户阅读消息时减少计数
  /// context.read<SocialProvider>().decrementUnreadCount();
  /// ```
  void decrementUnreadCount() {
    // 防止计数变为负数
    if (_totalUnreadCount > 0) {
      _totalUnreadCount--;
      notifyListeners();
    }
  }
}
