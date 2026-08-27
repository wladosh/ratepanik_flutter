import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ratepanik/app.dart';
import 'package:ratepanik/l10n/rp_strings.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpPhoneApp(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const RatepanikApp());
  }

  testWidgets('landing shell shows join and login', (tester) async {
    await pumpPhoneApp(tester);

    expect(find.text(RpStrings.appName), findsOneWidget);
    expect(find.text(RpStrings.landingJoin), findsOneWidget);
    expect(find.text(RpStrings.landingLogin), findsOneWidget);
  });

  testWidgets('login walks the shell to home', (tester) async {
    await pumpPhoneApp(tester);

    await tester.tap(find.text(RpStrings.landingLogin));
    await tester.pumpAndSettle();
    expect(find.text(RpStrings.loginSubtitle), findsOneWidget);

    await tester.tap(find.text(RpStrings.loginSubmit));
    await tester.pumpAndSettle();
    expect(find.text(RpStrings.homeCreateTitle), findsOneWidget);
  });
}
