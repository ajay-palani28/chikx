import 'dart:ui';

class AppColors {
  // --- Core Branding ---
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color bgColor = Color(0xFFFDF9F4);

  // --- Brand Palette ---
  static const Color primary = Color(0xFFFDB813);      // Royal Blue (Actually Yellow/Gold in UI)
  static const Color primaryLight = Color(0xFF1A1A1A); // Light Royal Blue
  // static const Color secondary = Color(0xFFC6FF3E);    // Lime Green (Accent)
  static const Color neutral = Color(0xFF7F7668);      // Dark Background

  // --- Create Account UI Colors ---
  static const Color scaffoldBg = Color(0xFFFDF8F4);   // Light cream background
  static const Color fieldFill = Color(0xFFF9F4EF);    // Very light brown fill
  static const Color fieldBorder = Color(0xFFE2D6C5);  // Light brown border
  static const Color textBrown = Color(0xFF745223);    // Dark brown for labels/links
  static const Color textGrey = Color(0xFF9E9E9E);     // Grey for hints

  // --- Support UI Specific ---
  static const Color chatIncoming = Color(0xFFF5E9D8);
  static const Color chatOutgoing = Color(0xFF745223);

  // --- Profile UI Specific ---
  static const Color logoutBg = Color(0xFFFEE2E2);
  static const Color logoutText = Color(0xFFB91C1C);
}
