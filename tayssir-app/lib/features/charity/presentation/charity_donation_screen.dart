import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tayssir/common/bayan_background.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/common/core/custom_app_bar.dart';
import 'package:tayssir/providers/data/models/charity_model.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/router/app_router.dart';
import 'package:tayssir/providers/user/subscription_model.dart';
import 'package:tayssir/providers/charity/charity_provider.dart';

class CharityDonationScreen extends ConsumerStatefulWidget {
  final CharityCampaign? initialCampaign;
  const CharityDonationScreen({super.key, this.initialCampaign});

  @override
  ConsumerState<CharityDonationScreen> createState() => _CharityDonationScreenState();
}

class _CharityDonationScreenState extends ConsumerState<CharityDonationScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String selectedQuickAmount = '';
  bool showCompleted = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showPaymentMethodBottomSheet(BuildContext context, int amount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
                24.verticalSpace,
                Text(
                  "اختر طريقة الدفع",
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black, fontFamily: 'SomarSans'),
                ),
                8.verticalSpace,
                Text(
                  "مبلغ التبرع: $amount دج لصالح سهم الخير",
                  style: TextStyle(fontSize: 14.sp, color: isDark ? AppColors.primaryColor : AppColors.warmAccent, fontWeight: FontWeight.bold, fontFamily: 'SomarSans'),
                ),
                24.verticalSpace,
                _buildPaymentOption(
                  context: context,
                  title: 'البطاقة الذهبية / CIB',
                  subtitle: 'دفع إلكتروني فوري وآمن',
                  icon: Icons.credit_card_rounded,
                  color: isDark ? const Color(0xFF10B981) : AppColors.warmAccent,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    final sub = SubscriptionModel(id: 999, name: 'تبرع سهم الخير', description: 'صدقة جارية', price: amount, endingDate: null);
                    context.pushNamed(AppRoutes.chargilyInit.name, extra: {
                      'subscription': sub,
                      'charity_campaign_id': null,
                    });
                  },
                ),
                12.verticalSpace,
                _buildPaymentOption(
                  context: context,
                  title: 'بريدي موب / CCP',
                  subtitle: 'تحويل بنكي مع إرفاق الوصل',
                  icon: Icons.account_balance_rounded,
                  color: const Color(0xFF3B82F6),
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    final sub = SubscriptionModel(id: 999, name: 'تبرع سهم الخير', description: 'صدقة جارية', price: amount, endingDate: null);
                    context.pushNamed(AppRoutes.subscriptionPaper.name, extra: {
                      'subscription': sub,
                      'charity_campaign_id': null,
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            16.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, fontFamily: 'SomarSans')),
                  4.verticalSpace,
                  Text(subtitle, style: TextStyle(fontSize: 12.sp, color: isDark ? Colors.white.withOpacity(0.5) : Colors.black54, fontFamily: 'SomarSans')),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white.withOpacity(0.2) : Colors.black26),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final charityState = ref.watch(charityCampaignsProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final screenW = MediaQuery.of(context).size.width;
    final bool isDesktop = screenW > 950;
    final double outerPadding = isDesktop ? 60.w : 24.w;

    return BayanBackground(
      child: AppScaffold(
        bodyBackgroundColor: isDark ? null : AppColors.warmBackground,
        topSafeArea: false,
        paddingX: 0,
        paddingY: 0,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 8.h, left: outerPadding, right: outerPadding),
                child: const CustomAppBar(
                  showLogo: true,
                  showActions: true,
                  reverse: true,
                ),
              ),
            ),

            // 2. Row of Message + Donation Card (Desktop only)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: outerPadding, vertical: 12.h),
                child: isDesktop 
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: _buildSpiritualCard(isDark)),
                        20.horizontalSpace,
                        Expanded(flex: 5, child: _buildDonationInputCard(isDark)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildSpiritualCard(isDark),
                        16.verticalSpace,
                        _buildDonationInputCard(isDark),
                      ],
                    ),
              ),
            ),

            // 4. Compact Search & Tabs
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: outerPadding, vertical: 8.h),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 42.h,
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.04) : AppColors.warmBorder.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12.r),
                            border: isDark ? null : Border.all(color: AppColors.warmBorder.withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildMiniTab(title: 'الجارية', active: !showCompleted, onTap: () => setState(() => showCompleted = false)),
                              _buildMiniTab(title: 'المنتهية', active: showCompleted, onTap: () => setState(() => showCompleted = true)),
                            ],
                          ),
                        ),
                        10.horizontalSpace,
                        Expanded(
                          child: Container(
                            height: 42.h,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: isDark ? null : Border.all(color: AppColors.warmBorder),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search_rounded, color: isDark ? Colors.white.withOpacity(0.2) : AppColors.warmSubtitle, size: 18.sp),
                                8.horizontalSpace,
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    style: TextStyle(color: isDark ? Colors.white : AppColors.warmTitle, fontSize: 13.sp),
                                    decoration: InputDecoration(
                                      hintText: 'ابحث عن مشروع...',
                                      hintStyle: TextStyle(color: isDark ? Colors.white.withOpacity(0.2) : AppColors.warmSubtitle.withOpacity(0.5), fontSize: 12.sp),
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    16.verticalSpace,
                  ],
                ),
              ),
            ),

            // 5. Campaigns List
            charityState.when(
              data: (campaigns) {
                final filtered = campaigns.where((c) {
                  final matchesStatus = showCompleted ? c.isCompleted : !c.isCompleted;
                  final matchesSearch = c.title.contains(_searchController.text);
                  return matchesStatus && matchesSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      child: Text('لا توجد مشاريع مطابقة', style: TextStyle(color: isDark ? Colors.white24 : AppColors.warmSubtitle, fontSize: 14.sp)),
                    )),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: outerPadding),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _buildCampaignCard(context, filtered[index], isDark),
                        ).animate().fadeIn(delay: (100 + index * 50).ms).slideY(begin: 0.05, end: 0);
                      },
                      childCount: filtered.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
              error: (err, stack) => const SliverToBoxAdapter(child: Center(child: Text('خطأ في تحميل المشاريع'))),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
        
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(left: outerPadding, right: outerPadding, bottom: 24.w, top: 12.w),
          child: GestureDetector(
            onTap: () {
              final amount = int.tryParse(_amountController.text) ?? 0;
              if (amount > 0) {
                _showPaymentMethodBottomSheet(context, amount);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('يرجى إدخال مبلغ التبرع أولاً', style: TextStyle(fontFamily: 'SomarSans', fontSize: 14.sp)),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  )
                );
              }
            },
            child: Container(
              height: 54.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                    ? [const Color(0xFF10B981), const Color(0xFF059669)]
                    : [const Color(0xFF7C4A27), const Color(0xFF5D361B)],
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? const Color(0xFF10B981) : const Color(0xFF7C4A27)).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Center(
                child: Text("تأكيد والمتابعة للدفع ✨", style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900, fontFamily: 'SomarSans')),
              ),
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5, end: 0),
        ),
      ),
    );
  }

  Widget _buildSpiritualCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [const Color(0xFF1E293B).withOpacity(0.5), const Color(0xFF0F172A).withOpacity(0.5)]
            : [AppColors.goldColor.withOpacity(0.1), AppColors.warmAccent.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : AppColors.goldColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.volunteer_activism_rounded,
            color: isDark ? AppColors.primaryColor : AppColors.warmAccent,
            size: 32.sp,
          ),
          12.verticalSpace,
          Text(
            " { وَتَعَاوَنُوا عَلَى الْبِرِّ وَالتَّقْوَىٰ } ",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.primaryColor : AppColors.warmAccent,
              fontFamily: 'UthmanicHafs',
            ),
          ),
          10.verticalSpace,
          Text(
            "نطلق حملاتنا الخيرية لتكون صدقةً جارية وذخراً لكم. تذكر أن أثر تبرعك، مهما كان بسيطاً، يتعاظم حين يجتمع مع مساهمات الكثيرين ليصنع فرجاً وتغييراً حقيقياً في حياة الآخرين.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.6,
              color: isDark ? Colors.white.withOpacity(0.7) : AppColors.warmTitle.withOpacity(0.8),
              fontFamily: 'SomarSans',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDonationInputCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : AppColors.warmBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "حدد مبلغ التبرع لسهم الخير :",
            style: TextStyle(
              fontSize: 16.sp, 
              fontWeight: FontWeight.bold, 
              color: isDark ? Colors.white.withOpacity(0.9) : AppColors.warmTitle, 
              fontFamily: 'SomarSans',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          12.verticalSpace,
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: isDark ? AppColors.primaryColor : AppColors.warmAccent, fontSize: 36.sp, fontWeight: FontWeight.w900, fontFamily: 'SomarSans'),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: isDark ? Colors.white.withOpacity(0.1) : AppColors.warmBorder, fontSize: 36.sp),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (v) => setState(() => selectedQuickAmount = ''),
                ),
              ),
              Text("دج", style: TextStyle(color: isDark ? Colors.white.withOpacity(0.4) : AppColors.warmSubtitle, fontSize: 18.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1), height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['500', '1000', '2000', '5000'].map((amount) {
              final bool isSelected = selectedQuickAmount == amount;
              return GestureDetector(
                onTap: () => setState(() { selectedQuickAmount = amount; _amountController.text = amount; }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? (isDark ? AppColors.primaryColor : AppColors.warmAccent) : (isDark ? Colors.white.withOpacity(0.05) : AppColors.warmBorder.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: isSelected ? (isDark ? AppColors.primaryColor : AppColors.warmAccent) : (isDark ? Colors.transparent : AppColors.warmBorder)),
                  ),
                  child: Text(amount, style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white.withOpacity(0.7) : AppColors.warmTitle), fontSize: 13.sp, fontWeight: FontWeight.bold)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05, end: 0);
  }

  Widget _buildMiniTab({required String title, required bool active, required VoidCallback onTap}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: active ? (isDark ? AppColors.primaryColor : AppColors.warmAccent) : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: active ? Colors.white : (isDark ? Colors.white.withOpacity(0.4) : AppColors.warmSubtitle),
              fontWeight: active ? FontWeight.w900 : FontWeight.bold,
              fontSize: 12.sp,
              fontFamily: 'SomarSans',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignCard(BuildContext context, CharityCampaign campaign, bool isDark) {
    return GestureDetector(
      onTap: () => context.pushNamed(AppRoutes.charityDetail.name, extra: {'campaign': campaign}),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.06) : AppColors.warmBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: campaign.themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(campaign.mainImageUrl), 
                  fit: BoxFit.cover
                ),
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(campaign.title, style: TextStyle(color: isDark ? Colors.white : AppColors.warmTitle, fontSize: 14.sp, fontWeight: FontWeight.bold, fontFamily: 'SomarSans')),
                  2.verticalSpace,
                  Text(
                    campaign.isCompleted ? 'تم الإكمال بنجاح ✅' : 'النسبة المنجزة ${ (campaign.progress * 100).toInt()}%',
                    style: TextStyle(
                      color: campaign.isCompleted 
                          ? (isDark ? const Color(0xFF10B981) : const Color(0xFF166534)) 
                          : (isDark ? Colors.white.withOpacity(0.4) : AppColors.warmSubtitle), 
                      fontSize: 11.sp, 
                      fontFamily: 'SomarSans',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white.withOpacity(0.3) : AppColors.warmSubtitle, size: 24.sp),
          ],
        ),
      ),
    );
  }
}
