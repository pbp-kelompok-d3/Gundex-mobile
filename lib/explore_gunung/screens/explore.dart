import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gundex_mobile/explore_gunung/models/gunung.dart'; 
import 'package:gundex_mobile/explore_gunung/screens/edit.dart';
import 'package:gundex_mobile/explore_gunung/screens/detail.dart';
import 'package:gundex_mobile/explore_gunung/widgets/gunung_card.dart'; 

class ExploreGunungScreen extends StatefulWidget {
  const ExploreGunungScreen({super.key});

  @override
  State<ExploreGunungScreen> createState() => _ExploreGunungScreenState();
}

class _ExploreGunungScreenState extends State<ExploreGunungScreen> {
  final String baseUrl = "http://localhost:8000"; 
  
  List<Result> _gunungList = [];
  bool _isLoading = true;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchGunung();
  }

  Future<void> fetchGunung([String query = ""]) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('$baseUrl/jsonall/?q=$query');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);
        
        Gunung responseData = Gunung.fromJson(jsonMap);
        setState(() {
          _gunungList = responseData.results;
          _isLoading = false;
        });
      } else {
        throw Exception('Gagal load data');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> deleteGunung(String id) async {
    try {
      final url = Uri.parse('$baseUrl/json/$id/delete');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil dihapus!")),
        );
        fetchGunung(_searchQuery); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menghapus data.")),
        );
      }
    } catch (e) {
      print("Error deleting: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Explore Gunung")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Cari Nama atau Provinsi",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                _searchQuery = value;
                fetchGunung(value);
              },
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _gunungList.isEmpty
                    ? const Center(child: Text("Tidak ada data gunung ditemukan."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8), 
                        itemCount: _gunungList.length,
                        itemBuilder: (context, index) {
                          final gunung = _gunungList[index];
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: GunungCard(
                              namaGunung: gunung.nama,
                              ketinggian: "${gunung.ketinggian} mdpl", 
                              lokasi: gunung.provinsi,
                              imageUrl: gunung.foto,

                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GunungDetailScreen(gunung: gunung),
                                  ),
                                );
                              },
                              
                              onEdit: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditGunungScreen(gunung: gunung),
                                  ),
                                );
                                if (result == true) {
                                  fetchGunung(_searchQuery);
                                }
                              },
                              
                              onDelete: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Hapus Gunung"),
                                    content: Text("Yakin ingin menghapus ${gunung.nama}?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text("Batal"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          deleteGunung(gunung.id);
                                        },
                                        child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}