import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mini_social/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('게시글 등록과 좋아요가 서버에 반영된다', (tester) async {
    await tester.runAsync(() async {
      app.main();

      Future<void> waitFor(Finder finder) async {
        final deadline = DateTime.now().add(const Duration(seconds: 20));
        while (finder.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          await tester.pump();
        }
        expect(finder, findsOneWidget);
      }

      await tester.pump();
      await waitFor(find.text('첫 이야기를 남겨 보세요.'));
      await tester.tap(find.text('글 쓰기'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), '제이');
      await tester.enterText(find.byType(TextFormField).at(1), '첫 번째 이야기');
      await tester.tap(find.text('게시'));
      await tester.pump();
      await waitFor(find.text('첫 번째 이야기'));
      await tester.tap(find.text('좋아요 0'));
      await tester.pump();
      await waitFor(find.text('좋아요 1'));
    });
  });
}
