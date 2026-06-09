class GuestProfileModel {
  final String guestId;
  final String nickname;
  final String avatarIcon;
  final bool lsasDemoCompleted;

  const GuestProfileModel({
    required this.guestId,
    required this.nickname,
    required this.avatarIcon,
    required this.lsasDemoCompleted,
  });

  factory GuestProfileModel.fromJson(Map<String, dynamic> json) {
    return GuestProfileModel(
      guestId: json['guestId']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      avatarIcon: json['avatarIcon']?.toString() ?? 'avatar_cat',
      lsasDemoCompleted: json['lsasDemoCompleted'] == true,
    );
  }
}
