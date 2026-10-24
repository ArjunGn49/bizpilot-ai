import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _audience = 'All Customers';
  bool _isPublishing = false;

  static const List<String> _audiences = ['All Customers', 'VIP Clients', 'Wholesale Buyers', 'Public Promo'];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _publishPost() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPublishing = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isPublishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Announcement post published successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Store Announcement Post'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Announcement Title',
                  prefixIcon: Icon(Icons.campaign_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),

              // Target Audience Dropdown
              DropdownButtonFormField<String>(
                value: _audience,
                decoration: const InputDecoration(
                  labelText: 'Target Audience',
                  prefixIcon: Icon(Icons.groups_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _audiences.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _audience = val);
                },
              ),
              const SizedBox(height: 16),

              // Content Body Field
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Post Message & Offer Details',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter message content' : null,
              ),
              const SizedBox(height: 20),

              // Photo Attachment Placeholder Button
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image attachment picker opened.')),
                  );
                },
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Attach Promo Banner Image'),
              ),
              const SizedBox(height: 28),

              // Publish Button
              ElevatedButton.icon(
                onPressed: _isPublishing ? null : _publishPost,
                icon: _isPublishing
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send_rounded),
                label: Text(_isPublishing ? 'Publishing...' : 'Publish Announcement'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
