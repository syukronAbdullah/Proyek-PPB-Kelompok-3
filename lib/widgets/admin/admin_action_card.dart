import 'package:flutter/material.dart';

class AdminActionCard extends StatelessWidget {
  final String currentStatus;
  final String? selectedStatus;
  final List<String> statusOptions;
  final TextEditingController catatanController;
  final bool isLoading;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onSave;

  const AdminActionCard({
    super.key,
    required this.currentStatus,
    required this.selectedStatus,
    required this.statusOptions,
    required this.catatanController,
    required this.isLoading,
    required this.onStatusChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isFinalStatus = currentStatus == 'selesai' || currentStatus == 'ditolak';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ActionHeader(),
          const SizedBox(height: 16),

          const _SectionLabel('Update Status'),
          const SizedBox(height: 8),

          _StatusDropdown(
            selectedStatus: selectedStatus,
            statusOptions: statusOptions,
            isEnabled: !isFinalStatus,
            onChanged: onStatusChanged,
          ),

          if (isFinalStatus) ...[
            const SizedBox(height: 6),
            const _FinalStatusMessage(),
          ],

          const SizedBox(height: 14),

          const _SectionLabel('Catatan Penanganan'),
          const SizedBox(height: 8),

          _CatatanField(
            controller: catatanController,
            isEnabled: !isFinalStatus,
          ),

          const SizedBox(height: 16),

          _SaveButton(
            isLoading: isLoading,
            isFinalStatus: isFinalStatus,
            onSave: onSave,
          ),
        ],
      ),
    );
  }
}

class _ActionHeader extends StatelessWidget {
  const _ActionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF1A5E35).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.settings_rounded,
            color: Color(0xFF1A5E35),
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Tindakan Admin',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155),
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final String? selectedStatus;
  final List<String> statusOptions;
  final bool isEnabled;
  final ValueChanged<String?> onChanged;

  const _StatusDropdown({
    required this.selectedStatus,
    required this.statusOptions,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          iconDisabledColor: Colors.grey,
          value: selectedStatus,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          borderRadius: BorderRadius.circular(10),
          items: statusOptions.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(
                _capitalize(status),
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: isEnabled ? onChanged : null,
        ),
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

class _FinalStatusMessage extends StatelessWidget {
  const _FinalStatusMessage();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.lock_outline_rounded,
          size: 13,
          color: Colors.black38,
        ),
        const SizedBox(width: 4),
        Text(
          'Status sudah final, tidak dapat diubah lagi',
          style: TextStyle(
            fontSize: 11.5,
            color: Colors.black.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

class _CatatanField extends StatelessWidget {
  final TextEditingController controller;
  final bool isEnabled;

  const _CatatanField({
    required this.controller,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 4,
      enabled: isEnabled,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Tambahkan catatan penanganan untuk mahasiswa...',
        hintStyle: TextStyle(
          fontSize: 13,
          color: Colors.black.withValues(alpha: 0.35),
        ),
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        contentPadding: const EdgeInsets.all(14),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(
          color: const Color(0xFF1A5E35),
          width: 1.5,
        ),
      ),
    );
  }

  OutlineInputBorder _border({
    Color color = const Color(0xFFE5E5E5),
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool isLoading;
  final bool isFinalStatus;
  final VoidCallback onSave;

  const _SaveButton({
    required this.isLoading,
    required this.isFinalStatus,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: (isLoading || isFinalStatus) ? null : onSave,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                isFinalStatus
                    ? Icons.lock_outline_rounded
                    : Icons.save_rounded,
                size: 18,
              ),
        label: Text(
          isLoading
              ? 'Menyimpan...'
              : isFinalStatus
                  ? 'Status Final'
                  : 'Simpan Perubahan',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A5E35),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF1A5E35).withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}