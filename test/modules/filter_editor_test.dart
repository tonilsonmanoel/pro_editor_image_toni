import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_editor_image_toni/modules/filter_editor/filter_editor.dart';
import 'package:pro_editor_image_toni/modules/filter_editor/widgets/image_with_filter.dart';
import 'package:pro_editor_image_toni/utils/design_mode.dart';

import '../fake/fake_image.dart';

void main() {
  group('FilterEditor Tests', () {
    testWidgets('FilterEditor should build without error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterEditor.memory(
              fakeMemoryImage,
              theme: ThemeData.light(),
              designMode: ImageEditorDesignModeE.material,
              heroTag: 'unique_hero_tag',
            ),
          ),
        ),
      );

      expect(find.byType(FilterEditor), findsOneWidget);
    });

    testWidgets('FilterEditor should have filter buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterEditor.memory(
              fakeMemoryImage,
              theme: ThemeData.light(),
              designMode: ImageEditorDesignModeE.material,
              heroTag: 'unique_hero_tag',
            ),
          ),
        ),
      );

      expect(find.byType(ImageWithFilter), findsWidgets);
    });
  });
}
