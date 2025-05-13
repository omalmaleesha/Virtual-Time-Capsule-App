import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:untitled/models/capsule.dart';
import 'package:untitled/theme/app_theme.dart';
import 'package:untitled/utils/animations.dart';

class CapsuleCard extends StatefulWidget {
  final Capsule capsule;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  const CapsuleCard({
    Key? key,
    required this.capsule,
    required this.onTap,
    this.onDelete,
    this.onShare,
  }) : super(key: key);

  @override
  State<CapsuleCard> createState() => _CapsuleCardState();
}

class _CapsuleCardState extends State<CapsuleCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    setState(() {
      _isPressed = false;
    });
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
    setState(() {
      _isPressed = false;
    });
  }

  Color _getStatusColor() {
    switch (widget.capsule.status) {
      case CapsuleStatus.locked:
        return AppTheme.warningColor;
      case CapsuleStatus.unlocked:
        return AppTheme.successColor;
      case CapsuleStatus.upcoming:
        return AppTheme.infoColor;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.capsule.status) {
      case CapsuleStatus.locked:
        return Icons.lock_rounded;
      case CapsuleStatus.unlocked:
        return Icons.lock_open_rounded;
      case CapsuleStatus.upcoming:
        return Icons.hourglass_top_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLocked = widget.capsule.status == CapsuleStatus.locked;
    final statusColor = _getStatusColor();
    
    final card = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: _isPressed
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
            ),
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: widget.onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              _getStatusIcon(),
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.capsule.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getStatusText(),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                    
                    // Card Content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.capsule.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoChip(
                                icon: Icons.calendar_today_rounded,
                                text: '${widget.capsule.unlockDate.day}/${widget.capsule.unlockDate.month}/${widget.capsule.unlockDate.year}',
                              ),
                              _buildInfoChip(
                                icon: Icons.attachment_rounded,
                                text: '${widget.capsule.contents.length} items',
                              ),
                              if (widget.capsule.isPublic)
                                _buildInfoChip(
                                  icon: Icons.public_rounded,
                                  text: 'Public',
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    
    // If we have delete or share actions, wrap in Slidable
    if (widget.onDelete != null || widget.onShare != null) {
      return GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              if (widget.onShare != null)
                SlidableAction(
                  onPressed: (_) => widget.onShare!(),
                  backgroundColor: AppTheme.infoColor,
                  foregroundColor: Colors.white,
                  icon: Icons.share_rounded,
                  label: 'Share',
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              if (widget.onDelete != null)
                SlidableAction(
                  onPressed: (_) => widget.onDelete!(),
                  backgroundColor: AppTheme.errorColor,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_rounded,
                  label: 'Delete',
                  borderRadius: widget.onShare == null
                      ? const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  )
                      : BorderRadius.zero,

                ),
            ],
          ),
          child: card,
        ),
      );
    }
    
    // Otherwise just return the card with gesture detector
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: card,
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (widget.capsule.status) {
      case CapsuleStatus.locked:
        return 'Locked • ${widget.capsule.daysUntilUnlock} days remaining';
      case CapsuleStatus.unlocked:
        return 'Unlocked • Ready to view';
      case CapsuleStatus.upcoming:
        return 'Coming soon';
    }
  }
}
