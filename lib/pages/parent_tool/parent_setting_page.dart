import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';
import 'package:tiomusic/widgets/dismiss_keyboard.dart';

class ParentSettingPage extends StatefulWidget {
  final String title;
  final Widget? numberInput;
  final Widget? customWidget;
  final Widget? infoWidget;
  final bool displayResetAtTop;
  final bool mustBeScrollable;

  final Function() confirm;
  final Function() reset;
  final Function()? cancel;

  const ParentSettingPage({
    super.key,
    required this.title,
    this.numberInput,
    required this.confirm,
    required this.reset,
    this.displayResetAtTop = false,
    this.cancel,
    this.customWidget,
    this.infoWidget,
    this.mustBeScrollable = false,
  });

  @override
  State<ParentSettingPage> createState() => _ParentSettingPageState();
}

class _ParentSettingPageState extends State<ParentSettingPage> {
  @override
  Widget build(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return DismissKeyboard(
      child: PopScope(
        canPop: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Center(child: Text(widget.title)),
            backgroundColor: ColorTheme.surfaceBright,
            foregroundColor: ColorTheme.primary,
            automaticallyImplyLeading: false,
          ),
          backgroundColor: ColorTheme.primary92,
          body: SafeArea(
            child: (widget.mustBeScrollable && isPortrait)
                ? LayoutBuilder(
                    builder: (context, viewportConstraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
                          child: _buildPortrait(),
                        ),
                      );
                    },
                  )
                : (isPortrait ? _buildPortrait() : _buildLandscape()),
          ),
          bottomSheet: _bottomSheet(),
        ),
      ),
    );
  }

  Widget _buildPortrait() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.displayResetAtTop) ...[
          const SizedBox(height: 20),
          TIOTextButton(text: context.l10n.commonReset, onTap: widget.reset),
          const SizedBox(height: 20),
        ],
        widget.numberInput ?? const SizedBox(),
        widget.customWidget ?? const SizedBox(),
        if (!widget.displayResetAtTop) ...[
          const SizedBox(height: 20),
          TIOTextButton(text: context.l10n.commonReset, onTap: widget.reset),
        ],
        const SizedBox(height: 160),
      ],
    );
  }

  Widget _buildLandscape() {
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    final double rightGutter = isPhone ? (TIOMusicParams.sizeBigButtons * 2 + TIOMusicParams.edgeInset * 5) : 0;
    return Padding(
      padding: EdgeInsets.all(TIOMusicParams.edgeInset),
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, viewportConstraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.only(right: rightGutter),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.displayResetAtTop) ...[
                              const SizedBox(height: 8),
                              TIOTextButton(text: context.l10n.commonReset, onTap: widget.reset),
                              const SizedBox(height: 20),
                            ],
                            widget.numberInput ?? const SizedBox(),
                            if (widget.customWidget != null) ...[const SizedBox(height: 12), widget.customWidget!],
                            if (!widget.displayResetAtTop) ...[
                              const SizedBox(height: 20),
                              TIOTextButton(text: context.l10n.commonReset, onTap: widget.reset),
                            ],
                            SizedBox(height: TIOMusicParams.sizeBigButtons * 2 + TIOMusicParams.edgeInset),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CancelButton(onTap: widget.cancel ?? () => Navigator.pop(context)),
                ConfirmButton(onTap: widget.confirm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _bottomSheet() {
    return MediaQuery.of(context).orientation == Orientation.landscape
        ? null
        : ColoredBox(
            color: ColorTheme.primary80,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ColoredBox(color: ColorTheme.secondary, child: widget.infoWidget ?? const SizedBox()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CancelButton(onTap: widget.cancel ?? () => Navigator.pop(context)),
                      ConfirmButton(onTap: widget.confirm),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}
