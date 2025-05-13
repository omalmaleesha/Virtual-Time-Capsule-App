import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:untitled/models/capsule_template.dart';
import 'package:untitled/screens/capsule/create_capsule_screen.dart';
import 'package:untitled/services/template_service.dart';
import 'package:untitled/theme/app_theme.dart';
import 'package:untitled/utils/animations.dart';
import 'package:untitled/widgets/animated_button.dart';

class TemplateSelectionScreen extends StatefulWidget {
  const TemplateSelectionScreen({Key? key}) : super(key: key);

  @override
  State<TemplateSelectionScreen> createState() =>
      _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {
  final _templateService = TemplateService();
  late List<CapsuleTemplate> _templates;
  CapsuleTemplate? _selectedTemplate;

  @override
  void initState() {
    super.initState();
    _templates = _templateService.getAllTemplates();
  }

  void _selectTemplate(CapsuleTemplate template) {
    setState(() {
      _selectedTemplate = template;
    });
  }

  void _navigateToCreateCapsule() {
    if (_selectedTemplate == null) return;

    Navigator.of(context).push(
      Animations.slideTransition(
        CreateCapsuleScreen(template: _selectedTemplate),
        direction: SlideDirection.left,
      ),
    );
  }

  void _skipTemplate() {
    Navigator.of(context).push(
      Animations.slideTransition(
        const CreateCapsuleScreen(),
        direction: SlideDirection.left,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Choose a Template'),
        actions: [
          TextButton(
            onPressed: _skipTemplate,
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Select a template to quickly create a capsule for a specific occasion',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: AnimationLimiter(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _templates.length,
                  itemBuilder: (context, index) {
                    final template = _templates[index];
                    final isSelected = _selectedTemplate?.id == template.id;

                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      columnCount: 2,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: _buildTemplateCard(template, isSelected),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (_selectedTemplate != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Animate(
                  effects: const [
                    SlideEffect(
                      begin: Offset(0, 1),
                      end: Offset(0, 0),
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    ),
                    FadeEffect(
                      begin: 0,
                      end: 1,
                      duration: Duration(milliseconds: 300),
                    ),
                  ],
                  child: AnimatedButton(
                    text: 'Continue with ${_selectedTemplate!.name}',
                    onPressed: _navigateToCreateCapsule,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(CapsuleTemplate template, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectTemplate(template),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              template.primaryColor,
              template.secondaryColor,
            ],
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: template.primaryColor.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          border: isSelected
              ? Border.all(
            color: Colors.white,
            width: 3,
          )
              : null,
        ),
        child: Stack(
          children: [
            if (isSelected)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: template.primaryColor,
                    size: 16,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconForTemplate(template.id),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    template.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Expanded( // 👈 this prevents overflow
                    child: Text(
                      template.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
