import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 1;

  @override
  User read(BinaryReader reader) {
    return User(
      id: reader.readString(),
      username: reader.readString(),
      email: reader.readString(),
      password: reader.readString(),
      createdAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.username);
    writer.writeString(obj.email);
    writer.writeString(obj.password);
    writer.writeString(obj.createdAt.toIso8601String());
  }
}

class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String password;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, username, email, password, createdAt];
}


