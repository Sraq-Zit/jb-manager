import 'package:jbmanager/models/settings.dart';

class User {
  final int userId;
  final String fullname;
  final String type;
  final String company;
  final String token;
  final Settings settings;

  const User({
    required this.userId,
    required this.fullname,
    required this.type,
    required this.company,
    required this.token,
    required this.settings,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: json['user_id'],
    fullname: json['fullname'],
    type: json['type'],
    company: json['company'],
    token: json['token'],
    settings: Settings.fromJson(json['settings']),
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'fullname': fullname,
    'type': type,
    'company': company,
    'token': token,
    'settings': settings.toJson(),
  };

  User sample() => User(
    userId: 1,
    fullname: 'John Doe',
    type: 'admin',
    company: 'Acme Corp',
    token: 'xxxxxxx',
    settings: Settings.sample(),
  );

  User copyWith({
    int? userId,
    String? fullname,
    String? type,
    String? company,
    String? token,
    Settings? settings,
  }) => User(
    userId: userId ?? this.userId,
    fullname: fullname ?? this.fullname,
    type: type ?? this.type,
    company: company ?? this.company,
    token: token ?? this.token,
    settings: settings ?? this.settings,
  );
}
