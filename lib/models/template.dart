// lib/models/template.dart
import 'package:cloud_firestore/cloud_firestore.dart';
class Template {
  final String id;
  final String? ownerId; 
  final String nameTr;
  final String nameEn;
  final String sourceUrl;
  final String previewUrl;
  final bool isPremium;
  final List<String> tags;

  Template({
    required this.id,
    this.ownerId, 
    required this.nameTr,
    required this.nameEn,
    required this.sourceUrl,
    required this.previewUrl,
    required this.isPremium,
    required this.tags,
  });

  // Firestore belgesinden Template nesnesi oluşturur
  factory Template.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Template(
      id: doc.id,
      ownerId: data['ownerId'] as String?,
      nameTr: data['name_tr'] as String? ?? '',
      nameEn: data['name_en'] as String? ?? '',
      sourceUrl: data['sourceUrl'] as String? ?? '', 
      previewUrl: data['previewUrl'] as String? ?? '',
      isPremium: data['isPremium'] as bool? ?? false,
      tags: List<String>.from(data['tags'] as List? ?? []),
    );
  }
}