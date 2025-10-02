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
            child: widget.mustBeScrollable
                ? LayoutBuilder(
                    builder: (context, viewportConstraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
                          child: isPortrait ? _buildPortrait() : _buildLandscape(),
                        ),
                      );
                    },
                  )
                : isPortrait
                ? _buildPortrait()
                : _buildLandscape(),
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
    var padding = 4.0;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(left: padding * 12, top: padding, child: widget.numberInput ?? const SizedBox()),
          Positioned(left: padding * 12, top: padding * 12, child: widget.customWidget ?? const SizedBox()),
          Positioned(
            right: padding,
            bottom: padding,
            child: ConfirmButton(onTap: widget.confirm),
          ),
          Positioned(
            right: padding + TIOMusicParams.sizeBigButtons * 2.5,
            bottom: padding + TIOMusicParams.sizeBigButtons / 2.5,
            child: CancelButton(onTap: widget.cancel ?? () => Navigator.pop(context)),
          ),
          Positioned(
            right: padding + TIOMusicParams.sizeBigButtons * 4.7,
            bottom: padding + TIOMusicParams.sizeBigButtons / 1.5,
            child: TIOTextButton(text: context.l10n.commonReset, onTap: widget.reset),
          ),
        ],
      ),
    );
  }

  Widget? _bottomSheet() {
    return MediaQuery.of(context).orientation == Orientation.landscape
        ? null
        : SafeArea(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColoredBox(color: ColorTheme.secondary, child: widget.infoWidget ?? const SizedBox()),
                ColoredBox(
                  color: ColorTheme.primary80,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
}
