import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/social/view/friend/friend_page.dart';
import 'package:we_pei_yang_flutter/social/view/profile/profile_page.dart';
import 'package:we_pei_yang_flutter/social/view/social_page.dart';

/// 社交模块路由配置类
///
/// 该类定义了社交模块的所有路由路径和对应的页面构建器，
/// 用于在应用中导航到不同的社交功能页面。
///
/// 路由路径：
/// - `social/social`: 社交功能入口页面（跳转到新的私信系统）
/// - `social/friend`: 好友管理页面
/// - `social/profile`: 用户资料页面
///
/// 使用示例：
/// ```dart
/// // 导航到社交入口页面
/// Navigator.pushNamed(context, SocialRouter.social);
///
/// // 导航到用户资料页面，传递用户ID
/// Navigator.pushNamed(
///   context,
///   SocialRouter.profile,
///   arguments: userId,
/// );
/// ```
class SocialRouter {
  /// 好友管理页面路由路径
  ///
  /// 用于查看关注列表和粉丝列表
  ///
  /// 页面：[FriendPage]
  /// 参数：无
  ///
  /// 使用示例：
  /// ```dart
  /// Navigator.pushNamed(context, SocialRouter.friend);
  /// ```
  static String friend = 'social/friend';

  /// 用户资料页面路由路径
  ///
  /// 用于查看用户的个人资料
  ///
  /// 页面：[ProfilePage]
  /// 参数：[int] - 用户ID
  ///
  /// 使用示例：
  /// ```dart
  /// Navigator.pushNamed(
  ///   context,
  ///   SocialRouter.profile,
  ///   arguments: userId,
  /// );
  /// ```
  static String profile = 'social/profile';

  /// 社交功能入口页面路由路径
  ///
  /// 社交模块的主入口，提供好友和私信功能入口
  ///
  /// 页面：[SocialPage]
  /// 参数：无
  ///
  /// 使用示例：
  /// ```dart
  /// Navigator.pushNamed(context, SocialRouter.social);
  /// ```
  static String social = 'social/social';

  /// 路由映射表
  ///
  /// 将路由路径映射到对应的页面构建器函数。
  ///
  /// 键：路由路径字符串
  /// 值：页面构建器函数，接收可选的arguments参数
  ///
  /// 路由配置：
  /// - `friend`: 好友管理页面，无参数
  /// - `profile`: 用户资料页面，参数类型为[int]
  /// - `social`: 社交入口页面，无参数
  ///
  /// 使用说明：
  /// - 无参数的页面：直接使用`(_) => PageName()`
  /// - 有参数的页面：使用`(args) => PageName(args as Type)`
  ///
  /// 注册到主路由表：
  /// ```dart
  /// Map<String, Widget Function(dynamic arguments)> allRoutes = {
  ///   ...SocialRouter.routers,
  ///   // 其他模块路由...
  /// };
  /// ```
  static final Map<String, Widget Function(dynamic arguments)> routers = {
    // 好友管理页面
    friend: (_) => FriendPage(),
    // 用户资料页面，参数为int类型
    profile: (args) => ProfilePage(args as int),
    // 社交入口页面
    social: (_) => const SocialPage(),
  };
}
