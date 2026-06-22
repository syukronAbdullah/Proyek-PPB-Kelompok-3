import 'package:flutter/material.dart';
import '../Models/laporan_model.dart';
import '../services/api_service.dart';
import 'detail_laporan_screen.dart'; 
import 'notifikasi_screen.dart'; // Memastikan file notifikasi ter-import dengan benar

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  bool _isLoading = true;
  List<LaporanModel> _allLaporan = [];
  List<LaporanModel> _filteredLaporan = [];
  String _selectedFilter = 'semua';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchListLaporan();
  }

  Future<void> _fetchListLaporan() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getLaporan();
      if (response != null && response['success'] == true) {
        final List<dynamic> listRaw = response['laporan'] ?? [];
        final List<LaporanModel> temp = [];
        for (var item in listRaw) {
          if (item is Map<String, dynamic>) {
            temp.add(LaporanModel.fromJson(item));
          }
        }
        if (mounted) {
          setState(() {
            _allLaporan = temp;
            _applyFilterAndSearch();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat riwayat laporan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilterAndSearch() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLaporan = _allLaporan.where((laporan) {
        bool matchesFilter = _selectedFilter == 'semua' || 
            laporan.status.toLowerCase() == _selectedFilter;
        bool matchesSearch = laporan.judul.toLowerCase().contains(query) || 
            laporan.namaKategori.toLowerCase().contains(query);
        return matchesFilter && matchesSearch;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 26),
          onPressed: () {},
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D4A28), Color(0xFF1A6B3A)],
            ),
          ),
        ),
        title: const Text(
          'Laporan Saya',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
            onPressed: () {
              // Jalur Klik Lonceng Atas: Meluncur ke halaman notifikasi dengan tombol Back!
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotifikasiScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchListLaporan,
        color: const Color(0xFF1A5E35),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildFilterChips(),
            _buildSearchBox(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A5E35)),
                      ),
                    )
                  : _filteredLaporan.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredLaporan.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildLaporanCard(_filteredLaporan[index]),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'semua', 'label': 'Semua'},
      {'key': 'menunggu', 'label': 'Menunggu'},
      {'key': 'diproses', 'label': 'Diproses'},
      {'key': 'selesai', 'label': 'Selesai'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((f) {
          bool isSelected = _selectedFilter == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f['label']!),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _selectedFilter = f['key']!;
                    _applyFilterAndSearch();
                  });
                }
              },
              selectedColor: const Color(0xFF1A5E35),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? Colors.transparent : const Color(0xFFCBD5E1)),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => _applyFilterAndSearch(),
          decoration: const InputDecoration(
            hintText: 'Cari laporan...',
            hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8)),
            suffixIcon: Icon(Icons.tune_rounded, color: Color(0xFF64748B)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildLaporanCard(LaporanModel item) {
    Color statusColor;
    Color statusBg;
    Color leftBorderColor;
    
    final currentStatus = item.status.toLowerCase();
    
    if (currentStatus == 'menunggu') {
      statusColor = const Color(0xFFE07B00);
      statusBg = const Color(0xFFFFF3E0);
      leftBorderColor = const Color(0xFFFFB300);
    } else if (currentStatus == 'selesai') {
      statusColor = const Color(0xFF1A6B3A);
      statusBg = const Color(0xFFE8F5EE);
      leftBorderColor = const Color(0xFF2E7D32);
    } else {
      statusColor = const Color(0xFF1565C0);
      statusBg = const Color(0xFFE3F2FD);
      leftBorderColor = const Color(0xFF1E88E5);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailLaporanScreen(laporan: item),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 5, color: leftBorderColor),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(21, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'L-${item.id.toString().padLeft(4, '0')}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          currentStatus == 'menunggu' ? 'Menunggu' : (currentStatus == 'selesai' ? 'Selesai' : 'Diproses'),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.judul,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.category_outlined, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(item.namaKategori, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(item.lokasi, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, thickness: 0.8, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(item.waktu, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      const Spacer(),
                      const Text(
                        'Detail ',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A6B3A)),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF1A6B3A)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const SizedBox(height: 50),
            Icon(Icons.assignment_turned_in_outlined, size: 80, color: const Color(0xFF1A5E35).withOpacity(0.4)),
            const SizedBox(height: 16),
            const Text(
              'Menampilkan semua riwayat laporan Anda\ndi lingkungan Kampus UIN.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}