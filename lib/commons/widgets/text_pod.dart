import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';

/// 文本标签组件
///
/// 用于显示带有圆角和背景色的文本标签
class TextPod extends StatelessWidget {
  /// 标签文本
  final String text;

  /// 构造函数
  const TextPod(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: WpyTheme.of(context).get(WpyColorKey.oldActionColor),
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Text(
        text,
        style:
            TextUtil.base.w600.NotoSansSC.sp(12).copyWith(color: Colors.white),
      ),
    );
  }
}
