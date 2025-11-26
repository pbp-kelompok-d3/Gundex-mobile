import 'package:flutter/material.dart';
import 'lod_pendakian_list.dart';

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

  late final TextEditingController _gunungController;
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  late final TextEditingController _teamSizeController;
  late final TextEditingController _ratingController;
  late final TextEditingController _notesController;

  bool _summitReached = false;

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
    final initial = controller.text.isNotEmpty
        ? DateTime.tryParse(controller.text) ?? now
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final existing = widget.initialLog;

    final log = LogPendakian(
      id: existing?.id ?? UniqueKey().toString(),
      gunungNama: _gunungController.text.trim(),
      startDate: _startController.text.trim().isEmpty
          ? null
          : _startController.text.trim(),
      endDate: _endController.text.trim().isEmpty
          ? null
          : _endController.text.trim(),
      summitReached: _summitReached,
      teamSize: _teamSizeController.text.isEmpty
          ? null
          : int.tryParse(_teamSizeController.text),
      rating: _ratingController.text.isEmpty
          ? null
          : int.tryParse(_ratingController.text),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      durationDays: null,
      photoUrl: existing?.photoUrl,
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
              TextFormField(
                controller: _gunungController,
                decoration: const InputDecoration(
                  labelText: 'Nama gunung',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama gunung wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal mulai',
                      ),
                      onTap: () => _pickDate(_startController),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _endController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal selesai',
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
                  labelText: 'Rating pendakian 1-5 (opsional)',
                ),
                keyboardType: TextInputType.number,
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
