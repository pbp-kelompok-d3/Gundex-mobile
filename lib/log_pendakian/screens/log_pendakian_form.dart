import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/log_pendakian.dart';
import 'package:gundex_mobile/explore_gunung/models/gunung.dart'; // Result, Gunung

class LogPendakianFormPage extends StatefulWidget {
  const LogPendakianFormPage({
    super.key,
    this.initialLog,
  });

  final LogPendakian? initialLog;

  @override
  State<LogPendakianFormPage> createState() => _LogPendakianFormPageState();
}

class _LogPendakianFormPageState extends State<LogPendakianFormPage> {
  final _formKey = GlobalKey<FormState>();

  static const String _baseUrl = "http://localhost:8000";

  late final TextEditingController _gunungController;
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  late final TextEditingController _teamSizeController;
  late final TextEditingController _ratingController;
  late final TextEditingController _notesController;

  bool _summitReached = false;
  Result? _selectedGunung; // dari ExploreGunung

  String? _startDateError;
  String? _endDateError;

  @override
  void initState() {
    super.initState();

    final init = widget.initialLog;
    _gunungController = TextEditingController(text: init?.gunungNama ?? '');
    _startController = TextEditingController(text: init?.startDate ?? '');
    _endController = TextEditingController(text: init?.endDate ?? '');
    _teamSizeController =
        TextEditingController(text: init?.teamSize?.toString() ?? '');
    _ratingController =
        TextEditingController(text: init?.rating?.toString() ?? '');
    _notesController = TextEditingController(text: init?.notes ?? '');
    _summitReached = init?.summitReached ?? false;

  }

  @override
  void dispose() {
    _gunungController.dispose();
    _startController.dispose();
    _endController.dispose();
    _teamSizeController.dispose();
    _ratingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final currentText = controller.text.trim();
    final initial = currentText.isNotEmpty
        ? DateTime.tryParse(currentText) ?? now
        : now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T').first;
    }
  }

  Future<void> _openGunungPicker() async {
    final Result? chosen = await showModalBottomSheet<Result>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _GunungPickerSheet(
          baseUrl: _baseUrl,
          initialSelectedId: _selectedGunung?.id ?? widget.initialLog?.gunungId,
        );
      },
    );

    if (chosen != null) {
      setState(() {
        _selectedGunung = chosen;
        _gunungController.text = chosen.nama;
      });
    }
  }

  void _submit() {
    // reset error tanggal dulu
    setState(() {
      _startDateError = null;
      _endDateError = null;
    });

    // Jalankan validator per-field (gunung & rating)
    if (!_formKey.currentState!.validate()) {
      // kalau ada field yang gagal validator (mis. rating 6)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Periksa kembali isian yang bertanda merah.'),
        ),
      );
      return;
    }

    final startText = _startController.text.trim();
    final endText = _endController.text.trim();

    String? toastMessage;
    DateTime? startDate;
    DateTime? endDate;

    // Wajib isi tanggal mulai
    if (startText.isEmpty) {
      _startDateError = 'Tanggal mulai wajib diisi';
      toastMessage ??= _startDateError;
    } else {
      startDate = DateTime.tryParse(startText);
      if (startDate == null) {
        _startDateError = 'Format tanggal mulai tidak valid';
        toastMessage ??= _startDateError;
      }
    }

    // Wajib isi tanggal selesai
    if (endText.isEmpty) {
      _endDateError = 'Tanggal selesai wajib diisi';
      toastMessage ??= _endDateError;
    } else {
      endDate = DateTime.tryParse(endText);
      if (endDate == null) {
        _endDateError = 'Format tanggal selesai tidak valid';
        toastMessage ??= _endDateError;
      }
    }

    // Kalau dua-duanya valid, cek urutan tanggal
    if (startDate != null && endDate != null) {
      if (endDate.isBefore(startDate)) {
        _endDateError =
        'Tanggal selesai tidak boleh sebelum tanggal mulai';
        toastMessage ??= _endDateError;
      }
    }

    // Kalau ada error tanggal apa pun
    if (toastMessage != null) {
      setState(() {}); // update errorText biar field jadi merah
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(toastMessage!)),
      );
      return;
    }

    // Rating sudah divalidasi lewat validator.
    int? rating;
    if (_ratingController.text.trim().isNotEmpty) {
      rating = int.tryParse(_ratingController.text.trim());
    }

    // Jumlah tim: opsional, tapi default = 1
    int teamSize;
    final teamText = _teamSizeController.text.trim();
    if (teamText.isEmpty) {
      teamSize = 1;
    } else {
      teamSize = int.tryParse(teamText) ?? 1;
      if (teamSize <= 0) teamSize = 1;
    }

    final existing = widget.initialLog;

    final log = LogPendakian(
      id: existing?.id ?? UniqueKey().toString(),
      gunungId: _selectedGunung?.id ?? existing?.gunungId,
      gunungNama: _selectedGunung?.nama ?? _gunungController.text.trim(),
      startDate: startText,
      endDate: endText,
      summitReached: _summitReached,
      teamSize: teamSize,
      rating: rating,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      durationDays: null,
      photoUrl: _selectedGunung?.foto ?? existing?.photoUrl,
    );

    Navigator.pop(context, log);
  }


  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialLog != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Log Pendakian' : 'Tambah Log Pendakian'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // PILIH GUNUNG
              TextFormField(
                controller: _gunungController,
                readOnly: true,
                onTap: _openGunungPicker,
                decoration: const InputDecoration(
                  labelText: 'Gunung',
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Gunung wajib dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // TANGGAL
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Tanggal mulai',
                        errorText: _startDateError, // <- bikin merah kalau ada error
                      ),
                      onTap: () => _pickDate(_startController),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _endController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Tanggal selesai',
                        errorText: _endDateError, // <- bikin merah kalau ada error
                      ),
                      onTap: () => _pickDate(_endController),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Tercapai puncak'),
                value: _summitReached,
                onChanged: (value) {
                  setState(() {
                    _summitReached = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _teamSizeController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah anggota tim (opsional)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _ratingController,
                decoration: const InputDecoration(
                  labelText: 'Rating pendakian 1–5 (opsional)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return null;

                  final r = int.tryParse(trimmed);
                  if (r == null) {
                    return 'Rating harus berupa angka';
                  }
                  if (r < 1 || r > 5) {
                    return 'Rating harus antara 1 dan 5';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submit,
                child: Text(isEdit ? 'Simpan Perubahan' : 'Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet untuk memilih gunung dari ExploreGunung.
///
/// Menggunakan endpoint:
///   GET /jsonall/?q=...
class _GunungPickerSheet extends StatefulWidget {
  const _GunungPickerSheet({
    required this.baseUrl,
    this.initialSelectedId,
  });

  final String baseUrl;
  final String? initialSelectedId;

  @override
  State<_GunungPickerSheet> createState() => _GunungPickerSheetState();
}

class _GunungPickerSheetState extends State<_GunungPickerSheet> {
  final TextEditingController _searchController = TextEditingController();

  // Simpan semua gunung dari server
  List<Result> _allItems = [];
  // List yang sudah difilter untuk ditampilkan
  List<Result> _items = [];

  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchGunung(); // load semua data sekali di awal
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter lokal berdasarkan nama gunung saja
  void _applyFilter() {
    final q = _searchController.text.trim().toLowerCase();

    setState(() {
      if (q.isEmpty) {
        _items = List<Result>.from(_allItems);
      } else {
        _items = _allItems
            .where(
              (g) => g.nama.toLowerCase().contains(q),
        )
            .toList();
      }
    });
  }

  // Ambil semua gunung sekali dari backend
  Future<void> _fetchGunung() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // tanpa ?q= -> backend kirim semua gunung
      final url = Uri.parse('${widget.baseUrl}/jsonall/');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);
        final data = Gunung.fromJson(jsonMap);

        setState(() {
          _allItems = data.results;
          _items = List<Result>.from(_allItems);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Gagal memuat data (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Terjadi kesalahan: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Cari gunung (berdasarkan nama)...',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                  ? Center(child: Text(_error))
                  : _items.isEmpty
                  ? const Center(
                child: Text('Tidak ada gunung yang cocok.'),
              )
                  : ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (_, __) =>
                const Divider(height: 1),
                itemBuilder: (context, index) {
                  final g = _items[index];
                  final bool isSelected =
                      g.id == widget.initialSelectedId;
                  return ListTile(
                    title: Text(g.nama),
                    subtitle: Text(
                      '${g.ketinggian} mdpl • ${g.provinsi}',
                    ),
                    trailing: isSelected
                        ? Icon(
                      Icons.check,
                      color: theme.colorScheme.primary,
                    )
                        : null,
                    onTap: () {
                      Navigator.pop<Result>(context, g);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

