// login_page.dart
import 'dart:io' show Platform;
import 'package:actpod_studio/features/create_story/controllers/package_create_controller.dart';
import 'package:actpod_studio/features/create_story/controllers/single_create_controller.dart';
import 'package:actpod_studio/features/create_story/controllers/user_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
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
    GoRouter.of(context).go('/publish/0');
    Navigator.of(context).maybePop();
  }

  Future<void> _loginToActpod(
    UserCredential cred, {
    String? email,
    String? displayName,
  }) async {
    final idToken = await cred.user?.getIdToken();
    final userCtrl = ref.read(userControllerProvider.notifier);
    await userCtrl.login(
      idToken ?? '',
      email ?? cred.user?.email,
      displayName ?? cred.user?.displayName ?? '',
    );
    await userCtrl.getUserInfo();

    final userState = ref.read(userControllerProvider);
    final singleCtrl = ref.read(singleCreateControllerProvider.notifier);
    final packageCtrl = ref.read(packageCreateControllerProvider.notifier);
    await singleCtrl.getSpaceList();
    singleCtrl.getUserChannels(userState?.userId ?? '');
    await packageCtrl.getSpaceList();
    packageCtrl.getUserChannels(userState?.userId ?? '');
  }

  String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  String? _profileString(Map<String, dynamic>? profile, String key) {
    final value = profile?[key];
    return value is String ? _nonEmpty(value) : null;
  }

  String? _appleDisplayName(AuthorizationCredentialAppleID credential) {
    return _nonEmpty(
      [
        credential.givenName,
        credential.familyName,
      ].whereType<String>().where((part) => part.trim().isNotEmpty).join(' '),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      UserCredential cred;

      final provider = GoogleAuthProvider();
      provider.addScope('email');
      provider.setCustomParameters({'prompt': 'select_account'});
      cred = await FirebaseAuth.instance.signInWithPopup(provider);
      final googleprofile = cred.additionalUserInfo?.profile;
      await _loginToActpod(
        cred,
        email: _profileString(googleprofile, 'email'),
        displayName: _profileString(googleprofile, 'name'),
      );

      await _onSignedIn(cred);
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _loading = true);
    try {
      UserCredential cred;
      String? appleEmail;
      String? appleName;

      if (kIsWeb) {
        // Web 走 Firebase 的 OAuthProvider + Popup
        final provider = OAuthProvider('apple.com');
        // 如需 email/name，Apple 只在首次授權提供，後續請自行保存
        cred = await FirebaseAuth.instance.signInWithPopup(provider);
        final appleProfile = cred.additionalUserInfo?.profile;
        appleEmail = _profileString(appleProfile, 'email');
        appleName = _profileString(appleProfile, 'name');
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
        appleEmail = appleIdCredential.email;
        appleName = _appleDisplayName(appleIdCredential);
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
        appleEmail = appleIdCredential.email;
        appleName = _appleDisplayName(appleIdCredential);
      }

      await _loginToActpod(cred, email: appleEmail, displayName: appleName);
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
                    icon: SvgPicture.asset(
                      'assets/images/Google_logo.svg',
                      width: 20,
                      height: 20,
                    ),
                    label: '使用 Google 登入',
                  ),
                  const SizedBox(height: 12),

                  // Apple 按鈕（可依需求強制顯示；此處僅在 iOS 13+ 顯示）
                  if (_appleAvailable ||
                      kIsWeb ||
                      (!kIsWeb && !Platform.isIOS && !Platform.isAndroid))
                    _AuthButton(
                      onPressed: _loading ? null : _signInWithApple,
                      icon: SvgPicture.asset(
                        'assets/images/Apple_logo.svg',
                        width: 20,
                        height: 20,
                      ),
                      label: '使用 Apple 登入',
                    ),

                  // const SizedBox(height: 24),
                  // Row(
                  //   children: const [
                  //     Expanded(child: Divider()),
                  //     Padding(
                  //       padding: EdgeInsets.symmetric(horizontal: 12),
                  //       child: Text('或'),
                  //     ),
                  //     Expanded(child: Divider()),
                  //   ],
                  // ),
                  // const SizedBox(height: 12),

                  // // 額外選項：遊客/稍後再說（可依你需求移除）
                  // TextButton(
                  //   onPressed: _loading
                  //       ? null
                  //       : () => Navigator.of(context).maybePop(),
                  //   child: const Text('稍後再說'),
                  // ),
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
