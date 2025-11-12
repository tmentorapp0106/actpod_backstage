// login_page.dart
import 'dart:io' show Platform;
import 'package:actpod_studio/features/api/api.dart';
import 'package:actpod_studio/features/api/channel_system_api.dart';
import 'package:actpod_studio/features/api/space_system_api.dart';
import 'package:actpod_studio/features/api/user_system_api.dart';
import 'package:actpod_studio/features/create_story/models/channel_model.dart';
import 'package:actpod_studio/features/create_story/models/space_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;
  bool _appleAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkAppleAvailability();
  }

  Future<void> _checkAppleAvailability() async {
    try {
      // iOS 13+ 才會回 true；Android/Web 通常為 false（若你有走 Web OAuth 可直接顯示按鈕）
      final available = await SignInWithApple.isAvailable();
      if (mounted) setState(() => _appleAvailable = available);
    } catch (_) {
      // 忽略，維持 false
    }
  }

  void _showError(Object e) {
    final msg = e is FirebaseAuthException
        ? (e.message ?? e.code)
        : e.toString();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg, maxLines: 3)));
  }

  Future<void> _onSignedIn(UserCredential cred) async {
    final name =
        cred.user?.displayName ?? cred.user?.email ?? cred.user?.uid ?? 'User';
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Welcome, $name')));
    GoRouter.of(context).go('/publish/:step');
    Navigator.of(context).maybePop();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      UserCredential cred;

      final provider = GoogleAuthProvider();
      provider.addScope('email');
      provider.setCustomParameters({'prompt': 'select_account'});
      cred = await FirebaseAuth.instance.signInWithPopup(provider);
      final googleId = cred.additionalUserInfo?.profile?['id'];
      final googleprofile = cred.additionalUserInfo?.profile;
      final idToken = await cred.user?.getIdToken();
      print('🔐 Firebase ID Token: $idToken');

      print('🆔 Google user id (Web): $googleId');
      print('🆔 Google user profile (Web): $googleprofile');

      


      final response = await UserApi().thirdPartyCreateUserOrLogin(
        idToken ?? '',
        cred.user?.email ?? '',
        cred.user?.displayName ?? '',
      );
      userToken = response.data['data']['userToken'] ?? '';
      userId = response.data['data']['userId'] ?? '';

      final userInfo = await UserApi().getUserInfo();
      print('userInfo000000000000000: $userInfo["avatarUrl"]');

      final spaceResponse = await SpaceApi().getSpaces();
      final spaceListData = spaceResponse.data['data'] as List;
      spaces = spaceListData
          .whereType<Map<String, dynamic>>()
          .map((e) => Space.fromJson(e))
          .toList();

      if (mounted) setState(() => _loading = false);

      final channelResponse = await ChannelApi().getUserChannels(userId);
      final channelListData = channelResponse.data['data'] as List;
      channels = channelListData.map((e) {
        return Channel.fromJson(e);
      }).toList();

      print('🌐 Backend response: ${channels.first}');
      await _onSignedIn(cred);
      print(
        '✅ 登入成功，使用者 UID：${cred.user?.providerData.firstWhere((p) => p.providerId == 'google.com').uid}',
      );

      print('✅ 登入成功，使用者 UID：${cred.user?.uid}');
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _loading = true);
    try {
      UserCredential cred;

      if (kIsWeb) {
        // Web 走 Firebase 的 OAuthProvider + Popup
        final provider = OAuthProvider('apple.com');
        // 如需 email/name，Apple 只在首次授權提供，後續請自行保存
        cred = await FirebaseAuth.instance.signInWithPopup(provider);
      } else if (Platform.isAndroid) {
        // Android 常見做法：走 Web OAuth（仍可用 sign_in_with_apple 取得 code/idToken）
        final appleIdCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          webAuthenticationOptions: WebAuthenticationOptions(
            clientId: 'app.actpod', // 你的 Service ID
            redirectUri: Uri.parse(
              'https://applelogin.actpodapp.com/callbacks/sign_in_with_apple',
            ),
          ),
        );
        final oauth = OAuthProvider('apple.com');
        final credential = oauth.credential(
          idToken: appleIdCredential.identityToken,
          accessToken: appleIdCredential.authorizationCode,
        );
        cred = await FirebaseAuth.instance.signInWithCredential(credential);
      } else {
        // iOS/macOS 原生 Sign in with Apple
        final appleIdCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
        final oauth = OAuthProvider('apple.com');
        final credential = oauth.credential(
          idToken: appleIdCredential.identityToken,
          accessToken: appleIdCredential.authorizationCode,
        );
        cred = await FirebaseAuth.instance.signInWithCredential(credential);
      }

      await _onSignedIn(cred);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code != AuthorizationErrorCode.canceled) {
        _showError(e);
      }
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LOGO / 標題區
                  Image.asset(
                    'assets/images/actpod_logo.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '登入你的帳號',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '使用 Google 或 Apple 快速登入',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Google 按鈕
                  _AuthButton(
                    onPressed: _loading ? null : _signInWithGoogle,
                    icon: SvgPicture.string(_googleSvg, width: 20, height: 20),
                    label: '使用 Google 登入',
                  ),
                  const SizedBox(height: 12),

                  // // Apple 按鈕（可依需求強制顯示；此處僅在 iOS 13+ 顯示）
                  // if (_appleAvailable ||
                  //     kIsWeb ||
                  //     (!kIsWeb && !Platform.isIOS && !Platform.isAndroid))
                  //   _AuthButton(
                  //     onPressed: _loading ? null : _signInWithApple,
                  //     icon: SvgPicture.string(_appleSvg, width: 20, height: 20),
                  //     label: '使用 Apple 登入',
                  //   ),
                  const SizedBox(height: 24),
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('或'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 額外選項：遊客/稍後再說（可依你需求移除）
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.of(context).maybePop(),
                    child: const Text('稍後再說'),
                  ),

                  const SizedBox(height: 24),

                  // 條款
                  Text(
                    '登入即表示你同意服務條款與隱私權政策。',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),

                  // 載入遮罩
                  if (_loading) ...[
                    const SizedBox(height: 24),
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.6),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String label;

  const _AuthButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: disabled
              ? theme.disabledColor
              : theme.colorScheme.onSurface,
          side: BorderSide(
            color: disabled ? theme.disabledColor : theme.dividerColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// 簡易 SVG（你也可改成本地資產）
const String _googleSvg = '''
<svg viewBox="0 0 24 24">
<path d="M21.35 11.1h-9.17v2.98h5.26c-.23 1.34-1.58 3.93-5.26 3.93-3.17 0-5.76-2.62-5.76-5.86s2.59-5.86 5.76-5.86c1.81 0 3.02.77 3.72 1.44l2.52-2.43C16.94 3.59 15.01 2.8 12.92 2.8 7.99 2.8 4 6.81 4 11.74s3.99 8.94 8.92 8.94c5.16 0 8.58-3.62 8.58-8.72 0-.59-.06-1.04-.15-1.86z" fill="currentColor"/>
</svg>
''';

const String _appleSvg = '''
<svg viewBox="0 0 24 24">
<path d="M16.365 1.43c0 1.14-.47 2.21-1.23 3-.79.84-2.1 1.48-3.21 1.45-.14-1.1.48-2.24 1.23-3.02.82-.83 2.24-1.45 3.21-1.43zm4.12 16.44c-.57 1.29-1.25 2.5-2.25 3.97-1.03 1.51-2.32 3.41-4.07 3.44-1.72.03-2.18-1.1-4.05-1.1-1.87 0-2.38 1.07-4.1 1.12-1.74.04-3.06-1.64-4.1-3.14C.8 19.94-.52 15.84.86 12.86c.77-1.67 2.14-2.74 3.64-2.77 1.71-.03 3.12 1.16 4.05 1.16.93 0 2.8-1.43 4.73-1.22.8.03 3.06.32 4.51 2.41-.12.07-2.69 1.57-2.66 4.67.03 3.72 3.25 4.97 3.34 4.97z" fill="currentColor"/>
</svg>
''';
