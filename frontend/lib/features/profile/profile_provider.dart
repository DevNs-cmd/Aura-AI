import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileState {
  final String userName;
  final String email;
  final String avatarUrl;
  final String
  selectedPersonality; // 'Empathetic', 'Analytical', 'Witty', 'Concise', 'Creative'

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
    : super(
        ProfileState(
          userName: 'Alex Rivera',
          email: 'alex.rivera@example.com',
          avatarUrl:
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=256&h=256&fit=crop',
          selectedPersonality: 'Empathetic',
        ),
      );

  void setPersonality(String value) {
    state = state.copyWith(selectedPersonality: value);
  }

  void updateProfile(String name, String email) {
    state = state.copyWith(userName: name, email: email);
  }

  void updateAvatar(String avatarUrl) {
    state = state.copyWith(avatarUrl: avatarUrl);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  return ProfileNotifier();
});
