import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/log_pendakian.dart';
import '../models/card_action_mode.dart';
import '../widgets/log_pendakian_card.dart';
import '../widgets/log_action_fab_menu.dart';
import 'log_pendakian_form.dart';

class LogPendakianListPage extends StatefulWidget {
  const LogPendakianListPage({super.key});

  @override
  State<LogPendakianListPage> createState() => _LogPendakianListPageState();
}

class _LogPendakianListPageState extends State<LogPendakianListPage> {
  static const String _baseUrl = "https://rasyad-zulham-gundex.pbp.cs.ui.ac.id/";

  late Future<void> _initialLoad;
  final List<LogPendakian> _logs = [];

  CardActionMode _mode = CardActionMode.none;
  bool _isFabMenuOpen = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _toggleFabMenu() {
    setState(() {
      _isFabMenuOpen = !_isFabMenuOpen;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initialLoad = _loadLogs();
  }

  Future<void> _loadLogs() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    final response = await request.get("$_baseUrl/log/json/");

    final Map<String, dynamic> jsonMap = response as Map<String, dynamic>;
    final List<dynamic> rawList = jsonMap['results'] as List<dynamic>;

    _logs
      ..clear()
      ..addAll(
        rawList
            .map((e) => LogPendakian.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
  }

  Future<void> _refreshLogs() async {
    _initialLoad = _loadLogs();
    setState(() {});
  }

  void _toggleEditMode() {
    setState(() {
      _mode = _mode == CardActionMode.edit
          ? CardActionMode.none
          : CardActionMode.edit;
    });
  }

  Future<void> _addLog() async {
    final created = await Navigator.push<LogPendakian>(
      context,
      MaterialPageRoute(
        builder: (_) => const LogPendakianFormPage(),
      ),
    );

    if (created == null) return;

    final request = context.read<CookieRequest>();
    final payload = {
      "gunung_id": created.gunungId,
      "start_date": created.startDate,
      "end_date": created.endDate,
      "summit_reached": created.summitReached,
      "team_size": created.teamSize,
      "rating": created.rating,
      "notes": created.notes,
    };

    final response = await request.postJson(
      "$_baseUrl/log/api/create/",
      jsonEncode(payload),
    ) as Map<String, dynamic>;

    if (!mounted) return;
    if (response["success"] == true) {
      await _refreshLogs();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Log pendakian berhasil ditambahkan.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Gagal menambah log: ${response["error"] ?? "Terjadi kesalahan."}",
          ),
        ),
      );
    }
  }

  Future<void> _editLog(int index) async {
    final current = _logs[index];

    final edited = await Navigator.push<LogPendakian>(
      context,
      MaterialPageRoute(
        builder: (_) => LogPendakianFormPage(initialLog: current),
      ),
    );

    if (edited == null) return;

    final request = context.read<CookieRequest>();
    final payload = {
      "gunung_id": edited.gunungId ?? current.gunungId,
      "start_date": edited.startDate,
      "end_date": edited.endDate,
      "summit_reached": edited.summitReached,
      "team_size": edited.teamSize,
      "rating": edited.rating,
      "notes": edited.notes,
    };

    final response = await request.postJson(
      "$_baseUrl/log/api/update/${current.id}/",
      jsonEncode(payload),
    ) as Map<String, dynamic>;

    if (!mounted) return;
    if (response["success"] == true) {
      await _refreshLogs();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perubahan log tersimpan.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Gagal mengubah log: ${response["error"] ?? "Terjadi kesalahan."}",
          ),
        ),
      );
    }
  }

  Future<void> _deleteLog(int index) async {
    final current = _logs[index];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: const Text("Hapus log"),
            content: const Text("Yakin ingin menghapus log ini?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Hapus",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    final request = context.read<CookieRequest>();
    final response = await request.postJson(
      "$_baseUrl/log/api/delete/${current.id}/",
      jsonEncode({}),
    ) as Map<String, dynamic>;

    if (!mounted) return;
    if (response["success"] == true) {
      await _refreshLogs();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Log pendakian terhapus.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Gagal menghapus log: ${response["error"] ?? "Terjadi kesalahan."}",
          ),
        ),
      );
    }
  }

  void _showDetails(LogPendakian log) {
    final dateText = (log.startDate != null && log.endDate != null)
        ? '${log.startDate} → ${log.endDate}'
        : (log.startDate ?? '');

    final hasPhoto = log.photoUrl != null && log.photoUrl!.trim().isNotEmpty;

    showDialog(
      context: context,
      builder: (ctx) {
        final size = MediaQuery
            .of(ctx)
            .size;
        final maxHeight = size.height * 0.9;
        final maxWidth = size.width * 0.9;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth.clamp(0, 520),
              // maksimum 520 biar gak kepanjangan
              maxHeight: maxHeight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ====== FOTO DI ATAS (opsional) ======
                if (hasPhoto)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.network(
                        log.photoUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                //  ISI UTAMA
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // header: judul + garis (statis)
                        Text(
                          log.gunungNama,
                          style: Theme
                              .of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),

                        // bagian yang bisa discroll
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  log.summitReached
                                      ? "Tercapai puncak"
                                      : "Belum sampai puncak",
                                  style:
                                  Theme
                                      .of(context)
                                      .textTheme
                                      .bodyMedium,
                                ),
                                if (log.teamSize != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    "${log.teamSize} orang",
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .bodyMedium,
                                  ),
                                ],
                                if (log.rating != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    "Rating: ${log.rating}/5 ⭐",
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .bodyMedium,
                                  ),
                                ],

                                if (log.notes != null &&
                                    log.notes!.trim().isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    "Catatan",
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .labelLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    log.notes!.trim(),
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .bodyMedium,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // footer: tanggal kiri, Tutup kanan (statis)
                        Row(
                          children: [
                            if (dateText.isNotEmpty)
                              Text(
                                dateText,
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("Tutup"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFCAD593), // sage
      backgroundColor: const Color(0xFFEFEFEF),
    appBar: AppBar(
        // backgroundColor: const Color(0xFF2A3C24), // Cal Poly Green
        backgroundColor: const Color(0xFF2A3C24),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("Log Pendakian"),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // SEARCH BAR DI BAWAH JUDUL
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Cari gunung...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // LIST LOG (PAKAI FUTUREBUILDER)
              Expanded(
                child: FutureBuilder<void>(
                  future: _initialLoad,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Terjadi kesalahan: ${snapshot.error}",
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    // filter berdasarkan search query
                    final query = _searchQuery.toLowerCase().trim();
                    final List<LogPendakian> visibleLogs = query.isEmpty
                        ? List<LogPendakian>.from(_logs)
                        : _logs
                        .where((log) =>
                        log.gunungNama
                            .toLowerCase()
                            .contains(query))
                        .toList();

                    if (visibleLogs.isEmpty) {
                      return const Center(
                        child: Text("Belum ada log pendakian."),
                      );
                    }

                    return ListView.builder(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: visibleLogs.length,
                      itemBuilder: (context, index) {
                        final log = visibleLogs[index];
                        final showInline = _mode == CardActionMode.edit;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: LogPendakianCard(
                            log: log,
                            showInlineActions: showInline,
                            onTapDetails: () => _showDetails(log),
                            onTapInlineEdit:
                            showInline ? () => _editLog(index) : null,
                            onTapInlineDelete:
                            showInline ? () => _deleteLog(index) : null,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // FAB MENU DI POJOK KANAN BAWAH
          LogActionFabMenu(
            mode: _mode,
            isMenuOpen: _isFabMenuOpen,
            onToggleMenu: _toggleFabMenu,
            onTapAdd: _addLog,
            onTapToggleEdit: _toggleEditMode,
          ),
        ],
      ),
    );
  }
}