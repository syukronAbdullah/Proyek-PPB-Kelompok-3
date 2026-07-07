import 'package:flutter/material.dart';

class FilterChips extends StatelessWidget {
  final String selectedFilter;
  final List<Map<String, String>> filters;
  final ValueChanged<String> onChanged;

  const FilterChips({
    super.key,
    required this.selectedFilter,
    required this.filters,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final id = filter['id']!;
          final label = filter['label']!;
          final isSelected = selectedFilter == id;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: GestureDetector(
              onTap: () => onChanged(id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1A6B3A)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF64748B),
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
}