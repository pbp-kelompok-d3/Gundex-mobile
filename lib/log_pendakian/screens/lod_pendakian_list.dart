import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'log_pendakian_form.dart';

class LogPendakian {
  final String id;
  final String gunungNama;
  final String? startDate;
  final String? endDate;
  final bool summitReached;
  final int? teamSize;
  final int? rating;
  final String? notes;
  final int? durationDays;
  final String? photoUrl;

  LogPendakian({
    required this.id,
    required this.gunungNama,
    required this.startDate,
    required this.endDate,
    required this.summitReached,
    required this.teamSize,
    required this.rating,
    required this.notes,
    required this.durationDays,
    this.photoUrl,
  });

  factory LogPendakian.fromJson(Map<String, dynamic> json) {
    return LogPendakian(
      id: json['id'].toString(),
      gunungNama: (json['gunung_nama'] ?? '-') as String,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      summitReached: (json['summit_reached'] ?? false) as bool,
      teamSize: json['team_size'] as int?,
      rating: json['rating'] as int?,
      notes: json['notes'] as String?,
      durationDays: json['duration_days'] as int?,
      photoUrl: json['photo_url'] as String?,
    );
  }
}

enum CardActionMode { none, editDelete }

class LogPendakianListPage extends StatefulWidget {
  const LogPendakianListPage({super.key});

  @override
  State<LogPendakianListPage> createState() => _LogPendakianListPageState();
}

class _LogPendakianListPageState extends State<LogPendakianListPage> {
  late Future<void> _initialLoad;
  final List<LogPendakian> _logs = [];
  CardActionMode _mode = CardActionMode.none;

  @override
  void initState() {
    super.initState();
    _initialLoad = _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await _fetchLogs();
    _logs
      ..clear()
      ..addAll(logs);
  }

  Future<List<LogPendakian>> _fetchLogs() async {
    const String baseUrl = "http://127.0.0.1:8000";
    final response = await http.get(Uri.parse('$baseUrl/log/json/'));

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat log pendakian: ${response.statusCode}');
    }

    final decoded =
    jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final List<dynamic> rawList = decoded['results'] as List<dynamic>;

    return rawList
        .map((e) => LogPendakian.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _addLog() async {
    final newLog = await Navigator.push<LogPendakian>(
      context,
      MaterialPageRoute(
        builder: (_) => const LogPendakianFormPage(),
      ),
    );

    if (newLog != null) {
      setState(() {
        _logs.add(newLog);
      });
    }
  }

  Future<void> _editLog(int index) async {
    final edited = await Navigator.push<LogPendakian>(
      context,
      MaterialPageRoute(
        builder: (_) => LogPendakianFormPage(
          initialLog: _logs[index],
        ),
      ),
    );

    if (edited != null) {
      setState(() {
        _logs[index] = edited;
      });
    }
  }

  Future<void> _deleteLog(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus log'),
        content: const Text('Yakin ingin menghapus log ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _logs.removeAt(index);
      });
    }
  }

  void _enterEditMode() {
    if (_logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada log yang bisa diedit / dihapus.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _mode = CardActionMode.editDelete;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mode edit aktif. Gunakan ikon di samping "Details".'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exitEditMode() {
    if (_mode != CardActionMode.none) {
      setState(() {
        _mode = CardActionMode.none;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const apple = Color(0xFF87A330);

    final content = FutureBuilder<void>(
      future: _initialLoad,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Terjadi kesalahan: ${snapshot.error}'),
          );
        }

        if (_logs.isEmpty) {
          return const Center(
            child: Text('Belum ada log pendakian.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _logs.length,
          itemBuilder: (context, index) {
            final log = _logs[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LogPendakianCard(
                log: log,
                mode: _mode,
                onEdit: () => _editLog(index),
                onDelete: () => _deleteLog(index),
              ),
            );
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Pendakian'),
      ),
      body: Stack(
        children: [
          content,
          Positioned(
            bottom: 16,
            right: 16,
            child: _GlobalActionMenu(
              baseColor: apple,
              bubbleColor: apple,
              isEditMode: _mode == CardActionMode.editDelete,
              onAdd: _addLog,
              onEnterEditMode: _enterEditMode,
              onExitEditMode: _exitEditMode,
            ),
          ),
        ],
      ),
    );
  }
}

class LogPendakianCard extends StatelessWidget {
  final LogPendakian log;
  final CardActionMode mode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LogPendakianCard({
    super.key,
    required this.log,
    required this.mode,
    required this.onEdit,
    required this.onDelete,
  });

  String _dateRange() {
    if (log.startDate == null && log.endDate == null) {
      return '-';
    }
    return '${log.startDate ?? '-'} → ${log.endDate ?? '-'}';
  }

  String _statusLine() {
    final parts = <String>[];
    parts.add(log.summitReached ? 'Tercapai puncak' : 'Belum sampai puncak');
    if (log.teamSize != null) parts.add('${log.teamSize} orang');
    if (log.rating != null) parts.add('⭐ ${log.rating}/5');
    return parts.join(' • ');
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.gunungNama,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _dateRange(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusLine(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Catatan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (log.notes == null || log.notes!.trim().isEmpty)
                        ? 'Tidak ada catatan.'
                        : log.notes!,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSmallCircle({
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const apple = Color(0xFF87A330);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: log.photoUrl != null
                ? Image.network(
              log.photoUrl!,
              fit: BoxFit.cover,
            )
                : Container(
              color: Colors.white,
              child: Icon(
                Icons.landscape,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: log.gunungNama,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const TextSpan(text: ' • '),
                      TextSpan(
                        text: _dateRange(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _statusLine(),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                if (log.notes != null && log.notes!.trim().isNotEmpty)
                  Text(
                    log.notes!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[800],
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Spacer(),
                    if (mode == CardActionMode.editDelete) ...[
                      _buildSmallCircle(
                        color: Colors.red[400]!,
                        icon: Icons.delete,
                        onTap: onDelete,
                      ),
                      const SizedBox(width: 8),
                      _buildSmallCircle(
                        color: apple,
                        icon: Icons.edit,
                        onTap: onEdit,
                      ),
                      const SizedBox(width: 8),
                    ],
                    TextButton(
                      onPressed: () => _showDetails(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        backgroundColor: Colors.blue[100],
                        foregroundColor: Colors.blue[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text(
                        'Details',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlobalActionMenu extends StatefulWidget {
  final Color baseColor;
  final Color bubbleColor;
  final bool isEditMode;
  final VoidCallback onAdd;
  final VoidCallback onEnterEditMode;
  final VoidCallback onExitEditMode;

  const _GlobalActionMenu({
    required this.baseColor,
    required this.bubbleColor,
    required this.isEditMode,
    required this.onAdd,
    required this.onEnterEditMode,
    required this.onExitEditMode,
  });

  @override
  State<_GlobalActionMenu> createState() => _GlobalActionMenuState();
}

class _GlobalActionMenuState extends State<_GlobalActionMenu>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _controller;
  late final Animation<double> _scale;

  static const double _baseSize = 56;
  static const double _bubbleSize = 52;
  static const double _margin = 10;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  double _bubbleBottom(int orderFromBottom) {
    return _baseSize + _margin + (_bubbleSize + _margin) * orderFromBottom;
  }

  @override
  Widget build(BuildContext context) {
    final showBubbles = !widget.isEditMode && _open;

    return SizedBox(
      width: _bubbleSize,
      height: _baseSize + 2 * (_bubbleSize + _margin) + _margin,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (showBubbles) ...[
            Positioned(
              right: 0,
              bottom: _bubbleBottom(0),
              child: FadeTransition(
                opacity: _scale,
                child: ScaleTransition(
                  scale: _scale,
                  child: GestureDetector(
                    onTap: () {
                      widget.onEnterEditMode();
                      _toggleMenu();
                    },
                    child: Container(
                      width: _bubbleSize,
                      height: _bubbleSize,
                      decoration: BoxDecoration(
                        color: widget.bubbleColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: _bubbleBottom(1),
              child: FadeTransition(
                opacity: _scale,
                child: ScaleTransition(
                  scale: _scale,
                  child: GestureDetector(
                    onTap: () {
                      widget.onAdd();
                      _toggleMenu();
                    },
                    child: Container(
                      width: _bubbleSize,
                      height: _bubbleSize,
                      decoration: BoxDecoration(
                        color: widget.bubbleColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                if (widget.isEditMode) {
                  widget.onExitEditMode();
                } else {
                  _toggleMenu();
                }
              },
              child: Container(
                width: _baseSize,
                height: _baseSize,
                decoration: BoxDecoration(
                  color: widget.baseColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  widget.isEditMode ? Icons.close : Icons.more_vert,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
