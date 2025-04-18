import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';



const kTextFieldDecoration=  InputDecoration(hintText: '...', contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white30, width: 1.0), borderRadius: BorderRadius.all(Radius.circular(borderRadius),),
  ), disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 1.0),  borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
  ), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color:  Colors.black87, width: 1.0), borderRadius: BorderRadius.all(Radius.circular(borderRadius)),),);

const kTextFieldDecorationTournament=  InputDecoration(hintText: '...', contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0), enabledBorder: InputBorder.none,
  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 1.0), borderRadius: BorderRadius.all(Radius.circular(borderRadius),),
  ), disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 1.0),  borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
  ), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 1.0), borderRadius: BorderRadius.all(Radius.circular(borderRadius)),),);
String barcodeData = '';


const double borderRadius=10;

// Responsive Breakpoints
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

// Responsive Layout Helper
class ResponsiveLayout {
  static bool isMobile(double width) => width < ResponsiveBreakpoints.mobile;
  static bool isTablet(double width) => width >= ResponsiveBreakpoints.mobile && width < ResponsiveBreakpoints.desktop;
  static bool isDesktop(double width) => width >= ResponsiveBreakpoints.desktop;

  static double getContentWidth(double screenWidth) {
    if (screenWidth <= ResponsiveBreakpoints.mobile) return screenWidth;
    if (screenWidth <= ResponsiveBreakpoints.tablet) return screenWidth * 0.85;
    if (screenWidth <= ResponsiveBreakpoints.desktop) return screenWidth * 0.7;
    return 1200; // Maximum Breite für sehr große Bildschirme
  }

  static double getLoginWidth(double screenWidth) {
    if (isMobile(screenWidth)) return screenWidth * 0.9;
    if (isTablet(screenWidth)) return screenWidth * 0.7;
    return screenWidth * 0.4;
  }
  static double getIconSize(double screenWidth) {
    if (isMobile(screenWidth)) return 24.0;
    if (isTablet(screenWidth)) return 28.0;
    if (isDesktop(screenWidth)) return 32.0;
    return 24.0; // Standardgröße
  }
  static double getLogoSize(double screenWidth) {
    if (isMobile(screenWidth)) return screenWidth * 0.5;
    if (isTablet(screenWidth)) return screenWidth * 0.3;
    return screenWidth * 0.2;
  }
}
// Neue PlatformInfo Klasse
class PlatformInfo {
  static bool get isMobilePlatform => kIsWeb ? false : (Platform.isIOS || Platform.isAndroid);
  static bool get isDesktopPlatform => kIsWeb ? false : (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  static bool get isWebPlatform => kIsWeb;

  static double getWebFactor(double screenWidth) {
    if (!isWebPlatform) return 1.0;
    if (screenWidth > ResponsiveBreakpoints.tablet) return 1.2;
    if (screenWidth > ResponsiveBreakpoints.mobile) return 1.1;
    return 1.0;
  }

  // Angepasste Icon-Größen für verschiedene Plattformen
  static double getIconSize(double baseSize, double screenWidth) {
    if (isMobilePlatform) return baseSize;
    if (isWebPlatform) return baseSize * getWebFactor(screenWidth);
    return baseSize * 1.2; // Etwas größer für Desktop
  }

  // Helper-Methode für Bottom Navigation Bar Icons
  static double getBottomNavIconSize(double screenWidth) {
    if (isMobilePlatform) return 24.0;
    if (isWebPlatform && screenWidth > ResponsiveBreakpoints.desktop) return 32.0;
    if (isWebPlatform && screenWidth > ResponsiveBreakpoints.tablet) return 28.0;
    return 24.0;
  }
}
// Überarbeitete Konstanten für responsives Design
class AppSizes {
  static double w = Adaptive.w(100);
  static double h = Adaptive.h(100);

  static double getHorizontalPadding(double width) {
    if (ResponsiveLayout.isMobile(width)) return 20;
    if (ResponsiveLayout.isTablet(width)) return 40;
    return 60;
  }

  static double getVerticalPadding(double width) {
    if (ResponsiveLayout.isMobile(width)) return 20;
    if (ResponsiveLayout.isTablet(width)) return 40;
    return 60;
  }
  static double getInputFieldHeight(double height) => height * 0.07;
  static double getButtonHeight(double height) => height * 0.06;
}

class AppColors {
  // Neue KinderStory Farben
 // static const Color bookRed = Color(0xFFFF4D4D);    // Rot (Buch)
  //LILA Color(0xFFA084E8)
  static const Color bookRed= Color(0xFFE03A3A);
  static const Color textPurple = Color(0xFFE03A3A); // Lila (Schriftzug)
  static const Color accentYellow = Color(0xFFFFD500); // Gelb (Seitenelemente)
  static const Color accentBlue = Color(0xFF2A9DF4);  // Blau (Seitenelemente)
  static const Color accentGreen = Color(0xFF30D158); // Grün (Seitenelemente)
  static const Color bgCream = Color(0xFFFFF8F8);    // Hintergrund (Hellcremeweiß)

  // Hauptfarben
  static const Color primaryLight = textPurple;        // Lila als Hauptfarbe (hell)
  static const Color primary = bookRed;                // Rot als primäre Akzentfarbe
  static const Color primaryDark = Color(0xFFE03A3A); // Dunkleres Rot

  // Farbkombinationen
  static const Color background = bgCream;
  static const Color cardBackground = Colors.white;
  static const Color appBarBackground = primary;
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = textPurple;

  // Text Farben
  static const Color textPrimary = Color(0xFF4A4A4A);
  static const Color textSecondary = Color(0xFF7B7B7B);
  static const Color textOnPrimary = Colors.white;

  // Icon Farben
  static const Color iconPrimary = primaryDark;
  static const Color iconOnPrimary = Colors.white;

  // Status-Farben
  static const Color success = accentGreen;
  static const Color error = bookRed;
  static const Color warning =Colors.black87;
  static const Color info = accentBlue;
}

// App-Thema-Daten
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.textPurple,
        background: AppColors.background,
        tertiary: AppColors.accentYellow,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.textOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPurple,
          side: const BorderSide(color: AppColors.textPurple),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPurple,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.textPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.textPurple, width: 2),
        ),
        prefixIconColor: AppColors.primary,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        thumbColor: AppColors.primaryDark,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.primary;
            }
            return Colors.transparent;
          },
        ),
      ),
      useMaterial3: true,
    );
  }
}