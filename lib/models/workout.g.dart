// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutAdapter extends TypeAdapter<Workout> {
  @override
  final int typeId = 0;

  @override
  Workout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Workout(
      exercise: fields[0] as String,
      sets: fields[1] as int,
      reps: fields[2] as int,
      weight: fields[3] as double,
      timestamp: fields[4] as DateTime,
      notes: fields[5] as String?,
      duration: fields[6] as Duration?,
    );
  }

  @override
  void write(BinaryWriter writer, Workout obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.exercise)
      ..writeByte(1)
      ..write(obj.sets)
      ..writeByte(2)
      ..write(obj.reps)
      ..writeByte(3)
      ..write(obj.weight)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
