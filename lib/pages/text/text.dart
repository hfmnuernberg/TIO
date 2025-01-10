import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/pages/parent_tool/parent_tool.dart';
import 'package:tiomusic/models/blocks/text_block.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';

class TextTool extends StatefulWidget {
  final bool isQuickTool;

  const TextTool({super.key, required this.isQuickTool});

  @override
  State<TextTool> createState() => _TextToolState();
}

class _TextToolState extends State<TextTool> {
  late TextBlock _textBlock;

  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _textBlock = Provider.of<ProjectBlock>(context, listen: false) as TextBlock;
    _textBlock.timeLastModified = getCurrentDateTime();

    // only allow portrait mode for this tool
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _textController.text = _textBlock.content;

    // Start listening to changes. These functions are called for evey little change in the text field
    _textController.addListener(_setTextOfTextBlock);
    _textController.addListener(_saveText);
  }

  @override
  void dispose() {
    _textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ParentTool(
      barTitle: _textBlock.title,
      isQuickTool: widget.isQuickTool,
      project: widget.isQuickTool
          ? null
          : Provider.of<Project>(context, listen: false),
      toolBlock: _textBlock,
      centerModule: SizedBox(
        height: MediaQuery.of(context).size.height -
            ParentToolParams.appBarHeight * 3,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(TIOMusicParams.edgeInset),
          child: Scrollbar(
            controller: _scrollController,
            trackVisibility: true,
            thumbVisibility: true,
            child: TextField(
              scrollController: _scrollController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: ColorTheme.surface,
                border: InputBorder.none,
              ),
              controller: _textController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: null,
              expands: true,
              style: const TextStyle(color: ColorTheme.primary),
            ),
          ),
        ),
      ),
      settingTiles: const [],
    );
  }

  void _setTextOfTextBlock() {
    _textBlock.content = _textController.text;
  }

  void _saveText() {
    FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
  }
}
