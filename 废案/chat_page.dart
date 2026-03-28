import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/social/model/social_models.dart';
import 'package:we_pei_yang_flutter/social/model/social_provider.dart';
import 'package:we_pei_yang_flutter/social/model/test_data_generator.dart';
import 'package:we_pei_yang_flutter/social/network/social_service.dart';
import 'package:we_pei_yang_flutter/social/social_router.dart';

import '../../../commons/themes/wpy_theme.dart';

/// 聊天页面
///
/// 用于显示和发送私信消息
class ChatPage extends StatefulWidget {
  /// 目标用户信息
  final SocialUser targetUser;

  /// 构造函数
  const ChatPage(this.targetUser);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  /// 消息列表
  final List<ChatMessage> _messageList = [];

  /// 文本输入控制器
  final TextEditingController _textController = TextEditingController();

  /// 消息列表滚动控制器
  final ScrollController _scrollController = ScrollController();

  /// 是否正在发送消息
  bool _isSending = false;

  /// 是否已关注对方
  bool _isFollowing = false;

  /// 对方是否已关注自己
  bool _isFollowed = false;

  /// 是否互相关注
  bool get _isMutualFollow => _isFollowing && _isFollowed;

  /// 是否可以发送消息
  bool get canSend => _isMutualFollow || _messageList.isEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SocialProvider>().refreshUnreadCount();
      _checkFollowStatus();
      _loadMessageHistory();
    });
  }

  /// 判断是否为测试用户
  bool get _isTestUser {
    // 检查用户ID是否在测试用户范围内
    return widget.targetUser.id >= 1000 && widget.targetUser.id <= 2000;
  }

  /// 加载消息历史
  void _loadMessageHistory() {
    if (_isTestUser) {
      // 测试用户：使用测试数据
      final currentUserId = 1;
      final testMessages = TestDataGenerator.generateTestMessages(
          widget.targetUser, currentUserId);
      // 标记对方发送的消息为已读
      for (var message in testMessages) {
        if (message.senderId == widget.targetUser.id) {
          message.isRead = true;
        }
      }
      setState(() {
        _messageList.addAll(testMessages);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } else {
      // 真实用户：从后端加载数据
      SocialService.getMessages(
        widget.targetUser.id,
        pageSize: 100,
      ).then((response) {
        // 标记对方发送的消息为已读
        for (var message in response.list) {
          if (message.senderId == widget.targetUser.id) {
            message.isRead = true;
          }
        }
        setState(() {
          _messageList.addAll(response.list);
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }).catchError((e) {
        ToastProvider.error(e.toString());
      });
    }
  }

  /// 页面销毁时清除该会话的未读消息
  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    // 不在这里刷新未读消息计数，避免红点重新生成
    super.dispose();
  }

  /// 检查关注状态
  Future<void> _checkFollowStatus() async {
    if (_isTestUser) {
      // 测试用户：设置为互关
      setState(() {
        _isFollowing = true;
        _isFollowed = true;
      });
    } else {
      // 真实用户：从后端加载
      try {
        var followingResponse = await SocialService.getFollowing(pageSize: 100);
        setState(() {
          _isFollowing =
              followingResponse.list.any((f) => f.uid == widget.targetUser.id);
        });

        var followersResponse = await SocialService.getFollowers(pageSize: 100);
        setState(() {
          _isFollowed =
              followersResponse.list.any((f) => f.uid == widget.targetUser.id);
        });
      } catch (e) {
        setState(() {
          _isFollowing = false;
          _isFollowed = false;
        });
      }
    }
  }

  /// 发送消息
  void _sendMessage() {
    final content = _textController.text.trim();
    if (content.isEmpty || _isSending) return;

    // 检查是否互关，未互关时只能发送一条消息
    if (!_isMutualFollow && _messageList.isNotEmpty) {
      ToastProvider.error('未互关时只能发送一条私信');
      return;
    }

    setState(() {
      _isSending = true;
    });

    if (_isTestUser) {
      // 测试用户：直接添加本地消息
      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch,
        senderId: 1,
        receiverId: widget.targetUser.id,
        content: content,
        createdAt: DateTime.now(),
        isRead: false,
        type: MessageType.text,
      );

      setState(() {
        _messageList.add(newMessage);
        _textController.clear();
        _isSending = false;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      });

      // 模拟对方在2秒后将消息标记为已读
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            newMessage.isRead = true;
          });
        }
      });
    } else {
      // 真实用户：调用后端API
      SocialService.sendMessage(
        widget.targetUser.id,
        content,
        onResult: (message) {
          setState(() {
            _messageList.add(message);
            _textController.clear();
            _isSending = false;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController
                    .jumpTo(_scrollController.position.maxScrollExtent);
              }
            });
          });
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
          setState(() {
            _isSending = false;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.targetUser.nickname),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // 消息列表
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messageList.length,
                itemBuilder: (context, index) {
                  final message = _messageList[index];
                  final isMe = message.senderId != widget.targetUser.id;
                  final isLatestMessage = index == _messageList.length - 1;
                  return _MessageItem(
                    message: message,
                    isMe: isMe,
                    targetUser: widget.targetUser,
                    isLatestMessage: isLatestMessage,
                  );
                },
              ),
            ),
            // 输入区域
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  /// 构建输入区域
  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: WpyTheme.of(context).get(WpyColorKey.lightBorderColor),
            width: 1.w,
          ),
        ),
        color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      ),
      // 水平布局：输入框 + 发送按钮
      child: Row(
        children: [
          // 文本输入框
          Expanded(
            child: TextField(
              // 绑定控制器
              controller: _textController,
              // 最大行数
              maxLines: 4,
              // 最小行数
              minLines: 1,
              // 文本样式
              style: TextUtil.base.w400.NotoSansSC.sp(14).primary(context),
              // 装饰样式
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: canSend ? '输入消息...' : '未互关时只能发送一条私信',
                hintStyle: TextUtil.base.w400.NotoSansSC
                    .sp(14)
                    .oldThirdAction(context),
              ),
              // 按回车键发送消息
              onSubmitted: (_) => _sendMessage(),
              // 禁用状态（未互关且已发送过消息）
              enabled: canSend,
            ),
          ),
          // 发送按钮
          Container(
            margin: EdgeInsets.only(left: 10.w),
            child: ElevatedButton(
              // 按钮文本
              child: Text(
                '发送',
                style: TextUtil.base.w600.NotoSansSC.sp(14),
              ),
              // 按钮样式
              style: ElevatedButton.styleFrom(
                // 根据发送状态设置颜色
                backgroundColor: canSend
                    ? WpyTheme.of(context).get(WpyColorKey.primaryActionColor)
                    : WpyTheme.of(context).get(WpyColorKey.oldHintColor),
                // 禁用状态颜色
                disabledBackgroundColor:
                    WpyTheme.of(context).get(WpyColorKey.oldHintColor),
                // 圆角
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.w),
                ),
                // 内边距
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              ),
              // 发送中禁用按钮
              onPressed: _isSending || !canSend ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

/// 消息项组件
///
/// 展示单条消息的内容和发送者信息
///
/// 参数：
/// - [message]: 消息数据模型
/// - [isMe]: 是否为自己发送的消息
/// - [targetUser]: 目标用户信息
/// - [isLatestMessage]: 是否是最新消息
class _MessageItem extends StatelessWidget {
  /// 消息数据
  final ChatMessage message;

  /// 是否为自己发送的消息
  ///
  /// true: 自己发送的消息，显示在右侧
  /// false: 对方发送的消息，显示在左侧
  final bool isMe;

  /// 目标用户信息
  final SocialUser targetUser;

  /// 是否是最新消息
  final bool isLatestMessage;

  /// 构造函数
  const _MessageItem({
    required this.message,
    required this.isMe,
    required this.targetUser,
    this.isLatestMessage = false,
  });

  /// 构建Widget树
  ///
  /// 创建包含头像和消息气泡的行布局
  @override
  Widget build(BuildContext context) {
    return Container(
      // 外边距
      margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 15.w),
      // 根据是否为自己发送的消息设置对齐方式
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 对方的头像（仅显示在对方消息左侧）
          if (!isMe) ...[
            GestureDetector(
              onTap: () {
                // 点击头像跳转到个人页面
                Navigator.pushNamed(
                  context,
                  SocialRouter.profile,
                  arguments: targetUser.id,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.w),
                child: (targetUser.id >= 1000 && targetUser.id <= 2000)
                    ? WpyPic(
                        targetUser.avatar,
                        width: 35.w,
                        height: 35.w,
                        fit: BoxFit.cover,
                      )
                    : targetUser.avatar.isEmpty
                        ? Container(
                            width: 35.w,
                            height: 35.w,
                            decoration: BoxDecoration(
                              color: WpyTheme.of(context)
                                  .get(WpyColorKey.secondaryBackgroundColor),
                            ),
                            child: Center(
                              child: Text(
                                targetUser.nickname.isNotEmpty
                                    ? targetUser.nickname.substring(0, 1)
                                    : '?',
                                style: TextUtil.base.w600.NotoSansSC.sp(14),
                              ),
                            ),
                          )
                        : WpyPic(
                            'https://qnhdpic.twt.edu.cn/download/origin/${targetUser.avatar}',
                            width: 35.w,
                            height: 35.w,
                            fit: BoxFit.cover,
                          ),
              ),
            ),
            // 头像和消息之间的间距
            SizedBox(width: 10.w),
          ],
          Flexible(
            child: Column(
              // 根据是否为自己发送的消息设置对齐方式
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // 消息气泡
                Container(
                  // 内边距
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                  // 装饰样式
                  decoration: BoxDecoration(
                    // 根据是否为自己发送的消息设置颜色
                    color: isMe
                        ? WpyTheme.of(context)
                            .get(WpyColorKey.primaryActionColor)
                        : WpyTheme.of(context)
                            .get(WpyColorKey.secondaryBackgroundColor),
                    // 圆角
                    borderRadius: BorderRadius.circular(15.w),
                  ),
                  // 消息文本
                  child: Text(
                    message.content,
                    // 根据是否为自己发送的消息设置文本颜色
                    style: TextUtil.base.w400.NotoSansSC.sp(14).copyWith(
                          color: isMe
                              ? Colors.white
                              : WpyTheme.of(context)
                                  .get(WpyColorKey.basicTextColor),
                        ),
                  ),
                ),
                // 消息时间和已读状态
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 消息时间（可选）
                    if (message.createdAt != null)
                      Container(
                        // 上边距
                        margin: EdgeInsets.only(top: 5.h),
                        // 时间文本
                        child: Text(
                          '${message.createdAt!.hour.toString().padLeft(2, '0')}:${message.createdAt!.minute.toString().padLeft(2, '0')}',
                          style: TextUtil.base.w400.NotoSansSC
                              .sp(12)
                              .oldThirdAction(context),
                        ),
                      ),
                    // 已读状态（仅最新消息且自己发送的显示）
                    if (isLatestMessage && isMe && message.isRead)
                      Container(
                        margin: EdgeInsets.only(left: 5.w, top: 5.h),
                        child: Text(
                          '已读',
                          style: TextUtil.base.w400.NotoSansSC
                              .sp(12)
                              .oldThirdAction(context),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // 自己的头像（仅显示在自己消息右侧）
          if (isMe) ...[
            // 消息和头像之间的间距
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: () {
                // 点击我的头像跳转到我的个人页面
                // 获取当前用户ID（假设为1）
                Navigator.pushNamed(
                  context,
                  SocialRouter.profile,
                  arguments: 1,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.w),
                child: CommonPreferences.avatar.value.isEmpty
                    ? Container(
                        width: 35.w,
                        height: 35.w,
                        decoration: BoxDecoration(
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.secondaryBackgroundColor),
                        ),
                        child: Center(
                          child: Text(
                            '我',
                            style: TextUtil.base.w600.NotoSansSC.sp(14),
                          ),
                        ),
                      )
                    : WpyPic(
                        'https://qnhdpic.twt.edu.cn/download/origin/${CommonPreferences.avatar.value}',
                        width: 35.w,
                        height: 35.w,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
