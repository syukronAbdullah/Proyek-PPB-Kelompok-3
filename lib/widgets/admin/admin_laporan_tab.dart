import 'package:flutter/material.dart';

// import '../../models/laporan_model.dart';
import '../laporan/filter_chips.dart';

class AdminLaporanTab extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedFilter;
  final bool isLoading;
  final List<dynamic> laporanList;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onSearchPressed;
  final ValueChanged<String> onFilterChanged;
  final Future<void> Function() onRefresh;
  final Widget Function(dynamic laporan) itemBuilder;

  const AdminLaporanTab({
    super.key,
    required this.searchController,
    required this.selectedFilter,
    required this.isLoading,
    required this.laporanList,
    required this.onSearchSubmitted,
    required this.onSearchPressed,
    required this.onFilterChanged,
    required this.onRefresh,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    const filters = [
      {'id': 'semua', 'label': 'Semua'},
      {'id': 'menunggu', 'label': 'Menunggu'},
      {'id': 'diproses', 'label': 'Diproses'},
      {'id': 'selesai', 'label': 'Selesai'},
      {'id': 'ditolak', 'label': 'Ditolak'},
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Cari laporan...',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
                size: 20,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E5E5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E5E5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF1A5E35),
                  width: 1.5,
                ),
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Color(0xFF1A5E35),
                ),
                onPressed: onSearchPressed,
              ),
            ),
            onSubmitted: onSearchSubmitted,
          ),
        ),
        const SizedBox(height: 10),
        FilterChips(
          selectedFilter: selectedFilter,
          filters: filters,
          onChanged: onFilterChanged,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1A5E35),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: onRefresh,
                  color: const Color(0xFF1A5E35),
                  child: laporanList.isEmpty
                      ? const Center(
                          child: Text(
                            'Tidak ada laporan',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: laporanList.length,
                          itemBuilder: (_, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: itemBuilder(laporanList[index]),
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }
}