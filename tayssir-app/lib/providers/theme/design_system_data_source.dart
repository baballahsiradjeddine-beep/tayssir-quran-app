import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tayssir/constants/end_points.dart';
import 'package:tayssir/providers/dio/dio.dart';

class DesignSystemDataSource {
  final DioClient dioClient;

  DesignSystemDataSource({required this.dioClient});

  Future<Response> getDesignSystem() async {
    return await dioClient.get(EndPoints.designSystem);
  }
}

final designSystemDataSourceProvider = Provider<DesignSystemDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DesignSystemDataSource(dioClient: dioClient);
});
