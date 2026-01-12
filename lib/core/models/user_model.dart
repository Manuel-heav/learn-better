import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool isPremium;
  final int dayStreak;
  final int quizzesCompleted;
  final int studyTimeMinutes;
  final String complexityLevel; // beginner, intermediate, advanced
  final String aiPersona; // friendly, professional, socratic, motivational
  final bool notificationsEnabled;
  final bool readAloudEnabled;
  final String theme; // system, light, dark
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.isPremium = false,
    this.dayStreak = 0,
    this.quizzesCompleted = 0,
    this.studyTimeMinutes = 0,
    this.complexityLevel = 'intermediate',
    this.aiPersona = 'friendly',
    this.notificationsEnabled = true,
    this.readAloudEnabled = false,
    this.theme = 'system',
    required this.createdAt,
    this.lastLoginAt,
  });

  // From Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      isPremium: data['isPremium'] ?? false,
      dayStreak: data['dayStreak'] ?? 0,
      quizzesCompleted: data['quizzesCompleted'] ?? 0,
      studyTimeMinutes: data['studyTimeMinutes'] ?? 0,
      complexityLevel: data['complexityLevel'] ?? 'intermediate',
      aiPersona: data['aiPersona'] ?? 'friendly',
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      readAloudEnabled: data['readAloudEnabled'] ?? false,
      theme: data['theme'] ?? 'system',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isPremium': isPremium,
      'dayStreak': dayStreak,
      'quizzesCompleted': quizzesCompleted,
      'studyTimeMinutes': studyTimeMinutes,
      'complexityLevel': complexityLevel,
      'aiPersona': aiPersona,
      'notificationsEnabled': notificationsEnabled,
      'readAloudEnabled': readAloudEnabled,
      'theme': theme,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  // CopyWith method
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isPremium,
    int? dayStreak,
    int? quizzesCompleted,
    int? studyTimeMinutes,
    String? complexityLevel,
    String? aiPersona,
    bool? notificationsEnabled,
    bool? readAloudEnabled,
    String? theme,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isPremium: isPremium ?? this.isPremium,
      dayStreak: dayStreak ?? this.dayStreak,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      studyTimeMinutes: studyTimeMinutes ?? this.studyTimeMinutes,
      complexityLevel: complexityLevel ?? this.complexityLevel,
      aiPersona: aiPersona ?? this.aiPersona,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      readAloudEnabled: readAloudEnabled ?? this.readAloudEnabled,
      theme: theme ?? this.theme,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  // Get initials for avatar
  String get initials {
    // Handle empty or null displayName
    if (displayName.trim().isEmpty) {
      return email.isNotEmpty ? email[0].toUpperCase() : '?';
    }
    
    final names = displayName.trim().split(' ').where((n) => n.isNotEmpty).toList();
    
    if (names.length >= 2 && names[0].isNotEmpty && names[1].isNotEmpty) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty && names[0].isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    
    return email.isNotEmpty ? email[0].toUpperCase() : '?';
  }

  // Get study time in hours
  String get studyTimeFormatted {
    final hours = studyTimeMinutes ~/ 60;
    final minutes = studyTimeMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

