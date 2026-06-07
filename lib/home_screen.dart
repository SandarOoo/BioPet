import 'package:flutter/material.dart';
import 'nearby_pets_map.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const FeedPage(),
    const NearbyPetsMap(),
    const BreedClassificationPage(),
    const PublicChatPage(),
    const UserProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Nearby',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Breed AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 1. FEED PAGE (like Facebook)
// ─────────────────────────────────────────
class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  final List<Map<String, String>> _posts = const [
    {
      'user': 'Mg Mg',
      'avatar': 'https://i.pravatar.cc/150?img=1',
      'time': '2 hours ago',
      'content': 'My cat just had kittens! 🐱',
      'image': 'https://placekitten.com/400/300',
      'likes': '24',
      'comments': '5',
    },
    {
      'user': 'Su Su',
      'avatar': 'https://i.pravatar.cc/150?img=2',
      'time': '5 hours ago',
      'content': 'Taking my dog for a walk today! 🐶',
      'image': 'https://placedog.net/400/300',
      'likes': '42',
      'comments': '8',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BioPet Feed'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () {},
            tooltip: 'Create Post',
          ),
        ],
      ),
      body: ListView(
        children: [
          // Create Post Box
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "What's on your pet's mind?",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Posts
          ..._posts.map((post) => _PostCard(post: post)),
        ],
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  final Map<String, String> post;
  const _PostCard({required this.post});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.post['avatar']!),
            ),
            title: Text(
              widget.post['user']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(widget.post['time']!),
            trailing: IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
            ),
          ),
          // Post Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(widget.post['content']!),
          ),
          // Post Image
          if (widget.post['image'] != null)
            Image.network(
              widget.post['image']!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 200,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
          // Likes & Comments Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.thumb_up, size: 16, color: Colors.teal),
                const SizedBox(width: 4),
                Text(widget.post['likes']!),
                const Spacer(),
                Text('${widget.post['comments']} comments'),
              ],
            ),
          ),
          const Divider(height: 1),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  icon: Icon(
                    _liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: _liked ? Colors.teal : Colors.grey,
                  ),
                  label: Text(
                    'Like',
                    style: TextStyle(
                      color: _liked ? Colors.teal : Colors.grey,
                    ),
                  ),
                  onPressed: () => setState(() => _liked = !_liked),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(Icons.comment_outlined, color: Colors.grey),
                  label: const Text('Comment',
                      style: TextStyle(color: Colors.grey)),
                  onPressed: () {},
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(Icons.share_outlined, color: Colors.grey),
                  label: const Text('Share',
                      style: TextStyle(color: Colors.grey)),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 2. BREED CLASSIFICATION PAGE
// ─────────────────────────────────────────
class BreedClassificationPage extends StatelessWidget {
  const BreedClassificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breed Classification'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.teal, width: 2),
                ),
                child: const Icon(
                  Icons.pets,
                  size: 80,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Identify Your Pet Breed',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Take a photo or upload from gallery\nto identify your pet breed using AI',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Upload from Gallery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.teal,
                  side: const BorderSide(color: Colors.teal),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 3. PUBLIC CHAT PAGE
// ─────────────────────────────────────────
class PublicChatPage extends StatefulWidget {
  const PublicChatPage({super.key});

  @override
  State<PublicChatPage> createState() => _PublicChatPageState();
}

class _PublicChatPageState extends State<PublicChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'user': 'Mg Mg', 'message': 'Anyone know a good vet in Yangon?', 'time': '10:00 AM'},
    {'user': 'Su Su', 'message': 'Try Happy Paws Clinic on Pyay Road!', 'time': '10:02 AM'},
    {'user': 'Ko Ko', 'message': 'My dog loves it there 🐶', 'time': '10:05 AM'},
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'user': 'Me',
        'message': _controller.text.trim(),
        'time': 'Now',
      });
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Chat'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['user'] == 'Me';
                return Align(
                  alignment:
                  isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.teal : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Text(
                            msg['user']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.teal,
                            ),
                          ),
                        Text(
                          msg['message']!,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time']!,
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe
                                ? Colors.white70
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Message Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: _sendMessage,
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

// ─────────────────────────────────────────
// 4. USER PROFILE PAGE
// ─────────────────────────────────────────
class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              color: Colors.teal.shade50,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Mg Mg',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pet Lover 🐾',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statItem('Posts', '12'),
                      _statItem('Pets', '3'),
                      _statItem('Friends', '48'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
            // My Pets Section
            const Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Pets',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _petAvatar('Milo', '🐶'),
                  _petAvatar('Luna', '🐱'),
                  _petAvatar('Buddy', '🐰'),
                  _addPetButton(),
                ],
              ),
            ),
            // Menu Items
            const SizedBox(height: 16),
            _menuItem(Icons.photo_library, 'My Posts', () {}),
            _menuItem(Icons.favorite, 'Saved Posts', () {}),
            _menuItem(Icons.history, 'Breed History', () {}),
            _menuItem(Icons.notifications, 'Notifications', () {}),
            _menuItem(Icons.logout, 'Logout', () {}),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _petAvatar(String name, String emoji) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.teal.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _addPetButton() {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.teal, width: 2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.teal),
          ),
          const SizedBox(height: 4),
          const Text('Add Pet', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}