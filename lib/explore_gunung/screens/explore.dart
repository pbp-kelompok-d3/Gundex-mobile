import 'package:flutter/material.dart';
import 'package:gundex_mobile/explore_gunung/models/gunung.dart'; 
import 'package:gundex_mobile/explore_gunung/screens/edit.dart';
import 'package:gundex_mobile/explore_gunung/screens/detail.dart';
import 'package:gundex_mobile/explore_gunung/widgets/gunung_card.dart'; 
import 'package:gundex_mobile/userprofile/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ExploreGunungScreen extends StatefulWidget {
  const ExploreGunungScreen({super.key});

  @override
  State<ExploreGunungScreen> createState() => _ExploreGunungScreenState();
}

class _ExploreGunungScreenState extends State<ExploreGunungScreen> {
  final String baseUrl = "http://localhost:8000"; 
  
  List<Result> _gunungList = [];
  bool _isLoading = true;
  bool _isAdmin = false; 
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchGunung(CookieRequest request, [String query = ""]) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await request.get('$baseUrl/jsonall/?q=$query');
      
      Gunung responseData = Gunung.fromJson(response);
      
      if(mounted) {
        setState(() {
          _gunungList = responseData.results;
          _isAdmin = responseData.isAdmin; 
          _isLoading = false;
        });
      }
    } catch (e) {
      if(mounted) {
        setState(() {
          _isLoading = false;
          _isAdmin = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  Future<void> deleteGunung(CookieRequest request, String id) async {
    try {
      final response = await request.post('$baseUrl/json/$id/delete', {});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil dihapus!")),
        );
        fetchGunung(request, _searchQuery); 
      }
    } catch (e) {
      print("Error deleting: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    if (_gunungList.isEmpty && _isLoading) {
      fetchGunung(request);
    }

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
                fetchGunung(request, value);
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
                              
                              isAdmin: _isAdmin && request.loggedIn, 

                              onTap: () {
                                if (request.loggedIn) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GunungDetailScreen(gunung: gunung),
                                    ),
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Login Diperlukan"),
                                      content: const Text("Silakan login untuk melihat detail gunung."),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text("Batal"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const LoginPage()),
                                            );
                                          },
                                          child: const Text("Login"),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              
                              onEdit: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditGunungScreen(gunung: gunung),
                                  ),
                                );
                                if (result == true) {
                                  fetchGunung(request, _searchQuery);
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
                                          deleteGunung(request, gunung.id);
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