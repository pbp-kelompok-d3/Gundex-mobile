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

  final String baseUrl = "https://rasyad-zulham-gundex.pbp.cs.ui.ac.id/";
  final Color _primaryColor = const Color(0xFF243010);
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.gunung.nama);
    _provinsiController = TextEditingController(text: widget.gunung.provinsi);
    _ketinggianController = TextEditingController(text: widget.gunung.ketinggian.toString());
    _deskripsiController = TextEditingController(text: widget.gunung.deskripsi);
    _fotoController = TextEditingController(text: widget.gunung.foto);

    _fotoController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _provinsiController.dispose();
    _ketinggianController.dispose();
    _deskripsiController.dispose();
    _fotoController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true; 
    });

    final url = Uri.parse('$baseUrl/gunung/${widget.gunung.id}/edit');

    final Map<String, dynamic> data = {
      'nama': _namaController.text,
      'provinsi': _provinsiController.text,
      'ketinggian': int.tryParse(_ketinggianController.text) ?? 0,
      'deskripsi': _deskripsiController.text,
      'foto': _fotoController.text,
    };

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);

      if (mounted) {
        if (response.statusCode == 200 && responseData['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Data berhasil disimpan!"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal: ${responseData['message']}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false; 
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text("Edit Gunung"),
        backgroundColor: Colors.transparent, 
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            _buildAnimatedHeader(),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildEntryAnimation(
                      delay: 100,
                      child: _buildSectionTitle("Informasi Dasar"),
                    ),
                    const SizedBox(height: 15),
                    
                    _buildEntryAnimation(
                      delay: 200,
                      child: _buildCustomTextField(
                        controller: _namaController,
                        label: "Nama Gunung",
                        icon: Icons.landscape,
                        validator: (value) => value!.isEmpty ? "Nama tidak boleh kosong" : null,
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    _buildEntryAnimation(
                      delay: 300,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildCustomTextField(
                              controller: _provinsiController,
                              label: "Provinsi",
                              icon: Icons.map,
                              validator: (value) => value!.isEmpty ? "Wajib diisi" : null,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildCustomTextField(
                              controller: _ketinggianController,
                              label: "Ketinggian",
                              icon: Icons.height,
                              suffixText: "mdpl",
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 25),
                    _buildEntryAnimation(
                      delay: 400,
                      child: _buildSectionTitle("Detail & Media"),
                    ),
                    const SizedBox(height: 15),

                    _buildEntryAnimation(
                      delay: 500,
                      child: _buildCustomTextField(
                        controller: _fotoController,
                        label: "URL Foto",
                        icon: Icons.link,
                        hint: "https://example.com/image.jpg",
                      ),
                    ),
                    const SizedBox(height: 15),

                    _buildEntryAnimation(
                      delay: 600,
                      child: _buildCustomTextField(
                        controller: _deskripsiController,
                        label: "Deskripsi",
                        icon: Icons.description,
                        maxLines: 4,
                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 40),

                    _buildEntryAnimation(
                      delay: 700,
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: _isSaving ? null : saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 8,
                              shadowColor: _primaryColor.withOpacity(0.5),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.save_rounded),
                                        SizedBox(width: 8),
                                        Text(
                                          "Simpan Perubahan",
                                          style: TextStyle(
                                              fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _isSaving ? null : () => Navigator.pop(context),
                            child: Text(
                              "Batal",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAnimatedHeader() {
    return Container(
      height: 300, 
      width: double.infinity,
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _fotoController.text.isNotEmpty
                  ? Image.network(
                      'https://rasyad-zulham-gundex.pbp.cs.ui.ac.id/proxy-image/?url=${Uri.encodeComponent(_fotoController.text)}',
                      key: ValueKey<String>(_fotoController.text), 
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: _primaryColor,
                        child: const Icon(Icons.image_not_supported, color: Colors.white30, size: 50),
                      ),
                    )
                  : Container(
                      color: _primaryColor,
                      child: const Icon(Icons.add_a_photo, color: Colors.white30, size: 50),
                    ),
            ),
          ),
          
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                  Colors.black.withOpacity(0.4), 
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _namaController.text.isEmpty ? "Nama Gunung" : _namaController.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Preview Tampilan",
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryAnimation({required Widget child, required int delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart, 
      builder: (context, value, child) {
        
        
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)), 
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: FutureBuilder(
        future: Future.delayed(Duration(milliseconds: delay)),
        builder: (context, snapshot) {
          return snapshot.connectionState == ConnectionState.done 
            ? child 
            : const SizedBox.shrink(); 
        },
      ),
    );
  }
  
  
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? suffixText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool alignLabelWithHint = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffixText,
        alignLabelWithHint: alignLabelWithHint,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }
}