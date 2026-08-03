import 'package:hive_flutter/hive_flutter.dart';
import 'package:agripilot_flutter/core/offline/models/sync_task.dart';

class SyncQueue {
  late Box<SyncTask> _taskBox;

  Future<void> init() async {
    _taskBox = await Hive.openBox<SyncTask>('sync_tasks');
  }

  Future<void> enqueue(SyncTask task) async {
    await _taskBox.put(task.uuid, task);
  }

  Future<List<SyncTask>> getPendingTasks() async {
    final tasks = _taskBox.values.where((task) => 
      task.status == TaskStatus.pending || task.status == TaskStatus.failed
    ).toList();
    
    tasks.sort((a, b) {
      final pCompare = a.priority.compareTo(b.priority);
      if (pCompare != 0) return pCompare;
      return a.createdAt.compareTo(b.createdAt);
    });

    return tasks;
  }

  Future<void> updateTaskStatus(String taskUuid, TaskStatus status, {String? error, int? retryCount}) async {
    final task = _taskBox.get(taskUuid);
    if (task != null) {
      task.status = status;
      task.updatedAt = DateTime.now();
      if (error != null) task.lastError = error;
      if (retryCount != null) task.retryCount = retryCount;
      await _taskBox.put(taskUuid, task);
    }
  }

  Future<void> removeTask(String taskUuid) async {
    await _taskBox.delete(taskUuid);
  }
}
