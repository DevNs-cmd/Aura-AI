import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileState {
  final String userName;
  final String email;
  final String avatarUrl;
  final String selectedPersonality;

  ProfileState({
    required this.userName,
    required this.email,
    required this.avatarUrl,
    required this.selectedPersonality,
  });

  ProfileState copyWith({
    String? userName,
    String? email,
    String? avatarUrl,
    String? selectedPersonality,
  }) {
    return ProfileState(
      userName: userName ?? this.userName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      selectedPersonality: selectedPersonality ?? this.selectedPersonality,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier()
      : super(ProfileState(
          userName: 'Soumya', 
          email: 'soumya@example.com',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
          selectedPersonality: 'Empathetic',
        ));

  void setPersonality(String value) {
    state = state.copyWith(selectedPersonality: value);
  }

  // 🛠️ Missing methods ko empty add kar diya taaki UI crash na ho:
  void updateProfile(String? userName, String? email) {
    state = state.copyWith(
      userName: userName ?? state.userName,
      email: email ?? state.email,
    );
  }

  void updateAvatar(String newUrl) {
    state = state.copyWith(avatarUrl: newUrl);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});