class UserAccessModel {
  final String userApplicationAccess;
  final String? message;

  UserAccessModel({
    required this.userApplicationAccess,
    this.message,
  });

  bool get isAllowed => userApplicationAccess == 'ALLOWED';

  factory UserAccessModel.fromJson(Map<String, dynamic> json) {
    return UserAccessModel(
      userApplicationAccess:
      json['userApplicationAccess']?.toString() ?? 'ALLOWED',
      message: json['message']?.toString(),
    );
  }
}