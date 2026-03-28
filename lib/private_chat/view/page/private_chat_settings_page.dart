import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/private_chat/model/private_chat_provider.dart';

/// 私信设置页面 — 私信开关、陌生人策略、拉黑管理
class PrivateChatSettingsPage extends StatefulWidget {
  const PrivateChatSettingsPage({super.key});

  @override
  State<PrivateChatSettingsPage> createState() =>
      _PrivateChatSettingsPageState();
}

class _PrivateChatSettingsPageState extends State<PrivateChatSettingsPage> {
  bool _isLoading = false;
  final _blockController = TextEditingController();
  bool? _localIsEnable;
  bool? _localIsAcceptStranger;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  @override
  void dispose() {
    _blockController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final provider = context.read<PrivateChatProvider>();
    final error = await provider.loadSetting();
    if (error != null && mounted) {
      ToastProvider.error(error);
    }
    if (mounted) {
      final setting = provider.userSetting;
      setState(() {
        _isLoading = false;
        if (setting != null) {
          _localIsEnable = setting.isEnable == 1;
          _localIsAcceptStranger = setting.isAcceptStranger == 1;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
      appBar: AppBar(
        title: Text(
          '私信设置',
          style: TextUtil.base.bold.sp(18).label(context),
        ),
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final provider = context.read<PrivateChatProvider>();
    final setting = provider.userSetting;
    if (setting == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings_outlined,
              size: 64.sp,
              color: WpyTheme.of(context).get(WpyColorKey.secondaryTextColor),
            ),
            SizedBox(height: 16.h),
            Text(
              '设置尚未加载',
              style: TextUtil.base.regular.sp(16).secondary(context),
            ),
            SizedBox(height: 16.h),
            FilledButton.icon(
              onPressed: _loadSettings,
              icon: const Icon(Icons.refresh),
              label: const Text('加载设置'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSettings,
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // 私信设置卡片
          _buildSectionCard(
            context: context,
            title: '📨 私信设置',
            children: [
              SwitchListTile(
                title: Text(
                  '私信总开关',
                  style: TextUtil.base.regular.sp(16).label(context),
                ),
                subtitle: Text(
                  (_localIsEnable ?? setting.isEnable == 1) ? '已开启' : '已关闭',
                  style: TextUtil.base.regular.sp(13).secondary(context),
                ),
                value: _localIsEnable ?? setting.isEnable == 1,
                activeColor: WpyTheme.of(context).get(WpyColorKey.successGreen),
                onChanged: (val) async {
                  setState(() {
                    _localIsEnable = val;
                  });
                  final error = await provider.toggleEnable(val);
                  if (error != null && mounted) {
                    ToastProvider.error(error);
                    setState(() {
                      _localIsEnable = setting.isEnable == 1;
                    });
                  }
                },
              ),
              Divider(
                height: 1,
                color: WpyTheme.of(context).get(WpyColorKey.lightBorderColor),
              ),
              SwitchListTile(
                title: Text(
                  '接收陌生人私信',
                  style: TextUtil.base.regular.sp(16).label(context),
                ),
                subtitle: Text(
                  (_localIsAcceptStranger ?? setting.isAcceptStranger == 1)
                      ? '已开启'
                      : '已关闭',
                  style: TextUtil.base.regular.sp(13).secondary(context),
                ),
                value: _localIsAcceptStranger ?? setting.isAcceptStranger == 1,
                activeColor: WpyTheme.of(context).get(WpyColorKey.successGreen),
                onChanged: (val) async {
                  setState(() {
                    _localIsAcceptStranger = val;
                  });
                  final error = await provider.toggleStranger(val);
                  if (error != null && mounted) {
                    ToastProvider.error(error);
                    setState(() {
                      _localIsAcceptStranger = setting.isAcceptStranger == 1;
                    });
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // 拉黑名单卡片 - 使用 Selector 只监听黑名单变化
          Selector<PrivateChatProvider, List<String>>(
            selector: (context, provider) =>
                provider.userSetting?.blockList ?? [],
            builder: (context, blockList, _) {
              final provider = context.read<PrivateChatProvider>();
              return _buildSectionCard(
                context: context,
                title: '🚫 拉黑名单',
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _blockController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '输入用户ID',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 8.h),
                              isDense: true,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        FilledButton(
                          onPressed: () => _blockUser(provider),
                          style: FilledButton.styleFrom(
                            backgroundColor: WpyTheme.of(context)
                                .get(WpyColorKey.dangerousRed),
                          ),
                          child: const Text('拉黑'),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color:
                        WpyTheme.of(context).get(WpyColorKey.lightBorderColor),
                  ),
                  if (blockList.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        '暂无拉黑用户 ✅',
                        style: TextUtil.base.regular.sp(14).secondary(context),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: blockList.map((id) {
                          return Chip(
                            avatar: Icon(
                              Icons.block,
                              size: 16.sp,
                              color: WpyTheme.of(context)
                                  .get(WpyColorKey.dangerousRed),
                            ),
                            label: Text(
                              '用户 $id',
                              style:
                                  TextUtil.base.regular.sp(13).label(context),
                            ),
                            deleteIcon: Icon(Icons.close, size: 16.sp),
                            onDeleted: () async {
                              final uid = int.tryParse(id.trim());
                              if (uid != null) {
                                final error = await provider.unblockUser(uid);
                                if (error != null && mounted) {
                                  ToastProvider.error(error);
                                }
                              }
                            },
                            backgroundColor: WpyTheme.of(context)
                                .get(WpyColorKey.secondaryBackgroundColor),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Text(
              title,
              style: TextUtil.base.bold.sp(16).label(context),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Future<void> _blockUser(PrivateChatProvider provider) async {
    final id = int.tryParse(_blockController.text.trim());
    if (id == null || id <= 0) {
      ToastProvider.error('请输入有效的用户ID');
      return;
    }
    final error = await provider.blockUser(id);
    if (error != null && mounted) {
      ToastProvider.error(error);
    } else {
      _blockController.clear();
      if (mounted) ToastProvider.success('拉黑成功');
    }
  }
}
