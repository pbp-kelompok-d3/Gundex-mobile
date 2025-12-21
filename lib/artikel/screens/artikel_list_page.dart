import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/artikel.dart';
import '../services/artikel_service.dart';
import 'artikel_detail_page.dart';
import 'artikel_form.dart';
import 'package:gundex_mobile/userprofile/login.dart';

class ArtikelListPage extends StatefulWidget {
  const ArtikelListPage({super.key});

  @override
  State<ArtikelListPage> createState() => _ArtikelListPageState();
}

class _ArtikelListPageState extends State<ArtikelListPage> {
  late Future<List<Artikel>> futureAll;
  late Future<List<Artikel>> futureSlider;

  String searchQuery = "";
  String sortOption = "A-Z";
  int _currentPage = 1;

  bool isAdmin = false;
  bool isAuthLoaded = false;

  // Slider
  final PageController _sliderController =
      PageController(initialPage: 5000);
  int _sliderIndex = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    // Future diinisialisasi di build karena perlu CookieRequest
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoSlide(_sliderController);
    });
  }

  void _loadAll(CookieRequest request) {
    futureAll = ArtikelService.fetchArtikelList(request);
    futureSlider =
        futureAll.then((list) => _pickRandom(list, 5));
  }

  Future<void> _refreshAll(CookieRequest request) async {
    setState(() {
      _loadAll(request);
      _currentPage = 1;
      _sliderIndex = 0;
    });
  }

  List<Artikel> _pickRandom(List<Artikel> list, int count) {
    if (list.isEmpty) return [];
    final rnd = Random();
    final copy = List<Artikel>.from(list);
    copy.shuffle(rnd);
    return copy.take(min(count, copy.length)).toList();
  }

  Future<void> _loadAuth(CookieRequest request) async {
    try {
      final res = await request.get(
        '${ArtikelService.baseUrl}/artikel/api/whoami/',
      );

      setState(() {
        isAdmin = res is Map && res['is_admin'] == true;
        isAuthLoaded = true;
      });
    } catch (_) {
      setState(() {
        isAdmin = false;
        isAuthLoaded = true;
      });
    }
  }

  void _startAutoSlide(PageController controller) {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) {
        if (!mounted) return;
        if (controller.hasClients) {
          controller.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _sliderController.dispose();
    super.dispose();
  }

  // ========================= BUILD UI =========================

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    _loadAll(request);
    if (!isAuthLoaded) {
      _loadAuth(request);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("GunDex — Artikel Pendakian"),
        backgroundColor: Colors.green,
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshAll(request),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // SLIDER
              // ============================================================
              FutureBuilder<List<Artikel>>(
                future: futureSlider,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 240,
                      child: Center(
                          child: CircularProgressIndicator()),
                    );
                  }

                  final sliderList = snapshot.data!;
                  if (sliderList.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final int realLength = sliderList.length;
                  const int virtualLength = 10000;

                  return Stack(
                    children: [
                      SizedBox(
                        height: 240,
                        child: PageView.builder(
                          controller: _sliderController,
                          itemCount: virtualLength,
                          onPageChanged: (index) {
                            setState(() =>
                                _sliderIndex = index % realLength);
                          },
                          itemBuilder: (_, index) {
                            final art =
                                sliderList[index % realLength];

                            return GestureDetector(
                              onTap: () async {
                                final updated =
                                    await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ArtikelDetailPage(
                                            artikelId: art.id),
                                  ),
                                );
                                if (updated == true) {
                                  _refreshAll(request);
                                }
                              },
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  _sliderImage(art),
                                  Container(
                                    alignment:
                                        Alignment.bottomCenter,
                                    padding:
                                        const EdgeInsets.all(16),
                                    color: Colors.black45,
                                    child: Text(
                                      art.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      textAlign:
                                          TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      _sliderNav(
                        icon: Icons.chevron_left,
                        alignLeft: true,
                        onTap: () => _sliderController
                            .previousPage(
                          duration:
                              const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                        ),
                      ),
                      _sliderNav(
                        icon: Icons.chevron_right,
                        alignLeft: false,
                        onTap: () => _sliderController.nextPage(
                          duration:
                              const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: List.generate(realLength, (i) {
                            return AnimatedContainer(
                              duration: const Duration(
                                  milliseconds: 300),
                              margin:
                                  const EdgeInsets.symmetric(
                                      horizontal: 4),
                              width:
                                  _sliderIndex == i ? 14 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _sliderIndex == i
                                    ? Colors.white
                                    : Colors.white54,
                                borderRadius:
                                    BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "Daftar Artikel",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),

              _buildSearchAndFilter(),
              _buildAllArticlesList(request),
            ],
          ),
        ),
      ),
      floatingActionButton: isAuthLoaded && isAdmin
          ? FloatingActionButton(
              onPressed: () async {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const ArtikelFormPage()),
                );
                if (created == true) {
                  _refreshAll(request);
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  // ========================= UI HELPERS =========================

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari artikel…",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _currentPage = 1;
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          DropdownButton<String>(
            value: sortOption,
            items: const [
              DropdownMenuItem(value: "A-Z", child: Text("A-Z")),
              DropdownMenuItem(value: "Z-A", child: Text("Z-A")),
              DropdownMenuItem(
                  value: "Paling Disukai",
                  child: Text("Paling Disukai")),
              DropdownMenuItem(
                  value: "Paling Populer",
                  child: Text("Paling Populer")),
              DropdownMenuItem(
                  value: "Paling Terbaru",  
                  child: Text("Paling Terbaru")),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  sortOption = val;
                  _currentPage = 1;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAllArticlesList(CookieRequest request) {
    return FutureBuilder<List<Artikel>>(
      future: futureAll,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator());
        }

        List<Artikel> list = snapshot.data!;

        list = list
            .where((a) =>
                a.title
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                a.description
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
            .toList();

        if (sortOption == "A-Z") {
          list.sort((a, b) => a.title.compareTo(b.title));
        } else if (sortOption == "Z-A") {
          list.sort((a, b) => b.title.compareTo(a.title));
        } else if (sortOption == "Paling Disukai") {
          list.sort((a, b) => b.likes.compareTo(a.likes));
        } else if (sortOption == "Paling Populer") {
          list.sort((a, b) => b.views.compareTo(a.views));
        } else if (sortOption == "Paling Terbaru") {
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }

        final int total = list.length;
        const int pageSize = 10;
        final int totalPages =
            max(1, (total / pageSize).ceil());
        final int currentPage =
            _currentPage.clamp(1, totalPages);

        final int startIndex = (currentPage - 1) * pageSize;
        final int endIndex =
            (startIndex + pageSize).clamp(0, total);

        final List<Artikel> pageItems =
            (startIndex < endIndex)
                ? list.sublist(startIndex, endIndex)
                : [];

        return Column(
          children: [
            for (var a in pageItems)
              Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: _thumb(a),
                  title: Text(a.title),
                  subtitle: Text(
                    a.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: _buildLikeButton(
                    a,
                    request,
                  ),
                  onTap: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArtikelDetailPage(
                            artikelId: a.id),
                      ),
                    );
                    if (updated == true) {
                      _refreshAll(request);
                    }
                  },
                ),
              ),
            _pagination(totalPages),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildLikeButton(
    Artikel a,
    CookieRequest request,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.favorite,
              color: Colors.red, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () async {
            try {
              await ArtikelService.likeArtikel(request, a.id);
              _refreshAll(request);
            } catch (_) {
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const LoginPage()),
              );
            }
          },
        ),
        Text(a.likes.toString()),
      ],
    );
  }

  Widget _pagination(int totalPages) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        if (_currentPage > 1)
          ElevatedButton(
            onPressed: () =>
                setState(() => _currentPage--),
            child: const Text("< Prev"),
          ),
        for (int i = 1; i <= totalPages; i++)
          InkWell(
            onTap: () => setState(() => _currentPage = i),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? Colors.green
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                i.toString(),
                style: TextStyle(
                  color: _currentPage == i
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ),
        if (_currentPage < totalPages)
          ElevatedButton(
            onPressed: () =>
                setState(() => _currentPage++),
            child: const Text("Next >"),
          ),
      ],
    );
  }

  Widget _sliderImage(Artikel a) {
    final url = a.proxied(ArtikelService.baseUrl);
    if (url == null || url.isEmpty) {
      return _defaultImage(large: true);
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          _defaultImage(large: true),
    );
  }

  Widget _thumb(Artikel a) {
    final url = a.proxied(ArtikelService.baseUrl);
    if (url == null || url.isEmpty) {
      return _defaultImage();
    }
    return Image.network(
      url,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _defaultImage(),
    );
  }

  Widget _defaultImage({bool large = false}) {
    return Container(
      width: large ? double.infinity : 60,
      height: large ? double.infinity : 60,
      color: const Color(0xFFE8F5E9),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.terrain,
              size: large ? 64 : 24,
              color: Colors.green),
          if (large) ...[
            const SizedBox(height: 8),
            const Text(
              'Gambar tidak tersedia',
              style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sliderNav({
    required IconData icon,
    required bool alignLeft,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: alignLeft ? 8 : null,
      right: alignLeft ? null : 8,
      top: 100,
      child: CircleAvatar(
        backgroundColor: Colors.black45,
        child: IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onTap,
        ),
      ),
    );
  }
}
