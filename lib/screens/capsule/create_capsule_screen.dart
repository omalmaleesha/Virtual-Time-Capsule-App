import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:untitled/models/capsule.dart';
import 'package:untitled/models/capsule_template.dart';
import 'package:untitled/providers/auth_provider.dart';
import 'package:untitled/providers/capsule_provider.dart';
import 'package:untitled/theme/app_theme.dart';
import 'package:untitled/widgets/animated_button.dart';
import 'package:untitled/widgets/custom_text_field.dart';

class CreateCapsuleScreen extends StatefulWidget {
  final CapsuleTemplate? template;

  const CreateCapsuleScreen({
    Key? key,
    this.template,
  }) : super(key: key);

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
  void initState() {
    super.initState();
    
    // Apply template if provided
    if (widget.template != null) {
      _selectedTheme = widget.template!.theme;
      _unlockDate = DateTime.now().add(widget.template!.defaultDuration);
      
      // Pre-fill title with template name if empty
      _titleController.text = widget.template!.name;
      
      // Pre-fill description with template description if empty
      _descriptionController.text = widget.template!.description;
    }
  }
  
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.template?.primaryColor ?? AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
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
    
    // Create capsule from template if available
    final Capsule newCapsule;
    if (widget.template != null) {
      newCapsule = widget.template!.createCapsule(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        creatorId: authProvider.currentUser!.id,
        unlockDate: _unlockDate,
        isPublic: _isPublic,
      );
    } else {
      newCapsule = Capsule(
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
    }
    
    final success = await capsuleProvider.createCapsule(newCapsule);
    
    if (success && mounted) {
      Navigator.of(context).pop();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newCapsule.title} created successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final capsuleProvider = Provider.of<CapsuleProvider>(context);
    final primaryColor = widget.template?.primaryColor ?? AppTheme.primaryColor;
    final secondaryColor = widget.template?.secondaryColor ?? AppTheme.secondaryColor;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template != null 
          ? 'Create ${widget.template!.name}'
          : 'Create New Capsule'
        ),
        backgroundColor: widget.template != null 
          ? primaryColor
          : null,
        foregroundColor: widget.template != null 
          ? Colors.white
          : null,
      ),
      body: Container(
        decoration: widget.template != null
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryColor.withOpacity(0.1),
                  Colors.white,
                ],
              ),
            )
          : null,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Template Header (if template is provided)
                if (widget.template != null)
                  Animate(
                    effects: const [
                      FadeEffect(
                        duration: Duration(milliseconds: 600),
                      ),
                      SlideEffect(
                        begin: Offset(0, -0.1),
                        end: Offset(0, 0),
                        duration: Duration(milliseconds: 600),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primaryColor,
                            secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIconForTemplate(widget.template!.id),
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
                                  widget.template!.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.template!.description,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                if (widget.template != null)
                  const SizedBox(height: 24),
                
                // Title Field
                Animate(
                  effects: [
                    FadeEffect(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 100),
                    ),
                    SlideEffect(
                      begin: const Offset(0, 0.1),
                      end: const Offset(0, 0),
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 100),
                    ),
                  ],
                  child: CustomTextField(
                    controller: _titleController,
                    hintText: 'Capsule Title',
                    labelText: 'Title',
                    showLabel: true,
                    prefixIcon: Icons.title_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title for your capsule';
                      }
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Description Field
                Animate(
                  effects: [
                    FadeEffect(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                    ),
                    SlideEffect(
                      begin: const Offset(0, 0.1),
                      end: const Offset(0, 0),
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                    ),
                  ],
                  child: CustomTextField(
                    controller: _descriptionController,
                    hintText: 'Description',
                    labelText: 'Description',
                    showLabel: true,
                    prefixIcon: Icons.description_rounded,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Unlock Date
                Animate(
                  effects: [
                    FadeEffect(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                    ),
                    SlideEffect(
                      begin: const Offset(0, 0.1),
                      end: const Offset(0, 0),
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                    ),
                  ],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Unlock Date',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (widget.template?.primaryColor ?? AppTheme.primaryColor).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.calendar_today_rounded,
                                  color: widget.template?.primaryColor ?? AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_unlockDate.day}/${_unlockDate.month}/${_unlockDate.year}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_unlockDate.difference(DateTime.now()).inDays} days from now',
                                    style: TextStyle(
                                      color: widget.template?.primaryColor ?? Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Theme Selection (only if no template is provided)
                if (widget.template == null)
                  Animate(
                    effects: [
                      FadeEffect(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 400),
                      ),
                      SlideEffect(
                        begin: const Offset(0, 0.1),
                        end: const Offset(0, 0),
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 400),
                      ),
                    ],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Theme',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<CapsuleTheme>(
                              isExpanded: true,
                              value: _selectedTheme,
                              items: CapsuleTheme.values.map((theme) {
                                return DropdownMenuItem<CapsuleTheme>(
                                  value: theme,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: _getColorForTheme(theme),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        theme.name.capitalize(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
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
                      ],
                    ),
                  ),
                
                if (widget.template == null)
                  const SizedBox(height: 24),
                
                // Public/Private Toggle
                Animate(
                  effects: [
                    FadeEffect(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 500),
                    ),
                    SlideEffect(
                      begin: const Offset(0, 0.1),
                      end: const Offset(0, 0),
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 500),
                    ),
                  ],
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SwitchListTile(
                      title: const Text(
                        'Make this capsule public',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: const Text(
                        'Public capsules can be viewed by anyone with the link',
                      ),
                      value: _isPublic,
                      onChanged: (value) {
                        setState(() {
                          _isPublic = value;
                        });
                      },
                      activeColor: widget.template?.primaryColor ?? AppTheme.primaryColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Error Message
                if (capsuleProvider.error != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: Colors.red.shade800,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            capsuleProvider.error!,
                            style: TextStyle(color: Colors.red.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                if (capsuleProvider.error != null) 
                  const SizedBox(height: 16),
                
                // Create Button
                Animate(
                  effects: [
                    FadeEffect(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 600),
                    ),
                    SlideEffect(
                      begin: const Offset(0, 0.1),
                      end: const Offset(0, 0),
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 600),
                    ),
                  ],
                  child: AnimatedButton(
                    text: 'Create Capsule',
                    isLoading: capsuleProvider.isLoading,
                    onPressed: _createCapsule,
                    color: widget.template?.primaryColor,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Prompt Questions (if template is provided)
                if (widget.template != null && widget.template!.promptQuestions.isNotEmpty)
                  Animate(
                    effects: [
                      FadeEffect(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 700),
                      ),
                      SlideEffect(
                        begin: const Offset(0, 0.1),
                        end: const Offset(0, 0),
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 700),
                      ),
                    ],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12),
                          child: Text(
                            'Suggested Prompts',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Consider adding content that answers these questions:',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...widget.template!.promptQuestions.map((prompt) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.lightbulb_outline_rounded,
                                        size: 18,
                                        color: widget.template!.primaryColor,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          prompt,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
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
  }

  Color _getColorForTheme(CapsuleTheme theme) {
    switch (theme) {
      case CapsuleTheme.birthday:
        return const Color(0xFFFF5252);
      case CapsuleTheme.graduation:
        return const Color(0xFF5C6BC0);
      case CapsuleTheme.wedding:
        return const Color(0xFF9C27B0);
      case CapsuleTheme.anniversary:
        return const Color(0xFFE91E63);
      case CapsuleTheme.personal:
        return AppTheme.primaryColor;
      case CapsuleTheme.custom:
        return const Color(0xFF009688);
    }
  }

  IconData _getIconForTemplate(String templateId) {
    switch (templateId) {
      case 'birthday':
        return Icons.cake_rounded;
      case 'graduation':
        return Icons.school_rounded;
      case 'wedding':
        return Icons.favorite_rounded;
      case 'anniversary':
        return Icons.celebration_rounded;
      case 'new_year':
        return Icons.event_rounded;
      case 'time_capsule':
        return Icons.hourglass_empty_rounded;
      case 'letter_to_future':
        return Icons.mail_rounded;
      case 'travel_memories':
        return Icons.flight_rounded;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
