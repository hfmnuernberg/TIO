import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/domain/flash_cards/category.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/app_orientation.dart';
import 'package:tiomusic/util/tutorial/tutorial_util.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/flash_cards/category_filter_button.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/flash_cards/flash_cards_list.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class FlashCardsPage extends StatefulWidget {
  const FlashCardsPage({super.key});

  @override
  State<FlashCardsPage> createState() => _FlashCardsPageState();
}

class _FlashCardsPageState extends State<FlashCardsPage> {
  FlashCardCategory? selectedCategory;
  bool bookmarkFilterActive = false;

  late ProjectRepository projectRepo;

  final Tutorial tutorial = Tutorial();
  final GlobalKey keyFilter = GlobalKey();
  final GlobalKey keyBookmark = GlobalKey();

  @override
  void initState() {
    super.initState();

    projectRepo = context.read<ProjectRepository>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      AppOrientation.set(context, policy: OrientationPolicy.phonePortrait);

      if (context.read<ProjectLibrary>().showFlashCardsPageTutorial) {
        createTutorial();
        tutorial.show(context);
      }
    });
  }

  void createTutorial() {
    final targets = <CustomTargetFocus>[
      CustomTargetFocus(
        keyFilter,
        context.l10n.flashCardsPageTutorialFilter,
        alignText: ContentAlign.bottom,
        pointingDirection: PointingDirection.up,
        shape: ShapeLightFocus.RRect,
      ),
      CustomTargetFocus(
        keyBookmark,
        context.l10n.flashCardsPageTutorialBookmark,
        alignText: ContentAlign.bottom,
        pointingDirection: PointingDirection.up,
        shape: ShapeLightFocus.RRect,
      ),
    ];

    targets.first.hideBack = true;
    tutorial.create(targets.map((e) => e.targetFocus).toList(), () async {
      context.read<ProjectLibrary>().showFlashCardsPageTutorial = false;
      await projectRepo.saveLibrary(context.read<ProjectLibrary>());
    }, context);
  }

  void toggleBookmarkFilter() {
    setState(() => bookmarkFilterActive = !bookmarkFilterActive);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      appBar: AppBar(
        title: Text(context.l10n.flashCardsPageTitle),
        backgroundColor: ColorTheme.surfaceBright,
        foregroundColor: ColorTheme.primary,
      ),
      backgroundColor: ColorTheme.primary92,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Row(
                  key: keyFilter,
                  children: [
                    CategoryFilterButton(
                      category: selectedCategory,
                      onSelected: (category) => setState(() => selectedCategory = category),
                    ),
                    SizedBox(width: 16),
                    Semantics(
                      label: bookmarkFilterActive
                          ? context.l10n.filterBookmarkDisable
                          : context.l10n.filterBookmarkEnable,
                      button: true,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: ColorTheme.onPrimary, borderRadius: BorderRadius.circular(8)),
                        child: InkWell(
                          onTap: toggleBookmarkFilter,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Icon(
                              bookmarkFilterActive ? Icons.bookmark : Icons.bookmark_border,
                              color: ColorTheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: FlashCardsList(
                  categoryFilter: selectedCategory,
                  bookmarkFilterActive: bookmarkFilterActive,
                  tutorialBookmarkKey: keyBookmark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
