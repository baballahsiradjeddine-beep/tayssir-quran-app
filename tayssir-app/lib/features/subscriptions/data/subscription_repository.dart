import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tayssir/exceptions/app_exception.dart';
import 'package:tayssir/features/subscriptions/data/init_chargily_payment_dto.dart';
import 'package:tayssir/features/subscriptions/data/subscription_remote_data_source.dart';
import 'package:tayssir/features/subscriptions/data/upload_payement_proof_dto.dart';
import 'package:tayssir/providers/user/subscription_model.dart';

class SubscriptionRepository {
  final SubscriptionRemoteDataSource subscriptionRemoteDataSource;
  SubscriptionRepository(this.subscriptionRemoteDataSource);

  Future<void> subscribeWithCard(String cardNumber) async {
    await subscriptionRemoteDataSource.subscribeWithCard(cardNumber);
  }

  Future<void> subscribeWithPaper({
    required File file,
    required int subscriptionId,
    String? promotorCode,
    double? amount,
    int? charityCampaignId,
  }) async {
    try {
      final dto = UploadPaymentProofDto(
        attachment: file,
        subscriptionId: subscriptionId,
        promotorCode: promotorCode,
        amount: amount,
        charityCampaignId: charityCampaignId,
      );
      await subscriptionRemoteDataSource.subscribeWithPaper(
        dto: dto,
      );
    } catch (e, st) {
      throw AppException.fromDartException(e, st);
    }
  }

  Future<String> initChargilyPayment(
      int subscriptionId, String? promotorCode,
      {double? amount, int? charityCampaignId}) async {
    try {
      final dto = InitChargilyPaymentDto(
        subscriptionId: subscriptionId,
        promotorCode: promotorCode,
        amount: amount,
        charityCampaignId: charityCampaignId,
      );
      final response = await subscriptionRemoteDataSource.initChargilyPayment(
        dto,
      );
      log('chargily response: ${response.data}');
      return response.data['data']['checkout_url'];
    } catch (e, st) {
      throw AppException.fromDartException(e, st);
    }
  }

  Future<List<SubscriptionModel>> getSubscriptions() async {
    try {
      final response = await subscriptionRemoteDataSource.getSubscriptions();
      return response.data['data']
          .map<SubscriptionModel>((e) => SubscriptionModel.fromMap(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final subscriptionRemoteDataSource =
      ref.watch(subscriptionRemoteDataSourceProvider);
  return SubscriptionRepository(subscriptionRemoteDataSource);
});
