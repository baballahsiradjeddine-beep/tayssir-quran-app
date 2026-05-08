#!/bin/bash
# Fix Light Mode Colors - Comprehensive Pass
# Run from project root

TARGET_DIR="lib"

echo "🎨 Starting Light Mode color fix..."

# Files to skip (these use primaryColor correctly for dark mode)
SKIP_FILES=("app_colors.dart" "app_theme.dart")

fix_file() {
  local file=$1
  
  # Skip files in SKIP list
  for skip in "${SKIP_FILES[@]}"; do
    if [[ "$file" == *"$skip" ]]; then
      return
    fi
  done

  # Fix standalone AppColors.primaryColor used as icon/accent color without isDark check
  # We can't blindly replace, but we fix common patterns:
  
  # 1. color: AppColors.primaryColor (used alone as text/icon color) 
  #    → needs isDark check. We'll add theme awareness via a helper pattern.
  #    This is too risky to do blindly, so we focus on specific patterns.
  
  # Fix: color: const Color(0xFF10B981) (hardcoded emerald - most common issue)
  # These appear without isDark checks
  sed -i '' "s/color: const Color(0xFF10B981),/color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF10B981) : AppColors.warmAccent,/g" "$file" 2>/dev/null
  
  # Fix: Colors.green and similar
  sed -i '' "s/color: AppColors.secondaryColor,/color: Theme.of(context).brightness == Brightness.dark ? AppColors.secondaryColor : AppColors.warmAccent,/g" "$file" 2>/dev/null
}

# Only apply to specific problem files identified
PROBLEM_FILES=(
  "lib/features/auth/presentation/login/forget_password_button.dart"
  "lib/features/auth/presentation/register/widgets/change_auth_type_widget.dart"
  "lib/features/auth/presentation/register/views/credentials_view.dart"
  "lib/features/auth/presentation/login/custom_text_form_field.dart"
  "lib/features/onboarding/onboarding_screen.dart"
  "lib/features/onboarding/widgets/onboarding_button.dart"
)

for f in "${PROBLEM_FILES[@]}"; do
  if [[ -f "$f" ]]; then
    fix_file "$f"
    echo "✅ Fixed: $f"
  fi
done

echo "✨ Done!"
