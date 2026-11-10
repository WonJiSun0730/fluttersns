import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const api = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8080');
const accent = Color(0xff5144b6);

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(colorSchemeSeed: accent, useMaterial3: true),
  home: const Feed(),
));

class Post {
  final int id, likes;
  final String author, body;
  Post.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int, likes = json['likes'] as int,
        author = json['author'] as String, body = json['body'] as String;
}

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  List<Post> posts = [];
  bool busy = false;
  String? error;

  @override
  void initState() {
    super.initState();
    request();
  }

  Future<void> request({String suffix = '', Map<String, String>? data}) async {
    if (busy) return;
    setState(() { busy = true; error = null; });
    try {
      final uri = Uri.parse('$api/api/posts$suffix');
      final response = await (data == null ? http.get(uri) : http.post(
        uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(data),
      )).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) throw StateError('HTTP ${response.statusCode}');
      final items = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      if (mounted) setState(() {
        posts = items.map((item) => Post.fromJson(item as Map<String, dynamic>)).toList();
      });
    } catch (_) {
      if (mounted) setState(() {
        error = '요청 결과를 확인하지 못했어요. 새로고침해 주세요.';
      });
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> compose() async {
    final data = await showDialog<Map<String, String>>(
      context: context, builder: (_) => const Composer(),
    );
    if (data != null && mounted) await request(data: data);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xfff6f4fc),
    appBar: AppBar(
      title: const Text('모아 · MOA', style: TextStyle(fontWeight: FontWeight.bold)),
      actions: [IconButton(tooltip: '새로고침', onPressed: busy ? null : () => request(),
        icon: const Icon(Icons.refresh))],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: busy ? null : compose, icon: const Icon(Icons.edit_outlined), label: const Text('글 쓰기'),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: RefreshIndicator(
          onRefresh: () => request(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(24)),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('COMMUNITY FEED', style: TextStyle(color: Colors.white70, letterSpacing: 2)),
                  SizedBox(height: 8),
                  Text('오늘의 이야기를 모아요', style: TextStyle(color: Colors.white,
                    fontSize: 24, fontWeight: FontWeight.bold)),
                ]),
              ),
              const SizedBox(height: 16),
              if (busy) const LinearProgressIndicator(),
              if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
              if (!busy && error == null && posts.isEmpty)
                const Padding(padding: EdgeInsets.all(24), child: Text('첫 이야기를 남겨 보세요.')),
              for (final post in posts)
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const CircleAvatar(child: Icon(Icons.person_outline)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(post.author, style: const TextStyle(fontWeight: FontWeight.bold))),
                      ]),
                      const SizedBox(height: 12),
                      Text(post.body, style: const TextStyle(fontSize: 16, height: 1.5)),
                      TextButton.icon(
                        onPressed: busy ? null : () => request(suffix: '/${post.id}/likes', data: {}),
                        icon: const Icon(Icons.favorite_border), label: Text('좋아요 ${post.likes}'),
                      ),
                    ]),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class Composer extends StatefulWidget {
  const Composer({super.key});
  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  final form = GlobalKey<FormState>();
  final author = TextEditingController();
  final body = TextEditingController();

  @override
  void dispose() {
    author.dispose();
    body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('새 이야기'),
    content: SingleChildScrollView(
      child: Form(key: form, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: author, maxLength: 20,
          decoration: const InputDecoration(labelText: '닉네임'),
          validator: (value) => value!.trim().isEmpty ? '닉네임을 입력해 주세요.' : null),
        TextFormField(controller: body, maxLength: 280, minLines: 3, maxLines: 5,
          decoration: const InputDecoration(labelText: '내용'),
          validator: (value) => value!.trim().isEmpty ? '내용을 입력해 주세요.' : null),
      ])),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
      FilledButton(onPressed: () {
        if (form.currentState!.validate()) {
          Navigator.pop(context, {'author': author.text.trim(), 'body': body.text.trim()});
        }
      }, child: const Text('게시')),
    ],
  );
}
