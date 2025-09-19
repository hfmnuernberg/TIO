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
    as _tiomusic_widgetbook_widgets_input_number_input_and_slider_int;
import 'package:tiomusic_widgetbook/widgets/piano/keyboard.dart'
    as _tiomusic_widgetbook_widgets_piano_keyboard;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'widgets',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'input',
        children: [
          _widgetbook.WidgetbookLeafComponent(
            name: 'NumberInputAndSliderInt',
            useCase: _widgetbook.WidgetbookUseCase(
              name: 'NumberInputAndSliderInt',
              builder:
                  _tiomusic_widgetbook_widgets_input_number_input_and_slider_int
                      .numberInputAndSliderInt,
            ),
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'piano',
        children: [
          _widgetbook.WidgetbookLeafComponent(
            name: 'Keyboard',
            useCase: _widgetbook.WidgetbookUseCase(
              name: 'Keyboard',
              builder: _tiomusic_widgetbook_widgets_piano_keyboard.keyboard,
            ),
          ),
        ],
      ),
    ],
  ),
];
