import 'dart:math' as math;

import 'package:authentication/widgets/custom_app_bar.dart';
import 'package:authentication/widgets/glass_quality.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Shared page chrome. Scrolling content stays opaque beneath floating controls.
class AppScaffold extends HookWidget {
  const AppScaffold({
    required this.appBar,
    required this.body,
    this.largeTitle = false,
    super.key,
  });

  final CustomAppBar appBar;
  final Widget body;
  final bool largeTitle;

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(GlassLargeTitleController.new);
    useEffect(() => controller.dispose, [controller]);
    final colors = Theme.of(context).colorScheme;
    return _PageScope(
      title: appBar.title,
      controller: largeTitle ? controller : null,
      child: Scaffold(
        backgroundColor: colors.surface,
        resizeToAvoidBottomInset: false,
        body: CupertinoTheme(
          data: CupertinoThemeData(
            brightness: colors.brightness,
            primaryColor: colors.primary,
            scaffoldBackgroundColor: colors.surface,
          ),
          child: GlassTheme(
            data: GlassThemeData.simple(quality: appGlassQuality),
            child: GlassScaffold(
              statusBarStyle: GlassStatusBarStyle.auto,
              backgroundColor: colors.surface,
              extendBody: largeTitle,
              edgeFade: largeTitle,
              appBar: appBar.buildBar(
                context,
                titleController: largeTitle ? controller : null,
              ),
              body: Material(
                type: MaterialType.transparency,
                child: SafeArea(top: false, child: body),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageScope extends InheritedWidget {
  const _PageScope({
    required this.title,
    required this.controller,
    required super.child,
  });

  final String title;
  final GlassLargeTitleController? controller;

  @override
  bool updateShouldNotify(_PageScope oldWidget) =>
      title != oldWidget.title || controller != oldWidget.controller;
}

/// One scroll owner for the large title and page content, with readable width.
class AppPageScrollView extends StatelessWidget {
  const AppPageScrollView({
    required this.slivers,
    this.maxWidth = 760,
    super.key,
  });

  final List<Widget> slivers;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final page = context.dependOnInheritedWidgetOfExactType<_PageScope>()!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final inset = math.max(16.0, (constraints.maxWidth - maxWidth) / 2);
        return CustomScrollView(
          controller: page.controller?.scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            if (page.controller != null)
              GlassLargeTitle(
                text: page.title,
                controller: page.controller!,
                color: Theme.of(context).colorScheme.onSurface,
                padding: EdgeInsets.fromLTRB(
                  inset + 8,
                  MediaQuery.paddingOf(context).top + 64,
                  inset + 8,
                  20,
                ),
              ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(inset, 0, inset, 32),
              sliver: SliverMainAxisGroup(slivers: slivers),
            ),
          ],
        );
      },
    );
  }
}

class AppPageList extends StatelessWidget {
  const AppPageList({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      AppPageScrollView(slivers: [SliverList.list(children: children)]);
}
