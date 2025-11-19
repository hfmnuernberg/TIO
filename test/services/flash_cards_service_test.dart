import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/impl/flash_cards_impl.dart';

void main() {
  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  group('FlashCardsImpl', () {
    test('resets seen flash cards when all cards have been seen', () {
      final library = ProjectLibrary.withDefaults();
      final flashCards = FlashCardsImpl();
      final allCards = flashCards.load();

      final seenIds = <String>{};

      for (var i = 0; i < allCards.length; i++) {
        final card = flashCards.regenerateNext(library);
        seenIds.add(card.id);
      }

      expect(library.seenFlashCards.length, allCards.length);
      expect(seenIds.length, allCards.length);

      final cardAfterReset = flashCards.regenerateNext(library);

      expect(library.seenFlashCards.length, 1);
      expect(library.seenFlashCards.first.id, cardAfterReset.id);
    });
  });
}
