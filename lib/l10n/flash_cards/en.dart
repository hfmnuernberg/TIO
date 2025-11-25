// overriding keys do not change something; ignored because soft warning
// ignore_for_file: annotate_overrides

import 'package:tiomusic/domain/flash_cards/category.dart';
import 'package:tiomusic/l10n/flash_cards/flash_cards_localization.dart';

mixin EnglishFlashCards on Object implements FlashCardsLocalization {
  String get categoryCulture => 'Culture';
  String get categoryJournaling => 'Journaling';
  String get categoryMixUp => 'Mix-Up';
  String get categoryPracticing => 'Practicing Tactics';
  String get categoryRelaxation => 'Relaxation';
  String get categorySelfCare => 'Self-Care';
  String get categoryTeam => 'Team';
  String get categoryVision => 'Vision';

  String categoryLabel(FlashCardCategory category) {
    switch (category) {
      case FlashCardCategory.culture:
        return categoryCulture;
      case FlashCardCategory.journaling:
        return categoryJournaling;
      case FlashCardCategory.mixUp:
        return categoryMixUp;
      case FlashCardCategory.practicing:
        return categoryPracticing;
      case FlashCardCategory.relaxation:
        return categoryRelaxation;
      case FlashCardCategory.selfCare:
        return categorySelfCare;
      case FlashCardCategory.team:
        return categoryTeam;
      case FlashCardCategory.vision:
        return categoryVision;
    }
  }

  String get descriptionCulture001 => "book a ticket for a concert you're really looking forward to!";
  String get descriptionCulture002 => 'reward yourself with whatever you can think of.';
  String get descriptionCulture003 =>
      "create your own private concert by watching or listening to a great recording of a piece that's important to you. Make yourself comfortable and create a feel-good oasis.";
  String get descriptionCulture004 =>
      'make plans to meet up with friends to listen to music and afterwards tell each other about your favorite moments and what excited you.';
  String get descriptionCulture005 =>
      'discover a piece that is new to you in as many ways as possible – listen to it, move to it, read the context in which it was written or performed, draw a picture, improvise on a theme...';
  String get descriptionCulture006 =>
      'rediscover a piece you already know in as many ways as possible – listen to it, move to it, read the context in which it was written or performed, draw a picture, improvise on a theme...';
  String get descriptionCulture007 =>
      'listen to music by one of your role models and write down what you would like to learn from that person.';
  String get descriptionCulture008 => 'write a 2-minute introduction for your current piece.';
  String get descriptionCulture009 =>
      'write an introduction to your current piece for two different target groups, for example, classical concert-goers, school classes, senior citizens, football fans, etc.';
  String get descriptionCulture010 =>
      'if available, read the section on your instrument in Hector Berlioz\'s "Treatise of Instrumentation", in the revised version by Richard Strauss (1905).';
  String get descriptionCulture011 => 'read the Wikipedia article about your instrument.';
  String get descriptionJournaling001 => 'write down what you will do and learn today.';
  String get descriptionJournaling002 => 'afterwards, document what you learned today or what insights you gained.';
  String get descriptionJournaling003 =>
      'write down your obstacles, pick the most important one and practice it more intensively.';
  String get descriptionJournaling004 =>
      "write down what you're grateful for or what you're looking forward to. On the day of a performance, write down why you're excited about the performance.";
  String get descriptionJournaling005 =>
      'write down which exercise worked best and note it down (perhaps digitally) as a reminder for tomorrow.';
  String get descriptionJournaling006 =>
      'before you play, write down what you would like to be able to do better after practicing today.';
  String get descriptionJournaling007 =>
      "start a success journal: write down what you've learned and what you've accomplished today. Choose a time to do it - for example, after practicing, during practice or in the evening after dinner.";
  String get descriptionJournaling008 => 'before you practice, write down your most important goal for the day.';
  String get descriptionJournaling009 => 'have a written dialogue with yourself: what do you need to enjoy practicing?';
  String get descriptionJournaling010 =>
      "have a written dialogue with yourself: why aren't you practicing right now? Be kind and understanding to yourself and try to find a healthy solution. What do you need to enjoy practicing?";
  String get descriptionJournaling011 =>
      "write down how you're feeling right now. Keep a journal, and when you encounter resistance, ask yourself how you can resolve it at its source.";
  String get descriptionJournaling012 => 'grade your practice satisfaction and your resistance to starting practicing.';
  String get descriptionJournaling013 => 'grade the quality of your practice on a scale of 1 to 10.';
  String get descriptionJournaling014 => 'write down how satisfied you are or were with your practice.';
  String get descriptionJournaling015 =>
      'note which muscles you use for your pitch or volume changes and which you could relax.';
  String get descriptionJournaling016 =>
      'plan your practice time in advance in 25-minute intervals and write down what you want to accomplish in each 25 minutes. Take at least a 5-minute break after each session.';
  String get descriptionJournaling017 =>
      'list your tasks according to priority and practice from important to unimportant.';
  String get descriptionJournaling018 =>
      'plan 20-minute practice sessions with specific tasks/goals for each session. Are you able to finish before your alarm? If not, stop as soon as the alarm goes off and revise your practice plan if necessary.';
  String get descriptionJournaling019 => 'write down everything you have practiced.';
  String get descriptionJournaling020 =>
      'at the end, write down your goals for tomorrow. What do you want to have achieved?';
  String get descriptionMixUp001 =>
      'go for a walk in nature. What can you do outside without your instrument that will help you better understand your piece?';
  String get descriptionMixUp002 =>
      'take time for a short power nap (max. 30 minutes). Play your piece in your head as you fall asleep, and be surprised by what happens next while you sleep.';
  String get descriptionMixUp003 =>
      "consider which piece, recording or song you currently want to listen to. Listen to it three times and try to figure out what appeals to you about it. Try to express the beauty you've found through your current piece.";
  String get descriptionMixUp004 =>
      "make a list of things you'd rather do than practice. Also note what you enjoy about those activities. Incorporate them into your practice!";
  String get descriptionMixUp005 =>
      "write a not-to-do list. Write down all the things you don't want to do today and check them off in the evening if they actually haven't been done.";
  String get descriptionMixUp006 =>
      'go to a secluded place (e.g., the basement) and laugh. Lie on your side and let your stomach bounce. Think of something funny or listen to something.';
  String get descriptionMixUp007 =>
      'treat your instrument like a pet. What kind of affection would you give it? What would you call it?';
  String get descriptionMixUp008 =>
      'think about what would make you truly happy if you accomplished it today. Try to do it in 10 minutes of practicing! What do you need to do to make it happen?';
  String get descriptionMixUp009 =>
      'listen to "Neinhorn" by Marc-Uwe Kling or read it (at the library!). What would you like to say "no" to? Go for it!';
  String get descriptionMixUp010 =>
      'install an app that allows you to create a drone, and play long tones, slow scales or chords over the drone.';
  String get descriptionMixUp011 =>
      'write down all the ideas you have for practicing to make it more fun. Imagine how many ideas you would collect if you repeat this for a week!';
  String get descriptionMixUp012 =>
      'practice singing a scale in tune. Play the root on the piano and sing the scale up and down.';
  String get descriptionMixUp013 =>
      'practice singing a triad in tune. Play the root on the piano and sing the triad up and down.';
  String get descriptionMixUp014 =>
      'look up finger-coordination excercises online and learn one. After a week, test how playing feels before and after doing the excercise.';
  String get descriptionMixUp015 =>
      'play or sing your piece while standing on one leg or on a balance board. What do you perceive?';
  String get descriptionMixUp016 => 'draw appropriate emoticons for the different sections of your piece.';
  String get descriptionMixUp017 => 'plan to do your favorite sport as a reward after practicing today.';
  String get descriptionMixUp018 => 'think about what your teacher would say about the phrases you practice.';
  String get descriptionMixUp019 => 'consciously incorporate mistakes into your piece and celebrate them vigorously.';
  String get descriptionMixUp020 => 'analyze a section of your piece.';
  String get descriptionMixUp021 => 'look at the score to see what is happening beyond your part.';
  String get descriptionMixUp022 => 'conduct your piece (in front of a mirror if you like).';
  String get descriptionMixUp023 =>
      'if you sometimes get bored or your mind wanders, change the place, method or piece.';
  String get descriptionMixUp024 => 'allow yourself to throw all the rules overboard and just play freely today.';
  String get descriptionMixUp025 => 'play a phrase with your eyes closed.';
  String get descriptionMixUp026 =>
      'think about what you really want to do. Would it be possible to incorporate it into your day today?';
  String get descriptionMixUp027 => 'listen to your sound once and then listen to your body.';
  String get descriptionMixUp028 =>
      'draw yourself and your instrument in action. What do you notice about your posture, proportions, details, etc.?';
  String get descriptionMixUp029 => 'darken the room or cover your eyes before you start.';
  String get descriptionMixUp030 => 'play a phrase on tiptoes.';
  String get descriptionMixUp031 => 'pay special attention to your artistic charisma or persuasiveness.';
  String get descriptionMixUp032 => 'play consistently with the most beautiful sound possible.';
  String get descriptionMixUp033 => 'after playing a phrase, ask yourself: Could it sound even better?';
  String get descriptionMixUp034 => 'create your own practice tip and then try it out.';
  String get descriptionMixUp035 => 'find the right balance between healthy tension and relaxation while playing.';
  String get descriptionMixUp036 =>
      'imagine you are playing in front of an audience (your parents, in a concert hall, etc.).';
  String get descriptionMixUp037 => 'choose three to five notes and use them to create a song.';
  String get descriptionMixUp038 => 'play something you know just by ear.';
  String get descriptionMixUp039 => 'divide the piece into sections and color-code them.';
  String get descriptionMixUp040 => 'play a phrase once at normal tempo, once at half speed, and once at double speed.';
  String get descriptionMixUp041 => 'invent a story about your current piece. If you like, tell it to someone.';
  String get descriptionMixUp042 => 'photocopy your current piece, cut it up and put it back together.';
  String get descriptionMixUp043 => 'compose a piece using only one pitch.';
  String get descriptionMixUp044 => 'choose a picture or photo and compose music to it.';
  String get descriptionMixUp045 =>
      'take a blank sheet of music paper and write down all the notes you can play. How many are there, and how many octaves do they cover? Research the range intended for your instrument. Is it rather large or small compared to other instruments?';
  String get descriptionMixUp046 =>
      'look through the practice tips and choose one that appeals to you and that you would like to do today.';
  String get descriptionMixUp047 => 'clap the rhythm of a phrase with the metronome.';
  String get descriptionMixUp048 =>
      'listen to a recording of your piece and follow your part at the same time, or alternatively follow the score.';
  String get descriptionMixUp049 =>
      'listen to a recording of your piece and sing along, finger along silently, or play along.';
  String get descriptionMixUp050 => 'research whether there is a playalong track for your piece and if so, play along.';
  String get descriptionMixUp051 => 'allow the sound to come out of your instrument as quietly as possible.';
  String get descriptionMixUp052 => 'choose three notes and play them as quietly as possible.';
  String get descriptionMixUp053 =>
      'practice for only 5 minutes at a time (stopwatch) and then change your practice goal or method so that you learn something different each time.';
  String get descriptionMixUp054 => 'play your current piece with an imaginary instrument.';
  String get descriptionMixUp055 => 'dance to your piece.';
  String get descriptionMixUp056 => 'alternate between playing one bar and thinking or singing the next bar.';
  String get descriptionMixUp057 => 'play a piece that will help you progress musically.';
  String get descriptionMixUp058 =>
      'change your practice location: change the room, turn to face a different direction, etc.';
  String get descriptionMixUp059 => 'write down a phrase from memory on music paper and compare it with the original.';
  String get descriptionMixUp060 => 'play your piece at the tempo of your pulse.';
  String get descriptionMixUp061 => 'imagine your piece was film music. What would the scene look like?';
  String get descriptionMixUp062 => 'visualize your next concert.';
  String get descriptionMixUp063 => 'improvise on the main motif of your piece for 5 minutes.';
  String get descriptionMixUp064 =>
      'if possible, stand in front of a wall so that you can directly hear your reflected sound.';
  String get descriptionMixUp065 =>
      'find at least one suitable adjective for every section of your piece and write it in the music.';
  String get descriptionMixUp066 =>
      'find at least one suitable image for every section of your piece (sunrise, forest, sparkling mineral water, etc.). If you like, search for suitable images online.';
  String get descriptionPracticing001 =>
      'practice in a variety of ways. Write down all the practice strategies you use spontaneously and use them for other pieces as well.';
  String get descriptionPracticing002 => 'play along with a recording.';
  String get descriptionPracticing003 => 'play your part on the piano. If your instrument is the piano, sing.';
  String get descriptionPracticing004 =>
      'play your piece with flutter tongue, sing your piece while biting on a cork, or think of something similar for your instrument.';
  String get descriptionPracticing005 => 'sing a phrase.';
  String get descriptionPracticing006 => 'sing through your piece changing octaves when necessary.';
  String get descriptionPracticing007 =>
      'find the most challenging part of the piece and learn to sing it. For singers: learn to sing the accompaniment, while singing your part mentally.';
  String get descriptionPracticing008 => 'whistle your piece.';
  String get descriptionPracticing009 => 'play a passage silently or whisper the passage if you are a singer.';
  String get descriptionPracticing010 =>
      'play a passage at different tempos - sometimes very slowly, sometimes very quickly.';
  String get descriptionPracticing011 => 'transpose a passage into three other keys.';
  String get descriptionPracticing012 => 'practice a challenging section in a loop.';
  String get descriptionPracticing013 =>
      'start at a random place somewhere in the middle of your piece, phrase or passage.';
  String get descriptionPracticing014 => 'play extremely quietly or excessively loudly.';
  String get descriptionPracticing015 => 'incorporate unusual accents into your piece.';
  String get descriptionPracticing016 =>
      'play standing on one leg, squatting, or balancing on a balance board. Next level: with closed eyes.';
  String get descriptionPracticing017 => 'exaggerate the given articulation.';
  String get descriptionPracticing018 =>
      'jump into the middle of a recording of your piece and listen for just two seconds. At this point, ideally in the middle of the phrase, start playing.';
  String get descriptionPracticing019 =>
      'play the passage in a suboptimal state: not warmed-up, in a midday slump, etc. Shine on the first try!';
  String get descriptionPracticing020 => 'expand the range of a passage.';
  String get descriptionPracticing021 => 'play certain notes of a passage an octave higher or lower.';
  String get descriptionPracticing022 =>
      'record yourself for 10 seconds and listen to the recording immediately. What are you satisfied with, and what would you improve?';
  String get descriptionPracticing023 => 'which exercise would you recommend to your best friend?';
  String get descriptionPracticing024 =>
      'lean against a wall or doorframe. Play while observing your shoulders and head, which should be touching the wall. If you notice any tension, release it.';
  String get descriptionPracticing025 =>
      'play a part you struggle with in front of the mirror. What happens at the point where you stumble?';
  String get descriptionPracticing026 =>
      'play a note on your instrument with different chords on the piano and notice how it feels when it is in tune.';
  String get descriptionPracticing027 =>
      "record a passage you can't play yet and listen to it at half-speed. What do you notice?";
  String get descriptionPracticing028 =>
      'play very slowly and consciously, in-tune and relaxed. Play so slowly that you always know what you have to do and can hear and feel everything.';
  String get descriptionPracticing029 => 'finger the exercise or passage silently and consciously before playing it.';
  String get descriptionPracticing030 => 'practice using especially challenging fingerings.';
  String get descriptionPracticing031 =>
      'pay attention to intonation, sound and phrasing when practicing technical exercises.';
  String get descriptionPracticing032 =>
      'take a group of notes, and think through them mentally. Then play them very slowly and cleanly, and then at maximum speed.';
  String get descriptionPracticing033 =>
      "practice differentially. For example with the flute: finger a half-hole that's too big, too small, too crooked... Place a finger too far away, or too close. Work your way through the differences.";
  String get descriptionPracticing034 =>
      'divide your piece into character sections and note an emotion and its intensity for each one.';
  String get descriptionPracticing035 =>
      'record a short section and try to embody an emotion. Listen to the recording: what irritates you?';
  String get descriptionPracticing036 =>
      'imagine yourself in a situation that you associate with your piece. While playing, feel exactly how you would in that situation.';
  String get descriptionPracticing037 => 'exaggerate dynamic differences.';
  String get descriptionPracticing038 => 'exaggerate differences in articulation.';
  String get descriptionPracticing039 => 'exaggerate agogics.';
  String get descriptionPracticing040 => 'exaggerate tonal differences.';
  String get descriptionPracticing041 => 'move to a recording of your piece.';
  String get descriptionPracticing042 =>
      'imagine playing or singing your piece without an instrument and change your facial expressions in front of the mirror to match.';
  String get descriptionPracticing043 =>
      "record yourself on your phone or a recording device. Listen to the recording immediately, and mark the parts of the music that you didn't quite get right. Then practice those parts exactly.";
  String get descriptionPracticing044 =>
      "video-record yourself on your phone or a recording device. Watch the recording immediately and note which parts you find convincing and which you don't. Then practice exactly those parts.";
  String get descriptionPracticing045 => "go through your piece mentally. Which parts aren't so clear yet?";
  String get descriptionPracticing046 =>
      "sing your piece by heart, using the note names. Which parts aren't flowing so smoothly yet?";
  String get descriptionPracticing047 => 'always take a break when things are going really well.';
  String get descriptionPracticing048 =>
      'divide your piece into phrases, and practice from the most challenging to the easiest.';
  String get descriptionPracticing049 => 'practice for 5 minutes, then take a 5 minute break.';
  String get descriptionPracticing050 =>
      "record tricky parts in slow-motion, and analyze what isn't working so well (or watch a video recorded at normal-speed slowed down).";
  String get descriptionPracticing051 => 'play as physically relaxed as you can.';
  String get descriptionPracticing052 => 'imagine yourself slowly playing a bar.';
  String get descriptionPracticing053 => "stop right when it's most fun.";
  String get descriptionPracticing054 =>
      'listen to short parts of your favorite recording and then play them immediately.';
  String get descriptionPracticing055 => 'allow yourself to make mistakes.';
  String get descriptionPracticing056 =>
      "if something isn't running smoothly, write down possible solutions and try them out.";
  String get descriptionPracticing057 =>
      'practice the most difficult phrase of the piece exactly 5 times, at a tempo where you can play everything correctly.';
  String get descriptionPracticing058 => 'play your piece on one note. Pay attention to the phrasing.';
  String get descriptionPracticing059 =>
      'practice in 15-minute sessions (with a stopwatch), and take a 5-minute break after each session.';
  String get descriptionPracticing060 => 'time how long you practice today.';
  String get descriptionPracticing061 => 'try to play your piece by heart, and just see how much is possible.';
  String get descriptionPracticing062 => 'deliberately play fast passages very slowly.';
  String get descriptionPracticing063 =>
      'direct your attention to a different aspect (intonation, sound, etc.) with each repetition of the phrase.';
  String get descriptionPracticing064 =>
      'practice a phrase from the end: for example, start with the last bar and gradually add more bars.';
  String get descriptionPracticing065 => 'practice a phrase backwards.';
  String get descriptionPracticing066 =>
      'what can you improve right now to immediately take the result to another level?';
  String get descriptionPracticing067 =>
      'play a phrase once at normal volume, once very quietly and once very loudly. Repeat the version that challenged you the most four more times.';
  String get descriptionPracticing068 => 'memorize the beginning and end of the piece you are practicing.';
  String get descriptionPracticing069 => 'start with a piece you need for an upcoming performance.';
  String get descriptionPracticing070 =>
      'vary the rhythm of your phrase at least three times (for example, dotted, triplet, swing).';
  String get descriptionPracticing071 =>
      'look for a challenging phrase and consciously increase the level of difficulty.';
  String get descriptionPracticing072 => 'memorize the most challenging phrase of your piece.';
  String get descriptionRelaxation001 =>
      'before entering the practice room, breathe out three times as deeply as you can.';
  String get descriptionRelaxation002 =>
      'every 10 minutes, take a short break to drink a sip of water and discover something around you that you find beautiful.';
  String get descriptionRelaxation003 =>
      'meditate in the practice room for 5 minutes before you start playing your instrument.';
  String get descriptionRelaxation004 =>
      'pick up your instrument and close your eyes. Feel your entire body, from your toes to the top of your head, and release unnecessary tension. Build breakes into your piece to relax.';
  String get descriptionRelaxation005 =>
      "think about how many days off you'd need before you wanted to practice again. From now on, define that number of days as days off. For every day off that you still practice, you've exceeded your plan — congratulations!";
  String get descriptionRelaxation006 =>
      "allow yourself to not have to accomplish anything while practicing. What would you do with your instrument if you didn't have to pursue the goals your daily life demands of you? Do just that first. Remember that everything you do, you don't have to do, because you don't have to do anything, ever.";
  String get descriptionRelaxation007 =>
      'listen to your piece first. Now decide whether you want to try it on the instrument or just listen to it today. You can listen to it several times.';
  String get descriptionRelaxation008 =>
      'reduce existing stress by shaking, stomping or lying down for 5 minutes. Do whatever comes to mind intuitively.';
  String get descriptionRelaxation009 => 'look around as fast as you can (only) with your eyes for 60 seconds.';
  String get descriptionRelaxation010 => 'hum sounds from time to time and feel them (physically).';
  String get descriptionRelaxation011 => 'first, sit down in the practice room and do nothing for 5 minutes.';
  String get descriptionRelaxation012 =>
      'do this eye exercise: look left, right, up, and down several times. Your eyes will thank you!';
  String get descriptionRelaxation013 => 'pay particular attention to your breathing.';
  String get descriptionRelaxation014 =>
      'record a phrase on video and, while watching it, pay attention to any unnecessary movements right before you start playing.';
  String get descriptionRelaxation015 =>
      'record your playing on video and, while watching it, pay special attention to your facial expressions during and between playing.';
  String get descriptionRelaxation016 => 'take 3 minutes beforehand and listen to your own breathing.';
  String get descriptionRelaxation017 => 'pay attention to your heartbeat, too.';
  String get descriptionRelaxation018 =>
      'lie down on the floor and squeeze all of your muscles simultaneously as hard as possible for 10 seconds. Do you feel a change from your original state?';
  String get descriptionSelfCare001 =>
      'start your practice with physical exercises: a tapping massage, kneading the neck, grounding, stretching.';
  String get descriptionSelfCare002 =>
      'ask yourself: How am I feeling? Express this emotion on your instrument or with your voice. Improvise, simply make some sounds, or play a suitable piece.';
  String get descriptionSelfCare003 =>
      'ask yourself: What do I want to express? Who am I, and what do I want to give to the world? Embody this spontaneously and intuitively on your instrument or with your voice. Improvise, make some sounds, or play a suitable piece.';
  String get descriptionSelfCare004 =>
      'take a 10-second break if you notice the part that you are working on is getting worse again. (Your brain learns during breaks!)';
  String get descriptionSelfCare005 =>
      'pay attention to your body: Write down body parts (neck, shoulders, stomach, feet, spine...) on a piece of paper and pay attention to the different areas one after the other during a phrase.';
  String get descriptionSelfCare006 => 'think about which book you want to read tonight before going to sleep.';
  String get descriptionSelfCare007 =>
      'think about which book could help you the most with your practice. Get it and read it.';
  String get descriptionSelfCare008 => 'plan your ideal bedtime for today.';
  String get descriptionSelfCare009 => 'plan when you want to finish work today.';
  String get descriptionSelfCare010 => 'consider how you can spend your practice time without digital devices.';
  String get descriptionSelfCare011 => 'drink half a liter of water beforehand.';
  String get descriptionSelfCare012 => 'ask yourself if you were able to sleep in today. If not, try tomorrow.';
  String get descriptionSelfCare013 => 'bite into a lemon first.';
  String get descriptionSelfCare014 => 'drink a ginger shot or eat raw ginger.';
  String get descriptionSelfCare015 => 'do a guided meditation beforehand.';
  String get descriptionSelfCare016 =>
      'consider which meal makes you feel energized and which meal makes you feel too tired to exercise.';
  String get descriptionSelfCare017 =>
      'consider whether you started the day with exercise. If not, try to do so tomorrow.';
  String get descriptionSelfCare018 =>
      'take a walk without electronic devices. Your brain needs boredom to clear its mind. Allow your thoughts to flow and simply observe them.';
  String get descriptionSelfCare019 =>
      'think about how you can take time for yourself several hours before your next performance and make sure that you feel comfortable.';
  String get descriptionSelfCare020 =>
      'make sure you have your needs met before practicing or meet them during breaks.';
  String get descriptionSelfCare021 => 'notice when your head is full and then take a break.';
  String get descriptionSelfCare022 =>
      'plan when you will take a day off (recommendation: once a week) and enter it in red in your calendar.';
  String get descriptionSelfCare023 => 'first, switch your smartphone to airplane mode, or turn off the internet.';
  String get descriptionSelfCare024 => 'write down all your extraneous thoughts before and during your practicing.';
  String get descriptionSelfCare025 =>
      'start with very long notes (drums: rolls). At least one of these should be dynamically constant, one with crescendo, one with diminuendo, and one both dynamically ascending and then descending again.';
  String get descriptionSelfCare026 => 'at the end, play your favorite piece or song.';
  String get descriptionSelfCare027 =>
      'take a 5-minute break halfway through your practice and use it to do things like drink a glass of water, get some fresh air, or exercise.';
  String get descriptionSelfCare028 => 'look around: is your room tidy? If not, can you tidy it up with little effort?';
  String get descriptionSelfCare029 =>
      'consider where you can practice effectively - at home or somewhere else? Do you prefer to practice in the same place, or do you benefit from variety?';
  String get descriptionSelfCare030 => 'see how you can have fun.';
  String get descriptionTeam001 => 'ask someone to observe you while practicing. What advice can he/she give you?';
  String get descriptionTeam002 => 'tell someone about one of your obstacles and brainstorm solutions together.';
  String get descriptionTeam003 => 'describe a goal to someone and think about ways to get there.';
  String get descriptionTeam004 =>
      'let someone else take the lead. He/She will guide you by giving instructions or demonstrating how to practice.';
  String get descriptionTeam005 =>
      'get someone to play the tonic of the phrase as a drone while you practice. Play your piece with open ears.';
  String get descriptionTeam006 => 'watch someone else practice and write down what inspires you.';
  String get descriptionTeam007 => 'ask someone (you like) to play chamber music with you.';
  String get descriptionTeam008 => 'play your piece with someone.';
  String get descriptionTeam009 => 'chat with somebody about what to do if you feel an aversion to practicing.';
  String get descriptionTeam010 =>
      'have someone else place their hands on your shoulders. Together, pay attention to where you can still release tension.';
  String get descriptionTeam011 => 'ask someone to distract you while you play.';
  String get descriptionTeam012 => 'ask someone to fast-forward a bit when playing along to a recording.';
  String get descriptionTeam013 =>
      'depending on your instrument, ask someone to press the keys while you blow into your instrument, or have someone play one hand while you play the other.';
  String get descriptionTeam014 => 'ask someone to listen to you practicing for 15 minutes without commenting.';
  String get descriptionTeam015 =>
      'afterwards, tell a friend what and how you practiced today. Does he/she have any tips for you?';
  String get descriptionTeam016 => 'practice together with a friend.';
  String get descriptionTeam017 => 'record a video of yourself and send it to a friend.';
  String get descriptionTeam018 => 'play a piece or song that you know well for someone you like.';
  String get descriptionVision001 =>
      'lie down and stay there until you know exactly why it is worth it for you to get up and pick up your instrument.';
  String get descriptionVision002 =>
      "think about why you might get up early tomorrow. What would be so stimulating that you would wake up before the alarm because you're so excited about it?";
  String get descriptionVision003 =>
      'write down a daily goal. Something you can easily achieve and try to accomplish in the first half of the day. This will make the second half feel much freer.';
  String get descriptionVision004 =>
      'stand in front of a mirror and give yourself a motivational speech in which you enthusiastically tell yourself what you have already achieved, how proud you are of yourself, why this path is the right one for you and what makes your eyes light up.';
  String get descriptionVision005 =>
      'write down key euphoric moments from the past. Do they have anything in common? What exactly made your eyes light up?';
  String get descriptionVision006 => 'think about your goal beforehand, and practice with this goal in mind.';

  String get flashCard => 'Flash card';
  String get flashCardTitle => 'When you practice today,';

  String get flashCardsAllCategories => 'All categories';
  String get flashCardsPageTitle => 'Practice tips';
  String get flashCardsSelectCategory => 'Select category';
}
