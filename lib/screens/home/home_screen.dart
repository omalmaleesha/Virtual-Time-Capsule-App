import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:untitled/models/capsule.dart';
import 'package:untitled/providers/auth_provider.dart';
import 'package:untitled/providers/capsule_provider.dart';
import 'package:untitled/screens/auth/login_screen.dart';
import 'package:untitled/screens/capsule/capsule_detail_screen.dart';
import 'package:untitled/screens/capsule/create_capsule_screen.dart';
import 'package:untitled/screens/profile/profile_screen.dart';
import 'package:untitled/theme/app_theme.dart';
import 'package:untitled/utils/animations.dart';
import 'package:untitled/widgets/capsule_card.dart';
import 'package:untitled/widgets/empty_state.dart';
import 'package:untitled/screens/capsule/template_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
    
    // Fetch capsules when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCapsules();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchCapsules() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final capsuleProvider = Provider.of<CapsuleProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      await capsuleProvider.fetchCapsules(authProvider.currentUser!.id);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      Animations.fadeTransition(const LoginScreen()),
    );
  }

  void _navigateToCapsuleDetail(Capsule capsule) {
    Navigator.of(context).push(
      Animations.slideTransition(
        CapsuleDetailScreen(capsuleId: capsule.id),
      ),
    );
  }

  void _navigateToCreateCapsule() {
    Navigator.of(context).push(
      Animations.slideTransition(
        const TemplateSelectionScreen(),
        direction: SlideDirection.up,
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.of(context).push(
      Animations.slideTransition(
        const ProfileScreen(),
      ),
    );
  }

  Future<void> _deleteCapsule(Capsule capsule) async {
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
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    final capsuleProvider = Provider.of<CapsuleProvider>(context, listen: false);
    await capsuleProvider.deleteCapsule(capsule.id);
  }

  void _shareCapsule(Capsule capsule) {
    Navigator.of(context).push(
      Animations.slideTransition(
        CapsuleDetailScreen(capsuleId: capsule.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final capsuleProvider = Provider.of<CapsuleProvider>(context);
    final user = authProvider.currentUser;
    
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, ${user?.displayName ?? user?.username ?? 'User'}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _navigateToProfile,
                            child: Hero(
                              tag: 'profile-avatar',
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: AppTheme.primaryColor,
                                child: Text(
                                  user?.displayName?.substring(0, 1).toUpperCase() ?? 
                                  user?.username.substring(0, 1).toUpperCase() ?? 
                                  'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primaryColor,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Locked'),
                  Tab(text: 'Unlocked'),
                ],
              ),
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: _fetchCapsules,
          color: AppTheme.primaryColor,
          child: capsuleProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Upcoming Capsules Tab
                    _buildCapsuleList(
                      capsuleProvider.upcomingCapsules,
                      'No upcoming capsules',
                      'You don\'t have any upcoming capsules yet. Create one to get started!',
                      'assets/animations/empty_box.json',
                    ),
                    
                    // Locked Capsules Tab
                    _buildCapsuleList(
                      capsuleProvider.lockedCapsules,
                      'No locked capsules',
                      'You don\'t have any locked capsules yet. Create one to get started!',
                      'assets/animations/locked.json',
                    ),
                    
                    // Unlocked Capsules Tab
                    _buildCapsuleList(
                      capsuleProvider.unlockedCapsules,
                      'No unlocked capsules',
                      'You don\'t have any unlocked capsules yet. They will appear here when they\'re ready to be opened.',
                      'assets/animations/unlock.json',
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: FloatingActionButton.extended(
              onPressed: _navigateToCreateCapsule,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Capsule'),
              backgroundColor: AppTheme.primaryColor,
              elevation: 4,
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCapsuleList(List<Capsule> capsules, String emptyTitle, String emptyMessage, String? lottieAnimation) {
    if (capsules.isEmpty) {
      return EmptyState(
        title: emptyTitle,
        message: emptyMessage,
        icon: Icons.hourglass_empty_rounded,
        lottieAnimation: lottieAnimation,
        actionText: 'Create Capsule',
        onActionPressed: _navigateToCreateCapsule,
      );
    }
    
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Extra bottom padding for FAB
        itemCount: capsules.length,
        itemBuilder: (context, index) {
          final capsule = capsules[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CapsuleCard(
                    capsule: capsule,
                    onTap: () => _navigateToCapsuleDetail(capsule),
                    onDelete: () => _deleteCapsule(capsule),
                    onShare: () => _shareCapsule(capsule),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
