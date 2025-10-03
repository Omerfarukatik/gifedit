// lib/services/template_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/template.dart'; // Template modelini import edin

class TemplateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'templates';



  /// Firestore'dan tüm şablonları çeker.
  Future<List<Template>> getTemplates(BuildContext context) async {
    final snapshot = await _firestore.collection(_collection).get();
    
    return snapshot.docs.map((doc) => Template.fromFirestore(doc)).toList();
  }
  
  // Kullanıcının yüklediği özel bir şablonu (PRO) templates koleksiyonuna ekler.
  Future<void> addUserTemplate(Template template) async {
      final newTemplateData = {
          'ownerId': template.ownerId,
          'name_tr': template.nameTr,
          'name_en': template.nameEn,
          'sourceUrl': template.sourceUrl,
          'previewUrl': template.previewUrl,
          'isPremium': template.isPremium,
          'tags': template.tags,
          'timestamp': FieldValue.serverTimestamp(),
      };
      
      await _firestore.collection(_collection).add(newTemplateData);
  }
}