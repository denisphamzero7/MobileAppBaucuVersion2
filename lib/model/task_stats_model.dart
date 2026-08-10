class TaskStatsModel {
  final int total;
  final int todo;
  final int inProgress;
  final int pendingApproval;
  final int done;
  final int paused;
  final int cancelled;
  final TimingStatsModel timingStats;

  TaskStatsModel({
    this.total = 0,
    this.todo = 0,
    this.inProgress = 0,
    this.pendingApproval = 0,
    this.done = 0,
    this.paused = 0,
    this.cancelled = 0,
    required this.timingStats,
  });

  factory TaskStatsModel.fromJson(Map<String, dynamic> json) {
    return TaskStatsModel(
      total: json['total'] ?? 0,
      todo: json['todo'] ?? 0,
      inProgress: json['in_progress'] ?? 0,
      pendingApproval: json['pending_approval'] ?? 0,
      done: json['done'] ?? 0,
      paused: json['paused'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
      timingStats: json['timing_stats'] != null 
          ? TimingStatsModel.fromJson(json['timing_stats'])
          : TimingStatsModel(),
    );
  }

  factory TaskStatsModel.empty() {
    return TaskStatsModel(timingStats: TimingStatsModel());
  }
}

class TimingStatsModel {
  final int upcoming;
  final int early;
  final int onTime;
  final int late;
  final int overdue;
  final int cancelled;

  TimingStatsModel({
    this.upcoming = 0,
    this.early = 0,
    this.onTime = 0,
    this.late = 0,
    this.overdue = 0,
    this.cancelled = 0,
  });

  factory TimingStatsModel.fromJson(Map<String, dynamic> json) {
    return TimingStatsModel(
      upcoming: json['upcoming'] ?? 0,
      early: json['early'] ?? 0,
      onTime: json['on_time'] ?? 0,
      late: json['late'] ?? 0,
      overdue: json['overdue'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
    );
  }
}
