import 'package:hive/hive.dart';

enum TaskType {
  chat,
  imageUpload,
  profileUpdate,
  farmUpdate,
  voiceNote,
  ocrRequest,
  diseaseScan,
  settings,
  custom
}

enum TaskStatus {
  pending,
  inProgress,
  completed,
  failed,
  deadLetter
}

class SyncTask {
  String uuid;
  TaskType type;
  String payload;
  int priority;
  TaskStatus status;
  int retryCount;
  DateTime createdAt;
  DateTime updatedAt;
  String? deviceId;
  String? userId;
  String? checksum;
  String? lastError;

  SyncTask({
    required this.uuid,
    required this.type,
    required this.payload,
    this.priority = 10,
    this.status = TaskStatus.pending,
    this.retryCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.deviceId,
    this.userId,
    this.checksum,
    this.lastError,
  });
}

class TaskTypeAdapter extends TypeAdapter<TaskType> {
  @override
  final typeId = 0;

  @override
  TaskType read(BinaryReader reader) {
    return TaskType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, TaskType obj) {
    writer.writeByte(obj.index);
  }
}

class TaskStatusAdapter extends TypeAdapter<TaskStatus> {
  @override
  final typeId = 1;

  @override
  TaskStatus read(BinaryReader reader) {
    return TaskStatus.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, TaskStatus obj) {
    writer.writeByte(obj.index);
  }
}

class SyncTaskAdapter extends TypeAdapter<SyncTask> {
  @override
  final typeId = 2;

  @override
  SyncTask read(BinaryReader reader) {
    return SyncTask(
      uuid: reader.readString(),
      type: reader.read(),
      payload: reader.readString(),
      priority: reader.readInt(),
      status: reader.read(),
      retryCount: reader.readInt(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      deviceId: reader.readString(),
      userId: reader.readString(),
      checksum: reader.readString(),
      lastError: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, SyncTask obj) {
    writer.writeString(obj.uuid);
    writer.write(obj.type);
    writer.writeString(obj.payload);
    writer.writeInt(obj.priority);
    writer.write(obj.status);
    writer.writeInt(obj.retryCount);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeInt(obj.updatedAt.millisecondsSinceEpoch);
    writer.writeString(obj.deviceId ?? '');
    writer.writeString(obj.userId ?? '');
    writer.writeString(obj.checksum ?? '');
    writer.writeString(obj.lastError ?? '');
  }
}
