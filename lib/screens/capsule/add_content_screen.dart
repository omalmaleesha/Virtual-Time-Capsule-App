import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:untitled/models/capsule_content.dart';
import 'package:untitled/providers/capsule_provider.dart';
import 'package:untitled/widgets/custom_button.dart';
import 'package:untitled/widgets/custom_text_field.dart';

class AddContentScreen extends StatefulWidget {
  final String capsuleId;

  const AddContentScreen({
    Key? key,
    required this.capsuleId,
  }) : super(key: key);

  @override
  State<AddContentScreen> createState() => _AddContentScreenState();
}

class _AddContentScreenState extends State<AddContentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  ContentType _selectedType = ContentType.text;
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  
  Future<void> _addContent() async {
    if (!_formKey.currentState!.validate()) return;
    
    final capsuleProvider = Provider.of<CapsuleProvider>(context, listen: false);
    
    final newContent = CapsuleContent(
      id: const Uuid().v4(),
      type: _selectedType,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      createdAt: DateTime.now(),
    );
    
    final success = await capsuleProvider.addContentToCapsule(
      widget.capsuleId,
      newContent,
    );
    
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final capsuleProvider = Provider.of<CapsuleProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Content'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Content Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ContentType>(
                    isExpanded: true,
                    value: _selectedType,
                    items: ContentType.values.map((type) {
                      return DropdownMenuItem<ContentType>(
                        value: type,
                        child: Text(type.name.capitalize()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _titleController,
                hintText: 'Title',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _contentController,
                hintText: _getContentHint(),
                prefixIcon: _getContentIcon(),
                maxLines: _selectedType == ContentType.text ? 5 : 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              if (capsuleProvider.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    capsuleProvider.error!,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
              if (capsuleProvider.error != null) const SizedBox(height: 16),
              CustomButton(
                text: 'Add to Capsule',
                isLoading: capsuleProvider.isLoading,
                onPressed: _addContent,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getContentHint() {
    switch (_selectedType) {
      case ContentType.text:
        return 'Write your message...';
      case ContentType.image:
        return 'Enter image URL...';
      case ContentType.video:
        return 'Enter video URL...';
      case ContentType.audio:
        return 'Enter audio URL...';
    }
  }
  
  IconData _getContentIcon() {
    switch (_selectedType) {
      case ContentType.text:
        return Icons.message;
      case ContentType.image:
        return Icons.image;
      case ContentType.video:
        return Icons.videocam;
      case ContentType.audio:
        return Icons.audiotrack;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
