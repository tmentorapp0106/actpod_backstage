import 'package:actpod_studio/features/api/user_system_api.dart';
import 'package:actpod_studio/features/create_story/controllers/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'theme/theme.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  const AppScaffold({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1100;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: _TopBar(title: title),
      ),
      drawer: isWide ? null : const _SideNav(),
      body: Row(
        children: [
          if (isWide) const _SideNav(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Text("", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(width: 90),
              Expanded(
                child: SvgPicture.asset('assets/images/logo.svg', height: 32),
              ),
              const SizedBox(width: 12),
              IconButton(
                tooltip: '通知',
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded, size: 24),
              ),
              const SizedBox(width: 4),
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.seed.withOpacity(.15),
                child: const Icon(Icons.person, color: AppTheme.seed, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    

    final items = [
      // _NavItem('故事館', Icons.auto_graph_rounded, '/stories'),
      _NavItem('新建故事', Icons.add_box_rounded, '/publish/0'),
    ];

    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 1 Creator info 區塊
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              child: Consumer(
                builder: (context, ref, _) {
                  final userState = ref.watch(userControllerProvider);

                  return userState.when(
                    data: (user) => _CreatorInfoTile(
                      name: user?.name ?? '',
                      subtitle: user?.email ?? '',
                      avatarUrl: (user?.avatarUrl.isNotEmpty ?? false)
                          ? user!.avatarUrl
                          : null,
                      onTap: () {},
                    ),
                    loading: () => const _CreatorInfoTile(
                      name: '載入中...',
                      subtitle: '',
                      avatarUrl: null,
                    ),
                    error: (_, __) => const _CreatorInfoTile(
                      name: '載入失敗',
                      subtitle: '',
                      avatarUrl: null,
                    ),
                  );
                },
              ),
            ),

            // Padding(
            //   padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
            //   child:
            //    _CreatorInfoTile(
            //     name: 'ActPod Official',
            //     subtitle: '',
            //     avatarUrl:
            //         'https://story.actpodapp.com/banner/banner4.jpg'.isNotEmpty
            //         ? 'https://story.actpodapp.com/banner/banner4.jpg'
            //         : null,

            //     onTap: () {
            //       // TODO: 導到個人設定頁
            //       // context.go('/settings/profile');
            //     },
            //   ), // 你自己的創作者資訊 Widget
            // ),

            const Divider(height: 1),

            // 2 導覽項目（可捲動）
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                itemBuilder: (_, i) {
                  final it = items[i];
                  final selected = location.startsWith(it.path);
                  return Material(
                    child: ListTile(
                      leading: Icon(
                        it.icon,
                        color: selected ? AppTheme.seed : null,
                      ),
                      title: Text(
                        it.label,
                        style: TextStyle(
                          color: selected ? AppTheme.seed : Colors.black87,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                      hoverColor: selected
                          ? Colors.transparent
                          : const Color.fromARGB(245, 245, 245, 245), // ✅ 修正後
                      tileColor: selected
                          ? AppTheme.seed.withOpacity(.1)
                          : Colors.white,
                      onTap: () => context.go(it.path),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemCount: items.length,
              ),
            ),

            const Divider(height: 1),

            // 3 登出按鈕（固定在底部）
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('登出'),
                  onPressed: () async {
                    // TODO: 登出邏輯
                    await _signOut(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _signOut(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    // 登出成功後，導向登入頁面或其他適當的頁面
    context.go('/login');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已登出')));
  } catch (e) {
    // 處理登出錯誤
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('登出失敗: $e')));
  }
}

class _CreatorInfoTile extends StatelessWidget {
  final String name;
  final String subtitle; // e.g. email 或 角色
  final String? avatarUrl; // 可選：頭像網址
  final VoidCallback? onTap; // 可選：點擊事件（例如進入個人設定）
  final int storyCount = 42; // 範例故事數
  final int channelCount = 2; // 範例頻道數

  const _CreatorInfoTile({
    super.key,
    required this.name,
    required this.subtitle,
    this.avatarUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final seed = AppTheme.seed;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: seed.withOpacity(.15),
              backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: (avatarUrl == null || avatarUrl!.isEmpty)
                  ? Icon(Icons.person, color: seed, size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(220, 0, 0, 0),
                        height: 1.2,
                      ),
                      // children: [
                      //   TextSpan(text: '$channelCount Channels'),
                      //   const TextSpan(text: '  •  '), // 中點分隔
                      //   TextSpan(text: '$storyCount Stories'),
                      // ],
                      children: [
                        TextSpan(text: '$subtitle Channels'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String path;
  _NavItem(this.label, this.icon, this.path);
}
