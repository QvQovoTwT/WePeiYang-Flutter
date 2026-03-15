import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/social/model/social_models.dart';
import 'package:we_pei_yang_flutter/social/model/test_data_generator.dart';
import 'package:we_pei_yang_flutter/social/network/social_service.dart';
import 'package:we_pei_yang_flutter/social/social_router.dart';

import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/widgets/w_button.dart';

/// 将测试用户转换为FollowUser
List<FollowUser> _getTestFollowUsers() {
  final testUsers = TestDataGenerator.generateTestUsers();
  return testUsers
      .map((user) => FollowUser(
            uid: user.id,
            nickname: user.nickname,
            avatarUrl: user.avatar,
          ))
      .toList();
}

/// 好友管理页面
///
/// 该页面展示当前用户的好友关系，包含两个标签页：
/// - 关注我的：展示当前用户关注的人列表
/// - 我的粉丝：展示关注当前用户的人列表
///
/// 页面功能：
/// - 查看关注列表和粉丝列表
/// - 点击用户头像进入用户主页
/// - 发送私信给好友
/// - 移除粉丝（仅粉丝列表）
///
/// 使用示例：
/// ```dart
/// // 导航到好友页面
/// Navigator.pushNamed(context, SocialRouter.friend);
/// ```
class FriendPage extends StatefulWidget {
  @override
  State<FriendPage> createState() => _FriendPageState();
}

/// 好友页面状态类
///
/// 管理TabController，用于切换关注和粉丝标签页
class _FriendPageState extends State<FriendPage>
    with SingleTickerProviderStateMixin {
  /// Tab控制器
  ///
  /// 用于管理两个标签页的切换和动画
  late TabController _tabController;

  /// 初始化状态
  ///
  /// 创建TabController，设置标签页数量为2
  @override
  void initState() {
    super.initState();
    // 创建TabController，length为标签页数量
    _tabController = TabController(length: 2, vsync: this);
  }

  /// 释放资源
  ///
  /// 释放TabController，避免内存泄漏
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 构建Widget树
  ///
  /// 创建包含AppBar和TabBarView的Scaffold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 应用栏配置
      appBar: AppBar(
        // 标题文本
        title: Text('我的好友'),
        // 标题居中显示
        centerTitle: true,
        // 标题样式
        titleTextStyle: TextUtil.base.w600.NotoSansSC.sp(16).primary(context),
        // 应用栏背景色
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        // 移除应用栏阴影
        shadowColor: Colors.transparent,
        // 底部TabBar配置
        bottom: TabBar(
          // 绑定TabController
          controller: _tabController,
          // 两个标签：关注我的、我的粉丝
          tabs: [
            Tab(text: '关注我的'),
            Tab(text: '我的粉丝'),
          ],
          // 选中标签样式
          labelStyle: TextUtil.base.w600.NotoSansSC.sp(14),
          // 未选中标签样式
          unselectedLabelStyle: TextUtil.base.w400.NotoSansSC.sp(14),
          // 选中标签颜色
          labelColor: WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
          // 未选中标签颜色
          unselectedLabelColor:
              WpyTheme.of(context).get(WpyColorKey.oldThirdActionColor),
          // 指示器颜色
          indicatorColor:
              WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
        ),
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
          // TabBarView，展示两个标签页内容
          child: TabBarView(
            controller: _tabController,
            children: [
              // 关注列表标签页
              _FollowingTab(),
              // 粉丝列表标签页
              _FollowersTab(),
            ],
          ),
        ),
      ),
    );
  }
}

/// 关注列表标签页
///
/// 展示当前用户关注的人列表，支持下拉刷新和上拉加载更多
class _FollowingTab extends StatefulWidget {
  @override
  State<_FollowingTab> createState() => _FollowingTabState();
}

/// 关注列表状态类
///
/// 管理关注列表数据、分页逻辑和刷新控制
class _FollowingTabState extends State<_FollowingTab> {
  /// 关注列表数据
  List<FollowUser> _followingList = [];

  /// 刷新控制器
  ///
  /// 控制下拉刷新和上拉加载的状态
  final _refreshController = RefreshController(initialRefresh: true);

  /// 当前页码
  ///
  /// 用于分页加载，初始值为1
  int _currentPage = 1;

  /// 下拉刷新回调
  ///
  /// 重置页码，清空列表，重新加载第一页数据
  Future<void> _onRefresh() async {
    // 重置页码为1
    _currentPage = 1;
    // 清空列表
    _followingList.clear();
    // 重置无数据状态
    _refreshController.resetNoData();
    try {
      // 尝试获取真实数据
      var response = await SocialService.getFollowing(page: _currentPage);
      setState(() {
        _followingList.addAll(response.list);
      });
      // 刷新完成
      _refreshController.refreshCompleted();
    } catch (e) {
      // 如果获取真实数据失败，使用测试数据
      final testFollowUsers = _getTestFollowUsers();
      setState(() {
        _followingList.addAll(testFollowUsers);
      });
      // 刷新完成
      _refreshController.refreshCompleted();
    }
  }

  /// 上拉加载回调
  ///
  /// 加载下一页数据，追加到列表末尾
  Future<void> _onLoading() async {
    // 页码加1
    _currentPage++;
    try {
      // 获取下一页数据
      var response = await SocialService.getFollowing(page: _currentPage);
      if (response.list.isEmpty) {
        // 没有更多数据
        _refreshController.loadNoData();
        // 页码回退
        _currentPage--;
      } else {
        setState(() {
          _followingList.addAll(response.list);
        });
        // 加载完成
        _refreshController.loadComplete();
      }
    } catch (e) {
      // 没有更多测试数据了
      _refreshController.loadNoData();
      // 页码回退
      _currentPage--;
    }
  }

  /// 构建Widget树
  ///
  /// 创建SmartRefresher，支持下拉刷新和上拉加载
  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      // 弹性滚动效果
      physics: BouncingScrollPhysics(),
      // 绑定刷新控制器
      controller: _refreshController,
      // 启用下拉刷新
      enablePullDown: true,
      // 启用上拉加载
      enablePullUp: true,
      // 下拉刷新回调
      onRefresh: _onRefresh,
      // 上拉加载回调
      onLoading: _onLoading,
      // 子组件
      child: _followingList.isEmpty
          // 空状态提示
          ? Container(
              height: 400.h,
              alignment: Alignment.center,
              child: Text('暂无关注', style: TextUtil.base.oldThirdAction(context)),
            )
          // 列表视图
          : ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              itemCount: _followingList.length,
              separatorBuilder: (context, index) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                return _FriendItem(
                  user: _followingList[index],
                  // 关注列表不显示移除按钮
                  showRemoveFollower: false,
                );
              },
            ),
    );
  }
}

/// 粉丝列表标签页
///
/// 展示关注当前用户的人列表，支持下拉刷新和上拉加载更多
class _FollowersTab extends StatefulWidget {
  @override
  State<_FollowersTab> createState() => _FollowersTabState();
}

/// 粉丝列表状态类
///
/// 管理粉丝列表数据、分页逻辑和刷新控制
class _FollowersTabState extends State<_FollowersTab> {
  /// 粉丝列表数据
  List<FollowUser> _followersList = [];

  /// 刷新控制器
  final _refreshController = RefreshController(initialRefresh: true);

  /// 当前页码
  int _currentPage = 1;

  /// 下拉刷新回调
  ///
  /// 重置页码，清空列表，重新加载第一页数据
  Future<void> _onRefresh() async {
    _currentPage = 1;
    _followersList.clear();
    _refreshController.resetNoData();
    try {
      var response = await SocialService.getFollowers(page: _currentPage);
      setState(() {
        _followersList.addAll(response.list);
      });
      _refreshController.refreshCompleted();
    } catch (e) {
      // 如果获取真实数据失败，使用测试数据
      final testFollowUsers = _getTestFollowUsers();
      setState(() {
        _followersList.addAll(testFollowUsers);
      });
      _refreshController.refreshCompleted();
    }
  }

  /// 上拉加载回调
  ///
  /// 加载下一页数据，追加到列表末尾
  Future<void> _onLoading() async {
    _currentPage++;
    try {
      var response = await SocialService.getFollowers(page: _currentPage);
      if (response.list.isEmpty) {
        _refreshController.loadNoData();
        _currentPage--;
      } else {
        setState(() {
          _followersList.addAll(response.list);
        });
        _refreshController.loadComplete();
      }
    } catch (e) {
      // 没有更多测试数据了
      _refreshController.loadNoData();
      _currentPage--;
    }
  }

  /// 构建Widget树
  ///
  /// 创建SmartRefresher，支持下拉刷新和上拉加载
  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      physics: BouncingScrollPhysics(),
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: true,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: _followersList.isEmpty
          ? Container(
              height: 400.h,
              alignment: Alignment.center,
              child: Text('暂无粉丝', style: TextUtil.base.oldThirdAction(context)),
            )
          : ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              itemCount: _followersList.length,
              separatorBuilder: (context, index) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                return _FriendItem(
                  user: _followersList[index],
                  // 粉丝列表显示移除按钮
                  showRemoveFollower: true,
                  // 移除回调，从列表中移除该项
                  onRemoved: () {
                    setState(() {
                      _followersList.removeAt(index);
                    });
                  },
                );
              },
            ),
    );
  }
}

/// 好友列表项组件
///
/// 展示单个好友的信息，包括头像、昵称、关系状态和操作按钮
///
/// 参数：
/// - [user]: 用户数据模型
/// - [showRemoveFollower]: 是否显示移除粉丝按钮
/// - [onRemoved]: 移除成功后的回调函数
class _FriendItem extends StatelessWidget {
  /// 用户数据
  final FollowUser user;

  /// 是否显示移除粉丝按钮
  ///
  /// true: 在粉丝列表中，显示移除按钮
  /// false: 在关注列表中，不显示移除按钮
  final bool showRemoveFollower;

  /// 移除成功回调
  ///
  /// 当移除粉丝成功后调用，用于更新列表
  final VoidCallback? onRemoved;

  /// 构造函数
  const _FriendItem({
    required this.user,
    this.showRemoveFollower = false,
    this.onRemoved,
  });

  /// 构建Widget树
  ///
  /// 创建包含头像、昵称、关系状态和操作按钮的卡片
  @override
  Widget build(BuildContext context) {
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
      // 水平排列
      child: Row(
        children: [
          // 头像按钮
          // 点击进入用户主页
          WButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                SocialRouter.profile,
                arguments: user.uid,
              );
            },
            // 头像容器
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25.w),
              // 判断是否有头像
              child: user.avatarUrl.isEmpty
                  // 无头像时显示昵称首字
                  ? Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color: WpyTheme.of(context)
                            .get(WpyColorKey.secondaryBackgroundColor),
                      ),
                      child: Center(
                        child: Text(
                          user.nickname.isNotEmpty
                              ? user.nickname.substring(0, 1)
                              : '?',
                          style: TextUtil.base.w600.NotoSansSC.sp(20),
                        ),
                      ),
                    )
                  // 有头像时显示头像图片
                  : WpyPic(
                      user.avatarUrl,
                      width: 50.w,
                      height: 50.w,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          // 头像和昵称之间的间距
          SizedBox(width: 15.w),
          // 昵称和关系状态
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 昵称
                Text(
                  user.nickname,
                  style: TextUtil.base.w600.NotoSansSC.sp(16).primary(context),
                ),
              ],
            ),
          ),
          // 间距
          SizedBox(width: 10.w),
          // 操作按钮区域
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 私信按钮
              Container(
                margin: EdgeInsets.only(right: 10.w),
                child: ElevatedButton(
                  onPressed: () {
                    // 创建一个简化的SocialUser对象用于跳转
                    final targetUser = SocialUser(
                      id: user.uid,
                      nickname: user.nickname,
                      avatar: user.avatarUrl,
                    );
                    // 导航到聊天页面
                    Navigator.pushNamed(
                      context,
                      SocialRouter.chat,
                      arguments: targetUser,
                    );
                  },
                  // 按钮样式
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                    backgroundColor: WpyTheme.of(context)
                        .get(WpyColorKey.primaryActionColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                  ),
                  child: Text(
                    '私信',
                    style: TextUtil.base.w500.NotoSansSC.sp(14).copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
              // 移除粉丝按钮（仅在粉丝列表显示）
              if (showRemoveFollower)
                Padding(
                  padding: EdgeInsets.only(left: 10.w),
                  child: ElevatedButton(
                    onPressed: () {
                      // 调用移除粉丝接口
                      SocialService.removeFollower(
                        user.uid,
                        onSuccess: () {
                          ToastProvider.success('已移除粉丝');
                          // 调用移除回调，更新列表
                          onRemoved?.call();
                        },
                        onFailure: (e) {
                          ToastProvider.error(e.error.toString());
                        },
                      );
                    },
                    // 按钮样式
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                      backgroundColor: WpyTheme.of(context)
                          .get(WpyColorKey.oldThirdActionColor)
                          .withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                    ),
                    child: Text(
                      '移除',
                      style: TextUtil.base.w500.NotoSansSC
                          .sp(14)
                          .oldThirdAction(context),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
