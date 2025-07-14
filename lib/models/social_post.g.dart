// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_post.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SocialPostAdapter extends TypeAdapter<SocialPost> {
  @override
  final int typeId = 3;

  @override
  SocialPost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SocialPost(
      id: fields[0] as String,
      userId: fields[1] as String,
      userDisplayName: fields[2] as String,
      userPhotoURL: fields[3] as String?,
      content: fields[4] as String,
      imageUrls: (fields[5] as List).cast<String>(),
      createdAt: fields[6] as DateTime,
      likes: (fields[7] as List).cast<String>(),
      comments: (fields[8] as List).cast<Comment>(),
      type: fields[9] as PostType,
      metadata: (fields[10] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, SocialPost obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.userDisplayName)
      ..writeByte(3)
      ..write(obj.userPhotoURL)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.imageUrls)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.likes)
      ..writeByte(8)
      ..write(obj.comments)
      ..writeByte(9)
      ..write(obj.type)
      ..writeByte(10)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialPostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CommentAdapter extends TypeAdapter<Comment> {
  @override
  final int typeId = 4;

  @override
  Comment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Comment(
      id: fields[0] as String,
      userId: fields[1] as String,
      userDisplayName: fields[2] as String,
      userPhotoURL: fields[3] as String?,
      content: fields[4] as String,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Comment obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.userDisplayName)
      ..writeByte(3)
      ..write(obj.userPhotoURL)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PostTypeAdapter extends TypeAdapter<PostType> {
  @override
  final int typeId = 5;

  @override
  PostType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PostType.workout;
      case 1:
        return PostType.progress;
      case 2:
        return PostType.motivation;
      case 3:
        return PostType.equipment;
      case 4:
        return PostType.general;
      default:
        return PostType.workout;
    }
  }

  @override
  void write(BinaryWriter writer, PostType obj) {
    switch (obj) {
      case PostType.workout:
        writer.writeByte(0);
        break;
      case PostType.progress:
        writer.writeByte(1);
        break;
      case PostType.motivation:
        writer.writeByte(2);
        break;
      case PostType.equipment:
        writer.writeByte(3);
        break;
      case PostType.general:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
