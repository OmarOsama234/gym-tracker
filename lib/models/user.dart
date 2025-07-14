import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String email;

  @HiveField(2)
  String displayName;

  @HiveField(3)
  String? photoURL;

  @HiveField(4)
  UserRole role;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime lastLoginAt;

  @HiveField(7)
  bool isFirstLogin;

  @HiveField(8)
  String? bio;

  @HiveField(9)
  int? age;

  @HiveField(10)
  String? phoneNumber;

  @HiveField(11)
  List<String> interests;

  @HiveField(12)
  Map<String, dynamic> preferences;

  @HiveField(13)
  DateTime? dateOfBirth;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.role,
    required this.createdAt,
    required this.lastLoginAt,
    this.isFirstLogin = true,
    this.bio,
    this.age,
    this.phoneNumber,
    this.interests = const [],
    this.preferences = const {},
    this.dateOfBirth,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      role: UserRole.values[json['role']],
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: DateTime.parse(json['lastLoginAt']),
      isFirstLogin: json['isFirstLogin'] ?? true,
      bio: json['bio'],
      age: json['age'],
      phoneNumber: json['phoneNumber'],
      interests: List<String>.from(json['interests'] ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'role': role.index,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'isFirstLogin': isFirstLogin,
      'bio': bio,
      'age': age,
      'phoneNumber': phoneNumber,
      'interests': interests,
      'preferences': preferences,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
    };
  }
}

@HiveType(typeId: 2)
enum UserRole {
  @HiveField(0)
  trainee,
  @HiveField(1)
  trainer,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.trainee:
        return 'Trainee';
      case UserRole.trainer:
        return 'Trainer';
    }
  }

  String get description {
    switch (this) {
      case UserRole.trainee:
        return 'Track your workouts and progress';
      case UserRole.trainer:
        return 'Guide and monitor trainees';
    }
  }
}