import 'package:actpod_studio/app/theme/theme.dart';
import 'package:flutter/material.dart';
import '../../app/app_scaffold.dart';
import '../widgets/app_card.dart';

enum SortBy { newest, oldest, mostPlayed }

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _status = '全部';
  SortBy _sortBy = SortBy.newest;
  String? _selectedChannel; // null = 所有頻道
  final _channels = ['ActPod Official', 'channel 1', 'channel 2'];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ActPod 後台',
      child: ListView(
        padding: _responsivePadding(context),

        children: [
          // 🔹 篩選與排序列
          Row(
            children: [
              // ✅ 讓 Wrap 在 Row 內有界寬度，才會乖乖換行
              Container(
                child: Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ChannelDropdown(
                        items: _channels, // 你上面宣告的頻道清單
                        value: _selectedChannel, // null 代表「所有頻道」
                        onChanged: (v) => setState(() => _selectedChannel = v),
                      ),

                      _buildSortMenu(context),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),
              Spacer(),
              // 右側搜尋（固定寬度或可展開的元件）
              const _SearchField(),
            ],
          ),

          const SizedBox(height: 20),

          GridView.builder(
            itemCount: 12,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _cols(context),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 4 / 3,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, i) => const _StoryCard(),
          ),
        ],
      ),
    );
  }

  // 篩選 chip
  Widget _buildFilterChip(String label) {
    final selected = _status == label;
    return FilterChip(
      label: Text(label),
      selected: selected,
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(.15),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      onSelected: (_) => setState(() => _status = label),
    );
  }

  // 排序選單
  Widget _buildSortMenu(BuildContext context) {
    return MenuAnchor(
      builder: (ctx, controller, _) {
        return OutlinedButton.icon(
          onPressed: () =>
              controller.isOpen ? controller.close() : controller.open(),
          icon: const Icon(Icons.sort_rounded, size: 20),
          label: Text(_sortLabel),
        );
      },
      menuChildren: [
        MenuItemButton(
          onPressed: () => setState(() => _sortBy = SortBy.newest),
          leadingIcon: _sortBy == SortBy.newest
              ? const Icon(Icons.check_rounded)
              : const SizedBox(width: 24),
          child: const Text('最新發布'),
        ),
        MenuItemButton(
          onPressed: () => setState(() => _sortBy = SortBy.oldest),
          leadingIcon: _sortBy == SortBy.oldest
              ? const Icon(Icons.check_rounded)
              : const SizedBox(width: 24),
          child: const Text('最舊發布'),
        ),
        MenuItemButton(
          onPressed: () => setState(() => _sortBy = SortBy.mostPlayed),
          leadingIcon: _sortBy == SortBy.mostPlayed
              ? const Icon(Icons.check_rounded)
              : const SizedBox(width: 24),
          child: const Text('最多播放'),
        ),
      ],
    );
  }

  String get _sortLabel {
    switch (_sortBy) {
      case SortBy.newest:
        return '最新發布';
      case SortBy.oldest:
        return '最舊發布';
      case SortBy.mostPlayed:
        return '最多播放';
    }
  }

  int _cols(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1400) return 3;
    if (w >= 1600) return 2;
    if (w >= 720) return 2;
    return 1;
  }

  EdgeInsets _responsivePadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1750) {
      return const EdgeInsets.symmetric(horizontal: 120, vertical: 16);
    } else if (w >= 1200) {
      return const EdgeInsets.symmetric(horizontal: 52, vertical: 16);
    } else if (w >= 720) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 8, vertical: 12);
    }
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({super.key});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  bool _expanded = false;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: _expanded ? 220 : 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB)), // 淺灰邊框
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Center(child: Icon(Icons.search_rounded, size: 20)),
            onPressed: () => setState(() => _expanded = true),
            padding: EdgeInsets.zero, // 移除預設 padding
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          if (_expanded)
            Expanded(
              child: TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '搜尋...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (v) {
                  debugPrint('搜尋: $v');
                  // TODO: 呼叫你的搜尋邏輯
                },
              ),
            ),
          if (_expanded)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () {
                setState(() {
                  _expanded = false;
                  _controller.clear();
                });
              },
            ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppTheme().theme.colorScheme.primary;
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 上半：左圖右文
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 封面 + 左下角「試聽精華」
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      // 建議固定寬高，接近你圖中的比例
                      SizedBox(
                        width: 110,
                        height: 110,
                        child: Image.network(
                          'https://picsum.photos/seed/actpod/600/400',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.55),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.play_arrow_rounded,
                                  size: 16, color: Colors.white),
                              SizedBox(width: 4),
                              Text('試聽精華',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // 右側文字區
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 標題（多行、粗）
                      Text(
                        'EP1｜標題標題標題標題標題標題標題標題標題標題',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // 作者
                      _LineMeta(
                        icon: Icons.person_rounded,
                        text: 'Test',
                      ),
                      const SizedBox(height: 4),
                      // 頻道
                      _LineMeta(
                        icon: Icons.podcasts_rounded,
                        text: 'Test’s channel',
                      ),
                      const SizedBox(height: 8),

                      // 標籤膠囊
                      const _TagChip(label: '空間'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 摘要
            const Text(
              '白日依山盡，黃河入海流，欲窮千里目，更上一層樓。白日依山盡，黃河入海流，欲窮千里目，更上一層樓...',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
            ),

            const SizedBox(height: 12),

            // 底部資訊列
            Row(
              children: [
                const Icon(Icons.calendar_month_outlined,
                    size: 16, color: Colors.black45),
                const SizedBox(width: 6),
                const Text('2025-01-01 15:00',
                    style: TextStyle(color: Colors.black54)),

                const SizedBox(width: 16),
                const Icon(Icons.headphones_outlined,
                    size: 16, color: Colors.black45),
                const SizedBox(width: 6),
                const Text('0 次', style: TextStyle(color: Colors.black54)),

                const SizedBox(width: 16),
                Icon(Icons.bolt_rounded, size: 16, color: primary),
                const SizedBox(width: 4),
                Text('新發布',
                    style: TextStyle(
                        color: primary, fontWeight: FontWeight.w600)),

                const Spacer(),

                // 右側播放圓鈕
                SizedBox(
                  width: 44,
                  height: 44,
                  child: FloatingActionButton(
                    elevation: 0,
                    heroTag: null,
                    onPressed: () {},
                    backgroundColor: primary,
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 單行小中繼資料（左icon + 右文字、灰色）
class _LineMeta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _LineMeta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

// 灰底膠囊
class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.black54),
      ),
    );
  }
}


/// 你的設計系統 token（可換成 AppTokens）
class T {
  static const chipBg        = Color(0xFFF3F4F6);
  static const chipFg        = Color(0xFF111111);
  static const chipBorder    = Color(0xFFE5E7EB);

  static const menuBg        = Colors.white;
  static const menuBorder    = Color(0xFFE5E7EB);
  static const menuShadow    = Colors.black26;

  static const itemFg        = Color(0xFF111111);
  static const itemFgMuted   = Color(0xFF666666);
  static const itemHover     = Color(0xFFF6F7F8);
  static const itemSelected  = Color.fromARGB(255, 241, 208, 130); // 淡藍底
  static const brand         = Color(0xFFFFBC1F); // ActPod Yellow
}


class ChannelDropdown extends StatefulWidget {
  final List<String> items;
  final String? value; // null = 所有頻道
  final ValueChanged<String?> onChanged;
  final double maxWidth;

  const ChannelDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.maxWidth = 200,
  });

  @override
  State<ChannelDropdown> createState() => _ChannelDropdownState();
}

class _ChannelDropdownState extends State<ChannelDropdown> {
  MenuController? _menu;

  @override
  Widget build(BuildContext context) {
    final label = widget.value ?? '所有頻道';

    return MenuAnchor(
      controller: _menu,
      // ⭐ 下拉面板樣式
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(T.menuBg),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 8)),
        elevation: const WidgetStatePropertyAll(10),
        shadowColor: const WidgetStatePropertyAll(T.menuShadow),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: T.menuBorder),
          ),
        ),
      ),
      builder: (ctx, controller, _) {
        _menu = controller;
        final opened = controller.isOpen;

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.maxWidth),
          child: TextButton.icon(
            onPressed: () => opened ? controller.close() : controller.open(),
            icon: AnimatedRotation(
              turns: opened ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 160),
              child: const Icon(Icons.expand_more_rounded, size: 18),
            ),
            label: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            // ⭐ 膠囊觸發器樣式（像灰底 chip）
            style: TextButton.styleFrom(
              foregroundColor: T.chipFg,
              backgroundColor: T.chipBg,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: StadiumBorder(
                side: const BorderSide(color: T.chipBorder),
              ),
              visualDensity: VisualDensity.compact,
            ),
          ),
        );
      },

      // ⭐ 下拉選單項目
      menuChildren: [
        _menuItem(
          title: '所有頻道',
          selected: widget.value == null,
          onTap: () {
            widget.onChanged(null);
            _menu?.close();
          },
        ),
        Divider(height: 8, thickness: 1, color: T.menuBorder),
        ...widget.items.map(
          (name) => _menuItem(
            title: name,
            selected: widget.value == name,
            onTap: () {
              widget.onChanged(name);
              _menu?.close();
            },
          ),
        ),
      ],
    );
  }

  MenuItemButton _menuItem({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return MenuItemButton(
      onPressed: onTap,
      leadingIcon: selected
          ? const Icon(Icons.check_rounded, size: 18, color: T.brand)
          : const SizedBox(width: 18),
      child: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: selected ? T.itemFg : T.itemFgMuted,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      // ⭐ hover / selected 底色 + 內距
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (selected) return T.itemSelected;
          if (states.contains(WidgetState.hovered)) return T.itemHover;
          return Colors.transparent;
        }),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}