import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/artikel.dart';
import '../services/artikel_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

  File? _imageFile;

  // Untuk Web
  Uint8List? _imageBytes;
  String? _imageName;

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = picked.name;
      });
    } else {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    try {
      if (isEdit) {
        final ok = await ArtikelService.editArtikel(
          id: widget.artikel!.id,
          title: title,
          description: desc,
          imageFile: _imageFile,
          imageBytes: _imageBytes,
          imageName: _imageName,
        );

        if (ok && mounted) Navigator.pop(context, true);
      } else {
        await ArtikelService.createArtikel(
          title: title,
          description: desc,
          imageFile: _imageFile,
          imageBytes: _imageBytes,
          imageName: _imageName,
        );

        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    }
  }

  Widget _buildImagePreview() {
    // 1. New selected image (Web)
    if (_imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          _imageBytes!,
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    // 2. New selected image (Android/iOS)
    if (_imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          _imageFile!,
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    // 3. Old image (EDIT MODE)
    if (isEdit && widget.artikel!.image != null && widget.artikel!.image!.isNotEmpty) {
      final url = widget.artikel!.proxied(ArtikelService.baseUrl);
      if (url == null) return const SizedBox();

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 160,
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            child: const Icon(Icons.image_not_supported),
          ),
        ),
      );
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
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
                decoration: const InputDecoration(labelText: 'Judul Artikel'),
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
              const SizedBox(height: 12),

              Text('Gambar (opsional)',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),

              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pilih dari galeri'),
              ),

              const SizedBox(height: 12),

              _buildImagePreview(),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _submit,
          child: Text(isEdit ? 'Simpan Perubahan' : 'Buat Artikel'),
        ),
      ),
    );
  }
}
