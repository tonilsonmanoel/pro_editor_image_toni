import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_editor_image_toni/modules/sticker_editor.dart';
import 'package:pro_editor_image_toni/pro_image_editor.dart';

void main() {
  group('StickerEditor Tests', () {
    testWidgets('StickerEditor widget should be created',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: StickerEditor(
          configs: StickerEditorConfigs(
            enabled: true,
            buildStickers: (setLayer) {
              return Container();
            },
          ),
        ),
      ));

      expect(find.byType(StickerEditor), findsOneWidget);
    });
  });
}
