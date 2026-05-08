import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/resources/theme/design_system.dart';
import 'design_system_data_source.dart';

final designSystemRemoteProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dataSource = ref.watch(designSystemDataSourceProvider);
  final response = await dataSource.getDesignSystem();
  return response.data;
});

final designSystemProvider = Provider<DesignSystem>((ref) {
  final remoteData = ref.watch(designSystemRemoteProvider).valueOrNull;
  
  if (remoteData != null && remoteData['light'] != null) {
    return DesignSystem.fromJson(remoteData['light']);
  }
  return DesignSystem.quranicLight();
});

final darkDesignSystemProvider = Provider<DesignSystem>((ref) {
  final remoteData = ref.watch(designSystemRemoteProvider).valueOrNull;
  
  if (remoteData != null && remoteData['dark'] != null) {
    return DesignSystem.fromJson(remoteData['dark']);
  }
  return DesignSystem.quranicDark();
});
