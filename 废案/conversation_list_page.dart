import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/social/model/social_models.dart';
import 'package:we_pei_yang_flutter/social/model/social_provider.dart';
import 'package:we_pei_yang_flutter/social/model/test_data_generator.dart';
import 'package:we_pei_yang_flutter/social/network/social_service.dart';
import 'package:we_pei_yang_flutter/social/social_router.dart';

import '../../../commons/themes/wpy_theme.dart';

/// 会话列表页面
///
/// 该页面展示当前用户的所有私信会话，每个会话包含：
/// - 目标用户信息（头像、昵称）
/// - 最后一条消息内容
/// - 最后一条消息时间
/// - 未读消息数量（红点提示）
///
/// 页面功能：
/// - 查看所有私信会话
/// - 点击会话进入聊天页面
/// - 下拉刷新会话列表
/// - 上拉加载更多会话
/// - 自动刷新未读消息总数
///
/// 使用示例：
/// ```dart
/// // 导航到会话列表页面
/// Navigator.pushNamed(context, SocialRouter.conversation);
/// ```
class ConversationListPage extends StatefulWidget {
  @override
  State<ConversationListPage> createState() => _ConversationListPageState();
}

/// 会话列表状态类
///
/// 管理会话列表数据、分页逻辑和未读消息状态
class _ConversationListPageState extends State<ConversationListPage> {
  /// 会话列表数据
  List<Conversation> _conversationList = [];

  /// 已读会话ID集合
  final Set<int> _readConversationIds = {};

  /// 刷新控制器
  ///
  /// 控制下拉刷新和上拉加载的状态
  final _refreshController = RefreshController(initialRefresh: true);

  /// 当前页码
  ///
  /// 用于分页加载，初始值为1
  int _currentPage = 1;

  /// 初始化状态
  ///
  /// 在页面加载完成后刷新未读消息总数
  @override
  void initState() {
    super.initState();
    // 在页面渲染完成后刷新未读消息总数
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SocialProvider>().refreshUnreadCount();
    });
  }

  /// 下拉刷新回调
  ///
  /// 重置页码，清空列表，重新加载第一页数据
  Future<void> _onRefresh() async {
    // 重置页码为1
    _currentPage = 1;
    // 清空列表
    _conversationList.clear();
    // 重置无数据状态
    _refreshController.resetNoData();
    try {
      // 使用测试数据
      final testConversations = TestDataGenerator.generateTestConversations();
      // 按最后消息时间降序排序，最新消息的会话置顶
      testConversations.sort((a, b) {
        if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });
      setState(() {
        _conversationList.addAll(testConversations);
      });
      // 刷新完成
      _refreshController.refreshCompleted();
    } catch (e) {
      // 显示错误提示
      ToastProvider.error(e.toString());
      // 刷新失败
      _refreshController.refreshFailed();
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
      var response = await SocialService.getConversations(page: _currentPage);
      if (response.list.isEmpty) {
        // 没有更多数据
        _refreshController.loadNoData();
        // 页码回退
        _currentPage--;
      } else {
        // 按最后消息时间降序排序，最新消息的会话置顶
        response.list.sort((a, b) {
          if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
          if (a.lastMessageTime == null) return 1;
          if (b.lastMessageTime == null) return -1;
          return b.lastMessageTime!.compareTo(a.lastMessageTime!);
        });
        setState(() {
          _conversationList.addAll(response.list);
        });
        // 加载完成
        _refreshController.loadComplete();
      }
    } catch (e) {
      // 显示错误提示
      ToastProvider.error(e.toString());
      // 加载失败
      _refreshController.loadFailed();
      // 页码回退
      _currentPage--;
    }
  }

  /// 构建Widget树
  ///
  /// 创建包含AppBar和SmartRefresher的Scaffold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 应用栏配置
      appBar: AppBar(
        // 标题文本
        title: Text('私信'),
        // 标题居中显示
        centerTitle: true,
        // 标题样式
        titleTextStyle: TextUtil.base.w600.NotoSansSC.sp(16).primary(context),
        // 应用栏背景色
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        // 移除应用栏阴影
        shadowColor: Colors.transparent,
        // 移除返回按钮，因为现在是导航栏的一个Tab
        automaticallyImplyLeading: false,
      ),
      // 页面主体
      body: Container(
        // 设置背景色
        color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        // 安全区域，避免刘海屏遮挡
        child: SafeArea(
          // SmartRefresher，支持下拉刷新和上拉加载
          child: SmartRefresher(
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
            child: _conversationList.isEmpty
                // 空状态提示
                ? Container(
                    height: 400.h,
                    alignment: Alignment.center,
                    child: Text('暂无私信',
                        style: TextUtil.base.oldThirdAction(context)),
                  )
                // 列表视图
                : ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    itemCount: _conversationList.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final conversation = _conversationList[index];
                      final isRead =
                          _readConversationIds.contains(conversation.id);
                      return _ConversationItem(
                        conversation: conversation,
                        isRead: isRead,
                        onTap: () {
                          setState(() {
                            _readConversationIds.add(conversation.id);
                          });
                          // 清除该会话的未读消息计数
                          final socialProvider = context.read<SocialProvider>();
                          final currentUnreadCount =
                              socialProvider.totalUnreadCount;
                          final newUnreadCount =
                              currentUnreadCount - conversation.unreadCount;
                          // 确保不出现负数
                          socialProvider.setUnreadCount(
                              newUnreadCount > 0 ? newUnreadCount : 0);
                          // 清空该会话的未读数
                          conversation.unreadCount = 0;
                          Navigator.pushNamed(
                            context,
                            SocialRouter.chat,
                            arguments: conversation.targetUser,
                          );
                        },
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

/// 会话列表项组件
///
/// 展示单个会话的信息，包括头像、昵称、最后消息、时间和未读数
///
/// 参数：
/// - [conversation]: 会话数据模型
/// - [isRead]: 是否已读
/// - [onTap]: 点击回调
class _ConversationItem extends StatelessWidget {
  /// 会话数据
  final Conversation conversation;

  /// 是否已读
  final bool isRead;

  /// 点击回调
  final VoidCallback onTap;

  /// 构造函数
  const _ConversationItem({
    required this.conversation,
    required this.isRead,
    required this.onTap,
  });

  /// 格式化时间显示
  ///
  /// 根据消息时间与当前时间的差距，显示不同的时间格式：
  /// - 今天：显示"HH:MM"
  /// - 昨天：显示"昨天"
  /// - 7天内：显示"N天前"
  /// - 超过7天：显示"MM/DD"
  ///
  /// 参数：
  /// - [time]: 要格式化的时间
  ///
  /// 返回格式化后的时间字符串
  String _formatTime(DateTime? time) {
    // 空时间返回空字符串
    if (time == null) return '';

    final now = DateTime.now();
    // 计算时间差
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      // 今天，显示"HH:MM"
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // 昨天
      return '昨天';
    } else if (difference.inDays < 7) {
      // 7天内，显示"N天前"
      return '${difference.inDays}天前';
    } else {
      // 超过7天，显示"MM/DD"
      return '${time.month}/${time.day}';
    }
  }

  /// 构建Widget树
  ///
  /// 创建包含头像、昵称、最后消息、时间和未读数的卡片
  @override
  Widget build(BuildContext context) {
    return WButton(
      // 点击进入聊天页面
      onPressed: onTap,
      // 会话卡片容器
      child: Container(
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
            // 头像容器
            ClipRRect(
              borderRadius: BorderRadius.circular(25.w),
              // 判断是否有头像
              child: conversation.targetUser.avatar.isEmpty
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
                          conversation.targetUser.nickname.isNotEmpty
                              ? conversation.targetUser.nickname.substring(0, 1)
                              : '?',
                          style: TextUtil.base.w600.NotoSansSC.sp(20),
                        ),
                      ),
                    )
                  // 有头像时使用WpyPic显示本地头像
                  : WpyPic(
                      conversation.targetUser.avatar,
                      width: 50.w,
                      height: 50.w,
                      fit: BoxFit.cover,
                    ),
            ),
            // 头像和内容之间的间距
            SizedBox(width: 15.w),
            // 内容区域（昵称、时间、最后消息、未读数）
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 第一行：昵称和时间
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 昵称
                      Text(
                        conversation.targetUser.nickname,
                        style: TextUtil.base.w600.NotoSansSC
                            .sp(16)
                            .primary(context),
                      ),
                      // 时间
                      Text(
                        _formatTime(conversation.lastMessageTime),
                        style: TextUtil.base.w400.NotoSansSC
                            .sp(12)
                            .oldThirdAction(context),
                      ),
                    ],
                  ),
                  // 第一行和第二行之间的间距
                  SizedBox(height: 5.h),
                  // 第二行：最后消息和未读数
                  Row(
                    children: [
                      // 最后消息内容
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          // 单行显示，超出部分省略
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextUtil.base.w400.NotoSansSC
                              .sp(14)
                              .oldThirdAction(context),
                        ),
                      ),
                      // 未读消息数红点（仅在有未读消息且未读时显示）
                      if (!isRead && conversation.unreadCount > 0)
                        Container(
                          margin: EdgeInsets.only(left: 10.w),
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          // 红色背景
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10.w),
                          ),
                          // 未读数文本
                          child: Text(
                            // 超过99显示"99+"
                            conversation.unreadCount > 99
                                ? '99+'
                                : conversation.unreadCount.toString(),
                            style:
                                TextUtil.base.w500.NotoSansSC.sp(10).copyWith(
                                      color: Colors.white,
                                    ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
