import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/forms/drop_down/taysir_drop_down.dart';
import 'package:tayssir/providers/geo/country.dart';
import 'package:tayssir/providers/geo/region.dart';
import 'package:tayssir/resources/resources.dart';
import 'package:tayssir/services/geo/geo_service.dart';

class TayssirCountryDropDown extends ConsumerWidget {
  const TayssirCountryDropDown({
    super.key,
    required this.country,
    required this.countries,
    required this.region,
  });

  final ValueNotifier<Country?> country;
  final List<Country> countries;
  final ValueNotifier<Region?> region;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TayssirDropDown<Country>(
      selectedItem: country.value,
      items: ref.watch(countriesProvider).isLoading ? [] : countries,
      onChanged: (value) {
        if (value == country.value) return;
        region.value = null;
        country.value = value;
      },
      hintText: "البلد",
      iconPath: SVGs.icBuilding, // We can change this later if we have a flag icon
    );
  }
}
