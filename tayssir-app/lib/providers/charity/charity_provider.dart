import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/providers/data/models/charity_model.dart';
import 'package:tayssir/providers/dio/dio.dart';

final charityCampaignsProvider = FutureProvider<List<CharityCampaign>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('v2/charity/campaigns');
    if (response.data['success'] == true) {
      final List data = response.data['data'];
      return data.map((json) => CharityCampaign.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    if (kDebugMode) {
      print('⛔ Error fetching charity campaigns: $e');
    }
    return [];
  }
});
