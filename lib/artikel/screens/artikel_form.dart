import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/artikel.dart';
import '../services/artikel_service.dart';

class ArtikelFormPage extends StatefulWidget {
  final Artikel? artikel;

  const ArtikelFormPage({super.key, this.artikel});

  @override
  State<ArtikelFormPage> createState() => _ArtikelFormPageState();
}

class _ArtikelFormPageState extends State<ArtikelFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;

  bool get isEdit => widget.artikel != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.artikel?.title ?? '');
    _descController =
        TextEditingController(text: widget.artikel?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit(CookieRequest request) async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    try {
      if (isEdit) {
        // ======================
        // EDIT ARTIKEL (POST)
        // ======================
        final response = await request.post(
          '${ArtikelService.baseUrl}/artikel/api/flutter/${widget.artikel!.id}/edit/',
          {
            'title': title,
            'description': desc,
          },
        );

        if (response is Map && response['error'] == 'LOGIN_REQUIRED') {
          throw Exception('LOGIN_REQUIRED');
        }
      } else {
        // ======================
        // CREATE ARTIKEL (POST)
        // ======================
        final response = await request.post(
          '${ArtikelService.baseUrl}/artikel/api/flutter/create/',
          {
            'title': title,
            'description': desc,
          },
        );

        if (response is Map && response['error'] == 'LOGIN_REQUIRED') {
          throw Exception('LOGIN_REQUIRED');
        }
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan artikel: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Artikel' : 'Buat Artikel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration:
                    const InputDecoration(labelText: 'Judul Artikel'),
                validator: (value) =>
                    value!.trim().isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Artikel',
                  alignLabelWithHint: true,
                ),
                validator: (value) =>
                    value!.trim().isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),

              // INFO PENTING
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Catatan:\n'
                  '- Upload gambar tidak tersedia di versi mobile.\n'
                  '- Gambar artikel dapat diatur melalui web/admin.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => _submit(request),
          child: Text(isEdit ? 'Simpan Perubahan' : 'Buat Artikel'),
        ),
      ),
    );
  }
}