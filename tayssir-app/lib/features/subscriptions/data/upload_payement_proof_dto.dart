import 'dart:io';

class UploadPaymentProofDto {
  final int subscriptionId;
  final String? promotorCode;
  final File attachment;
  final double? amount;
  final int? charityCampaignId;

  UploadPaymentProofDto({
    required this.subscriptionId,
    this.promotorCode,
    required this.attachment,
    this.amount,
    this.charityCampaignId,
  });

  Map<String, dynamic> toJson() {
    return {
      'subscription_id': subscriptionId,
      'promocode': promotorCode,
      if (amount != null) 'amount': amount,
      if (charityCampaignId != null) 'charity_campaign_id': charityCampaignId,
    };
  }
}
