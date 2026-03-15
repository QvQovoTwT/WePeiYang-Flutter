import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/level_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/social/model/social_models.dart';
import 'package:we_pei_yang_flutter/social/model/test_data_generator.dart';
import 'package:we_pei_yang_flutter/social/network/social_service.dart';
import 'package:we_pei_yang_flutter/social/social_router.dart';

/// 用户资料页面
///
/// 该页面展示用户的个人资料，包括：
/// - 用户基本信息（头像、昵称、等级、学院、专业）
/// - 粉丝数、关注数、动态数统计
/// - 关注/取消关注按钮（查看他人主页时）
/// - 私信按钮（查看他人主页时）
/// - 主页可见性设置（查看自己主页时）
///
/// 页面功能：
/// - 查看用户资料
/// - 关注/取消关注用户
/// - 发送私信
/// - 设置主页可见性
///
/// 使用示例：
/// ```dart
/// // 导航到用户资料页面，传递用户ID
/// Navigator.pushNamed(
///   context,
///   SocialRouter.profile,
///   arguments: userId,
/// );
/// ```
class ProfilePage extends StatefulWidget {
  /// 用户ID
  ///
  /// 要查看的用户ID
  final int userId;

  /// 构造函数
  ///
  /// [userId] 必填参数，指定要查看的用户
  const ProfilePage(this.userId);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

/// 用户资料页面状态类
///
/// 管理用户资料数据、关注状态和主页可见性设置
class _ProfilePageState extends State<ProfilePage> {
  /// 用户资料数据
  ///
  /// 包含用户信息、粉丝列表、关注列表等
  Map<String, dynamic>? _profileData;

  /// 是否正在加载
  ///
  /// 加载过程中显示加载指示器
  bool _isLoading = true;

  /// 是否已关注该用户
  ///
  /// 用于控制关注按钮的显示状态
  bool _isFollowing = false;

  /// 是否是自己的主页
  ///
  /// true: 显示主页可见性设置
  /// false: 显示关注和私信按钮
  bool _isOwnProfile = false;

  /// 用户可见性
  bool _userVisible = true;

  /// 是否显示历史发帖
  bool _showHistoryPosts = false;

  /// 初始化状态
  ///
  /// 判断是否是自己的主页，并加载用户资料
  @override
  void initState() {
    super.initState();
    // 判断是否是自己的主页 - 使用 lakeUid（论坛用户ID）
    final myLakeUid = CommonPreferences.lakeUid.value;
    _isOwnProfile =
        myLakeUid.isNotEmpty && int.tryParse(myLakeUid) == widget.userId;
    // 初始化历史发帖显示开关
    _showHistoryPosts = CommonPreferences.showHistoryPosts.value;
    // 加载用户资料
    _loadProfile();
    // 检查关注状态
    _checkFollowStatus();
  }

  /// 切换历史发帖显示开关
  void _toggleShowHistoryPosts(bool value) {
    setState(() {
      _showHistoryPosts = value;
    });
    CommonPreferences.showHistoryPosts.value = value;
    ToastProvider.success(value ? '已开启历史发帖展示' : '已关闭历史发帖展示');
  }

  /// 检查关注状态
  Future<void> _checkFollowStatus() async {
    try {
      var followingResponse = await SocialService.getFollowing(pageSize: 100);
      setState(() {
        _isFollowing =
            followingResponse.list.any((f) => f.uid == widget.userId);
      });
    } catch (e) {
      setState(() {
        _isFollowing = false;
      });
    }
  }

  /// 判断是否为测试用户
  bool get _isTestUser {
    return widget.userId >= 1000 && widget.userId <= 2000;
  }

  /// 加载用户资料
  ///
  /// 从服务器获取用户资料数据，包括基本信息、粉丝列表、关注列表等
  ///
  /// 工作流程：
  /// 1. 调用SocialService.getUserProfile获取用户资料
  /// 2. 更新_profile和_isFollowing状态
  /// 3. 设置_isLoading为false
  /// 4. 失败时显示错误提示
  Future<void> _loadProfile() async {
    try {
      Map<String, dynamic> profileData;

      if (_isTestUser) {
        // 测试用户：从测试数据中获取
        final testUsers = TestDataGenerator.generateTestUsers();
        final testUser = testUsers.firstWhere(
          (user) => user.id == widget.userId,
          orElse: () => testUsers[0],
        );

        profileData = {
          'id': testUser.id,
          'nickname': testUser.nickname,
          'avatar': testUser.avatar,
          'level': testUser.level,
          'department': testUser.department,
          'major': testUser.major,
          'profile_visibility': testUser.visible ? 1 : 0,
          'fans_count': 128,
          'following_count': 64,
          'posts_count': 32,
          'identification': testUser.identification,
        };
      } else if (_isOwnProfile) {
        // 自己的主页：使用本地存储的用户信息
        profileData = {
          'id': widget.userId,
          'nickname': CommonPreferences.nickname.value,
          'avatar': CommonPreferences.avatar.value,
          'level': 10,
          'department': '计算机科学与技术学院',
          'major': '软件工程',
          'profile_visibility': 1,
          'fans_count': 100,
          'following_count': 50,
          'posts_count': 20,
          'identification': null,
        };
      } else {
        // 真实用户：从服务器获取
        profileData = await SocialService.getUserProfile(widget.userId);
      }

      setState(() {
        _profileData = profileData;
        _userVisible = profileData['profile_visibility'] == 1;
        _isLoading = false;
      });
    } catch (e) {
      // 如果是自己的主页或测试用户，即使出错也显示一些默认数据
      if (_isOwnProfile || _isTestUser) {
        Map<String, dynamic> fallbackData;
        if (_isTestUser) {
          final testUsers = TestDataGenerator.generateTestUsers();
          final testUser = testUsers.firstWhere(
            (user) => user.id == widget.userId,
            orElse: () => testUsers[0],
          );
          fallbackData = {
            'id': testUser.id,
            'nickname': testUser.nickname,
            'avatar': testUser.avatar,
            'level': testUser.level,
            'department': testUser.department,
            'major': testUser.major,
            'profile_visibility': testUser.visible ? 1 : 0,
            'fans_count': 128,
            'following_count': 64,
            'posts_count': 32,
            'identification': testUser.identification,
          };
        } else {
          fallbackData = {
            'id': widget.userId,
            'nickname': CommonPreferences.nickname.value,
            'avatar': CommonPreferences.avatar.value,
            'level': 10,
            'department': '计算机科学与技术学院',
            'major': '软件工程',
            'profile_visibility': 1,
            'fans_count': 100,
            'following_count': 50,
            'posts_count': 20,
            'identification': null,
          };
        }

        setState(() {
          _profileData = fallbackData;
          _userVisible = fallbackData['profile_visibility'] == 1;
          _isLoading = false;
        });
      } else {
        // 真实用户：显示错误提示
        ToastProvider.error(e.toString());
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 切换关注状态
  ///
  /// 关注或取消关注当前用户
  ///
  /// 工作流程：
  /// 1. 检查当前关注状态
  /// 2. 已关注：调用unfollowUser取消关注
  /// 3. 未关注：调用followUser关注
  /// 4. 成功后更新_isFollowing状态并显示提示
  /// 5. 失败时显示错误提示
  void _toggleFollow() {
    if (_isFollowing) {
      // 取消关注
      SocialService.unfollowUser(
        widget.userId,
        onSuccess: () {
          setState(() {
            _isFollowing = false;
          });
          ToastProvider.success('已取消关注');
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
        },
      );
    } else {
      // 关注
      SocialService.followUser(
        widget.userId,
        onSuccess: () {
          setState(() {
            _isFollowing = true;
          });
          ToastProvider.success('已关注');
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
        },
      );
    }
  }

  /// 切换主页可见性
  ///
  /// 设置当前用户的主页是否对其他用户可见
  ///
  /// 工作流程：
  /// 1. 检查_profile是否为空
  /// 2. 计算新的可见性状态（取反）
  /// 3. 调用SocialService.setVisible设置可见性
  /// 4. 成功后更新_profile中的visible状态并显示提示
  /// 5. 失败时显示错误提示
  void _toggleVisible() {
    // 计算新的可见性状态
    final newValue = !_userVisible;

    // 调用设置可见性接口
    SocialService.setVisible(
      newValue,
      onSuccess: () {
        setState(() {
          _userVisible = newValue;
        });
        ToastProvider.success(newValue ? '已设为可见' : '已设为不可见');
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
      },
    );
  }

  /// 构建Widget树
  ///
  /// 创建包含AppBar和用户资料内容的Scaffold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 应用栏配置
      appBar: AppBar(
        // 标题文本
        title: Text('个人主页'),
        // 标题居中显示
        centerTitle: true,
        // 标题样式
        titleTextStyle: TextUtil.base.w600.NotoSansSC.sp(16).primary(context),
        // 应用栏背景色
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        // 移除应用栏阴影
        shadowColor: Colors.transparent,
        // 返回按钮
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: WpyTheme.of(context).get(WpyColorKey.oldActionColor),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // 页面主体
      body: Container(
        // 设置背景色
        color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        // 安全区域，避免刘海屏遮挡
        child: SafeArea(
          // 根据加载状态显示不同内容
          child: _isLoading
              // 加载中：显示加载指示器
              ? Center(
                  child: CircularProgressIndicator(
                    color: WpyTheme.of(context)
                        .get(WpyColorKey.primaryActionColor),
                  ),
                )
              // 加载完成：显示用户资料内容
              : _buildContent(context),
        ),
      ),
    );
  }

  /// 构建用户资料内容
  ///
  /// 根据用户资料数据构建页面内容，包括：
  /// - 加载失败提示
  /// - 主页不可见提示（查看他人主页时）
  /// - 用户头像、昵称、等级、学院、专业
  /// - 粉丝数、关注数、动态数统计
  /// - 主页可见性设置（查看自己主页时）
  ///
  /// 参数：
  /// - [context]: BuildContext
  ///
  /// 返回用户资料内容的Widget
  Widget _buildContent(BuildContext context) {
    // 检查profile是否为空
    if (_profileData == null) {
      return Container(
        alignment: Alignment.center,
        child: Text('加载失败', style: TextUtil.base.oldThirdAction(context)),
      );
    }

    // 检查主页是否可见（查看他人主页时）
    if (!_userVisible && !_isOwnProfile) {
      return Container(
        alignment: Alignment.center,
        child: Text('该用户主页不可见', style: TextUtil.base.oldThirdAction(context)),
      );
    }

    // 滚动视图，包含所有内容
    return SingleChildScrollView(
      child: Column(
        children: [
          // 用户头像、昵称、等级、学院、专业
          _buildHeader(context),
          // 粉丝数、关注数、动态数统计
          _buildStats(context),
          // 主页可见性设置（仅自己主页显示）
          if (_isOwnProfile) _buildVisibleSetting(context),
          // 历史发帖显示开关（仅自己主页显示）
          if (_isOwnProfile) _buildHistoryPostsSetting(context),
          // 底部间距
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  /// 构建用户头部信息
  ///
  /// 创建包含头像、昵称、等级、学院、专业和操作按钮的头部区域
  ///
  /// 参数：
  /// - [context]: BuildContext
  ///
  /// 返回头部区域的Widget
  Widget _buildHeader(BuildContext context) {
    final nickname = _profileData?['nickname'] ?? '';
    final avatar = _profileData?['avatar'] ?? '';
    final level = _profileData?['level'] ?? 0;
    final department = _profileData?['department'];
    final major = _profileData?['major'];
    final identification = _profileData?['identification'];

    // 为测试用户设置认证标识
    String? finalIdentification;
    if (_isTestUser) {
      final testUsers = TestDataGenerator.generateTestUsers();
      final testUser = testUsers.firstWhere(
        (u) => u.id == widget.userId,
        orElse: () => testUsers[0],
      );
      finalIdentification = testUser.identification;
    } else {
      finalIdentification = identification;
    }

    // 获取认证图标
    String? getIdentificationIcon() {
      if (finalIdentification == 'gold') {
        return 'assets/svg_pics/social_icons/identification_gold.svg';
      } else if (finalIdentification == 'blue') {
        return 'assets/svg_pics/social_icons/identification_blue.svg';
      }
      return null;
    }

    // 创建一个简化的SocialUser对象用于跳转
    final targetUser = SocialUser(
      id: widget.userId,
      nickname: nickname,
      avatar: avatar,
      level: level,
      department: department,
      major: major,
      identification: finalIdentification,
    );

    return Container(
      // 内边距
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // 第一行：头像 + 基本信息
          Row(
            children: [
              // 头像容器
              ClipRRect(
                borderRadius: BorderRadius.circular(30.w),
                // 判断是否有头像
                child: avatar.isEmpty
                    // 无头像时显示昵称首字
                    ? Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.secondaryBackgroundColor),
                        ),
                        child: Center(
                          child: Text(
                            nickname.isNotEmpty
                                ? nickname.substring(0, 1)
                                : '?',
                            style: TextUtil.base.w600.NotoSansSC.sp(32),
                          ),
                        ),
                      )
                    // 有头像时显示头像图片
                    : WpyPic(
                        avatar,
                        width: 80.w,
                        height: 80.w,
                        fit: BoxFit.cover,
                      ),
              ),
              // 头像和基本信息之间的间距
              SizedBox(width: 20.w),
              // 基本信息：昵称、等级、学院、专业
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 昵称 + 认证标识
                    Row(
                      children: [
                        // 昵称
                        Text(
                          nickname,
                          style: TextUtil.base.w600.NotoSansSC
                              .sp(20)
                              .primary(context),
                        ),
                        // 认证标识（如果有）
                        if (getIdentificationIcon() != null) ...[
                          SizedBox(width: 8.w),
                          WpyPic(
                            getIdentificationIcon()!,
                            width: 20.w,
                            height: 20.w,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ],
                    ),
                    // 昵称和等级之间的间距
                    SizedBox(height: 5.h),
                    // 等级标签
                    LevelUtil(
                      level: level.toString(),
                      style: TextUtil.base.bright(context).bold.sp(10),
                    ),
                    // 学院（可选）
                    if (department != null) ...[
                      SizedBox(height: 5.h),
                      Text(
                        department,
                        style: TextUtil.base.w400.NotoSansSC
                            .sp(12)
                            .oldThirdAction(context),
                      ),
                    ],
                    // 专业（可选）
                    if (major != null)
                      Text(
                        major,
                        style: TextUtil.base.w400.NotoSansSC
                            .sp(12)
                            .oldThirdAction(context),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // 第一行和第二行之间的间距
          SizedBox(height: 20.h),
          // 第二行：操作按钮（仅查看他人主页时显示）
          if (!_isOwnProfile)
            Row(
              children: [
                // 关注/取消关注按钮
                Expanded(
                  child: ElevatedButton(
                    onPressed: _toggleFollow,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      // 根据关注状态设置背景色
                      backgroundColor: _isFollowing
                          ? WpyTheme.of(context)
                              .get(WpyColorKey.oldThirdActionColor)
                              .withOpacity(0.1)
                          : WpyTheme.of(context)
                              .get(WpyColorKey.primaryActionColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isFollowing)
                          Icon(
                            Icons.check,
                            size: 16.w,
                            color: WpyTheme.of(context)
                                .get(WpyColorKey.oldThirdActionColor),
                          ),
                        if (_isFollowing) SizedBox(width: 5.w),
                        Text(
                          _isFollowing ? '已关注' : '+关注',
                          style: TextUtil.base.w600.NotoSansSC.sp(14).copyWith(
                                // 根据关注状态设置文本颜色
                                color: _isFollowing
                                    ? WpyTheme.of(context)
                                        .get(WpyColorKey.oldThirdActionColor)
                                    : Colors.white,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 两个按钮之间的间距
                SizedBox(width: 15.w),
                // 私信按钮
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 导航到聊天页面
                      Navigator.pushNamed(
                        context,
                        SocialRouter.chat,
                        arguments: targetUser,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      backgroundColor: WpyTheme.of(context)
                          .get(WpyColorKey.secondaryBackgroundColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                    ),
                    child: Text(
                      '私信',
                      style:
                          TextUtil.base.w600.NotoSansSC.sp(14).primary(context),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// 构建统计数据区域
  ///
  /// 创建包含粉丝数、关注数、动态数的统计卡片
  ///
  /// 参数：
  /// - [context]: BuildContext
  ///
  /// 返回统计区域的Widget
  Widget _buildStats(BuildContext context) {
    final followerCount = _profileData?['follower_count'] ?? 0;
    final followingCount = _profileData?['following_count'] ?? 0;
    final postCount = _profileData?['post_count'] ?? 0;

    return Container(
      // 外边距
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      // 内边距
      padding: EdgeInsets.all(20.w),
      // 装饰样式
      decoration: BoxDecoration(
        color: WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
        borderRadius: BorderRadius.circular(12.w),
      ),
      // 水平布局：粉丝数 | 关注数 | 动态数
      child: Row(
        children: [
          // 粉丝数
          Expanded(
            child: Column(
              children: [
                // 粉丝数量
                Text(
                  followerCount.toString(),
                  style: TextUtil.base.w600.NotoSansSC.sp(20).primary(context),
                ),
                // 数量和标签之间的间距
                SizedBox(height: 5.h),
                // 标签文本
                Text(
                  '粉丝',
                  style: TextUtil.base.w400.NotoSansSC
                      .sp(12)
                      .oldThirdAction(context),
                ),
              ],
            ),
          ),
          // 分隔线
          Container(
            width: 1.w,
            height: 40.h,
            color: WpyTheme.of(context)
                .get(WpyColorKey.oldThirdActionColor)
                .withOpacity(0.2),
          ),
          // 关注数
          Expanded(
            child: Column(
              children: [
                // 关注数量
                Text(
                  followingCount.toString(),
                  style: TextUtil.base.w600.NotoSansSC.sp(20).primary(context),
                ),
                // 数量和标签之间的间距
                SizedBox(height: 5.h),
                // 标签文本
                Text(
                  '关注',
                  style: TextUtil.base.w400.NotoSansSC
                      .sp(12)
                      .oldThirdAction(context),
                ),
              ],
            ),
          ),
          // 分隔线
          Container(
            width: 1.w,
            height: 40.h,
            color: WpyTheme.of(context)
                .get(WpyColorKey.oldThirdActionColor)
                .withOpacity(0.2),
          ),
          // 动态数
          Expanded(
            child: Column(
              children: [
                // 动态数量
                Text(
                  postCount.toString(),
                  style: TextUtil.base.w600.NotoSansSC.sp(20).primary(context),
                ),
                // 数量和标签之间的间距
                SizedBox(height: 5.h),
                // 标签文本
                Text(
                  '动态',
                  style: TextUtil.base.w400.NotoSansSC
                      .sp(12)
                      .oldThirdAction(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建主页可见性设置
  ///
  /// 创建包含主页可见性开关的设置卡片
  ///
  /// 参数：
  /// - [context]: BuildContext
  ///
  /// 返回设置区域的Widget
  Widget _buildVisibleSetting(BuildContext context) {
    return Container(
      // 外边距
      margin: EdgeInsets.all(20.w),
      // 内边距
      padding: EdgeInsets.all(15.w),
      // 装饰样式
      decoration: BoxDecoration(
        color: WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
        borderRadius: BorderRadius.circular(12.w),
      ),
      // 水平布局：标签 + 开关
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 标签文本
          Text(
            '主页可见',
            style: TextUtil.base.w500.NotoSansSC.sp(14).primary(context),
          ),
          // 开关控件
          Switch(
            // 当前状态
            value: _userVisible,
            // 状态改变回调
            onChanged: (_) => _toggleVisible(),
            // 激活状态颜色
            activeColor:
                WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
          ),
        ],
      ),
    );
  }

  /// 构建历史发帖显示设置
  ///
  /// 创建包含历史发帖显示开关的设置卡片
  ///
  /// 参数：
  /// - [context]: BuildContext
  ///
  /// 返回设置区域的Widget
  Widget _buildHistoryPostsSetting(BuildContext context) {
    return Container(
      // 外边距
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      // 内边距
      padding: EdgeInsets.all(15.w),
      // 装饰样式
      decoration: BoxDecoration(
        color: WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
        borderRadius: BorderRadius.circular(12.w),
      ),
      // 水平布局：标签 + 开关
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 标签文本
          Text(
            '展示历史发帖',
            style: TextUtil.base.w500.NotoSansSC.sp(14).primary(context),
          ),
          // 开关控件
          Switch(
            // 当前状态
            value: _showHistoryPosts,
            // 状态改变回调
            onChanged: _toggleShowHistoryPosts,
            // 激活状态颜色
            activeColor:
                WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
          ),
        ],
      ),
    );
  }
}
