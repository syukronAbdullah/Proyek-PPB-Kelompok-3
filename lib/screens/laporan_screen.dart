import 'package:flutter/material.dart';
import '../models/laporan_model.dart';
import '../services/api_service.dart';
import 'detail_laporan_screen.dart'; 
import 'notifikasi_screen.dart'; 

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
        setState(() {
          _allLaporan = temp;
          _filteredLaporan = temp;
        });
        _applyFilterAndSearch();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilterAndSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLaporan = _allLaporan.where((item) {
        final matchesStatus = _selectedFilter == 'semua' || 
            item.status.toLowerCase() == _selectedFilter;
        final matchesSearch = item.judul.toLowerCase().contains(query) || 
            item.namaKategori.toLowerCase().contains(query);
        return matchesStatus && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          _buildSectionTitle(),
          _buildSearchBar(),
          _buildFilterBadges(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A5E35))))
                : _filteredLaporan.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchListLaporan,
                        color: const Color(0xFF1A5E35),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredLaporan.length,
                          itemBuilder: (context, index) => _buildLaporanItem(_filteredLaporan[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: const Text(
        'Riwayat Pengaduan',
        style: TextStyle(color: Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
        child: TextField(
          controller: _searchController,
          onChanged: (_) => _applyFilterAndSearch(),
          decoration: const InputDecoration(
            hintText: 'Cari judul pengaduan atau kategori...',
            hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBadges() {
    final filters = [
      {'id': 'semua', 'label': 'Semua'},
      {'id': 'menunggu', 'label': 'Menunggu'},
      {'id': 'proses', 'label': 'Proses'},
      {'id': 'selesai', 'label': 'Selesai'},
    ];

    return Container(
      height: 48,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final f = filters[index];
          final isSelected = _selectedFilter == f['id'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedFilter = f['id']!);
                _applyFilterAndSearch();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1A6B3A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    f['label']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLaporanItem(LaporanModel item) {
    Color statusColor;
    Color statusBg;
    final s = item.status.toLowerCase();

    if (s == 'menunggu') {
      statusColor = const Color(0xFFE07B00);
      statusBg = const Color(0xFFFFF3E0);
    } else if (s == 'selesai') {
      statusColor = const Color(0xFF1A6B3A);
      statusBg = const Color(0xFFE8F5EE);
    } else if (s == 'ditolak') {
      statusColor = const Color(0xFFDC2626);
      statusBg = const Color(0xFFFEF2F2);
    } else {
      statusColor = const Color(0xFF1565C0);
      statusBg = const Color(0xFFE3F2FD);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailLaporanScreen(laporan: item)),
          );
          if (mounted) {
            _fetchListLaporan();
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      item.namaKategori.toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      s == 'menunggu' ? 'Menunggu' : s == 'selesai' ? 'Selesai' : s == 'ditolak' ? 'Ditolak' : 'Diproses',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(item.judul, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.8, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(item.waktu, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  const Spacer(),
                  const Text('Detail ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A6B3A))),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF1A6B3A)),
                ],
              ),
            ],
          ),
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
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}