import 'package:flutter/material.dart';
import 'package:untitled/models/capsule_content.dart';

class ContentPreview extends StatelessWidget {
  final CapsuleContent content;
  final bool isLocked;
  final VoidCallback? onDelete;

  const ContentPreview({
    Key? key,
    required this.content,
    required this.isLocked,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildContentTypeIcon(),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    content.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _buildContentPreview(context),
            const SizedBox(height: 8),
            Text(
              'Added on ${content.createdAt.day}/${content.createdAt.month}/${content.createdAt.year}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContentTypeIcon() {
    IconData iconData;
    Color iconColor;
    
    switch (content.type) {
      case ContentType.text:
        iconData = Icons.message;
        iconColor = Colors.blue;
        break;
      case ContentType.image:
        iconData = Icons.image;
        iconColor = Colors.green;
        break;
      case ContentType.video:
        iconData = Icons.videocam;
        iconColor = Colors.red;
        break;
      case ContentType.audio:
        iconData = Icons.audiotrack;
        iconColor = Colors.purple;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }
  
  Widget _buildContentPreview(BuildContext context) {
    if (isLocked) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              'Content is locked until unlock date',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      );
    }
    
    switch (content.type) {
      case ContentType.text:
        return Text(content.content);
      case ContentType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            content.content,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              );
            },
          ),
        );
      case ContentType.video:
        return Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.play_circle_fill, size: 50, color: Colors.white),
          ),
        );
      case ContentType.audio:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.audiotrack, color: Colors.purple),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audio Recording',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow, size: 20, color: Colors.purple),
                          const SizedBox(width: 8),
                          Text(
                            'Play Audio',
                            style: TextStyle(color: Colors.purple.shade800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }
}
