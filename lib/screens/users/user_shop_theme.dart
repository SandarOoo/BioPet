import 'package:flutter/material.dart';

class UserShopTheme {
  const UserShopTheme._();

  static const Color emerald = Color(0xFF065F46);
  static const Color emeraldDark = Color(0xFF044836);
  static const Color mint = Color(0xFFA7F3D0);
  static const Color mintSoft = Color(0xFFECFDF5);
  static const Color cream = Color(0xFFFFF8E7);
  static const Color background = Color(0xFFF8FBF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF10231D);
  static const Color textSecondary = Color(0xFF66766F);
  static const Color border = Color(0xFFDDEBE5);
  static const Color danger = Color(0xFFDC5A5A);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF3B82F6);

  static const double pagePadding = 16;
  static const double cardRadius = 20;
  static const double buttonRadius = 16;

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: emerald.withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];

  static BoxDecoration card({
    Color color = surface,
    double radius = cardRadius,
    bool showBorder = true,
    bool showShadow = true,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: showBorder ? Border.all(color: border) : null,
      boxShadow: showShadow ? softShadow : null,
    );
  }

  static BoxDecoration selectedCard({required bool selected}) {
    return BoxDecoration(
      color: selected ? mintSoft : surface,
      borderRadius: BorderRadius.circular(cardRadius),
      border: Border.all(
        color: selected ? emerald : border,
        width: selected ? 1.5 : 1,
      ),
      boxShadow: selected ? softShadow : null,
    );
  }

  static InputDecoration input({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon, color: emerald),
      filled: true,
      fillColor: surface,
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: emerald, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: border),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: danger),
      ),
    );
  }

  static ButtonStyle primaryButton({EdgeInsetsGeometry? padding}) {
    return ElevatedButton.styleFrom(
      backgroundColor: emerald,
      foregroundColor: Colors.white,
      disabledBackgroundColor: emerald.withOpacity(0.35),
      disabledForegroundColor: Colors.white70,
      elevation: 0,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonRadius),
      ),
    );
  }

  static ButtonStyle outlineButton({EdgeInsetsGeometry? padding}) {
    return OutlinedButton.styleFrom(
      foregroundColor: emerald,
      side: const BorderSide(color: emerald),
      padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonRadius),
      ),
    );
  }

  static AppBar appBar(String title, {PreferredSizeWidget? bottom}) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      backgroundColor: background,
      surfaceTintColor: background,
      elevation: 0,
      iconTheme: const IconThemeData(color: textPrimary),
      bottom: bottom,
    );
  }
}
