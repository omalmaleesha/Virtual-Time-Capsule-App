import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:untitled/models/capsule.dart';
import 'package:untitled/providers/auth_provider.dart';
import 'package:untitled/providers/capsule_provider.dart';
import 'package:untitled/widgets/custom_button.dart';
import 'package:untitled/widgets/custom_text_field.dart';

class CreateCapsuleScreen extends StatefulWidget {
  const CreateCapsuleScreen({Key? key}) : super(key: key);

  @override
  State<CreateCapsuleScreen> createState() => _CreateCapsuleScreenState();
}

class _CreateCapsuleScreenState extends State<CreateCapsuleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _unlockDate = DateTime.now().add(const Duration(days: 30));
  CapsuleTheme _selectedTheme = CapsuleTheme.personal;
  bool _isPublic = false;
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _unlockDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)), // 10 years
    );
    
    if (picked != null && picked != _unlockDate) {
      setState(() {
        _unlockDate = picked;
      });
    }
  }
  
  Future<void> _createCapsule() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final capsuleProvider = Provider.of<CapsuleProvider>(context, listen: false);
    
    if (authProvider.currentUser == null) return;
    
    final newCapsule = Capsule(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      createdAt: DateTime.now(),
      unlockDate: _unlockDate,
      status: CapsuleStatus.locked,
      theme: _selectedTheme,
      contents: [],
      creatorId: authProvider.currentUser!.id,
      isPublic: _isPublic,
    );
    
    final success = await capsuleProvider.createCapsule(newCapsule);
    
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final capsuleProvider = Provider.of<CapsuleProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Capsule'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _titleController,
                hintText: 'Capsule Title',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title for your capsule';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                hintText: 'Description',
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Unlock Date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 16),
                      Text(
                        '${_unlockDate.day}/${_unlockDate.month}/${_unlockDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      Text(
                        '${_unlockDate.difference(DateTime.now()).inDays} days from now',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Theme',
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
                  child: DropdownButton<CapsuleTheme>(
                    isExpanded: true,
                    value: _selectedTheme,
                    items: CapsuleTheme.values.map((theme) {
                      return DropdownMenuItem<CapsuleTheme>(
                        value: theme,
                        child: Text(theme.name.capitalize()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedTheme = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Make this capsule public'),
                subtitle: const Text(
                  'Public capsules can be viewed by anyone with the link',
                ),
                value: _isPublic,
                onChanged: (value) {
                  setState(() {
                    _isPublic = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
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
                text: 'Create Capsule',
                isLoading: capsuleProvider.isLoading,
                onPressed: _createCapsule,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
