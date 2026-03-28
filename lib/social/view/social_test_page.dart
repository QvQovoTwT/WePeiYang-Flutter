import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/private_chat/model/private_chat_model.dart';
import 'package:we_pei_yang_flutter/private_chat/view/page/private_chat_conversation_page.dart';
import 'package:we_pei_yang_flutter/social/model/social_models.dart';
import 'package:we_pei_yang_flutter/social/model/test_data_generator.dart';

import '../../commons/themes/wpy_theme.dart';

/// 私信功能测试页面
///
/// 该页面用于快速测试私信功能，提供测试用户列表
class SocialTestPage extends StatelessWidget {
  /// 构造函数
  const SocialTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final testUsers = TestDataGenerator.generateTestUsers();

    return Scaffold(
      appBar: AppBar(
        title: Text('私信功能测试'),
        centerTitle: true,
        titleTextStyle: TextUtil.base.w600.NotoSansSC.sp(16).primary(context),
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        shadowColor: Colors.transparent,
      ),
      body: Container(
        color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        child: SafeArea(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
            itemCount: testUsers.length,
            separatorBuilder: (context, index) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final user = testUsers[index];
              return _TestUserItem(user: user);
            },
          ),
        ),
      ),
    );
  }
}

/// 测试用户项组件
class _TestUserItem extends StatelessWidget {
  final SocialUser user;

  const _TestUserItem({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Row(
        children: [
          // 头像
          ClipRRect(
            borderRadius: BorderRadius.circular(25.w),
            child: user.avatar.isEmpty
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
                : WpyPic(
                    user.avatar,
                    width: 50.w,
                    height: 50.w,
                    fit: BoxFit.cover,
                  ),
          ),
          SizedBox(width: 15.w),
          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nickname,
                  style: TextUtil.base.w600.NotoSansSC.sp(16).primary(context),
                ),
                if (user.department != null) ...[
                  SizedBox(height: 5.h),
                  Text(
                    user.department!,
                    style: TextUtil.base.w400.NotoSansSC
                        .sp(12)
                        .oldThirdAction(context),
                  ),
                ],
              ],
            ),
          ),
          // 测试按钮
          ElevatedButton(
            onPressed: () {
              // 创建 PrivateChatContact 对象用于跳转
              final contact = PrivateChatContact(
                userId: user.id,
                username: user.nickname,
                avatar: user.avatar,
              );
              // 导航到新的聊天页面
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivateChatConversationPage(
                    contact: contact,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.w),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            ),
            child: Text(
              '测试私信',
              style: TextUtil.base.w600.NotoSansSC
                  .sp(14)
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
