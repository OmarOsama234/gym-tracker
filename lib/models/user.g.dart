// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 1;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      email: fields[1] as String,
      displayName: fields[2] as String,
      photoURL: fields[3] as String?,
      role: fields[4] as UserRole,
      createdAt: fields[5] as DateTime,
      lastLoginAt: fields[6] as DateTime,
      isFirstLogin: fields[7] as bool,
      bio: fields[8] as String?,
      age: fields[9] as int?,
      phoneNumber: fields[10] as String?,
      interests: (fields[11] as List).cast<String>(),
      preferences: (fields[12] as Map).cast<String, dynamic>(),
      dateOfBirth: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.photoURL)
      ..writeByte(4)
      ..write(obj.role)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.lastLoginAt)
      ..writeByte(7)
      ..write(obj.isFirstLogin)
      ..writeByte(8)
      ..write(obj.bio)
      ..writeByte(9)
      ..write(obj.age)
      ..writeByte(10)
      ..write(obj.phoneNumber)
      ..writeByte(11)
      ..write(obj.interests)
      ..writeByte(12)
      ..write(obj.preferences)
      ..writeByte(13)
      ..write(obj.dateOfBirth);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserRoleAdapter extends TypeAdapter<UserRole> {
  @override
  final int typeId = 2;

  @override
  UserRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserRole.trainee;
      case 1:
        return UserRole.trainer;
      default:
        return UserRole.trainee;
    }
  }

  @override
  void write(BinaryWriter writer, UserRole obj) {
    switch (obj) {
      case UserRole.trainee:
        writer.writeByte(0);
        break;
      case UserRole.trainer:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
