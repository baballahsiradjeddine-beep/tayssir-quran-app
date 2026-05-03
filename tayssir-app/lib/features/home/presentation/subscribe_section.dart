import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/app_buttons/subscribe_button.dart';
import 'package:tayssir/features/home/data/banners/banner_repository.dart';
import 'package:tayssir/features/home/presentation/banner_model.dart';
import 'package:tayssir/features/home/presentation/banner_widget.dart';
import 'package:tayssir/features/home/presentation/user_progress_widget.dart';
import 'package:tayssir/providers/user/user_notifier.dart';
import 'package:carousel_slider/carousel_slider.dart';

final bannerItemsProvider = FutureProvider<List<BannerModel>>((ref) async {
  // Don't fetch banners if user is not authenticated (guest/tour mode)
  final user = ref.watch(userNotifierProvider).valueOrNull;
  if (user == null) return [];

  final res = await ref.watch(bannerRepositoryProvider).getBanners();
  return res;
});

class SubscribeSection extends ConsumerStatefulWidget {
  final bool showProgress;
  const SubscribeSection({super.key, this.showProgress = true});

  @override
  ConsumerState<SubscribeSection> createState() => _SubscribeSectionState();
}

class _SubscribeSectionState extends ConsumerState<SubscribeSection> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _scheduleNext();
  }

  void _scheduleNext() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      final count = _getItemCount();
      if (count > 1 && _pageController.hasClients) {
        final next = (_currentIndex + 1) % count;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
      _scheduleNext();
    });
  }

  int _getItemCount() {
    final bannerAsync = ref.read(bannerItemsProvider);
    final user = ref.read(userNotifierProvider).valueOrNull;
    int count = 0;
    if (user?.isSub != true) count++;
    count += bannerAsync.valueOrNull?.length ?? 0;
    if (widget.showProgress) count++;
    return count;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannerAsync = ref.watch(bannerItemsProvider);
    final user = ref.watch(userNotifierProvider).valueOrNull;
    final isLoading = bannerAsync.isLoading;

    final List<Widget> items = [
      if (user?.isSub != true)
        const SubscribeButton(key: ValueKey('subscribe')),
      if (!isLoading)
        ...bannerAsync.valueOrNull?.asMap().entries.map((e) {
          final banner = e.value;
          return BannerWidget(
            key: ValueKey('banner_${e.key}'),
            title: banner.title,
            description: banner.description,
            actionUrl: banner.actionUrl,
            gradientStart: banner.gradientStart,
            gradientEnd: banner.gradientEnd,
            image: banner.image,
            desktopImage: banner.desktopImage,
          );
        }) ?? [],
      if (widget.showProgress)
        const UserProgressWidget(key: ValueKey('progress')),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return ClipRect(
      child: SizedBox(
        height: 135.h,
        child: PageView.builder(
          controller: _pageController,
          clipBehavior: Clip.hardEdge,
          itemCount: items.length,
          onPageChanged: (i) {
            if (mounted) setState(() => _currentIndex = i);
          },
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: items[index],
          ),
        ),
      ),
    );
  }
}

class SliderIndicator extends StatelessWidget {
  const SliderIndicator(
      {super.key,
      required this.itemsCount,
      required this.itemIndex,
      required this.selectedChild,
      required this.unselectedChild});
  final int itemsCount;
  final int itemIndex;
  final Widget selectedChild;
  final Widget unselectedChild;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Keep indicators compact
      children: [
        ...List.generate(itemsCount, (index) {
          bool isSelected = index == itemIndex;

          return isSelected ? selectedChild : unselectedChild;
        })
      ],
    );
  }
}
