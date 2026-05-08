import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tayssir/router/app_router.dart';
import 'package:tayssir/features/challanges/presentation/widgets/challenge_mode_landing.dart';
import 'package:tayssir/providers/auth/auth_notifier.dart';
import 'package:tayssir/utils/enums/auth_state.dart';
import 'package:tayssir/services/actions/dialog_service.dart';

class ChallengesScreen extends HookConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authNotifierProvider).status;
    final isGuest = authStatus == AuthStatus.unauthenticated || authStatus == AuthStatus.unknown;

    return Scaffold(
      body: ChallengeModeLanding(
        key: const ValueKey("landing"),
        onEnterMode: () {
          if (isGuest) {
            DialogService.showNeedLoginDialog(context);
          } else {
            // Push to the newly created dashboard route which is outside of the bottom nav scope
            context.pushNamed(AppRoutes.challengeDashboard.name);
          }
        },
      ),
    );
  }
}
