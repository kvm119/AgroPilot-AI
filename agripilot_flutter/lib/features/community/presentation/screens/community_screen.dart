import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/community_models.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _postController = TextEditingController();

  final List<CommunityPost> _feedPosts = [
    CommunityPost(
      id: 'post_1',
      author: const FarmerProfile(
        id: 'f1',
        name: 'Ramesh Kumar',
        village: 'Guntur Rural',
        state: 'Andhra Pradesh',
        farmSizeAcres: 4.5,
        experienceYears: 14,
      ),
      topicGroup: 'Cotton Farmers',
      title: 'Pink Bollworm Defense Tip',
      content: 'Installed Pheromone traps yesterday in my 4-acre cotton plot. Caught 12 moths in 24 hours. Highly recommend fellow farmers to install traps now!',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      likesCount: 38,
      commentsCount: 14,
    ),
    CommunityPost(
      id: 'post_2',
      author: const FarmerProfile(
        id: 'f2',
        name: 'Suresh Reddy',
        village: 'Tenali',
        state: 'Andhra Pradesh',
        farmSizeAcres: 8.0,
        experienceYears: 20,
      ),
      topicGroup: 'Rice & Paddy',
      title: 'DSR Paddy vs Normal Transplanting',
      content: 'Switched to Direct Seeded Rice (DSR) this season. Saved ₹4,000 per acre on labor costs and 30% less water usage!',
      timestamp: DateTime.now().subtract(const Duration(hours: 7)),
      likesCount: 72,
      commentsCount: 29,
    ),
  ];

  final List<String> _topicGroups = const [
    'Rice & Paddy',
    'Cotton Farmers',
    'Chilli & Spices',
    'Organic Farming',
    'Dairy & Livestock',
    'Farm Machinery',
    'Government Subsidies',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _postController.dispose();
    super.dispose();
  }

  void _showNewPostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_note_rounded, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text('Share with Farmer Community', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop()),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _postController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Ask a question or share advice about your crops...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  if (_postController.text.trim().isNotEmpty) {
                    setState(() {
                      _feedPosts.insert(
                        0,
                        CommunityPost(
                          id: DateTime.now().toString(),
                          author: const FarmerProfile(
                            id: 'me',
                            name: 'My Farm Profile',
                            village: 'My Village',
                            state: 'India',
                            farmSizeAcres: 2.5,
                            experienceYears: 5,
                          ),
                          topicGroup: 'General Agriculture',
                          title: 'Community Query',
                          content: _postController.text.trim(),
                          timestamp: DateTime.now(),
                        ),
                      );
                    });
                    _postController.clear();
                    Navigator.of(ctx).pop();
                  }
                },
                icon: const Icon(Icons.send_rounded),
                label: const Text('Post to Community'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showReportUserDialog(String farmerName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Report $farmerName'),
        content: const Text('Do you want to report this user or post for spam or inappropriate agricultural content?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User reported to AgriPilot moderation team.')),
              );
            },
            child: const Text('Report & Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.groups_rounded, color: Colors.green),
            SizedBox(width: 8),
            Text('Farmer Community'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          tabs: const [
            Tab(text: 'Feed'),
            Tab(text: 'Groups'),
            Tab(text: 'Discussions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Community Feed
          ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: _feedPosts.length,
            itemBuilder: (ctx, idx) {
              final post = _feedPosts[idx];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: Text(post.author.name[0], style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(post.author.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified, color: Colors.blue, size: 16),
                                  ],
                                ),
                                Text('${post.author.village}, ${post.author.state} • ${post.author.farmSizeAcres} Acres', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (val) {
                              if (val == 'report') _showReportUserDialog(post.author.name);
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(value: 'report', child: Text('Report Post / User')),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(post.content, style: const TextStyle(fontSize: 13, height: 1.4)),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Text('${post.likesCount}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 20),
                          const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('${post.commentsCount} Comments', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.reply, size: 14),
                            label: const Text('Reply', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Tab 2: Crop Topic Groups
          ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: _topicGroups.length,
            itemBuilder: (ctx, idx) {
              final group = _topicGroups[idx];
              return Card(
                elevation: 1.5,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.forum_rounded, color: Colors.white, size: 20),
                  ),
                  title: Text(group, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${(idx + 1) * 340} Active Farmer Members'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Joined $group Community Group!')),
                      );
                    },
                    child: const Text('Join'),
                  ),
                ),
              );
            },
          ),

          // Tab 3: Private Discussions Shell
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mark_chat_read_rounded, size: 64, color: Colors.green),
                SizedBox(height: 12),
                Text('Direct Farmer Messaging', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text('WebSocket real-time chat architecture initialized.', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewPostModal,
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('New Post'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }
}
