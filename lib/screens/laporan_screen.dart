import 'package:flutter/material.dart';
import '../models/laporan_model.dart';
import '../services/api_service.dart';
import 'detail_laporan_screen.dart'; 
import 'notifikasi_screen.dart';
import '../widgets/laporan/status_badge.dart';
import '../widgets/laporan/filter_chips.dart';
import '../widgets/laporan/laporan_card.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => LaporanScreenState();
}

class LaporanScreenState extends State<LaporanScreen> {
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
  final query = _searchController.text.trim().toLowerCase();

  setState(() {
    _filteredLaporan = _allLaporan.where((item) {
      final status = item.status.toLowerCase();

      final matchesStatus =
          _selectedFilter == 'semua' || status == _selectedFilter;

      final matchesSearch = query.isEmpty ||
          item.judul.toLowerCase().contains(query) ||
          item.namaKategori.toLowerCase().contains(query) ||
          item.lokasi.toLowerCase().contains(query);

      return matchesStatus && matchesSearch;
    }).toList();
  });
}

void applyFilterFromDashboard(String status) {
  setState(() {
    _selectedFilter = status;
  });

  _applyFilterAndSearch();
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
  const filters = [
    {'id': 'semua', 'label': 'Semua'},
    {'id': 'menunggu', 'label': 'Menunggu'},
    {'id': 'diproses', 'label': 'Diproses'},
    {'id': 'selesai', 'label': 'Selesai'},
    {'id': 'ditolak', 'label': 'Ditolak'},
  ];

  return FilterChips(
    selectedFilter: _selectedFilter,
    filters: filters,
    onChanged: (value) {
      setState(() {
        _selectedFilter = value;
      });
      _applyFilterAndSearch();
    },
  );
}
Widget _buildLaporanItem(LaporanModel item) {
  return LaporanCard(
    laporan: item,
    onTap: () async {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailLaporanScreen(laporan: item),
        ),
      );

      if (mounted) {
        _fetchListLaporan();
      }
    },
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