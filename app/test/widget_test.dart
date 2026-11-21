import 'package:ejbl_app/main.dart';
import 'package:ejbl_app/models/ejbl_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Shows Supabase config guidance when --dart-define is omitted',
      (WidgetTester tester) async {
    await tester.pumpWidget(const EjblBackendApp());
    expect(find.text('EJBL — Supabase Not Configured'), findsOneWidget);
    expect(find.textContaining('SUPABASE_URL'), findsWidgets);
  });

  test('UserRole.fromString parses all internal roles and falls back to staff',
      () {
    expect(UserRole.fromString('admin'), UserRole.admin);
    expect(UserRole.fromString('MANAGER'), UserRole.manager);
    expect(UserRole.fromString('staff'), UserRole.staff);
    expect(UserRole.fromString('unknown'), UserRole.staff);
  });

  test('SaleItemInput.toJson omits applied_price_per_kg when null', () {
    const item = SaleItemInput(
      riceVarietyId: 'uuid-1',
      qtyInput: 2,
      unit: 'SACK',
    );
    expect(item.toJson(), {
      'rice_variety_id': 'uuid-1',
      'qty_input': 2.0,
      'unit': 'SACK',
    });
  });
}
