import 'package:flutter/foundation.dart';

import 'secure/local_file_store.dart';

/// 인트로/스냅샷 이미지를 채팅에 어떤 비율로 보여줄지.
enum ChatImageDisplayMode { square, fullWidth }

const _storeKey = 'chat_image_display_mode';

/// 마이페이지 > 환경설정에서 고른 이미지 표시 방식을 관리한다. 앱 시작 시 저장된 값을
/// 읽어 복원하고, 바뀌면 [ValueNotifier]를 통해 채팅 화면에 즉시 반영된다.
class ChatImagePreferences extends ValueNotifier<ChatImageDisplayMode> {
  ChatImagePreferences() : super(ChatImageDisplayMode.square);

  final _store = LocalFileStore();

  Future<void> load() async {
    final saved = await _store.read(_storeKey);
    value = ChatImageDisplayMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ChatImageDisplayMode.square,
    );
  }

  Future<void> setMode(ChatImageDisplayMode mode) async {
    value = mode;
    await _store.write(_storeKey, mode.name);
  }
}
