import 'package:tiomusic/l10n/app_localization.dart';
import 'package:tiomusic/models/metronome_sound.dart';

extension MetronomeSoundExtension on MetronomeSound {
  String getLabel(AppLocalizations l10n) => switch (this) {
    MetronomeSound.soundBop => l10n.metronomeSoundTypeBop,
    MetronomeSound.soundClick => l10n.metronomeSoundTypeClick,
    MetronomeSound.soundClock => l10n.metronomeSoundTypeClock,
    MetronomeSound.soundHeart => l10n.metronomeSoundTypeHeart,
    MetronomeSound.soundPing => l10n.metronomeSoundTypePing,
    MetronomeSound.soundTick => l10n.metronomeSoundTypeTick,
    MetronomeSound.soundWood => l10n.metronomeSoundTypeWood,
    MetronomeSound.soundCowbell => l10n.metronomeSoundTypeCowbell,
    MetronomeSound.soundClap => l10n.metronomeSoundTypeClap,
    MetronomeSound.soundRim => l10n.metronomeSoundTypeRim,
    MetronomeSound.soundBlup => l10n.metronomeSoundTypeBlup,
    MetronomeSound.soundDigiClick => l10n.metronomeSoundTypeDigiClick,
    MetronomeSound.soundKick => l10n.metronomeSoundTypeKick,
    MetronomeSound.soundNoise => l10n.metronomeSoundTypeNoise,
    MetronomeSound.soundPling => l10n.metronomeSoundTypePling,
  };
}
