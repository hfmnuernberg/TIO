import 'package:tiomusic/l10n/app_localization.dart';
import 'package:tiomusic/models/sound_font.dart';

extension SoundFontExtension on SoundFont {
  String getLabel(AppLocalizations l10n) => switch (this) {
    SoundFont.piano1 => l10n.pianoInstrumentGrandPiano1,
    SoundFont.piano2 => l10n.pianoInstrumentGrandPiano2,
    SoundFont.electricPiano1 => l10n.pianoInstrumentElectricPiano1,
    SoundFont.electricPiano2 => l10n.pianoInstrumentElectricPiano2,
    SoundFont.pipeOrgan => l10n.pianoInstrumentPipeOrgan,
    SoundFont.harpsicord => l10n.pianoInstrumentHarpsichord,
  };
}
