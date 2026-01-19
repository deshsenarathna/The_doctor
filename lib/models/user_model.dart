class UserModel {
  final String email;
  final String phone;
  final String role;
  final String uid;
  final bool isDoctor;

  UserModel({
    required this.email,
    required this.phone,
    required this.role,
    required this.uid,
    required this.isDoctor,
  });
}
