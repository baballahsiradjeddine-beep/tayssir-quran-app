import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tayssir/exceptions/app_exception.dart';
import 'package:tayssir/features/auth/data/auth_repository.dart';
import 'package:tayssir/features/auth/presentation/register/state/otp_type.dart';

import 'package:tayssir/providers/geo/country.dart';
import 'package:tayssir/providers/geo/region.dart';
import '../../../data/requests/register_request_model.dart';
import 'register_state.dart';

final registerControllerProvider =
    StateNotifierProvider<RegisterNotifier, RegisterState>((ref) {
  final authRepository = ref.watch(authRepoProvider);
  return RegisterNotifier(authRepository);
});

class RegisterNotifier extends StateNotifier<RegisterState> {
  RegisterNotifier(
    this.authRepository,
  ) : super(RegisterState.empty());

  final AuthRepository authRepository;
  Timer? _timer;

  void nextPage() {
    state.pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    state = state.copyWith(currentPage: state.currentPage + 1);
  }

  Future<bool> isPhoneNumberExists(String phoneNumber) async {
    return await authRepository.checkPhoneNumberExists(phoneNumber);
  }

  void setCredentials(String email, String password) async {
    state = state.setLoading();
    try {
      if ((await authRepository.checkEmailExists(email))) {
        state =
            state.setError(AppException(type: AppExceptionType.emailExists));
        return;
      }
    } catch (e, st) {
      state = state.setError(AppException.fromDartException(e, st));
    }
    state = state.setCredentials(
      email,
      password,
    );
    state = state.setData();
    // await sendOtpCode();
    nextPage();
  }

  Future<void> googleSignUp(String idToken, String name, String email) async {
    state = state.setLoading();
    try {
      if ((await authRepository.checkEmailExists(email))) {
        state =
            state.setError(AppException(type: AppExceptionType.emailExists));
        return;
      }
    } catch (e, st) {
      state = state.setError(AppException.fromDartException(e, st));
    }
    state = state.setIdToken(idToken);
    state = state.setUserName(name);

    state = state.setData();
    nextPage();
  }

  void _startTimer() {
    if (_timer != null && _timer!.isActive) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      tick();
    });
  }

  void tick() {
    if (state.canResend) {
      stop();
    } else {
      state = state.decrementRemainingTime();
    }
  }

  void clearError() {
    state = state.setData();
  }

  void stop() {
    _timer?.cancel();
  }

  void reset() {
    stop();
    state = state.copyWith(verifyState: state.verifyState.resetTimer());
    // _startTimer();
  }

  Future<void> sendOtpCode({OtpType otpType = OtpType.email}) async {
    try {
      if (state.isLoading) return;
      state = state.setLoading();
      if (otpType == OtpType.email) {
        await authRepository.sendEmailOtpCode(state.userData.email);
      } else {
        // await authRepository.sendPhoneOtpCode(state.userData.phoneNumber);
      }
      state = state.setData();
      _startTimer();
    } catch (e, st) {
      state = state.setError(
        AppException.fromDartException(e, st),
      );
    }
  }

  void verifyOtp(String pin, OtpType otpType) async {
    try {
      if (state.isLoading) return;
      state = state.setLoading();
      if (otpType == OtpType.email) {
        await authRepository.verifyEmailOtpCode(state.userData.email, pin);
      } else {
        // await authRepository.verifyPhoneOtpCode(state.userData.phoneNumber, pin);
      }
      state = state.setData();
      stop();
      nextPage();
    } catch (e, st) {
      state = state.setError(
        AppException.fromDartException(e, st),
      );
    }
  }

  void resetOtpOption({OtpType otpType = OtpType.email}) async {
    stop();
    if (otpType == OtpType.email) {
      state = state.copyWith(
        verifyState: state.verifyState.resetTimer(),
        userData: UserData.empty(),
      );
    } else {
      state = state.copyWith(
        verifyState: state.verifyState.resetTimer(),
        userData: state.userData.copyWith(phoneNumber: ''),
      );
    }
    prevPage();
  }

  void resendOtpCode({
    OtpType otpType = OtpType.email,
  }) async {
    if (!state.canResend) return;
    reset();
    await sendOtpCode(otpType: otpType);
  }

  void setUserData(String name, int age, String phoneNumber, Country country,
      Region region, int filliere) async {
    try {
      print('📝 REGISTER_CONTROLLER: setUserData started');
      state = state.setLoading();
      
      // Prepend phone code if not already present
      String fullPhoneNumber = phoneNumber;
      if (!phoneNumber.startsWith('+')) {
        final code = country.phoneCode?.replaceAll('+', '') ?? '';
        // Strip leading zero from national number if it exists
        String cleanNumber = phoneNumber;
        if (cleanNumber.startsWith('0')) {
          cleanNumber = cleanNumber.substring(1);
        }
        fullPhoneNumber = '+$code$cleanNumber';
      }

      print('📝 REGISTER_CONTROLLER: Checking if phone exists: $fullPhoneNumber');
      final exists = await isPhoneNumberExists(fullPhoneNumber);
      print('📝 REGISTER_CONTROLLER: Phone exists: $exists');

      if (exists) {
        state = state.setError(
          AppException(type: AppExceptionType.phoneExists),
        );
        return;
      }

      print('📝 REGISTER_CONTROLLER: Setting user data in state');
      state = state.setUserData(name, age, fullPhoneNumber, country, region, filliere);

      state = state.setData();
      print('📝 REGISTER_CONTROLLER: Moving to next page');
      nextPage();
    } catch (e, st) {
      print('❌ REGISTER_CONTROLLER: Error in setUserData: $e');
      print(st);
      state = state.setError(AppException.fromDartException(e, st));
    }
  }

  Future<void> setKnowOption(int knowOption) async {
    state = state.setKnowOption(knowOption);
    // await fullRegister();
    nextPage();
  }

  Future<void> fullRegister() async {
    if (state.isLoading) return;

    state = state.setLoading();
    try {
      if (state.isGoogleSignUp) {
        await _handleGoogleSignUp();
      } else {
        await _handleEmailSignUp();
      }

      state = state.setData();
      // REMOVED: nextPage() - Let the auth status listener handle navigation 
    } catch (e, st) {
      state = state.setError(
        AppException.fromDartException(e, st),
      );
    }
  }

  Future<void> _handleGoogleSignUp() async {
    final model = GoogleSignUpRequest(
      idToken: state.userData.idToken!,
      name: state.userData.fullName,
      phoneNumber: state.userData.phoneNumber,
      age: state.userData.age,
      countryId: state.userData.country?.id,
      regionId: state.userData.region?.id,
      divisionId: state.userData.filliere,
      referralSourceId: state.userData.knowOption,
    );
    await authRepository.signUpGoogle(model);
  }

  Future<void> _handleEmailSignUp() async {
    final model = CreateAccountRequestModel(
      email: state.userData.email,
      password: state.userData.password,
      fullName: state.userData.fullName,
      phoneNumber: state.userData.phoneNumber,
      age: state.userData.age,
      countryId: state.userData.country?.id,
      regionId: state.userData.region?.id,
      filliere: state.userData.filliere,
      knowOption: state.userData.knowOption,
    );
    await authRepository.register(model);
  }

  // payment stuff
  // void setPaymentMethod(
  // PayementMethod paymentMethod,
  // ) {
  // state = state.setPaymentMethod(paymentMethod);
  // nextPage();
  // }
  // //TODO: seperate it into another controller and  pay throught that
  // // pay with card
  // void payWithCard() {
  //   state = state.setLoading();
  //   // state = state.setData();
  //   // nextPage();
  // }

  // // pay with baridi mob
  // void payWithBaridiMob() {
  //   state = state.setLoading();
  //   // state = state.setData();
  //   // nextPage();
  // }

  void prevPage() {
    state.pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    state = state.copyWith(currentPage: state.currentPage - 1);
  }

  @override
  void dispose() {
    state.pageController.dispose();
    super.dispose();
  }
}
