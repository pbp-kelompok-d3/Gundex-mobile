import 'dart:async'; 
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
  final String baseUrl = "https://rasyad-zulham-gundex.pbp.cs.ui.ac.id/";

  List<Result> _gunungList = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchGunung(CookieRequest request, [String query = ""]) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await request.get('$baseUrl/jsonall/?q=$query');

      Gunung responseData = Gunung.fromJson(response);

      if (mounted) {
        setState(() {
          _gunungList = responseData.results;
          _isAdmin = responseData.isAdmin;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
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

  void _onSearchChanged(String query, CookieRequest request) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = query;
      fetchGunung(request, query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    if (_gunungList.isEmpty && _isLoading && _searchQuery.isEmpty) {
      fetchGunung(request);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        title: const Text(
          "Explore Gunung",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF243010),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: const BoxDecoration(
              color: Color(0xFF243010), 
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: "Cari Nama atau Provinsi...",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => _onSearchChanged(value, request),
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await fetchGunung(request, _searchQuery);
              },
              color: const Color(0xFF243010),
              child: _isLoading
                  ? _buildSkeletonLoading() 
                  : _gunungList.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _gunungList.length,
                          itemBuilder: (context, index) {
                            final gunung = _gunungList[index];

                            return TweenAnimationBuilder(
                              duration: const Duration(milliseconds: 500),
                              tween: Tween<double>(begin: 0, end: 1),
                              curve: Curves.easeOutQuad,
                              builder: (context, double value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 50 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: GunungCard(
                                  namaGunung: gunung.nama,
                                  ketinggian: "${gunung.ketinggian} mdpl",
                                  lokasi: gunung.provinsi,
                                  imageUrl: gunung.foto,
                                  gunungId: gunung.id,
                                  isAdmin: _isAdmin && request.loggedIn,
                                  onTap: () {
                                    if (request.loggedIn) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              GunungDetailScreen(gunung: gunung),
                                        ),
                                      );
                                    } else {
                                      _showLoginDialog(context);
                                    }
                                  },
                                  onEdit: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditGunungScreen(gunung: gunung),
                                      ),
                                    );
                                    if (result == true) {
                                      fetchGunung(request, _searchQuery);
                                    }
                                  },
                                  onDelete: () {
                                    _showDeleteDialog(context, request, gunung);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4, 
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: 150, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    Container(height: 10, width: 100, color: Colors.grey[300]),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.landscape_rounded, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Gunung tidak ditemukan",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Coba cari dengan kata kunci lain.",
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Login Diperlukan"),
        content: const Text("Silakan login untuk melihat detail gunung."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF243010),
              foregroundColor: Colors.white,
            ),
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

  void _showDeleteDialog(BuildContext context, CookieRequest request, Result gunung) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Gunung"),
        content: Text("Yakin ingin menghapus ${gunung.nama}?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
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
  }
}