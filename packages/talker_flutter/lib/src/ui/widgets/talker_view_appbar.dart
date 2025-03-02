import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:talker_flutter/src/controller/controller.dart';
import 'package:talker_flutter/talker_flutter.dart';

class TalkerViewAppBar extends StatefulWidget {
  const TalkerViewAppBar({
    Key? key,
    required this.title,
    required this.leading,
    required this.talker,
    required this.talkerTheme,
    required this.titlesController,
    required this.controller,
    required this.titles,
    required this.uniqTitles,
    required this.onMonitorTap,
    required this.onSettingsTap,
    required this.onActionsTap,
    required this.onToggleTitle,
  }) : super(key: key);

  final String? title;
  final Widget? leading;

  final Talker talker;
  final TalkerScreenTheme talkerTheme;
  final GroupButtonController titlesController;
  final TalkerViewController controller;

  final List<String?> titles;
  final List<String?> uniqTitles;

  final VoidCallback onMonitorTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onActionsTap;

  final Function(String title, bool selected) onToggleTitle;

  @override
  State<TalkerViewAppBar> createState() => _TalkerViewAppBarState();
}

class _TalkerViewAppBarState extends State<TalkerViewAppBar>
    with WidgetsBindingObserver {
  final GlobalKey _groupButtonKey = GlobalKey();

  final GlobalKey _searchTextFieldKey = GlobalKey();

  double? _spaceBarHeight;

  final double _defaultSpaceBarHeight = 50;

  final double _defaultToolbarHeight = 60;

  static const double _padding = 8;

  @override
  void initState() {
    WidgetsBinding.instance
      ..addObserver(this)
      ..addPostFrameCallback(_addPostFrameCallback);
    super.initState();
  }

  @override
  void didChangeMetrics() {
    _calculateHeight();
    super.didChangeMetrics();
  }

  void _addPostFrameCallback(Duration timestamp) => _calculateHeight();

  void _calculateHeight() {
    final groupBtnRenderBox =
        _groupButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (groupBtnRenderBox == null) return;

    final searchFieldRenderBox =
        _searchTextFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (searchFieldRenderBox == null) return;

    setState(() {
      _spaceBarHeight = searchFieldRenderBox.size.height +
          groupBtnRenderBox.size.height +
          _defaultToolbarHeight +
          _padding;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      backgroundColor: widget.talkerTheme.backgroundColor,
      elevation: 0,
      pinned: true,
      floating: true,
      expandedHeight: _spaceBarHeight ?? _defaultSpaceBarHeight,
      collapsedHeight: _defaultToolbarHeight,
      toolbarHeight: _defaultToolbarHeight,
      leading: widget.leading,
      iconTheme: IconThemeData(color: widget.talkerTheme.textColor),
      actions: [
        UnconstrainedBox(
          child: _MonitorButton(
            talker: widget.talker,
            onPressed: widget.onMonitorTap,
            talkerTheme: widget.talkerTheme,
          ),
        ),
        UnconstrainedBox(
          child: IconButton(
            onPressed: widget.onSettingsTap,
            icon: Icon(
              Icons.settings_rounded,
              color: widget.talkerTheme.textColor,
            ),
          ),
        ),
        UnconstrainedBox(
          child: IconButton(
            onPressed: widget.onActionsTap,
            icon: Icon(
              Icons.menu_rounded,
              color: widget.talkerTheme.textColor,
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
      title: widget.title != null
          ? Text(
              widget.title!,
              style: TextStyle(
                color: widget.talkerTheme.textColor,
              ),
            )
          : null,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GroupButton(
                    key: _groupButtonKey,
                    controller: widget.titlesController,
                    isRadio: false,
                    buttonBuilder: (selected, value, context) {
                      final count =
                          widget.titles.where((e) => e == value).length;
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: widget.talkerTheme.textColor),
                          borderRadius: BorderRadius.circular(10),
                          color: selected
                              ? theme.colorScheme.primaryContainer
                              : widget.talkerTheme.cardColor,
                        ),
                        child: Row(
                          children: [
                            Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.talkerTheme.textColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$value',
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.talkerTheme.textColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    onSelected: (_, i, selected) =>
                        _onToggle(widget.uniqTitles[i], selected),
                    buttons: widget.uniqTitles,
                  ),
                ),
                const SizedBox(height: _padding),
                _SearchTextField(
                  key: _searchTextFieldKey,
                  controller: widget.controller,
                  talkerTheme: widget.talkerTheme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onToggle(String? title, bool selected) {
    if (title == null) return;
    widget.onToggleTitle(title, selected);
  }
}

class _SearchTextField extends StatelessWidget {
  const _SearchTextField({
    super.key,
    required this.talkerTheme,
    required this.controller,
  });

  final TalkerScreenTheme talkerTheme;
  final TalkerViewController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        style: theme.textTheme.bodyLarge!.copyWith(
          color: talkerTheme.textColor,
          fontSize: 14,
        ),
        onChanged: controller.updateFilterSearchQuery,
        decoration: InputDecoration(
          fillColor: talkerTheme.backgroundColor,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: talkerTheme.textColor),
            borderRadius: BorderRadius.circular(10),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: talkerTheme.textColor),
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          prefixIcon: Icon(
            Icons.search,
            color: talkerTheme.textColor,
            size: 20,
          ),
          hintText: 'Search...',
          hintStyle: theme.textTheme.bodyLarge!.copyWith(
            color: talkerTheme.textColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _MonitorButton extends StatelessWidget {
  const _MonitorButton({
    Key? key,
    required this.talker,
    required this.onPressed,
    required this.talkerTheme,
  }) : super(key: key);

  final Talker talker;
  final TalkerScreenTheme talkerTheme;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TalkerBuilder(
      talker: talker,
      builder: (context, data) {
        final haveErrors = data
            .where((e) => e is TalkerError || e is TalkerException)
            .isNotEmpty;
        return Stack(
          children: [
            Center(
              child: IconButton(
                onPressed: onPressed,
                icon: Icon(
                  Icons.monitor_heart_outlined,
                  color: talkerTheme.textColor,
                ),
              ),
            ),
            if (haveErrors)
              Positioned(
                right: 6,
                top: 8,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  height: 7,
                  width: 7,
                ),
              ),
          ],
        );
      },
    );
  }
}
