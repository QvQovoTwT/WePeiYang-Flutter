import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/feedback/view/person_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/search_result_page.dart';

import '../../../../commons/preferences/common_prefs.dart';
import '../../../../commons/themes/template/wpy_theme_data.dart';
import '../../../../commons/themes/wpy_theme.dart';
import '../../../../commons/widgets/w_button.dart';

class CommentIdentificationContainer extends StatelessWidget {
  final String text;
  final bool active;

  CommentIdentificationContainer(this.text, this.active);

  @override
  Widget build(BuildContext context) {
    return text == ''
        ? SizedBox()
        : Container(
            margin: EdgeInsets.only(left: 3),
            child: Text(this.text,
                style: TextUtil.base.w500.NotoSansSC
                    .sp(10)
                    .primaryAction(context)),
          );
  }
}

class ETagUtil {
  final Color colorA, colorB;
  final String text, fullName;

  ETagUtil(this.colorA, this.colorB, this.text, this.fullName);
}

class ETagWidget extends StatefulWidget {
  final String entry;
  final bool full;

  const ETagWidget({Key? key, required this.entry, required this.full})
      : super(key: key);

  State<StatefulWidget> createState() => _ETagWidgetState();
}

class _ETagWidgetState extends State<ETagWidget> {
  @override
  Widget build(BuildContext context) {
    var entry = widget.entry;
    var full = widget.full;
    var eTag = ETagUtil(
      WpyTheme.of(context).get(WpyColorKey.elegantPostTagBColor),
      WpyTheme.of(context).get(WpyColorKey.elegantPostTagCColor),
      '加精',
      '加入精华帖',
    );

    var pinedTag = ETagUtil(
      WpyTheme.of(context).get(WpyColorKey.pinedPostTagBColor),
      WpyTheme.of(context).get(WpyColorKey.pinedPostTagCColor),
      '置顶',
      '将此帖置顶',
    );

    var activityTag = ETagUtil(
      WpyTheme.of(context).get(WpyColorKey.activityPostBColor),
      WpyTheme.of(context).get(WpyColorKey.activityPostTagCColor),
      '活动',
      '变为活动帖',
    );

    if (entry == 'elegant') eTag = eTag;
    if (entry == 'pined') eTag = pinedTag;
    if (entry == 'activity') eTag = activityTag;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(
          color: eTag.colorA,
          width: 1.w,
        ),
      ),
      child: Text(
        full ? eTag.fullName : eTag.text,
        style: TextUtil.base.w500.NotoSansSC.sp(10).copyWith(
              color: eTag.colorB,
            ),
      ),
    );
  }
}

class SolveOrNotWidget extends StatelessWidget {
  final int? solved;

  SolveOrNotWidget(this.solved);

  @override
  Widget build(BuildContext context) {
    if (solved == null) return SizedBox();
    if (solved == 1) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.w),
          border: Border.all(
            color: WpyTheme.of(context).get(WpyColorKey.tagLabelColor),
            width: 1.w,
          ),
        ),
        child: Text(
          '已解决',
          style: TextUtil.base.w500.NotoSansSC.sp(10).copyWith(
                color: WpyTheme.of(context).get(WpyColorKey.tagLabelColor),
              ),
        ),
      );
    } else {
      return SizedBox();
    }
  }
}

class AvatarPlaceholder extends StatelessWidget {
  final String nickname;
  final int uid;

  AvatarPlaceholder({required this.nickname, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
      child: Center(
        child: Text(
          nickname.isNotEmpty ? nickname.substring(0, 1) : '?',
          style: TextUtil.base.w600.NotoSansSC.sp(16),
        ),
      ),
    );
  }
}

class ProfileImageWithDetailedPopup extends StatefulWidget {
  final int postOrCommentId;
  final bool fromPostCard;
  final int type;
  final int uid;
  final String avatar;
  final String nickName;
  final String level;
  final String heroTag;
  final String avatarBox;

  ProfileImageWithDetailedPopup(
      this.postOrCommentId,
      this.fromPostCard,
      this.type,
      this.avatar,
      this.uid,
      this.nickName,
      this.level,
      this.heroTag,
      this.avatarBox);

  static WidgetBuilder defaultPlaceholderBuilder =
      (BuildContext ctx) => SizedBox(
            width: 24.h,
            height: 24.h,
            child: FittedBox(fit: BoxFit.fitWidth, child: Loading()),
          );

  @override
  State<ProfileImageWithDetailedPopup> createState() =>
      _ProfileImageWithDetailedPopupState();
}

class _ProfileImageWithDetailedPopupState
    extends State<ProfileImageWithDetailedPopup> {
  bool get hasAdmin =>
      CommonPreferences.isSchAdmin.value ||
      CommonPreferences.isStuAdmin.value ||
      CommonPreferences.isSuper.value;

  @override
  Widget build(BuildContext ctx) {
    return WButton(
      onPressed: () {
        if ((widget.type != 1) || hasAdmin)
          Navigator.pushNamed(context, FeedbackRouter.person,
              arguments: PersonPageArgs(
                  widget.postOrCommentId,
                  widget.fromPostCard,
                  widget.type,
                  widget.uid,
                  widget.avatar,
                  widget.nickName,
                  widget.level,
                  widget.heroTag));
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            child: SizedBox(
              height: 32,
              width: 32,
              child: (widget.type == 1 || widget.avatar == '')
                  ? AvatarPlaceholder(
                      nickname: widget.nickName, uid: widget.uid)
                  : WpyPic(
                      width: 32,
                      height: 32,
                      'https://qnhdpic.twt.edu.cn/download/origin/${widget.avatar}',
                      fit: BoxFit.cover,
                      withCache: true,
                      withHolder: false,
                    ),
            ),
          ),
          if (widget.avatarBox != '' &&
              widget.avatarBox != 'Error' &&
              widget.type != 1 &&
              widget.avatarBox.length > 5)
            SizedBox(
              width: 32,
              height: 32,
              child: OverflowBox(
                maxWidth: 60,
                maxHeight: 60,
                child: WpyPic(
                  width: 60,
                  height: 60,
                  widget.avatarBox,
                  fit: BoxFit.contain,
                  reduce: false,
                  withCache: true,
                  withHolder: false,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class TagsWrap extends StatefulWidget {
  final List<String> tags;
  final VoidCallback? onTap;

  TagsWrap({required this.tags, this.onTap});

  @override
  _TagsWrapState createState() => _TagsWrapState();
}

class _TagsWrapState extends State<TagsWrap> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final tags = widget.tags;
    final onTap = widget.onTap;

    if (tags.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _isExpanded
              ? tags.map((tag) => _buildTag(tag)).toList()
              : tags.take(3).map((tag) => _buildTag(tag)).toList(),
        ),
        if (tags.length > 3)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
              if (onTap != null) onTap!();
            },
            child: Text(
              _isExpanded ? '收起' : '展开更多',
              style:
                  TextUtil.base.w500.NotoSansSC.sp(12).primaryAction(context),
            ),
          ),
      ],
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: WpyTheme.of(context).get(WpyColorKey.tagLabelColor),
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Text(
        '#$tag',
        style: TextUtil.base.w400.NotoSansSC.sp(12).primaryAction(context),
      ),
    );
  }
}

class TagShowWidget extends StatelessWidget {
  final String text;
  final double width;
  final int type;
  final int id;
  final int action;
  final int postType;

  TagShowWidget(
      this.text, this.width, this.type, this.id, this.action, this.postType);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      constraints: BoxConstraints(maxWidth: width),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(
          color: WpyTheme.of(context).get(WpyColorKey.tagLabelColor),
          width: 1.w,
        ),
      ),
      child: Text(
        text,
        style: TextUtil.base.w500.NotoSansSC.sp(10).primaryAction(context),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
