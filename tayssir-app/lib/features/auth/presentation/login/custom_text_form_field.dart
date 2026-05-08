import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import '../../../../utils/validators.dart';

class CustomTextFormField extends HookConsumerWidget {
  final TextEditingController? controller;
  final String labelText;
  final String hintText;
  final String? Function(String?)? validator;
  final bool isPassword;
  final Widget? suffix;
  final Widget? prefix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool isReadOnly;
  final bool isMultiLine;
  final String? initialValue;
  final TextDirection? textDirection;
  final TextAlign? textAlign;
  final void Function(String)? onFieldSubmitted;

  const CustomTextFormField({
    super.key,
    this.controller,
    this.hintText = "",
    required this.labelText,
    this.validator = Validators.nonEmptyValidator,
    this.isPassword = false,
    this.suffix,
    this.prefix,
    this.keyboardType,
    this.textInputAction,
    this.isReadOnly = false,
    this.isMultiLine = false,
    this.initialValue,
    this.textDirection,
    this.textAlign,
    this.onFieldSubmitted,
  }) : assert(initialValue == null || controller == null);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHidden = useState<bool>(true);
    final focusNode = useFocusNode();
    final isFocused = useState<bool>(false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    useEffect(() {
      void listener() => isFocused.value = focusNode.hasFocus;
      focusNode.addListener(listener);
      return () => focusNode.removeListener(listener);
    }, [focusNode]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8.w, bottom: 8.h),
          child: Text(
            labelText,
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : AppColors.warmTitle,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'SomarSans',
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              if (isFocused.value)
                BoxShadow(
                  color: (isDark ? AppColors.primaryColor : AppColors.warmAccent).withOpacity(0.15),
                  blurRadius: 15,
                  spreadRadius: 0,
                ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            readOnly: isReadOnly,
            initialValue: initialValue,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textInputAction: textInputAction ?? TextInputAction.next,
            maxLines: isMultiLine ? 5 : 1,
            obscureText: isPassword && isHidden.value,
            textDirection: textDirection,
            textAlign: textAlign ?? TextAlign.start,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.warmTitle,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'SomarSans',
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: isDark ? const Color(0xFF475569) : AppColors.warmSubtitle.withOpacity(0.6),
                fontSize: 14.sp,
                fontFamily: 'SomarSans',
              ),
              prefixIcon: prefix != null
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: IconTheme(
                        data: IconThemeData(
                          color: isFocused.value 
                              ? (isDark ? AppColors.primaryColor : AppColors.warmAccent) 
                              : (isDark ? const Color(0xFF475569) : AppColors.warmSubtitle),
                          size: 22.sp,
                        ),
                        child: prefix!,
                      ),
                    )
                  : null,
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isHidden.value ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: isFocused.value 
                            ? (isDark ? AppColors.primaryColor : AppColors.warmAccent) 
                            : (isDark ? const Color(0xFF475569) : AppColors.warmSubtitle),
                        size: 22.sp,
                      ),
                      onPressed: () => isHidden.value = !isHidden.value,
                    )
                  : suffix,
              filled: true,
              fillColor: isDark 
                  ? (isFocused.value ? const Color(0xFF1E293B) : const Color(0xFF0F172A))
                  : (isFocused.value ? Colors.white : AppColors.warmBackground),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 14.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.r),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF334155) : AppColors.warmBorder,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.r),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF334155) : AppColors.warmBorder,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.r),
                borderSide: BorderSide(
                  color: isDark ? AppColors.primaryColor : AppColors.warmAccent,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.r),
                borderSide: const BorderSide(
                  color: Color(0xFFF43F5E),
                  width: 1.5,
                ),
              ),
            ),
            validator: validator,
            onFieldSubmitted: onFieldSubmitted,
          ),
        ),
      ],
    );
  }
}
