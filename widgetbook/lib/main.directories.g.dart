// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:tiomusic_widgetbook/widgets/input/number_input_and_slider_int.dart'
    as _i2;
import 'package:tiomusic_widgetbook/widgets/media_player/waveform.dart' as _i3;
import 'package:tiomusic_widgetbook/widgets/piano/keyboard.dart' as _i4;
import 'package:widgetbook/widgetbook.dart' as _i1;

final directories = <_i1.WidgetbookNode>[
  _i1.WidgetbookFolder(
    name: 'widgets',
    children: [
      _i1.WidgetbookFolder(
        name: 'input',
        children: [
          _i1.WidgetbookLeafComponent(
            name: 'NumberInputAndSliderInt',
            useCase: _i1.WidgetbookUseCase(
              name: 'NumberInputAndSliderInt',
              builder: _i2.numberInputAndSliderInt,
            ),
          ),
        ],
      ),
      _i1.WidgetbookFolder(
        name: 'media_player',
        children: [
          _i1.WidgetbookLeafComponent(
            name: 'Waveform',
            useCase: _i1.WidgetbookUseCase(
              name: 'Waveform',
              builder: _i3.waveform,
            ),
          ),
        ],
      ),
      _i1.WidgetbookFolder(
        name: 'piano',
        children: [
          _i1.WidgetbookLeafComponent(
            name: 'Keyboard',
            useCase: _i1.WidgetbookUseCase(
              name: 'Keyboard',
              builder: _i4.keyboard,
            ),
          ),
        ],
      ),
    ],
  ),
];
