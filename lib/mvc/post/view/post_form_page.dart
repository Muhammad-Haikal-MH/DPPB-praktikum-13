import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/post_bloc.dart';
import '../data/post_model.dart';

class PostFormPage extends StatefulWidget {
  static const String routeName = '/posts/form';
  final PostModel? postToEdit;

  const PostFormPage({super.key, this.postToEdit});

  @override
  State<PostFormPage> createState() => _PostFormPageState();
}

class _PostFormPageState extends State<PostFormPage> {
  final _titleController = TextEditingController();
  final _articleController = TextEditingController();
  final _authorController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool get isEditing => widget.postToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.postToEdit!.title;
      _articleController.text = widget.postToEdit!.article; // Sesuai PostModel
      _authorController.text = widget.postToEdit!.author; // Sesuai PostModel
      _imageUrlController.text = widget.postToEdit!.imageUrl ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _articleController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      if (isEditing) {
        context.read<PostBloc>().add(
              PostUpdated(
                postId: widget.postToEdit!.id,
                title: _titleController.text,
                content: _articleController.text, // Dikirim sebagai 'content' ke Bloc
                author: _authorController.text,
                imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
              ),
            );
      } else {
        context.read<PostBloc>().add(
              PostCreated(
                title: _titleController.text,
                content: _articleController.text,
                author: _authorController.text,
                imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Postingan' : 'Buat Postingan')),
      body: BlocListener<PostBloc, PostState>(
        listener: (context, state) {
          if (state.status == PostStatus.success && 
              state.message != null && 
              state.message!.contains('berhasil')) {
            Navigator.of(context).pop();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Judul', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Judul wajib diisi' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _articleController,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Isi Artikel', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Artikel wajib diisi' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _authorController,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Penulis', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Penulis wajib diisi' : null,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'URL Gambar (Opsional)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 30),
                BlocBuilder<PostBloc, PostState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.status == PostStatus.loading ? null : _onSubmit,
                        child: state.status == PostStatus.loading
                            ? const CircularProgressIndicator()
                            : Text(isEditing ? 'Simpan Perubahan' : 'Terbitkan'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}