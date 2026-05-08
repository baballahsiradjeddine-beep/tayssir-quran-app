import 'package:flutter/material.dart';
import 'package:tayssir/environment_config.dart';

class Milestone {
  final double amount;
  final String label;
  final String iconPath;

  Milestone({
    required this.amount,
    required this.label,
    required this.iconPath,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      amount: (json['amount'] ?? 0).toDouble(),
      label: json['label'] ?? '',
      iconPath: json['icon_path'] ?? '',
    );
  }
}

class DocumentationMedia {
  final int id;
  final String url;
  final String thumb;

  DocumentationMedia({required this.id, required this.url, required this.thumb});

  factory DocumentationMedia.fromJson(Map<String, dynamic> json) {
    return DocumentationMedia(
      id: json['id'] ?? 0,
      url: EnvironmentConfig.resolveImageUrl(json['url'] ?? ''),
      thumb: EnvironmentConfig.resolveImageUrl(json['thumb'] ?? ''),
    );
  }
}

class CharityCampaign {
  final int id;
  final String title;
  final String description;
  final double currentAmount;
  final double targetAmount;
  final String mainMediaType; // 'image' or 'video'
  final String mainImageUrl;
  final String mainVideoUrl;
  final List<Milestone> milestones;
  final List<DocumentationMedia> documentationImages;
  final Color themeColor;
  final String status; // 'ongoing' or 'completed'

  CharityCampaign({
    required this.id,
    required this.title,
    required this.description,
    required this.currentAmount,
    required this.targetAmount,
    required this.mainMediaType,
    required this.mainImageUrl,
    required this.mainVideoUrl,
    this.milestones = const [],
    this.documentationImages = const [],
    this.themeColor = const Color(0xFF10B981),
    this.status = 'ongoing',
  });

  factory CharityCampaign.fromJson(Map<String, dynamic> json) {
    return CharityCampaign(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      currentAmount: (json['raised_amount'] ?? 0).toDouble(),
      targetAmount: (json['target_amount'] ?? 0).toDouble(),
      mainMediaType: json['main_media_type'] ?? 'image',
      mainImageUrl: EnvironmentConfig.resolveImageUrl(json['main_image_url'] ?? ''),
      mainVideoUrl: json['main_video_url'] ?? '',
      status: json['status'] ?? 'ongoing',
      milestones: (json['milestones'] as List? ?? [])
          .map((m) => Milestone.fromJson(m))
          .toList(),
      documentationImages: (json['documentation_images'] as List? ?? [])
          .map((m) => DocumentationMedia.fromJson(m))
          .toList(),
      themeColor: _getColorFromStatus(json['status']),
    );
  }

  static Color _getColorFromStatus(String? status) {
    if (status == 'completed') return Colors.blueGrey;
    return const Color(0xFF10B981);
  }

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  double get remainingAmount => (targetAmount - currentAmount).clamp(0.0, double.infinity);
  bool get isCompleted => status == 'completed';
}
