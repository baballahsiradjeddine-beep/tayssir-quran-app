import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/app_buttons/big_button.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/common/data/configs.dart';
import 'package:tayssir/common/sliver_scrolling_widget.dart';
import 'package:tayssir/common/bayan_bubble_talk_widget.dart';
import 'package:tayssir/features/subscriptions/presentation/paper/upload_button.dart';
import 'package:tayssir/features/subscriptions/presentation/paper/upload_button_failure.dart';
import 'package:tayssir/features/subscriptions/presentation/paper/upload_button_successful.dart';
import 'package:tayssir/features/subscriptions/presentation/paper/upload_progress_button.dart';
import 'package:tayssir/features/subscriptions/presentation/state/paper/subscription_paper_controller.dart';
import 'package:tayssir/providers/user/subscription_model.dart';
import 'package:tayssir/router/app_router.dart';
import 'package:tayssir/services/actions/dialog_service.dart';
import 'package:tayssir/utils/enums/triangle_side.dart';
import 'package:tayssir/utils/extensions/async_value.dart';
import 'package:tayssir/common/bayan_background.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:flutter/services.dart';

enum UploadStatus { uploading, uploaded, error, none }

class SubscriptionPaperScreen extends HookConsumerWidget {
  const SubscriptionPaperScreen({super.key, required this.subscription, this.charityCampaignId});
  final SubscriptionModel subscription;
  final int? charityCampaignId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SubscriptionPaperView(subscription: subscription, charityCampaignId: charityCampaignId);
  }
}

class _SubscriptionPaperView extends HookConsumerWidget {
  const _SubscriptionPaperView({required this.subscription, this.charityCampaignId});
  final SubscriptionModel subscription;
  final int? charityCampaignId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = useState<UploadStatus>(UploadStatus.none);
    final progress = useState<double>(0);
    final file = useState<PlatformFile?>(null);
    final nameController = useTextEditingController();
    final promotorCodeController = useTextEditingController();
    final configs = ref.watch(configsProvider).valueOrNull;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(subscriptionPaperControllerProvider.select((v) => v.state), (prv, nxt) {
      nxt.handleSideThings(context, () {
        if (subscription.id == 999) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => DialogContent(
              title: "جزاك الله خيراً! 💚",
              subTitle: "تم استلام وصل التبرع الخاص بك بنجاح. سيتم مراجعته وإضافته لرصيد الحملة الجارية قريباً.",
              buttonText: "العودة للرئيسية",
              onPressed: () {
                context.goNamed(AppRoutes.home.name);
              },
            ),
          );
        } else {
          DialogService.showSubscriptionDoneDialog(context, () {
            context.goNamed(AppRoutes.home.name);
          });
        }
      }, shouldShowError: true);
    });

    pickFile() async {
      final result = await FilePicker.platform.pickFiles(type: FileType.any); 
      if (result != null) {
        file.value = result.files.single;
        if (file.value!.size > 10 * 1024 * 1024) {
          status.value = UploadStatus.error;
          return;
        }
        status.value = UploadStatus.uploading;
      }
    }

    Widget getStatusWidget({required UploadStatus uploadStatus, bool isDesktop = false}) {
      switch (uploadStatus) {
        case UploadStatus.none:
          return UploadButton(onTap: pickFile);
        case UploadStatus.uploading:
          return UploadProgressButton(
            current: progress.value,
            filename: file.value?.name ?? "",
            onStop: () {
              status.value = UploadStatus.none;
              file.value = null;
              progress.value = 0;
            },
          );
        case UploadStatus.uploaded:
          return UploadButtonSuccessful(
            filename: file.value?.name ?? "",
            fileSize: file.value?.size.toDouble() ?? 0,
          );
        case UploadStatus.error:
          return UploadButtonFailure(filename: file.value?.name ?? "", onTap: pickFile);
      }
    }

    useEffect(() {
      Timer? timer;
      if (status.value == UploadStatus.uploading) {
        timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
          if (progress.value < 100) {
            progress.value += 10;
          } else {
            status.value = UploadStatus.uploaded;
            timer.cancel();
          }
        });
      }
      return timer?.cancel;
    }, [status.value]);

    return BayanBackground(
      child: AppScaffold(
        paddingY: 0,
        paddingX: 0,
        includeBackButton: false,
        topSafeArea: true,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final isDesktop = availableWidth > 800;
            final double contentWidth = isDesktop ? 700 : availableWidth;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'التحويل البريدي (CCP)',
                            style: TextStyle(
                              fontSize: isDesktop ? 24.sp : 18.sp,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppColors.textBlack,
                              fontFamily: 'SomarSans',
                            ),
                          ),
                          _buildBackButton(context, isDark),
                        ],
                      ),
                    ).animate().fadeIn(),

                    Expanded(
                      child: SliverScrollingWidget(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Column(
                              children: [
                                20.verticalSpace,
                                
                                // Info Card
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(isDesktop ? 32.r : 24.r),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF10B981), Color(0xFF005B8C)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF10B981).withOpacity(0.3), 
                                        blurRadius: 30, 
                                        offset: const Offset(0, 10)
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'قم بالتحويل لهذا الحساب :',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9), 
                                          fontSize: isDesktop ? 16.sp : 13.sp, 
                                          fontWeight: FontWeight.bold, 
                                          fontFamily: 'SomarSans'
                                        ),
                                      ),
                                      12.verticalSpace,
                                      Text(
                                        '${subscription.price} دج',
                                        style: TextStyle(
                                          color: Colors.white, 
                                          fontSize: isDesktop ? 36.sp : 28.sp, 
                                          fontWeight: FontWeight.w900, 
                                          fontFamily: 'SomarSans'
                                        ),
                                      ),
                                      24.verticalSpace,
                                      Container(
                                        padding: EdgeInsets.all(20.r),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(16.r),
                                          border: Border.all(color: Colors.white.withOpacity(0.12)),
                                        ),
                                        child: Column(
                                          children: [
                                            _buildInfoRow("الإسم :", configs?.paymentName ?? 'SIRADJ EDDINE BABALLAH', isDesktop),
                                            20.verticalSpace,
                                            _buildInfoRow("الحساب (RIP) :", configs?.paymentNumber ?? '00799999002888539926', isDesktop, isRIP: true),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ).animate().scale(curve: Curves.easeOutBack),
                                
                                32.verticalSpace,
                                
                                // Upload Section
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'أرفق صورة وصل التحويل :',
                                      style: TextStyle(
                                        fontSize: isDesktop ? 20.sp : 16.sp, 
                                        fontWeight: FontWeight.w900, 
                                        color: isDark ? Colors.white : AppColors.textBlack, 
                                        fontFamily: 'SomarSans'
                                      ),
                                    ),
                                    20.verticalSpace,
                                    getStatusWidget(uploadStatus: status.value, isDesktop: isDesktop).animate().fadeIn(delay: 200.ms),
                                    24.verticalSpace,
                                    _buildPremiumInput(
                                      controller: nameController,
                                      hint: "الإسم واللقب الظاهر في الوصل",
                                      icon: Icons.person_rounded,
                                      isDark: isDark,
                                      isDesktop: isDesktop,
                                    ),
                                    if (subscription.id != 999) ...[
                                      20.verticalSpace,
                                      _buildPremiumInput(
                                        controller: promotorCodeController,
                                        hint: "كود المروج (اختياري)",
                                        icon: Icons.card_giftcard_rounded,
                                        isDark: isDark,
                                        isDesktop: isDesktop,
                                      ),
                                    ],
                                  ],
                                ),
                                
                                60.verticalSpace,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Bottom Button
                    Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
                      child: BigButton(
                        text: "تحقق من المعلومات وإرسال",
                        onPressed: status.value == UploadStatus.uploaded
                            ? () => ref.read(subscriptionPaperControllerProvider.notifier).subscribeWithPaper(
                                subscription: subscription,
                                promotorCode: promotorCodeController.text.isEmpty ? null : promotorCodeController.text,
                                file: File(file.value!.path!),
                                amount: subscription.price.toDouble(),
                                charityCampaignId: charityCampaignId,
                              )
                            : null,
                      ).animate().fadeIn(delay: 400.ms),
                    ),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        width: 48.sp,
        height: 48.sp,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
        ),
        child: Icon(Icons.arrow_forward_ios_rounded, color: isDark ? Colors.white : AppColors.textBlack, size: 20.sp),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDesktop, {bool isRIP = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: isDesktop ? 14.sp : 12.sp, fontWeight: FontWeight.bold)),
        6.verticalSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SelectableText(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isRIP ? (isDesktop ? 22.sp : 15.sp) : (isDesktop ? 18.sp : 13.sp),
                  fontWeight: FontWeight.w900,
                  letterSpacing: isRIP ? 1.5 : 0,
                  fontFamily: isRIP ? 'monospace' : 'SomarSans',
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.copy_rounded, color: Colors.white.withOpacity(0.6), size: isDesktop ? 24.sp : 20.sp),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPremiumInput({
    required TextEditingController controller, 
    required String hint, 
    required IconData icon,
    required bool isDark,
    required bool isDesktop,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textBlack, 
          fontWeight: FontWeight.bold, 
          fontSize: isDesktop ? 16.sp : 14.sp,
          fontFamily: 'SomarSans'
        ),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Icon(icon, color: const Color(0xFF10B981), size: isDesktop ? 24.sp : 20.sp),
          ),
          hintStyle: TextStyle(
            color: (isDark ? Colors.white : AppColors.textBlack).withOpacity(0.3), 
            fontSize: isDesktop ? 15.sp : 13.sp
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: isDesktop ? 20.h : 16.h),
        ),
      ),
    );
  }
}
