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

enum UploadStatus { uploading, uploaded, error, none }

class SubscriptionPaperScreen extends HookConsumerWidget {
  const SubscriptionPaperScreen({super.key, required this.subscription});
  final SubscriptionModel subscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SubscriptionPaperView(subscription: subscription);
  }
}

class _SubscriptionPaperView extends HookConsumerWidget {
  const _SubscriptionPaperView({required this.subscription});
  final SubscriptionModel subscription;

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
        DialogService.showSubscriptionDialog(context, () {
          context.goNamed(AppRoutes.home.name);
        }, SubscrptionStatus.pending);
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

    Widget getStatusWidget({required UploadStatus uploadStatus}) {
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

    return AppScaffold(
      paddingY: 0,
      paddingX: 0,
      includeBackButton: false,
      topSafeArea: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final isDesktop = availableWidth > 800;
          const double targetContentWidth = 1050;

          final double horizontalPadding = isDesktop 
              ? (availableWidth > targetContentWidth + 160 ? (availableWidth - targetContentWidth) / 2 : 80.0)
              : 20.w;

          return Column(
            children: [
              // Custom Managed AppBar
              Padding(
                padding: EdgeInsets.fromLTRB(horizontalPadding, 12.h, horizontalPadding, 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'SomarSans',
                        ),
                        children: [
                          TextSpan(
                            text: "بيان ",
                            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
                          ),
                          const TextSpan(
                            text: "القرآن",
                            style: TextStyle(color: Color(0xFF10B981)),
                          ),
                        ],
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
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        children: [
                          20.verticalSpace,
                          
                          // Dolphin & Speech Bubble
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "📖",
                                style: TextStyle(fontSize: 70.sp),
                              ).animate(onPlay: (c) => c.repeat(reverse: true))
                               .moveY(begin: 0, end: -6, duration: 4.seconds, curve: Curves.easeInOutSine),
                              
                              8.horizontalSpace,
                              
                              SizedBox(
                                width: isDesktop ? 300.w : 180.w,
                                child: const BayanBubbleTalkWidget(
                                  text: "أحسنت الإختيار! بيان القرآن رفيقك نحو الحفظ 😉",
                                  triangleSide: TriangleSide.right,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 100.ms),
                          
                          20.verticalSpace,
                          
                          // Virtual Card with RIP
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(24.r),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF10B981), Color(0xFF005B8C)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withOpacity(0.35),
                                    blurRadius: 25,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: -50,
                                    left: -50,
                                    child: Container(
                                      width: 200,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: [Colors.white.withOpacity(0.15), Colors.transparent],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'قم بالدفع لهذا الحساب',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'SomarSans',
                                        ),
                                      ),
                                      8.verticalSpace,
                                      Text(
                                        '${subscription.realPrice} دج',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28.sp,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'SomarSans',
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      24.verticalSpace,
                                      Container(
                                        padding: EdgeInsets.all(20.r),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(16.r),
                                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                                        ),
                                        child: Column(
                                          children: [
                                            _buildInfoRow("الإسم :", configs?.paymentName ?? 'SIRADJ EDDINE BABALLAH', isDark, isName: true),
                                            16.verticalSpace,
                                            _buildInfoRow("الحساب (RIP) :", configs?.paymentNumber ?? '00799999002888539926', isDark, isRIP: true),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(delay: 200.ms).scale(curve: Curves.easeOutBack),
                          
                          32.verticalSpace,
                          
                          // Form Section
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'إكمال عملية الدفع :',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                                    fontFamily: 'SomarSans',
                                  ),
                                ),
                                16.verticalSpace,
                                
                                getStatusWidget(uploadStatus: status.value).animate().fadeIn(delay: 300.ms),
                                
                                16.verticalSpace,
                                
                                _buildPremiumInput(
                                  controller: nameController,
                                  hint: "الإسم واللقب",
                                  icon: Icons.person_rounded,
                                  isDark: isDark,
                                ).animate().fadeIn(delay: 400.ms),
                                
                                16.verticalSpace,
                                
                                _buildPremiumInput(
                                  controller: promotorCodeController,
                                  hint: "كود المروج (اختياري)",
                                  icon: Icons.card_giftcard_rounded,
                                  isDark: isDark,
                                ).animate().fadeIn(delay: 500.ms),
                              ],
                            ),
                          ),
                          
                          40.verticalSpace,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Fixed Bottom Action
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      top: 12.r,
                      bottom: 32.r,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A).withOpacity(0.9) : Colors.white.withOpacity(0.9),
                      border: Border(top: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9))),
                    ),
                    child: BigButton(
                      text: "تحقق من المعلومات",
                      onPressed: status.value == UploadStatus.uploaded
                          ? () => ref.read(subscriptionPaperControllerProvider.notifier).subscribeWithPaper(
                              subscription: subscription,
                              promotorCode: promotorCodeController.text.isEmpty ? null : promotorCodeController.text,
                              file: File(file.value!.path!),
                            )
                          : null,
                    ).animate().fadeIn(delay: 700.ms).scale(curve: Curves.easeOutBack),
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDark) {
    return IconButton(
      onPressed: () => context.pop(),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Container(
        width: 44.sp,
        height: 44.sp,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Icon(
          Icons.arrow_forward_ios_rounded,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
          size: 18.sp,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark, {bool isRIP = false, bool isName = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13.sp, fontWeight: FontWeight.bold),
        ),
        8.verticalSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SelectableText(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isRIP ? 16.sp : 14.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: isRIP ? 1.5 : 0,
                  fontFamily: isRIP ? 'monospace' : 'SomarSans',
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.copy_rounded, color: Colors.white.withOpacity(0.7), size: 20.sp),
              onPressed: () {
                // Clipboard logic logic here
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1E293B),
          fontWeight: FontWeight.bold,
          fontFamily: 'SomarSans',
        ),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF10B981)),
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.bold,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        ),
      ),
    );
  }
}
