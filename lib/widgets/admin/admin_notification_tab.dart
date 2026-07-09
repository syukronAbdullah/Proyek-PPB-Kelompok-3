import 'package:flutter/material.dart';

import 'admin_notification_model.dart';

class AdminNotificationTab extends StatelessWidget {
  final bool isLoading;
  final List<AdminNotificationModel> notifications;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onMarkAllRead;
  final ValueChanged<AdminNotificationModel> onTapNotification;

  const AdminNotificationTab({
    super.key,
    required this.isLoading,
    required this.notifications,
    required this.onRefresh,
    required this.onMarkAllRead,
    required this.onTapNotification,
  });

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications
        .where((notification) => !notification.isRead)
        .length;

    return Column(
      children: [
        _NotificationHeader(
          unreadCount: unreadCount,
          onMarkAllRead: unreadCount == 0 ? null : onMarkAllRead,
        ),
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
                  child: notifications.isEmpty
                      ? const _EmptyNotificationState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          itemCount: notifications.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return _AdminNotificationTile(
                              notification: notification,
                              onTap: () => onTapNotification(notification),
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }
}

class _NotificationHeader extends StatelessWidget {
  final int unreadCount;
  final Future<void> Function()? onMarkAllRead;

  const _NotificationHeader({
    required this.unreadCount,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifikasi Admin',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unreadCount == 0
                      ? 'Tidak ada notifikasi baru'
                      : '$unreadCount notifikasi belum dibaca',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onMarkAllRead == null
                ? null
                : () async {
                    await onMarkAllRead!();
                  },
            icon: const Icon(Icons.done_all_rounded, size: 18),
            label: const Text('Tandai dibaca'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1A5E35),
              disabledForegroundColor: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminNotificationTile extends StatelessWidget {
  final AdminNotificationModel notification;
  final VoidCallback onTap;

  const _AdminNotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isUnread
                  ? const Color(0xFF1A5E35)
                  : const Color(0xFFE2E8F0),
              width: isUnread ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationIcon(isUnread: isUnread),
              const SizedBox(width: 12),
              Expanded(child: _NotificationContent(notification: notification)),
              const SizedBox(width: 8),
              _ReadIndicator(isUnread: isUnread),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final bool isUnread;

  const _NotificationIcon({required this.isUnread});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: isUnread
          ? const Color(0xFFE8F5EE)
          : const Color(0xFFF1F5F9),
      child: Icon(
        Icons.assignment_outlined,
        color: isUnread ? const Color(0xFF1A5E35) : const Color(0xFF64748B),
        size: 20,
      ),
    );
  }
}

class _NotificationContent extends StatelessWidget {
  final AdminNotificationModel notification;

  const _NotificationContent({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          notification.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        if (notification.body.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            notification.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          _formatTime(notification.createdAt),
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatTime(String value) {
    final createdAt = DateTime.tryParse(value);
    if (createdAt == null) return 'Baru saja';

    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari yang lalu';
  }
}

class _ReadIndicator extends StatelessWidget {
  final bool isUnread;

  const _ReadIndicator({required this.isUnread});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFF1A5E35) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isUnread ? const Color(0xFF1A5E35) : const Color(0xFFE2E8F0),
        ),
      ),
    );
  }
}

class _EmptyNotificationState extends StatelessWidget {
  const _EmptyNotificationState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 120),
        Icon(
          Icons.notifications_off_outlined,
          size: 64,
          color: Color(0xFF94A3B8),
        ),
        SizedBox(height: 14),
        Center(
          child: Text(
            'Belum ada notifikasi laporan baru.',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
