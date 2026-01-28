import 'package:flutter/material.dart';
import 'model/post.dart';
import 'repository/post_repository.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PostScreen()
  );
}

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});
  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final PostRepository _repository = PostRepository();
  late Future<List<Post>> _posts;

  @override
  void initState() {
    super.initState();
    _posts = _repository.fetchPosts();
  }

  // Method to handle the POST request
  void _createNewPost() async {
    try {
      Post newPost = Post(
        userId: 1,
        title: 'New Post Title',
        body: 'This is the content of post 101'
      );

      final result = await _repository.createPost(newPost);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Success! Created Post ID: ${result.id}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JSONPlaceholder API')),
      body: FutureBuilder<List<Post>>(
        future: _posts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final posts = snapshot.data!;
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(child: Text('${posts[index].id}')),
                  title: Text(posts[index].title),
                  subtitle: Text(posts[index].body, maxLines: 1),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewPost,
        child: const Icon(Icons.add),
      ),
    );
  }
}