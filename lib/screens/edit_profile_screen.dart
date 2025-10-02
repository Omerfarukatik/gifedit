// lib/screens/edit_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:memecreat/l10n/app_localizations.dart';
import 'package:memecreat/providers/profile_provider.dart';
import 'package:memecreat/services/image_picker_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _usernameController;
  final _formKey = GlobalKey<FormState>();
  final ImagePickerService _pickerService = ImagePickerService();

  File? _newAvatarFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.userData['username'] ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final File? image = await _pickerService.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _newAvatarFile = image;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);

    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final newUsername = _usernameController.text.trim();

    try {
      await profileProvider.updateUserProfile(
        newUsername: newUsername,
        newAvatarFile: _newAvatarFile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil başarıyla güncellendi!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil güncellenirken bir hata oluştu: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currentAvatarUrl = widget.userData['avatarUrl'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profili Düzenle"), // TODO: Yerelleştir
        centerTitle: true,
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _saveProfile,
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profil Resmi Düzenleme
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    backgroundImage: _newAvatarFile != null
                        ? FileImage(_newAvatarFile!)
                        : (currentAvatarUrl != null && currentAvatarUrl.isNotEmpty)
                            ? CachedNetworkImageProvider(currentAvatarUrl)
                            : null as ImageProvider?,
                    child: (_newAvatarFile == null && (currentAvatarUrl == null || currentAvatarUrl.isEmpty))
                        ? Icon(Icons.person, size: 70, color: theme.colorScheme.primary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _pickImage,
                child: Text("Fotoğrafı Değiştir"), // TODO: Yerelleştir
              ),
              const SizedBox(height: 40),

              // Kullanıcı Adı Düzenleme
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: l10n.username,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.enterUsername;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}