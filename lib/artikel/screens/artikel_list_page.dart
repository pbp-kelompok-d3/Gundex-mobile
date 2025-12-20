import 'package:flutter/material.dart';
import '../models/artikel.dart';
import '../services/artikel_service.dart';
import '../screens/artikel_detail_page.dart';
import '../screens/artikel_form.dart';
import 'dart:async';
import 'dart:math';

class ArtikelListPage extends StatefulWidget {
  const ArtikelListPage({super.key});

  @override
  State<ArtikelListPage> createState() => _ArtikelListPageState();
}

class _ArtikelListPageState extends State<ArtikelListPage> {
  late Future<List<Artikel>> futureAll;
  late Future<List<Artikel>> futureSlider; // random slider items

  String searchQuery = "";
  String sortOption = "A-Z";
  int _currentPage = 1;

  // Slider
  final PageController _sliderController = PageController(initialPage: 5000);
  int _sliderIndex = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _loadAll();

    // start auto-slide once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoSlide(_sliderController);
    });
  }

  void _loadAll() {
    futureAll = ArtikelService.fetchArtikelList();
    futureSlider = futureAll.then((list) => _pickRandom(list, 5));
  }

  Future<void> _refreshAll() async {
    setState(() {
      _loadAll();
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

  Widget _buildLikeCount(int likes) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.favorite, size: 16, color: Colors.red),
        Text(likes.toString()),
      ],
    );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("GunDex — Artikel Pendakian"),
        backgroundColor: Colors.green,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ============================================================
                  // SLIDER RANDOM (maks 5 artikel, ambil dari semua artikel)
                  // ============================================================
                  FutureBuilder<List<Artikel>>(
                    future: futureSlider,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox(
                          height: 240,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final sliderList = snapshot.data!;
                      if (sliderList.isEmpty) return const SizedBox.shrink();

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
                                setState(() => _sliderIndex = index % realLength);
                              },
                              itemBuilder: (_, index) {
                                final art = sliderList[index % realLength];

                                return GestureDetector(
                                  onTap: () async {
                                    final updated = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ArtikelDetailPage(
                                          artikelId: art.id,
                                        ),
                                      ),
                                    );
                                    if (updated == true) _refreshAll();
                                  },
                                  
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        art.proxied(ArtikelService.baseUrl) ?? "",
                                        fit: BoxFit.cover,
                                      ),

                                      Container(
                                        alignment: Alignment.bottomCenter,
                                        padding: const EdgeInsets.all(16),
                                        color: Colors.black45,
                                        child: Text(
                                          art.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          // PREV
                          Positioned(
                            left: 8,
                            top: 100,
                            child: CircleAvatar(
                              backgroundColor: Colors.black45,
                              child: IconButton(
                                icon: const Icon(Icons.chevron_left, color: Colors.white),
                                onPressed: () {
                                  _sliderController.previousPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOut,
                                  );
                                },
                              ),
                            ),
                          ),

                          // NEXT
                          Positioned(
                            right: 8,
                            top: 100,
                            child: CircleAvatar(
                              backgroundColor: Colors.black45,
                              child: IconButton(
                                icon: const Icon(Icons.chevron_right, color: Colors.white),
                                onPressed: () {
                                  _sliderController.nextPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOut,
                                  );
                                },
                              ),
                            ),
                          ),

                          // DOTS
                          Positioned(
                            bottom: 12,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(realLength, (i) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: _sliderIndex == i ? 14 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _sliderIndex == i ? Colors.white : Colors.white54,
                                    borderRadius: BorderRadius.circular(4),
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

                  // ============================================================
                  // SEMUA ARTIKEL + SEARCH + FILTER + PAGINATION
                  // ============================================================

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "Daftar Artikel",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),

                  _buildSearchAndFilter(),
                  _buildAllArticlesList(),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ArtikelFormPage()),
          );
          if (created == true) _refreshAll();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // ================================================================
  // SEARCH + FILTER UI
  // ================================================================

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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
              DropdownMenuItem(value: "Paling Disukai", child: Text("Paling Disukai")),
              DropdownMenuItem(value: "Paling Populer", child: Text("Paling Populer")),
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

  // ================================================================
  // LIST SEMUA ARTIKEL
  // ================================================================

  Widget _buildAllArticlesList() {
    return FutureBuilder<List<Artikel>>(
      future: futureAll,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Artikel> list = snapshot.data!;

        // FILTER SEARCH
        list = list
            .where((a) =>
                a.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                a.description.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

        // SORTING
        if (sortOption == "A-Z") {
          list.sort((a, b) => a.title.compareTo(b.title));
        } else if (sortOption == "Z-A") {
          list.sort((a, b) => b.title.compareTo(a.title));
        } else if (sortOption == "Paling Disukai") {
          list.sort((a, b) => b.likes.compareTo(a.likes));
        } else if (sortOption == "Paling Populer") {
          list.sort((a, b) => b.views.compareTo(a.views));
        }

        // PAGINATION
        final int total = list.length;
        const int pageSize = 10;
        final int totalPages = max(1, (total / pageSize).ceil());
        final int currentPage = _currentPage.clamp(1, totalPages);

        final int startIndex = (currentPage - 1) * pageSize;
        final int endIndex = (startIndex + pageSize).clamp(0, total);

        final List<Artikel> pageItems =
            (startIndex < endIndex) ? list.sublist(startIndex, endIndex) : [];

        return Column(
          children: [
            for (var a in pageItems)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: _thumb(a),
                  title: Text(a.title),
                  subtitle: Text(
                    a.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: _buildLikeCount(a.likes),
                  onTap: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArtikelDetailPage(artikelId: a.id),
                      ),
                    );
                    if (updated == true) _refreshAll();
                  },
                ),
              ),

            const SizedBox(height: 12),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                if (currentPage > 1)
                  ElevatedButton(
                    onPressed: () => setState(() => _currentPage--),
                    child: const Text("< Prev"),
                  ),

                for (int i = 1; i <= totalPages; i++)
                  InkWell(
                    onTap: () => setState(() => _currentPage = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _currentPage == i ? Colors.green : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        i.toString(),
                        style: TextStyle(
                          color: _currentPage == i ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),

                if (currentPage < totalPages)
                  ElevatedButton(
                    onPressed: () => setState(() => _currentPage++),
                    child: const Text("Next >"),
                  ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  // ================================================================
  // HELPER WIDGETS
  // ================================================================

  Widget _thumb(Artikel a) {
    return (a.image != null && a.image!.isNotEmpty)
        ? Image.network(
            a.proxied(ArtikelService.baseUrl) ?? "",
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          )
        : const Icon(Icons.image);
  }
}

