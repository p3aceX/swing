import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

/// Google sign-in scoped to YouTube. Single responsibility: hand back a
/// usable [YouTubeApi] client. Token refresh is handled by google_sign_in.
class YouTubeAuth {
  final _signIn = GoogleSignIn(
    scopes: [YouTubeApi.youtubeScope],
  );

  YouTubeApi? _api;
  GoogleSignInAccount? _account;

  GoogleSignInAccount? get account => _account;
  YouTubeApi? get api => _api;
  bool get isSignedIn => _api != null && _account != null;

  Future<bool> signInSilently() async {
    try {
      final acc = await _signIn.signInSilently();
      if (acc == null) return false;
      return _bindApi(acc);
    } catch (e) {
      debugPrint('[AUTH] silent sign-in failed: $e');
      return false;
    }
  }

  Future<bool> signInInteractive() async {
    try {
      final acc = await _signIn.signIn();
      if (acc == null) return false;
      return _bindApi(acc);
    } catch (e) {
      debugPrint('[AUTH] interactive sign-in failed: $e');
      return false;
    }
  }

  Future<bool> _bindApi(GoogleSignInAccount acc) async {
    final client = await _signIn.authenticatedClient();
    if (client == null) {
      debugPrint('[AUTH] no auth client');
      return false;
    }
    _account = acc;
    _api = YouTubeApi(client);
    return true;
  }

  Future<void> signOut() async {
    await _signIn.signOut();
    _account = null;
    _api = null;
  }
}
