import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campo_minado/main.dart';

void main() {
  testWidgets('Campo Minado abre a tela corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: const JogoCampoMinado()));

    expect(find.text('Campo Minado'), findsOneWidget);

    
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
}
