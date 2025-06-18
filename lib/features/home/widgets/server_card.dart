import 'package:desk_switch/shared/models/server_info.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ServerCard extends StatelessWidget {
  const ServerCard({
    super.key,
    required this.server,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmarkToggle,
  });

  final ServerInfo server;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: 16,
        right: 4,
      ),
      selectedTileColor: theme.colorScheme.primaryContainer,
      leading: Stack(
        children: [
          SizedBox.square(
            dimension: 28,
            child: Icon(
              Icons.computer,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.circle,
                size: 8,
                color: server.isOnline
                    ? Colors.green
                    : theme.colorScheme.surface,
              ),
            ),
          ),
        ],
      ),
      title: Text(
        server.name,
        style: theme.textTheme.titleSmall,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${server.ipAddress}:${server.port}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          if (server.lastSeen != null) ...[
            const Gap(2),
            Text(
              'Last seen: ${_formatLastSeen(server.lastSeen!)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          size: 20,
          color: isBookmarked
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        onPressed: onBookmarkToggle,
        tooltip: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
      ),
      onTap: onTap,
    );
  }

  String _formatLastSeen(String lastSeen) {
    try {
      final lastSeenTime = DateTime.parse(lastSeen);
      final now = DateTime.now();
      final difference = now.difference(lastSeenTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
