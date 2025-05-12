import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/models/capsule.dart';
import 'package:untitled/models/capsule_content.dart';
import 'package:untitled/providers/auth_provider.dart';
import 'package:untitled/providers/capsule_provider.dart';
import 'package:untitled/screens/capsule/add_content_screen.dart';
import 'package:untitled/screens/capsule/share_capsule_screen.dart';
import 'package:untitled/theme/app_theme.dart';
import 'package:untitled/widgets/content_preview.dart';
import 'package:untitled/widgets/countdown_timer.dart';
import 'package:untitled/widgets/empty_state.dart';

class CapsuleDetailScreen extends StatefulWidget {
  final String capsuleId;

  const CapsuleDetailScreen({
    Key? key,
    required this.capsuleId,
  }) : super(key: key);

  @override
  State<CapsuleDetailScreen> createState() => _CapsuleDetailScreenState();
}

class _CapsuleDetailScreenState extends State<CapsuleDetailScreen> {
  @override
  void initState() {
    super.initState();
    
    // Fetch capsule details when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCapsuleDetails();
    });
  }
  
  Future<void> _fetchCapsuleDetails() async {
    final capsuleProvider = Provider.of<CapsuleProvider>(context, listen: false);
    await capsuleProvider.fetchCapsuleById(widget.capsuleId);
  }
  
  Future<void> _deleteCapsule() async {
    final capsuleProvider = Provider.of<CapsuleProvider>(context, listen: false);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Capsule'),
        content: const Text(
          'Are you sure you want to delete this capsule? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final success = await capsuleProvider.deleteCapsule(widget.capsuleId);
      
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }
  
  void _navigateToAddContent() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddContentScreen(capsuleId: widget.capsuleId),
      ),
    );
  }
  
  void _navigateToShareCapsule() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShareCapsuleScreen(capsuleId: widget.capsuleId),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final capsuleProvider = Provider.of<CapsuleProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final capsule = capsuleProvider.selectedCapsule;
    
    if (capsuleProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Capsule Details'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (capsule == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Capsule Details'),
        ),
        body: EmptyState(
          title: 'Capsule Not Found',
          message: 'The capsule you are looking for does not exist or has been deleted.',
          icon: Icons.error_outline,
        ),
      );
    }
    
    final isOwner = capsule.creatorId == authProvider.currentUser?.id;
    final isLocked = capsule.status == CapsuleStatus.locked;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(capsule.title),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _navigateToShareCapsule,
            ),
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteCapsule,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCapsuleDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Capsule Header
              _buildCapsuleHeader(capsule),
              
              // Capsule Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Contents',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isOwner && isLocked)
                          ElevatedButton.icon(
                            onPressed: _navigateToAddContent,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Content List
                    if (capsule.contents.isEmpty)
                      EmptyState(
                        title: 'No Content Yet',
                        message: isOwner && isLocked
                            ? 'Add photos, videos, messages, or audio to your time capsule.'
                            : 'This capsule has no content yet.',
                        icon: Icons.inbox,
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: capsule.contents.length,
                        itemBuilder: (context, index) {
                          final content = capsule.contents[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ContentPreview(
                              content: content,
                              isLocked: isLocked && !capsule.isUnlocked,
                              onDelete: isOwner && isLocked
                                  ? () => _deleteContent(content.id)
                                  : null,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCapsuleHeader(Capsule capsule) {
    final theme = Theme.of(context);
    final isLocked = capsule.status == CapsuleStatus.locked;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Icon(
            isLocked ? Icons.lock : Icons.lock_open,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              capsule.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              capsule.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          if (isLocked && !capsule.isUnlocked)
            CountdownTimer(unlockDate: capsule.unlockDate)
          else
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Unlocked on ${capsule.unlockDate.day}/${capsule.unlockDate.month}/${capsule.unlockDate.year}',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 24),
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteContent(String contentId) async {
    final capsuleProvider = Provider.of<CapsuleProvider>(context, listen: false);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Content'),
        content: const Text(
          'Are you sure you want to remove this content from the capsule?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await capsuleProvider.removeContentFromCapsule(
        widget.capsuleId,
        contentId,
      );
    }
  }
}
