import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/screens/home_screen.dart';
import 'package:crossclimber/services/statistics_repository.dart';
import 'package:crossclimber/services/sound_service.dart';
import 'package:crossclimber/services/haptic_service.dart';

// Mock Services
class MockStatisticsRepository extends Mock implements StatisticsRepository {}
class MockSoundService extends Mock implements SoundService {}
class MockHapticService extends Mock implements HapticService {}

void main() {
  late MockStatisticsRepository mockStatisticsRepo;
  late MockSoundService mockSoundService;
  late MockHapticService mockHapticService;

  setUp(() {
    mockStatisticsRepo = MockStatisticsRepository();
    mockSoundService = MockSoundService();
    mockHapticService = MockHapticService();

    when(() => mockStatisticsRepo.getStatistics())
        .thenAnswer((_) async => Statistics(totalGamesPlayed: 5, totalGamesWon: 3));
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        soundServiceProvider.overrideWithValue(mockSoundService),
        hapticServiceProvider.overrideWithValue(mockHapticService),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en')],
        home: HomeScreen(),
      ),
    );
  }

  testWidgets('HomeScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('CrossClimber'), findsOneWidget);

    // Verify Play Button
    expect(find.text('Play'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    // Verify Quick Access Buttons
    expect(find.text('Daily\nChallenge'), findsOneWidget);
    expect(find.text('Achievements'), findsOneWidget);
    expect(find.text('Statistics'), findsOneWidget);

    // Verify Settings Button
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });

  testWidgets('Play button triggers navigation and sound', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final playButton = find.text('Play');
    await tester.tap(playButton);
    await tester.pump();

    verify(() => mockSoundService.play(SoundEffect.tap)).called(1);
    verify(() => mockHapticService.trigger(HapticType.selection)).called(1);
  });
}
