import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gundex_mobile/explore_gunung/models/gunung.dart';

class EditGunungScreen extends StatefulWidget {
  final Result gunung;

  const EditGunungScreen({super.key, required this.gunung});

  @override
  State<EditGunungScreen> createState() => _EditGunungScreenState();
}

class _EditGunungScreenState extends State<EditGunungScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _namaController;
  late TextEditingController _provinsiController;
  late TextEditingController _ketinggianController;
  late TextEditingController _deskripsiController;
  late TextEditingController _fotoController;

  final String baseUrl = "http://localhost:8000";

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.gunung.nama);
    _provinsiController = TextEditingController(text: widget.gunung.provinsi);
    _ketinggianController = TextEditingController(text: widget.gunung.ketinggian.toString());
    _deskripsiController = TextEditingController(text: widget.gunung.deskripsi);
    _fotoController = TextEditingController(text: widget.gunung.foto);
  }

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse('$baseUrl/gunung/${widget.gunung.id}/edit');
    
    final Map<String, dynamic> data = {
      'nama': _namaController.text,
      'provinsi': _provinsiController.text,
      'ketinggian': int.tryParse(_ketinggianController.text) ?? 0,
      'deskripsi': _deskripsiController.text,
      'foto': _fotoController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"}, 
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil disimpan!")),
        );
        Navigator.pop(context, true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: ${responseData['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Gunung")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: "Nama Gunung"),
                validator: (value) => value!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),
              TextFormField(
                controller: _provinsiController,
                decoration: const InputDecoration(labelText: "Provinsi"),
                validator: (value) => value!.isEmpty ? "Provinsi tidak boleh kosong" : null,
              ),
              TextFormField(
                controller: _ketinggianController,
                decoration: const InputDecoration(labelText: "Ketinggian (mdpl)"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _fotoController,
                decoration: const InputDecoration(labelText: "URL Foto"),
              ),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Simpan Perubahan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}