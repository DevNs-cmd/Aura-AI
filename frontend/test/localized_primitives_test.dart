import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura_ai/core/widgets/localized_settings_row.dart';
import 'package:aura_ai/core/widgets/localized_action_row.dart';
import 'package:aura_ai/core/widgets/localized_section_header.dart';
import 'package:aura_ai/core/widgets/localized_button.dart';
import 'package:aura_ai/core/widgets/localized_dialog_action_bar.dart';
import 'package:aura_ai/core/widgets/localized_adaptive_chip_group.dart';
import 'package:aura_ai/core/widgets/localized_responsive_header.dart';
import 'package:aura_ai/core/widgets/localized_navigation_label.dart';
import 'package:aura_ai/core/widgets/localized_metadata_row.dart';

void main() {
  Widget buildTestableWidget({
    required Widget child,
    double width = 300.0,
    double textScaleFactor = 1.0,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: MediaQuery(
              data: MediaQueryData(
                textScaler: TextScaler.linear(textScaleFactor),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  group('LocalizedSettingsRow Tests', () {
    testWidgets('Renders long translations safely without overflow', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestableWidget(
          width: 320,
          textScaleFactor: 1.3,
          child: LocalizedSettingsRow(
            leading: const Icon(Icons.settings),
            title:
                'Notificaciones muy largas de configuración', // Spanish-style long title
            subtitle: 'Recordatorios inteligentes y avisos urgentes',
            trailingText: 'Personalizado para el usuario final',
            onTap: () => tapped = true,
          ),
        ),
      );

      // Verify strings are present
      expect(find.textContaining('Notificaciones'), findsOneWidget);
      expect(find.textContaining('Recordatorios'), findsOneWidget);

      // Verify tap works
      await tester.tap(find.byType(LocalizedSettingsRow));
      expect(tapped, isTrue);

      // Verify no exceptions or overflows occurred (tester.takeException is null)
      expect(tester.takeException(), isNull);
    });

    testWidgets('Stacks elements vertically on extreme text scale 2.0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          width: 300,
          textScaleFactor: 2.0,
          child: LocalizedSettingsRow(
            title: 'Settings Option Label',
            trailingText: 'Enabled State Description',
          ),
        ),
      );

      expect(find.text('Settings Option Label'), findsOneWidget);
      expect(find.text('Enabled State Description'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('LocalizedActionRow Tests', () {
    testWidgets('Adapts title and action label on overflow', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestableWidget(
          width: 320,
          textScaleFactor: 1.3,
          child: LocalizedActionRow(
            title: 'Mi Diario de Reflexión y Agradecimiento',
            actionLabel: 'Ver todos los registros',
            onActionPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.textContaining('Diario'), findsOneWidget);
      expect(find.text('Ver todos los registros'), findsOneWidget);

      await tester.tap(find.text('Ver todos los registros'));
      expect(tapped, isTrue);
      expect(tester.takeException(), isNull);
    });
  });

  group('LocalizedSectionHeader Tests', () {
    testWidgets('Renders localized header label safely', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: const LocalizedSectionHeader(
            title: 'Preferencias de Aura AI y Configuración General',
          ),
        ),
      );

      expect(find.textContaining('Preferencias'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('LocalizedButton Tests', () {
    testWidgets('Supports vertical growth and multiline text', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestableWidget(
          width: 250,
          textScaleFactor: 1.5,
          child: LocalizedButton(
            text: 'Enviar enlace de restablecimiento de contraseña muy largo',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.textContaining('Enviar enlace'), findsOneWidget);
      await tester.tap(find.byType(LocalizedButton));
      expect(tapped, isTrue);
      expect(tester.takeException(), isNull);
    });
  });

  group('LocalizedDialogActionBar Tests', () {
    testWidgets('Stacks action buttons vertically using OverflowBar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          width: 200,
          child: LocalizedDialogActionBar(
            children: [
              TextButton(onPressed: () {}, child: const Text('Cancelar')),
              TextButton(
                onPressed: () {},
                child: const Text('Confirmar y Guardar'),
              ),
            ],
          ),
        ),
      );

      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Confirmar y Guardar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('LocalizedAdaptiveChipGroup Tests', () {
    testWidgets('Wraps chips dynamically without overflow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          width: 320,
          child: LocalizedAdaptiveChipGroup(
            children: List.generate(
              5,
              (index) => Chip(label: Text('Chip $index')),
            ),
          ),
        ),
      );

      expect(find.text('Chip 0'), findsOneWidget);
      expect(find.text('Chip 4'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('LocalizedResponsiveHeader Tests', () {
    testWidgets('Wraps title safely and preserves leading/trailing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          width: 320,
          textScaleFactor: 1.3,
          child: LocalizedResponsiveHeader(
            title: 'Hola Jose Maria, ¿cómo te sientes hoy?',
            leading: const Icon(Icons.person),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {},
              ),
            ],
            isDark: false,
          ),
        ),
      );

      expect(find.textContaining('Jose Maria'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('LocalizedNavigationLabel Tests', () {
    testWidgets('Shows navigation label text and scales correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          width: 80,
          child: const LocalizedNavigationLabel(
            label: 'Explorar',
            color: Colors.blue,
            isSelected: true,
          ),
        ),
      );

      expect(find.text('Explorar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('LocalizedMetadataRow Tests', () {
    testWidgets('Adapts layouts for key-value pair sizes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          width: 320,
          textScaleFactor: 1.3,
          child: const LocalizedMetadataRow(
            label: 'Tamaño del archivo cargado',
            value: '2.4 MB (PDF Document)',
          ),
        ),
      );

      expect(find.text('Tamaño del archivo cargado'), findsOneWidget);
      expect(find.text('2.4 MB (PDF Document)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
