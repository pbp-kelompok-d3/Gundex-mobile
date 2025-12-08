class LogPendakian {
  final String id;
  final String? gunungId;
  final String gunungNama;
  final String? startDate;
  final String? endDate;
  final bool summitReached;
  final int? teamSize;
  final int? rating;
  final String? notes;
  final int? durationDays;
  final String? photoUrl;

  LogPendakian({
    required this.id,
    this.gunungId,
    required this.gunungNama,
    this.startDate,
    this.endDate,
    required this.summitReached,
    this.teamSize,
    this.rating,
    this.notes,
    this.durationDays,
    this.photoUrl,
  });

  factory LogPendakian.fromJson(Map<String, dynamic> json) {
    return LogPendakian(
      id: json['id'].toString(),
      gunungId: json['gunung_id'] as String?,
      gunungNama: (json['gunung_nama'] ?? '-') as String,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      summitReached: (json['summit_reached'] ?? false) as bool,
      teamSize: json['team_size'] as int?,
      rating: json['rating'] as int?,
      notes: json['notes'] as String?,
      durationDays: json['duration_days'] as int?,
      photoUrl: json['photo_url'] as String?,
    );
  }
}
