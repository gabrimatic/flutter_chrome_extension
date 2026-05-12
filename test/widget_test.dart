import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chrome_extension/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('shows the extension overview by default', (tester) async {
    await tester.pumpWidget(const FlutterChromeExtensionApp());

    expect(find.text('Flutter Chrome Extension'), findsOneWidget);
    expect(find.text('Manifest V3'), findsOneWidget);
    expect(find.text('No permissions'), findsOneWidget);
    expect(find.text('Local assets'), findsOneWidget);
    expect(find.text('What this popup is for'), findsOneWidget);
  });

  testWidgets('shows build guidance and copies the build command', (
    tester,
  ) async {
    final methodCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          methodCalls.add(call);
          return null;
        });

    await tester.pumpWidget(const FlutterChromeExtensionApp());
    await tester.tap(find.text('Build'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'flutter build web --csp --no-web-resources-cdn --no-source-maps',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Copy build command'));
    await tester.pump();

    expect(find.text('Build command copied'), findsOneWidget);
    expect(
      methodCalls,
      contains(
        isA<MethodCall>().having(
          (call) => call.method,
          'method',
          'Clipboard.setData',
        ),
      ),
    );
  });

  testWidgets('updates release checklist state', (tester) async {
    await tester.pumpWidget(const FlutterChromeExtensionApp());
    await tester.tap(find.text('Ship'));
    await tester.pumpAndSettle();

    expect(find.text('Release checklist'), findsOneWidget);
    expect(find.text('Chrome loads the unpacked folder'), findsOneWidget);

    final chromeChecklistLabel = find.text('Chrome loads the unpacked folder');
    await tester.ensureVisible(chromeChecklistLabel);
    await tester.tap(chromeChecklistLabel);
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Checkbox && widget.value == true,
      ),
      findsNWidgets(3),
    );
  });
}
