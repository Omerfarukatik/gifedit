// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memecreat/main.dart';
import 'package:memecreat/providers/auth_provider.dart';
import 'package:memecreat/providers/creation_provider.dart';
import 'package:memecreat/providers/gif_provider.dart';
import 'package:memecreat/providers/localization_provider.dart';
import 'package:memecreat/providers/profile_provider.dart';
import 'package:memecreat/providers/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  // Bu test, uygulamanın ana widget'ının (MyApp) hatasız bir şekilde
  // oluşturulup oluşturulmadığını kontrol eder.
  testWidgets('App starts without crashing smoke test', (WidgetTester tester) async {
    // Uygulamayı, main.dart'taki gibi gerekli Provider'lar ile sarmalıyoruz.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => CreationProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => GifProvider()),
        ],
        child: const StitchDesignApp(), // Ana widget'ınız
      ),
    );

    // pumpAndSettle, tüm animasyonların ve asenkron işlemlerin bitmesini bekler.
    await tester.pumpAndSettle();

    // Uygulamanın açılış ekranında bir Scaffold'un varlığını kontrol edelim.
    expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
  });
}
