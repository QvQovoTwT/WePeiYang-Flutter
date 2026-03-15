import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/social/social_router.dart';

import '../../commons/themes/wpy_theme.dart';

/// 私信功能入口页面
///
/// 该页面作为私信模块的主入口，直接导航到会话列表页面
class SocialPage extends StatelessWidget {
  /// 构造函数
  ///
  /// [key] 可选的Widget键
  const SocialPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 直接导航到会话列表页面
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, SocialRouter.conversation);
    });

    // 临时占位Widget
    return Scaffold(
      body: Container(
        color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
