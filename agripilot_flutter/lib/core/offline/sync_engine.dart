import 'dart:async';
import 'package:agripilot_flutter/core/offline/connectivity_monitor.dart';
import 'package:agripilot_flutter/core/offline/sync_queue.dart';
import 'package:agripilot_flutter/core/offline/models/sync_task.dart';

class SyncEngine {
  final ConnectivityMonitor _connectivityMonitor;
  final SyncQueue _syncQueue;
  StreamSubscription<NetworkStatus>? _subscription;

  SyncEngine(this._connectivityMonitor, this._syncQueue);

  void start() {
    _subscription = _connectivityMonitor.onStatusChanged.listen((status) {
      if (status == NetworkStatus.online) {
        processQueue();
      }
    });
  }

  void stop() {
    _subscription?.cancel();
  }

  Future<void> processQueue() async {
    final tasks = await _syncQueue.getPendingTasks();
    for (final task in tasks) {
      // Dispatch task payload to API client (placeholder)
      // Then mark as completed
      await _syncQueue.updateTaskStatus(task.uuid, TaskStatus.completed);
    }
  }
}
