import 'package:actpod_studio/api/response/user_response/withdraws.dart';
import 'package:actpod_studio/app/app_scaffold.dart';
import 'package:actpod_studio/features/create_story/controllers/user_controller.dart';
import 'package:actpod_studio/features/statistic/widgets/stat_metric_card.dart';
import 'package:actpod_studio/features/withdraw/controllers/withdraw_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WithdrawPage extends ConsumerStatefulWidget {
  const WithdrawPage({super.key});

  @override
  ConsumerState<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends ConsumerState<WithdrawPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _podCashController = TextEditingController();
  String? _loadedUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadForCurrentUser();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _podCashController.dispose();
    super.dispose();
  }

  void _loadForCurrentUser() {
    final userId = ref.read(userControllerProvider)?.userId ?? '';
    if (userId.isEmpty || userId == _loadedUserId) return;
    _loadedUserId = userId;
    Future.microtask(
      () => ref.read(withdrawControllerProvider.notifier).load(),
    );
  }

  Future<void> _submit(WithdrawState state) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final podcash = int.tryParse(_podCashController.text.trim()) ?? 0;
    final success = await ref
        .read(withdrawControllerProvider.notifier)
        .createWithdraw(
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          podcash: podcash,
        );
    if (!mounted) return;

    if (success) {
      _formKey.currentState?.reset();
      _emailController.clear();
      _phoneController.clear();
      _podCashController.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('提領申請已送出')));
    } else {
      _showError(state.error ?? '提領申請失敗');
    }
  }

  Future<void> _editWithdraw(Withdraw withdraw) async {
    final result = await showDialog<_WithdrawContactInput>(
      context: context,
      builder: (context) => _EditWithdrawDialog(withdraw: withdraw),
    );
    if (result == null) return;

    final success = await ref
        .read(withdrawControllerProvider.notifier)
        .updateWithdrawEmailPhone(
          withdrawId: withdraw.withdrawId,
          email: result.email,
          phone: result.phone,
        );
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('提領聯絡資料已更新')));
    } else {
      final error = ref.read(withdrawControllerProvider).error;
      _showError(error ?? '更新提領資料失敗');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE11D48),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(withdrawControllerProvider);
    final userId = ref.watch(userControllerProvider)?.userId ?? '';
    if (userId.isNotEmpty && userId != _loadedUserId) {
      _loadedUserId = userId;
      Future.microtask(
        () => ref.read(withdrawControllerProvider.notifier).load(),
      );
    }

    return AppScaffold(
      title: 'ActPod 後台',
      child: RefreshIndicator(
        onRefresh: () => ref.read(withdrawControllerProvider.notifier).load(),
        child: ListView(
          padding: _responsivePadding(context),
          children: [
            _Header(
              loading: state.loading,
              onRefresh: () =>
                  ref.read(withdrawControllerProvider.notifier).load(),
            ),
            const SizedBox(height: 18),
            if (state.error != null) ...[
              _ErrorBanner(message: state.error!),
              const SizedBox(height: 18),
            ],
            _SummaryGrid(state: state),
            const SizedBox(height: 18),
            _WithdrawForm(
              formKey: _formKey,
              emailController: _emailController,
              phoneController: _phoneController,
              podCashController: _podCashController,
              availablePodCash: state.availablePodCash,
              submitting: state.submitting,
              onSubmit: () => _submit(state),
            ),
            const SizedBox(height: 18),
            if (state.loading && state.withdraws.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              WithdrawTable(
                withdraws: state.withdraws,
                updatingWithdrawId: state.updatingWithdrawId,
                onEdit: _editWithdraw,
              ),
          ],
        ),
      ),
    );
  }

  EdgeInsets _responsivePadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1750) {
      return const EdgeInsets.symmetric(horizontal: 120, vertical: 16);
    }
    if (w >= 1200) {
      return const EdgeInsets.symmetric(horizontal: 52, vertical: 16);
    }
    if (w >= 720) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    }
    return const EdgeInsets.symmetric(horizontal: 8, vertical: 12);
  }
}

class _Header extends StatelessWidget {
  final bool loading;
  final VoidCallback onRefresh;

  const _Header({required this.loading, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '提領',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 4),
            Text('查看提領紀錄與提交新的提領申請', style: TextStyle(color: Color(0xFF6B7280))),
          ],
        ),
        IconButton.outlined(
          tooltip: '重新整理',
          onPressed: loading ? null : onRefresh,
          icon: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final WithdrawState state;

  const _SummaryGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1180
            ? 3
            : constraints.maxWidth >= 760
            ? 2
            : 1;
        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: columns == 1 ? 3.4 : 2.5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            StatMetricCard(
              icon: Icons.account_balance_wallet_rounded,
              label: '可提領 PodCash',
              value: _formatNumber(state.availablePodCash),
              caption: _formatDateTime(state.cashPurse?.updateTime),
              color: const Color(0xFFFFBC1F),
            ),
            StatMetricCard(
              icon: Icons.receipt_long_rounded,
              label: '提領紀錄',
              value: _formatNumber(state.withdraws.length),
              caption: '${state.pendingCount} 筆待處理',
              color: const Color(0xFF2563EB),
            ),
            StatMetricCard(
              icon: Icons.payments_rounded,
              label: '累計申請 PodCash',
              value: _formatNumber(state.requestedPodCash),
              caption: '所有提領紀錄',
              color: const Color(0xFF22C55E),
            ),
          ],
        );
      },
    );
  }
}

class _WithdrawForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController podCashController;
  final int availablePodCash;
  final bool submitting;
  final VoidCallback onSubmit;

  const _WithdrawForm({
    required this.formKey,
    required this.emailController,
    required this.phoneController,
    required this.podCashController,
    required this.availablePodCash,
    required this.submitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Form(
        key: formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 860;
            final fields = [
              _FieldSlot(
                child: TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateEmail,
                ),
              ),
              _FieldSlot(
                child: TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateRequired,
                ),
              ),
              _FieldSlot(
                child: TextFormField(
                  controller: podCashController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'PodCash',
                    helperText: '可提領 ${_formatNumber(availablePodCash)}',
                    prefixIcon: const Icon(Icons.payments_outlined),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      _validatePodCash(value, availablePodCash),
                ),
              ),
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: submitting ? null : onSubmit,
                  icon: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: const Text('提交提領'),
                ),
              ),
            ];

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final field in fields) ...[
                    field,
                    if (field != fields.last) const SizedBox(height: 12),
                  ],
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: fields[0]),
                const SizedBox(width: 12),
                Expanded(child: fields[1]),
                const SizedBox(width: 12),
                Expanded(child: fields[2]),
                const SizedBox(width: 12),
                SizedBox(width: 140, child: fields[3]),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FieldSlot extends StatelessWidget {
  final Widget child;

  const _FieldSlot({required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class WithdrawTable extends StatelessWidget {
  final List<Withdraw> withdraws;
  final String? updatingWithdrawId;
  final ValueChanged<Withdraw> onEdit;

  const WithdrawTable({
    super.key,
    required this.withdraws,
    required this.updatingWithdrawId,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (withdraws.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 42),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('尚無提領紀錄', style: TextStyle(color: Color(0xFF6B7280))),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
          columns: const [
            DataColumn(label: Text('建立時間')),
            DataColumn(label: Text('狀態')),
            DataColumn(numeric: true, label: Text('PodCash')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Phone')),
            DataColumn(label: Text('轉帳時間')),
            DataColumn(label: Text('提領編號')),
            DataColumn(label: Text('操作')),
          ],
          rows: [
            for (final withdraw in withdraws)
              DataRow(
                cells: [
                  DataCell(Text(_formatDateTime(withdraw.createTime))),
                  DataCell(_StatusChip(status: withdraw.status)),
                  DataCell(
                    Text(
                      _formatNumber(withdraw.podCash),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  DataCell(_ConstrainedText(withdraw.email, width: 210)),
                  DataCell(_ConstrainedText(withdraw.phone, width: 140)),
                  DataCell(Text(_formatDateTime(withdraw.transferTime))),
                  DataCell(_ConstrainedText(withdraw.withdrawId, width: 180)),
                  DataCell(
                    IconButton.outlined(
                      tooltip: '編輯聯絡資料',
                      onPressed: updatingWithdrawId == null
                          ? () => onEdit(withdraw)
                          : null,
                      icon: updatingWithdrawId == withdraw.withdrawId
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.edit_rounded),
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

class _ConstrainedText extends StatelessWidget {
  final String text;
  final double width;

  const _ConstrainedText(this.text, {required this.width});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: Text(
        text.isEmpty ? '-' : text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.isEmpty ? '-' : status,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'done':
        return const Color(0xFF16A34A);
      case 'failed':
      case 'rejected':
        return const Color(0xFFE11D48);
      case 'pending':
      default:
        return const Color(0xFF2563EB);
    }
  }
}

class _EditWithdrawDialog extends StatefulWidget {
  final Withdraw withdraw;

  const _EditWithdrawDialog({required this.withdraw});

  @override
  State<_EditWithdrawDialog> createState() => _EditWithdrawDialogState();
}

class _EditWithdrawDialogState extends State<_EditWithdrawDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.withdraw.email);
    _phoneController = TextEditingController(text: widget.withdraw.phone);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('編輯提領聯絡資料'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                  border: OutlineInputBorder(),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: _validateRequired,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton.icon(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            Navigator.of(context).pop(
              _WithdrawContactInput(
                email: _emailController.text.trim(),
                phone: _phoneController.text.trim(),
              ),
            );
          },
          icon: const Icon(Icons.save_rounded),
          label: const Text('儲存'),
        ),
      ],
    );
  }
}

class _WithdrawContactInput {
  final String email;
  final String phone;

  const _WithdrawContactInput({required this.email, required this.phone});
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        border: Border.all(color: const Color(0xFFFDA4AF)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFE11D48)),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

String? _validateRequired(String? value) {
  if (value == null || value.trim().isEmpty) return '必填';
  return null;
}

String? _validateEmail(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return '必填';
  if (!text.contains('@') || !text.contains('.')) return 'Email 格式不正確';
  return null;
}

String? _validatePodCash(String? value, int availablePodCash) {
  final amount = int.tryParse(value?.trim() ?? '') ?? 0;
  if (amount <= 0) return '請輸入大於 0 的金額';
  if (availablePodCash > 0 && amount > availablePodCash) return '超過可提領 PodCash';
  return null;
}

String _formatNumber(int value) {
  final text = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) buffer.write(',');
    buffer.write(text[i]);
  }
  return buffer.toString();
}

String _formatDateTime(DateTime? value) {
  if (value == null) return '-';
  final local = value.toLocal();
  return '${local.year}/${_twoDigits(local.month)}/${_twoDigits(local.day)} '
      '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
