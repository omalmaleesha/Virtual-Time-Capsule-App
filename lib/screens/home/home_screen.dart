import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/models/capsule.dart';
import 'package:untitled/providers/auth_provider.dart';
import 'package:untitled/providers/capsule_provider.dart';
import 'package:untitled/screens/auth/login_screen.dart';
import 'package:untitled/screens/capsule/capsule_detail_screen.dart';
import 'package:untitled/screens/capsule/create_capsule_screen.dart';
import 'package:untitled/screens/profile/profile_screen.dart';
import 'package:untitled/widgets/capsule_card.dart';
import 'package:untitled/widgets/empty_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
  
  void _navigateToCapsuleDetail(Capsule capsule) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CapsuleDetailScreen(capsuleId: capsule.id),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final capsuleProvider = Provider.of<CapsuleProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Time Capsules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Locked'),
            Tab(text: 'Unlocked'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCapsules,
        child: capsuleProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  // Upcoming Capsules Tab
                  _buildCapsuleList(
                    capsuleProvider.upcomingCapsules,
                    'No upcoming capsules',
                    'You don\'t have any upcoming capsules yet. Create one to get started!',
                  ),
                  
                  // Locked Capsules Tab
                  _buildCapsuleList(
                    capsuleProvider.lockedCapsules,
                    'No locked capsules',
                    'You don\'t have any locked capsules yet. Create one to get started!',
                  ),
                  
                  // Unlocked Capsules Tab
                  _buildCapsuleList(
                    capsuleProvider.unlockedCapsules,
                    'No unlocked capsules',
                    'You don\'t have any unlocked capsules yet. They will appear here when they\'re ready to be opened.',
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateCapsuleScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Capsule'),
      ),
    );
  }
  
  Widget _buildCapsuleList(List<Capsule> capsules, String emptyTitle, String emptyMessage) {
    if (capsules.isEmpty) {
      return EmptyState(
        title: emptyTitle,
        message: emptyMessage,
        icon: Icons.hourglass_empty,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: capsules.length,
      itemBuilder: (context, index) {
        final capsule = capsules[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CapsuleCard(
            capsule: capsule,
            onTap: () => _navigateToCapsuleDetail(capsule),
          ),
        );
      },
    );
  }
}
