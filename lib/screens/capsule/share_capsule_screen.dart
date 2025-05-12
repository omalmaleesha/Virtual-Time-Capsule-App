import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:untitled/providers/capsule_provider.dart';
import 'package:untitled/widgets/custom_button.dart';
import 'package:untitled/widgets/custom_text_field.dart';

class ShareCapsuleScreen extends StatefulWidget {
  final String capsuleId;

  const ShareCapsuleScreen({
    Key? key,
    required this.capsuleId,
  }) : super(key: key);

  @override
  State<ShareCapsuleScreen> createState() => _ShareCapsuleScreenState();
}

class _ShareCapsuleScreenState extends State<ShareCapsuleScreen> {
  final _emailController = TextEditingController();
  final List<String> _emails = [];
  bool _isPublic = false;
  
  @override
  void initState() {
    super.initState();
    
    // Load capsule details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCapsuleDetails();
    });
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCapsuleDetails() async {
    final capsuleProvider = Provider.of<CapsuleProvider>(context, listen: false);
    await capsuleProvider.fetchCapsuleById(widget.capsuleId);
    
    final capsule = capsuleProvider.selectedCapsule;
    if (capsule != null) {
      setState(() {
        _isPublic = capsule.isPublic;
      });
    }
  }
  
  void _addEmail() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty && email.contains('@') && email.contains('.')) {
      setState(() {
        _emails.add(email);
        _emailController.clear();
      });
    }
  }
  
  void _removeEmail(String email) {
    setState(() {
      _emails.remove(email);
    });
  }
  
  Future<void> _shareCapsule() async {
    if (_emails.isEmpty) return;
    
    final capsuleProvider = Provider.of<CapsuleProvider>(context, listen: false);
    
    // In a real app, this would send invites to the emails
    // For now, we'll just update the capsule's shared list
    await capsuleProvider.shareCapsule(widget.capsuleId, _emails);
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
  
  Future<void> _togglePublicStatus() async {
    final capsuleProvider = Provider.of<CapsuleProvider>(context, listen: false);
    final capsule = capsuleProvider.selectedCapsule;
    
    if (capsule != null) {
      final updatedCapsule = capsule.copyWith(
        isPublic: !_isPublic,
      );
      
      await capsuleProvider.updateCapsule(updatedCapsule);
      
      setState(() {
        _isPublic = !_isPublic;
      });
    }
  }
  
  Future<void> _copyShareLink() async {
    // In a real app, this would generate a proper sharing link
    final shareLink = 'https://vtcapsules.com/capsule/${widget.capsuleId}';
    
    await Clipboard.setData(ClipboardData(text: shareLink));
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share link copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final capsuleProvider = Provider.of<CapsuleProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Capsule'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Public/Private Toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Visibility',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Make this capsule public'),
                      subtitle: const Text(
                        'Anyone with the link can view this capsule',
                      ),
                      value: _isPublic,
                      onChanged: (value) => _togglePublicStatus(),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_isPublic) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _copyShareLink,
                              icon: const Icon(Icons.link),
                              label: const Text('Copy Share Link'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Share with specific people
            const Text(
              'Share with specific people',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _emailController,
                    hintText: 'Enter email address',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addEmail,
                  icon: const Icon(Icons.add_circle),
                  color: Theme.of(context).colorScheme.primary,
                  iconSize: 36,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Email Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emails.map((email) {
                return Chip(
                  label: Text(email),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _removeEmail(email),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            
            CustomButton(
              text: 'Share Capsule',
              isLoading: capsuleProvider.isLoading,
              onPressed: _emails.isNotEmpty ? _shareCapsule : null,
            ),
          ],
        ),
      ),
    );
  }
}
