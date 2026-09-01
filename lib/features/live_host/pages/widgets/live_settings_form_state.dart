part of '../live_host_page.dart';

class _LiveSettingsFormState extends State<_LiveSettingsForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _capacityController;
  late final TextEditingController _notyetOwnedPriceController;
  late final TextEditingController _alreadyOwnedPriceController;
  final _titleFocusNode = FocusNode();
  final _capacityFocusNode = FocusNode();
  final _notyetOwnedPriceFocusNode = FocusNode();
  final _alreadyOwnedPriceFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.state.roomTitle);
    _capacityController = TextEditingController(
      text: widget.state.capacity == 0 ? '' : widget.state.capacity.toString(),
    );
    _notyetOwnedPriceController = TextEditingController(
      text: widget.state.notyetOwnedStoryPrice.toString(),
    );
    _alreadyOwnedPriceController = TextEditingController(
      text: widget.state.alreadyOwnedStoryPrice.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant _LiveSettingsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllerText(
      controller: _titleController,
      focusNode: _titleFocusNode,
      value: widget.state.roomTitle,
    );
    _syncControllerText(
      controller: _capacityController,
      focusNode: _capacityFocusNode,
      value: widget.state.capacity == 0 ? '' : widget.state.capacity.toString(),
    );
    _syncControllerText(
      controller: _notyetOwnedPriceController,
      focusNode: _notyetOwnedPriceFocusNode,
      value: widget.state.notyetOwnedStoryPrice.toString(),
    );
    _syncControllerText(
      controller: _alreadyOwnedPriceController,
      focusNode: _alreadyOwnedPriceFocusNode,
      value: widget.state.alreadyOwnedStoryPrice.toString(),
    );
  }

  void _syncControllerText({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String value,
  }) {
    if (focusNode.hasFocus || controller.text == value) return;
    controller.text = value;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _capacityController.dispose();
    _notyetOwnedPriceController.dispose();
    _alreadyOwnedPriceController.dispose();
    _titleFocusNode.dispose();
    _capacityFocusNode.dispose();
    _notyetOwnedPriceFocusNode.dispose();
    _alreadyOwnedPriceFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final numberFormatters = [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(6),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              key: ValueKey('room-title-${state.selectedStory?.storyId ?? ''}'),
              controller: _titleController,
              focusNode: _titleFocusNode,
              onChanged: widget.onTitleChanged,
              decoration: InputDecoration(
                labelText: '房間標題',
                hintText: state.selectedStory?.storyName ?? '輸入直播房間標題',
                prefixIcon: const Icon(Icons.title_rounded),
                errorText: state.roomTitle.trim().isEmpty ? '請輸入房間標題' : null,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              '直播模式',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SegmentedButton<LiveHostRoomType>(
              segments: const [
                ButtonSegment(
                  value: LiveHostRoomType.listenOnly,
                  icon: Icon(Icons.headphones_rounded),
                  label: Text('陪聽直播'),
                ),
                ButtonSegment(
                  value: LiveHostRoomType.interactive,
                  icon: Icon(Icons.record_voice_over_rounded),
                  label: Text('互動直播'),
                ),
              ],
              selected: {state.roomType},
              onSelectionChanged: (values) =>
                  widget.onRoomTypeChanged(values.first),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _capacityController,
              focusNode: _capacityFocusNode,
              enabled: state.roomType == LiveHostRoomType.interactive,
              onChanged: widget.onCapacityChanged,
              keyboardType: TextInputType.number,
              inputFormatters: numberFormatters,
              decoration: InputDecoration(
                labelText: '人數上限',
                prefixIcon: const Icon(Icons.groups_rounded),
                helperText: state.roomType == LiveHostRoomType.listenOnly
                    ? '陪聽直播固定 100 人'
                    : '互動直播最多 $liveHostInteractiveCapacityLimit 人',
                errorText: _capacityErrorText(state),
              ),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: state.notifyFans,
              onChanged: widget.onNotifyFansChanged,
              title: const Text('通知粉絲'),
              subtitle: const Text('開播時通知追蹤者'),
              secondary: const Icon(Icons.notifications_active_rounded),
            ),
            const Divider(height: 30),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _notyetOwnedPriceController,
                    focusNode: _notyetOwnedPriceFocusNode,
                    onChanged: widget.onNotyetOwnedPriceChanged,
                    keyboardType: TextInputType.number,
                    inputFormatters: numberFormatters,
                    decoration: InputDecoration(
                      labelText: '未購買價格',
                      prefixIcon: const Icon(Icons.lock_rounded),
                      suffixText: 'PodCoin',
                      errorText: state.notyetOwnedStoryPrice < 0
                          ? '價格不可小於 0'
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextFormField(
                    controller: _alreadyOwnedPriceController,
                    focusNode: _alreadyOwnedPriceFocusNode,
                    onChanged: widget.onAlreadyOwnedPriceChanged,
                    keyboardType: TextInputType.number,
                    inputFormatters: numberFormatters,
                    decoration: InputDecoration(
                      labelText: '已購買價格',
                      prefixIcon: const Icon(Icons.verified_rounded),
                      suffixText: 'PodCoin',
                      errorText: state.alreadyOwnedStoryPrice < 0
                          ? '價格不可小於 0'
                          : null,
                    ),
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
