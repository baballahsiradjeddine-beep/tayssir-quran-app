import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/forms/drop_down/taysir_drop_down.dart';
import 'package:tayssir/providers/geo/region.dart';
import 'package:tayssir/resources/resources.dart';

class TayssirRegionDropDown extends ConsumerWidget {
  const TayssirRegionDropDown({
    super.key,
    required this.region,
    required this.regions,
  });

  final ValueNotifier<Region?> region;
  final List<Region> regions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TayssirDropDown<Region>(
      selectedItem: region.value,
      items: regions,
      onChanged: (value) {
        region.value = value;
      },
      hintText: "المنطقة / الولاية",
      iconPath: SVGs.icBuilding,
    );
  }
}
