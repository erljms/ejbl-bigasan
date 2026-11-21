import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/supabase_config.dart';
import 'models/ejbl_models.dart';
import 'services/ejbl_backend_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
  }

  runApp(const EjblBackendApp());
}

class EjblBackendApp extends StatelessWidget {
  const EjblBackendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EJBL Bigasan — Backend Console',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
        useMaterial3: true,
      ),
      home: SupabaseConfig.isConfigured
          ? const _AuthGate()
          : const _MissingConfigScreen(),
    );
  }
}

class _MissingConfigScreen extends StatelessWidget {
  const _MissingConfigScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EJBL — Supabase Not Configured')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pass SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    SelectableText(
                      'flutter run -d chrome '
                      '--dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co '
                      '--dart-define=SUPABASE_ANON_KEY=sb_publishable_YOUR_KEY',
                      style: TextStyle(fontFamily: 'monospace'),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Use only your Publishable key (never your Secret/service_role key).',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  final _backend = EjblBackendService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _backend.authStateChanges,
      builder: (context, snapshot) {
        final session =
            snapshot.data?.session ?? Supabase.instance.client.auth.currentSession;
        if (session == null) {
          return _LoginScreen(backend: _backend);
        }
        return _BackendVerifyScreen(backend: _backend);
      },
    );
  }
}

class _LoginScreen extends StatefulWidget {
  final EjblBackendService backend;
  const _LoginScreen({required this.backend});

  @override
  State<_LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<_LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.backend.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'EJBL Bigasan',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text('Supabase Connection & Role Verification'),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email (admin / manager / staff)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _loading ? null : _submit(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign In'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackendVerifyScreen extends StatefulWidget {
  final EjblBackendService backend;
  const _BackendVerifyScreen({required this.backend});

  @override
  State<_BackendVerifyScreen> createState() => _BackendVerifyScreenState();
}

class _BackendVerifyScreenState extends State<_BackendVerifyScreen> {
  final _php = NumberFormat.currency(locale: 'en_PH', symbol: '₱');
  bool _loading = true;
  String? _error;
  UserProfile? _profile;
  List<InventorySummaryItem> _inventory = const [];
  List<Map<String, dynamic>> _consignments = const [];
  final Map<String, String> _rlsChecks = {};

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
      _rlsChecks.clear();
    });
    try {
      final profile = await widget.backend.getMyProfile();
      final inventory = await widget.backend.getInventorySummary();
      final consignments = await widget.backend.getConsignmentClients();

      await _probeRls('v_cashbook_entries (Manager/Admin)', () async {
        final rows = await widget.backend.getCashbookEntries(limit: 5);
        return 'Readable (${rows.length} rows)';
      });
      await _probeRls('void_audit_logs (Admin all / Manager own)', () async {
        final rows = await widget.backend.getVoidAuditLogs(limit: 5);
        return 'Readable (${rows.length} rows)';
      });
      await _probeRls('bir_ledger_entries (Admin only)', () async {
        final rows = await widget.backend.getBirEntries(limit: 5);
        return 'Readable (${rows.length} rows)';
      });

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _inventory = inventory;
        _consignments = consignments;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Connection or query failed: $e';
        _loading = false;
      });
    }
  }

  Future<void> _probeRls(String label, Future<String> Function() fn) async {
    try {
      _rlsChecks[label] = await fn();
    } on PostgrestException catch (e) {
      _rlsChecks[label] = 'Blocked / Error (${e.code ?? e.message})';
    } catch (e) {
      _rlsChecks[label] = 'Error ($e)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EJBL — Live Supabase Connection'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadAll,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Sign Out',
            onPressed: widget.backend.signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _loadAll,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.verified_user),
                        title: Text(_profile?.fullName ?? 'No profile row found'),
                        subtitle: Text(
                          'Role: ${_profile?.role.label ?? "UNKNOWN"} • '
                          '${widget.backend.currentUser?.email ?? ""}',
                        ),
                        trailing: Chip(
                          label: Text(
                            (_profile?.role.name ?? 'none').toUpperCase(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'RLS Access Check (Current Role)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            for (final entry in _rlsChecks.entries)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(entry.key)),
                                    Text(
                                      entry.value,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Consignment Clients (${_consignments.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _consignments
                          .map(
                            (c) => Chip(
                              label: Text(
                                '${c['business_name']} (${c['payment_schedule'] ?? 'Contract'})',
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Seeded Rice Varieties / Inventory (${_inventory.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    ..._inventory.map(
                      (item) => Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              item.code,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          title: Text('${item.name} (${item.code})'),
                          subtitle: Text(
                            'Wholesale/sack: ${_php.format(item.wholesaleSackPrice)} • '
                            'Retail/kg: ${_php.format(item.retailKgPrice)}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${item.totalRemainingKg.toStringAsFixed(1)} kg',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: item.isLowStock
                                      ? Colors.red
                                      : Colors.green[800],
                                ),
                              ),
                              Text('${item.remainingSacks} sacks'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
