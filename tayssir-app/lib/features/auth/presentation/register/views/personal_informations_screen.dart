import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/app_buttons/big_button.dart';
import 'package:tayssir/common/sliver_scrolling_widget.dart';
import 'package:tayssir/common/tayssir_country_drop_down.dart';
import 'package:tayssir/common/tayssir_region_drop_down.dart';
import 'package:tayssir/common/tayssir_speciality_drop_down.dart';
import 'package:tayssir/features/auth/presentation/register/state/register_controller.dart';
import 'package:tayssir/features/onboarding/onboarding_notifier.dart';
import 'package:tayssir/providers/divisions/division_model.dart';
import 'package:tayssir/providers/divisions/divisions.dart';
import 'package:tayssir/providers/geo/country.dart';
import 'package:tayssir/providers/geo/region.dart';
import 'package:tayssir/services/geo/geo_service.dart';
import 'package:tayssir/services/actions/snack_bar_service.dart';
import '../../../../../common/core/app_scaffold.dart';
import '../../../../../constants/strings.dart';
import '../../../../../utils/validators.dart';
import '../../login/custom_text_form_field.dart';
import '../../../../../common/bayan_advice_widget.dart';
import '../../common/header_text.dart';

class PersonalInformationsView extends HookConsumerWidget {
  const PersonalInformationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerController = ref.watch(registerControllerProvider);
    final nameController = useTextEditingController(text: registerController.userData.fullName);
    final ageController = useTextEditingController();
    final phoneController = useTextEditingController();
    final countriesAsync = ref.watch(countriesProvider);
    final divisionsAsync = ref.watch(divisionsProvider);

    if (countriesAsync.isLoading || divisionsAsync.isLoading) {
      return const AppScaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
      );
    }
    
    final countries = countriesAsync.valueOrNull ?? [];
    if (countries.isEmpty) { return const AppScaffold(body: Center(child: Text("Error: No data available"))); }
    
    final specialityValue = divisionsAsync.valueOrNull;
    if (specialityValue == null) { return const AppScaffold(body: Center(child: Text("Error: Divisions not loaded"))); }

    final country = useState<Country?>(countries.isNotEmpty ? countries.firstWhere((c) => c.code == 'DZ', orElse: () => countries.first) : null);
    final regions = country.value != null ? (ref.watch(regionsProvider(country.value!.id)).asData?.value ?? []) : <Region>[];
    final region = useState<Region?>(null);
    final speciality = useState<DivisionModel?>(null);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    
    // Auto-listen to controllers and state to trigger rebuilds for button validation
    useListenable(nameController);
    useListenable(ageController);
    useListenable(phoneController);
    useListenable(country);
    useListenable(region);
    useListenable(speciality);

    final canSubmit = nameController.text.isNotEmpty &&
        ageController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        country.value != null &&
        region.value != null &&
        speciality.value != null;

    return AppScaffold(
      paddingB: 0,
      bodyBackgroundColor: Colors.transparent,
      body: Form(
        key: formKey,
        child: SliverScrollingWidget(
          children: [
            24.verticalSpace,
            const HeaderText(text: "المعومات الشخصية")
                .animate().fadeIn().slideY(begin: -0.1, end: 0),
            
            32.verticalSpace,
            
            const BayanAdviceWidget(
              text: "قم بإدخال المعلومات الشخصية الخاصة بك",
              isHorizontal: false,
            ).animate().fadeIn(delay: 100.ms).scale(curve: Curves.easeOutBack),
            
            40.verticalSpace,
            
            Builder(
              builder: (context) {
                final isDesktop = MediaQuery.sizeOf(context).width > 600;
                
                final rightFields = [
                  CustomTextFormField(
                    controller: nameController,
                    labelText: AppStrings.name,
                    hintText: "الاسم الكامل",
                    prefix: const Icon(Icons.person_outline_rounded),
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
                  
                  isDesktop ? 30.verticalSpace : 20.verticalSpace,
                  
                  CustomTextFormField(
                    controller: ageController,
                    labelText: AppStrings.age,
                    hintText: "مثلاً: 18",
                    keyboardType: TextInputType.number,
                    prefix: const Icon(Icons.cake_outlined),
                    validator: Validators.validateAge,
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),
                  
                  isDesktop ? 30.verticalSpace : 20.verticalSpace,
                  
                  CustomTextFormField(
                    controller: phoneController,
                    labelText: AppStrings.phoneNumber,
                    hintText: "06 / 07 / 05 ...",
                    keyboardType: TextInputType.phone,
                    prefix: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone_outlined, size: 20),
                        4.horizontalSpace,
                        if (country.value?.phoneCode != null) ...[
                          Text(
                            country.value!.phoneCode!.startsWith('+') 
                                ? country.value!.phoneCode! 
                                : '+${country.value!.phoneCode!}',
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          4.horizontalSpace,
                          Container(
                            width: 1,
                            height: 20.h,
                            color: Colors.white24,
                          ),
                          8.horizontalSpace,
                        ],
                      ],
                    ),
                    validator: Validators.phone,
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
                ];

                final leftFields = [
                  TayssirCountryDropDown(country: country, region: region, countries: countries)
                      .animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
                  
                  isDesktop ? 22.verticalSpace : 16.verticalSpace,
                  
                  TayssirRegionDropDown(region: region, regions: regions)
                      .animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
                  
                  isDesktop ? 22.verticalSpace : 16.verticalSpace,
                  
                  TayssirSpecialityDropDown(
                    division: speciality,
                    items: specialityValue,
                  ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),
                ];

                if (isDesktop) {
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: rightFields[0]), // Name
                          24.horizontalSpace,
                          Expanded(child: leftFields[0]), // Country
                        ],
                      ),
                      30.verticalSpace,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: rightFields[2]), // Age
                          24.horizontalSpace,
                          Expanded(child: leftFields[2]), // Region
                        ],
                      ),
                      30.verticalSpace,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: rightFields[4]), // Phone
                          24.horizontalSpace,
                          Expanded(child: leftFields[4]), // Speciality
                        ],
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    ...rightFields,
                    20.verticalSpace,
                    ...leftFields,
                  ],
                );
              }
            ),
            
            40.verticalSpace,
            
            BigButton(
              text: AppStrings.continueText,
              isLoading: registerController.isLoading,
              onPressed: registerController.isLoading || !canSubmit
                  ? null
                  : () {
                      try {
                        if (nameController.text.length < 4) {
                          SnackBarService.showErrorSnackBar('يجب أن يكون الإسم أكبر من 3 أحرف', context: context);
                          return;
                        }
                        
                        final age = int.tryParse(ageController.text);
                        if (age == null) {
                          SnackBarService.showErrorSnackBar('يرجى إدخال عمر صحيح', context: context);
                          return;
                        }

                        if (formKey.currentState!.validate()) {
                          ref.read(registerControllerProvider.notifier).setUserData(
                                nameController.text,
                                age,
                                phoneController.text,
                                country.value!,
                                region.value!,
                                speciality.value!.id,
                              );
                          // Force update onboarding division to ensure data provider picks it up immediately
                          ref.read(onboardingProvider.notifier).setDivision(speciality.value!.id, speciality.value!.name);
                        }
                      } catch (e) {
                        SnackBarService.showErrorSnackBar('حدث خطأ غير متوقع، يرجى المحاولة لاحقاً', context: context);
                      }
                    },
            ).animate().fadeIn(delay: 800.ms).scale(),
            
            40.verticalSpace,
          ],
        ),
      ),
    );
  }
}
