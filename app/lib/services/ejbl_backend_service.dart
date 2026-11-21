import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ejbl_models.dart';

/// Centralized Supabase repository for EJBL Bigasan.
///
/// Frontend screens should call this service rather than embedding raw
/// PostgREST or RPC calls directly inside UI widgets.
class EjblBackendService {
  final SupabaseClient _client;
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

  EjblBackendService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ---------------------------------------------------------------------------
  // AUTH & PROFILE
  // ---------------------------------------------------------------------------

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<UserProfile?> getMyProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final data = await _client
        .from('profiles')
        .select('id, full_name, role, is_active')
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) return null;
    return UserProfile.fromJson(data);
  }

  // ---------------------------------------------------------------------------
  // INVENTORY & MASTER DATA
  // ---------------------------------------------------------------------------

  Future<List<InventorySummaryItem>> getInventorySummary() async {
    final rows = await _client
        .from('v_inventory_summary')
        .select()
        .order('code', ascending: true);

    return (rows as List)
        .map((r) => InventorySummaryItem.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getConsignmentClients() async {
    final rows = await _client
        .from('consignment_clients')
        .select('id, business_name, contact_info, payment_schedule, notes')
        .eq('is_active', true)
        .order('business_name', ascending: true);

    return List<Map<String, dynamic>>.from(rows as List);
  }

  Future<List<Map<String, dynamic>>> getSuppliers() async {
    final rows = await _client
        .from('suppliers')
        .select('id, name, contact_info, notes')
        .eq('is_active', true)
        .order('name', ascending: true);

    return List<Map<String, dynamic>>.from(rows as List);
  }

  // ---------------------------------------------------------------------------
  // BUSINESS RECORDS, AUDIT LOG & BIR BOOKS (RLS-ENFORCED)
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getCashbookEntries({int limit = 50}) async {
    final rows = await _client
        .from('v_cashbook_entries')
        .select()
        .order('entry_date', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(rows as List);
  }

  Future<List<Map<String, dynamic>>> getVoidAuditLogs({int limit = 50}) async {
    final rows = await _client
        .from('void_audit_logs')
        .select()
        .order('voided_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(rows as List);
  }

  Future<List<Map<String, dynamic>>> getBirEntries({
    String? bookType, // 'GL' | 'CRJ' | 'CDJ' | 'GJ'
    int limit = 100,
  }) async {
    var query = _client.from('bir_ledger_entries').select();
    if (bookType != null) {
      query = query.eq('book_type', bookType);
    }
    final rows = await query.order('entry_date', ascending: false).limit(limit);
    return List<Map<String, dynamic>>.from(rows as List);
  }

  // ---------------------------------------------------------------------------
  // ATOMIC SQL RPC CALLS (FIFO, AUTO-COGS, VOID AUDIT, BIR POSTING)
  // ---------------------------------------------------------------------------

  /// RPC 1: Receive rice stock -> FIFO batch + auto COGS expense + CDJ/GL.
  Future<String> receiveStock({
    required String riceVarietyId,
    String? supplierId,
    required DateTime receivedDate,
    required double qtyKg,
    required double unitCostPerKg,
    required String paymentMethod, // cash | gcash | bank_transfer
    String? supplierInvoiceNo,
    String? referenceNo,
    bool isOpeningBalance = false,
    String? notes,
  }) async {
    final result = await _client.rpc('receive_stock', params: {
      'p_rice_variety_id': riceVarietyId,
      'p_supplier_id': supplierId,
      'p_received_date': _isoDate.format(receivedDate),
      'p_qty_kg': qtyKg,
      'p_unit_cost_per_kg': unitCostPerKg,
      'p_payment_method': paymentMethod,
      'p_supplier_invoice_no': supplierInvoiceNo,
      'p_reference_no': referenceNo,
      'p_is_opening_balance': isOpeningBalance,
      'p_notes': notes,
    });
    return result as String;
  }

  /// RPC 2: Create sale -> SI/NSI + FIFO deduction + split payment + CRJ/GL.
  Future<String> createSale({
    required DateTime saleDate,
    required String invoiceType, // 'SI' | 'NSI'
    required String fulfillmentType, // 'pickup' | 'delivery'
    double deliveryFee = 0,
    bool isConsignment = false,
    String? consignmentClientId,
    required List<SaleItemInput> items,
    List<PaymentInput> payments = const [],
    String? notes,
  }) async {
    final result = await _client.rpc('create_sale', params: {
      'p_sale_date': _isoDate.format(saleDate),
      'p_invoice_type': invoiceType,
      'p_fulfillment_type': fulfillmentType,
      'p_delivery_fee': deliveryFee,
      'p_is_consignment': isConsignment,
      'p_consignment_client_id': consignmentClientId,
      'p_items': items.map((i) => i.toJson()).toList(),
      'p_payments': payments.map((p) => p.toJson()).toList(),
      'p_notes': notes,
    });
    return result as String;
  }

  /// RPC 3: Void/cancel sale -> restores FIFO batches + void_audit_logs + GJ/GL.
  Future<void> voidSale({
    required String saleId,
    required String reason,
  }) async {
    await _client.rpc('void_sale', params: {
      'p_sale_id': saleId,
      'p_reason': reason.trim(),
    });
  }

  /// RPC 4: Record partial/full B2B consignment collection -> Cashbook + CRJ/GL.
  Future<String> recordConsignmentPayment({
    required String saleId,
    required DateTime paymentDate,
    required String method,
    required double amount,
    String? referenceNo,
    String? notes,
  }) async {
    final result = await _client.rpc('record_consignment_payment', params: {
      'p_sale_id': saleId,
      'p_payment_date': _isoDate.format(paymentDate),
      'p_method': method,
      'p_amount': amount,
      'p_reference_no': referenceNo,
      'p_notes': notes,
    });
    return result as String;
  }

  /// RPC 5: Record expense (Log Out) -> expenses + CDJ/GL (+ capital if withdrawal).
  Future<String> recordExpense({
    required DateTime expenseDate,
    String? invoiceNo,
    required String category,
    required String description,
    required String paymentMethod,
    required double amount,
    String? referenceNo,
    String? notes,
  }) async {
    final result = await _client.rpc('record_expense', params: {
      'p_expense_date': _isoDate.format(expenseDate),
      'p_invoice_no': invoiceNo,
      'p_category': category,
      'p_description': description.trim(),
      'p_payment_method': paymentMethod,
      'p_amount': amount,
      'p_reference_no': referenceNo,
      'p_notes': notes,
    });
    return result as String;
  }

  /// RPC 6: Void/cancel expense -> void_audit_logs + GJ/GL reversal.
  Future<void> voidExpense({
    required String expenseId,
    required String reason,
  }) async {
    await _client.rpc('void_expense', params: {
      'p_expense_id': expenseId,
      'p_reason': reason.trim(),
    });
  }
}
