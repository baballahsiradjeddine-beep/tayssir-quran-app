class InitChargilyPaymentDto {
  final int subscriptionId;
  final String? promotorCode;
  final double? amount;
  final int? charityCampaignId;

  InitChargilyPaymentDto({
    required this.subscriptionId,
    this.promotorCode,
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
