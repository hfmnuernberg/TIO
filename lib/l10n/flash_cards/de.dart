// overriding keys do not change something; ignored because soft warning
// ignore_for_file: annotate_overrides

import 'package:tiomusic/domain/flash_cards/category.dart';
import 'package:tiomusic/l10n/flash_cards/flash_cards_localization.dart';

mixin GermanFlashCards on Object implements FlashCardsLocalization {
  String get categoryCulture => 'Kultur';
  String get categoryJournaling => 'Dokumentation';
  String get categoryMixUp => 'Abwechslung';
  String get categoryPracticing => 'Übetaktik';
  String get categoryRelaxation => 'Entspannung';
  String get categorySelfCare => 'Alltagshygiene';
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

  String get descriptionCulture001 =>
      'buche dir eine Karte für einen Konzertbesuch, auf den du dich jetzt schon total freust!';
  String get descriptionCulture002 => 'belohne dich dafür mit was immer dir einfällt.';
  String get descriptionCulture003 =>
      'schaffe dir ein eigenes privates Konzert, indem du dir eine tolle Aufnahme von einem Stück ansiehst/anhörst, das dir wichtig ist. Mach es dir dazu ganz gemütlich und schaffe dir so eine Wohlfühloase.';
  String get descriptionCulture004 =>
      'verabrede dich mit Freund*innen zum Musik hören und erzählt euch hinterher gegenseitig, was eure tollsten Hörmomente waren und was euch begeistert hat.';
  String get descriptionCulture005 =>
      'entdecke ein Stück, das dir neu ist, auf möglichst viele Arten und Weisen - hör es dir an, bewege dich dazu, lies, in welchem Kontext es geschrieben wurde/aufgeführt wurde, male ein Bild dazu, improvisiere über ein Thema...';
  String get descriptionCulture006 =>
      'entdecke ein Stück, das dir schon bekannt ist, auf möglichst viele Arten und Weisen neu - hör es dir an, bewege dich dazu, lies, in welchem Kontext es geschrieben wurde/aufgeführt wird, male ein Bild dazu, improvisiere über ein Thema...';
  String get descriptionCulture007 =>
      'höre dir Musik von einem deiner Vorbilder an und notiere, was du von der Person lernen möchtest.';
  String get descriptionCulture008 => 'überlege dir für dein aktuelles Stück eine 2-minütige Anmoderation.';
  String get descriptionCulture009 =>
      'überlege dir für dein aktuelles Stück eine Einführung für zwei verschiedene Zielguppen, zum Beispiel klassische Konzertbesucher*innen, Schulklassen, Senior*innen, Fußballfans, ...';
  String get descriptionCulture010 =>
      'lies, soweit vorhanden, den Abschnitt zu deinem Instrument in der Instrumentationslehre von Hector Berlioz, in der revidierten Fassung von Richard Strauss (1905).';
  String get descriptionCulture011 => 'lies den Wikipedia-Artikel zu deinem Instrument.';
  String get descriptionJournaling001 => 'notiere dir, was du heute tun und dabei lernen wirst.';
  String get descriptionJournaling002 =>
      'notiere danach, was du heute gelernt oder welche Erkenntnisse du erlangt hast.';
  String get descriptionJournaling003 =>
      'notiere, welches deine Baustellen sind, nimm dir die wichtigste vor und übe heute verstärkt daran.';
  String get descriptionJournaling004 =>
      'notiere dir, wofür du dankbar bist oder worauf du dich freust. Notiere dir am Tag eines Auftritts, warum du dich auf den Auftritt freust.';
  String get descriptionJournaling005 =>
      'schreibe danach auf, welche Übung heute am besten gelungen ist und notiere sie (evtl. digital) als Erinnerung für morgen.';
  String get descriptionJournaling006 =>
      'notiere dir vor dem Spielen, was du nach dem Üben heute besser können möchtest.';
  String get descriptionJournaling007 =>
      'starte ein Erfolgstagebuch: Notiere, was du gelernt hast und was du heute geschafft hast. Suche dir dafür einen Zeitpunkt - zum Beispiel nach dem Üben, währenddessen oder abends nach dem Essen.';
  String get descriptionJournaling008 => 'notiere dir vor dem Üben dein wichtigstes Ziel für den Tag.';
  String get descriptionJournaling009 =>
      'führe schriftlich einen Dialog mit dir selbst: Was brauchst du, um gerne zu üben?';
  String get descriptionJournaling010 =>
      'führe schriftlich einen Dialog mit dir selbst: Warum übst du gerade nicht? Sei freundlich und verständnisvoll mit dir und versuche, eine gesunde Lösung zu finden. Was brauchst du, um gerne zu üben?';
  String get descriptionJournaling011 =>
      'notiere, wie es dir gerade geht. Führe Tagebuch und frage dich bei Widerständen selbst, wie du sie im Ursprung auflösen kannst.';
  String get descriptionJournaling012 => 'miss deine Übezufriedenheit und deinen Startwiderstand mit Schulnoten.';
  String get descriptionJournaling013 => 'miss die Qualität des Übens auf einer Skala von 1 bis 10.';
  String get descriptionJournaling014 => 'schreibe auf, wie zufrieden du mit deinem Üben bist oder warst.';
  String get descriptionJournaling015 =>
      'notiere, welche Muskeln du für deine Tonhöhen- oder Lautstärkeveränderungen verwendest und welche du entspannen könntest.';
  String get descriptionJournaling016 =>
      'plane vorher deine Übezeit in 25-min-Einheiten ein und schreibe auf, was du jeweils in den 25 min getan haben möchtest. Mache nach einer Einheit mind. 5 min Pause.';
  String get descriptionJournaling017 => 'priorisiere schriftlich deine Aufgaben und übe von wichtig zu unwichtig.';
  String get descriptionJournaling018 =>
      'plane 20-Minuten-Übeeinheiten mit konkreten Aufgaben/Zielen für jede Einheit. Schaffst du es, vor dem Wecker fertig zu sein? Wenn nicht, höre auf, sobald der Wecker klingelt, und überarbeite ggf. deinen Übeplan.';
  String get descriptionJournaling019 => 'schreibe auf, was du alles geübt hast.';
  String get descriptionJournaling020 => 'schreibe danach deine Ziele auf: Was willst du morgen erreicht haben?';
  String get descriptionMixUp001 =>
      'geh in der Natur spazieren. Was kannst du ohne dein Instrument draußen tun, damit du danach dein Stück besser kannst?';
  String get descriptionMixUp002 =>
      'nimm dir Zeit für einen kurzen Powernap (max. 30 min). Spiele beim Einschlafen im Kopf dein Stück durch und lass dich überraschen, was im Schlaf weiter passiert.';
  String get descriptionMixUp003 =>
      'überlege, welches Stück, welche Aufnahme oder welchen Song du gerade anhören möchtest? Hör ihn bzw. es dir dreimal an und versuche herauszufinden, was dich daran anspricht. Probiere, die Schönheit, die du gefunden hast, durch dein aktuelles Stück auszudrücken.';
  String get descriptionMixUp004 =>
      'mache dir eine Liste, was du lieber tun würdest als Üben. Notiere dir auch, was dir an diesen Tätigkeiten gefällt. Baue sie in dein Üben ein!';
  String get descriptionMixUp005 =>
      'schreibe dir eine Not-To-Do-Liste. Schreib alle Dinge auf, die du heute nicht tun möchtest und hake diese abends ab, wenn sie tatsächlich nicht geschehen sind.';
  String get descriptionMixUp006 =>
      'gehe zum Lachen an einen abgeschiedenen Ort (z. B. Keller): Leg dich auf die Seite und lass den Bauch federn. Denk dir etwas lustiges oder hör dir etwas an.';
  String get descriptionMixUp007 =>
      'behandle dein Instrument wie ein Haustier. Welche Zuwendungen würdest du ihm entgegenbringen oder schenken? Wie würdest du es nennen?';
  String get descriptionMixUp008 =>
      'mache dir bewusst, was dich wirklich zufrieden machen würde, wenn du es heute erledigst. Versuche es in 10 min Übezeit zu schaffen! Was musst du tun, damit das klappt?';
  String get descriptionMixUp009 =>
      'hör dir das Hörspiel "Neinhorn" von Marc-Uwe Kling an oder lies es dir durch (Bibliothek!). Zu was möchtest du alles "Nein" sagen? Go for it!';
  String get descriptionMixUp010 =>
      'installiere eine App, mit der man einen Orgelpunkt erzeugen kann (engl. drone) und spiele lange Töne, langsame Skalen oder Akkordbrechungen über den Orgelpunkt.';
  String get descriptionMixUp011 =>
      'sammle alle Ideen schriftlich, die du für das Üben hast, damit es dir mehr Spaß macht. Stelle dir vor, wie viele Ideen du gesammelt hast, wenn du das eine Woche lang wiederholst!';
  String get descriptionMixUp012 =>
      'übe eine Skala sauber zu singen. Nimm dir den Grundton vom Klavier und singe die Skala rauf und runter.';
  String get descriptionMixUp013 =>
      'übe einen Dreiklang sauber zu singen. Nimm dir den Grundton vom Klavier und singe den Dreiklang rauf und runter.';
  String get descriptionMixUp014 =>
      'lerne eine Fingerkoordinationsübung: Schaue im Internet nach "Hase und Jäger". Teste nach einer Woche, wie sich das Spielen davor und danach anfühlt.';
  String get descriptionMixUp015 =>
      'spiele oder singe dein Stück auf einem Bein oder auf einem Balanceboard. Was nimmst du wahr?';
  String get descriptionMixUp016 => 'male passende Emoticons zu den unterschiedlichen Abschnitten deines Stückes.';
  String get descriptionMixUp017 =>
      'plane, wann du heute nach dem Üben als Belohnung deinen Lieblingssport machen wirst.';
  String get descriptionMixUp018 => 'überlege dir, was deine Lehrkraft zu deiner gespielten Phrase sagen würde.';
  String get descriptionMixUp019 => 'baue bewusst Verspieler in dein Stück ein und feiere sie kräftig.';
  String get descriptionMixUp020 => 'analysiere einen Abschnitt deines Stückes.';
  String get descriptionMixUp021 => 'schaue in die Partitur, was abseits deiner Stimme passiert.';
  String get descriptionMixUp022 => 'dirigiere dein Stück (wenn du magst, vor einem Spiegel).';
  String get descriptionMixUp023 =>
      'du dich aber manchmal langweilst bzw. deine Gedanken abschweifen, wechsle den Übeort, die Methode oder das Stück.';
  String get descriptionMixUp024 =>
      'erlaube dir, alle Regeln über Bord zu werfen und heute einfach nur frei zu spielen.';
  String get descriptionMixUp025 => 'spiele eine Phrase mit geschlossenen Augen.';
  String get descriptionMixUp026 =>
      'überlege dir, auf was du so richtig große Lust hast. Wäre es möglich, es heute in deinen Tag einzubauen?';
  String get descriptionMixUp027 =>
      'höre einmal auf deinen Klang und in einem zweiten Durchgang, höre deinem Körper zu.';
  String get descriptionMixUp028 =>
      'male dich und dein Instrument in Aktion. Was fällt dir auf bezüglich Haltung, Proportionen, Details etc.?';
  String get descriptionMixUp029 => 'verdunkle den Raum oder verdecke deine Augen, bevor du loslegst.';
  String get descriptionMixUp030 => 'spiele eine Phrase auf Zehenspitzen.';
  String get descriptionMixUp031 => 'achte besonders auf deine künstlerische Ausstrahlung/Überzeugungskraft.';
  String get descriptionMixUp032 => 'spiele durchgehend mit dem schönstmöglichen Klang.';
  String get descriptionMixUp033 =>
      'frage dich nach dem Spielen einer Phrase: Was kann ich tun, damit es noch schöner klingt?';
  String get descriptionMixUp034 => 'entwirf selbst einen Übetipp und probiere ihn anschließend aus.';
  String get descriptionMixUp035 =>
      'finde das richtige Verhältnis zwischen gesunder Spannung und Entspannung beim Spielen.';
  String get descriptionMixUp036 => 'stelle dir vor, du spielst vor Publikum (deinen Eltern, im Konzertsaal etc.).';
  String get descriptionMixUp037 => 'suche dir drei bis fünf Töne aus und erfinde damit ein Lied.';
  String get descriptionMixUp038 => 'spiele etwas dir Bekanntes nur nach Gehör.';
  String get descriptionMixUp039 => 'unterteile das Stück in Abschnitte und markiere sie farblich.';
  String get descriptionMixUp040 =>
      'spiele eine Phrase einmal in normalem Tempo, einmal halb so schnell und einmal doppelt so schnell.';
  String get descriptionMixUp041 =>
      'erfinde eine Geschichte zu deinem aktuellen Stück. Wenn du magst, erzähle sie jemandem.';
  String get descriptionMixUp042 => 'kopiere dein aktuelles Stück, zerschneide es und puzzle es wieder zusammen.';
  String get descriptionMixUp043 => 'komponiere eine Stück, in dem die Tonhöhe immer gleich bleibt.';
  String get descriptionMixUp044 => 'suche dir ein Bild oder Foto aus und vertone es.';
  String get descriptionMixUp045 =>
      'nimm ein Notenblatt und schreibe alle Töne auf, die du spielen kannst. Wie viele sind es, wie viele Oktaven decken sie ab? Recherchiere, welcher Tonumfang für dein Instrument vorgesehen ist. Ist er eher groß oder eher klein im Vergleich zu anderen Instrumenten?';
  String get descriptionMixUp046 =>
      'schaue dir die Übetipps durch und suche einen aus, der dich anspricht und den du heute gerne machen möchtest.';
  String get descriptionMixUp047 => 'klatsche den Rhythmus einer Phrase zum Metronom.';
  String get descriptionMixUp048 =>
      'höre dir eine Aufnahme deines Stückes an und lies gleichzeitig deine Stimme mit, alternativ die Partitur.';
  String get descriptionMixUp049 =>
      'höre dir eine Aufnahme deines Stückes an und singe mit, greife stumm mit oder spiele mit.';
  String get descriptionMixUp050 => 'recherchiere, ob es ein Playalong zu deinem Stück gibt und wenn ja, spiele dazu.';
  String get descriptionMixUp051 => 'lasse einen Ton so leise wie möglich kommen.';
  String get descriptionMixUp052 => 'suche dir drei Töne aus und spiele sie so leise wie möglich.';
  String get descriptionMixUp053 =>
      'übe jeweils nur 5 Minuten (Stoppuhr) und wechsle dann das Lernziel oder die Methode, sodass du jedes Mal etwas anderes lernst.';
  String get descriptionMixUp054 => 'spiele dein aktuelles Stück mit einem Luftinstrument.';
  String get descriptionMixUp055 => 'tanze dein Stück.';
  String get descriptionMixUp056 => 'spiele abwechselnd einen Takt und denke oder singe den nächsten Takt.';
  String get descriptionMixUp057 => 'spiele ein Stück, welches dich musikalisch weiterbringt.';
  String get descriptionMixUp058 => 'wechsle den Übeplatz: Den Raum, drehe dich in eine andere Richtung etc.';
  String get descriptionMixUp059 =>
      'notiere eine Phrase aus dem Kopf auf Notenpapier und vergleiche sie mit dem Original.';
  String get descriptionMixUp060 => 'spiele dein Stück im Tempo deines Pulses (Herzfrequenz) durch.';
  String get descriptionMixUp061 => 'stelle dir vor, dein Stück wäre Filmmusik. Wie würde die Szene aussehen?';
  String get descriptionMixUp062 => 'visualisiere deinen nächsten Auftritt.';
  String get descriptionMixUp063 => 'improvisiere 5 Minuten lang über das Hauptmotiv deines Stückes.';
  String get descriptionMixUp064 =>
      'wenn möglich, stelle dich so vor eine Wand, dass du deinen reflektierten Schall direkt wahrnehmen kannst.';
  String get descriptionMixUp065 =>
      'finde zu jedem Abschnitt deines Stück mindestens ein passendes Adjektiv und schreibe es in die Noten.';
  String get descriptionMixUp066 =>
      'finde zu jedem Abschnitt deines Stück mindestens ein passendes Bild (Sonnenaufgang, Wald, perlendes Mineralwasser etc.). Wenn du magst, suche dir passende Bilder im Internet heraus.';
  String get descriptionPracticing001 =>
      'übe abwechslungsreich: Notiere alle Übestrategien, die du spontan machst und verwende sie auch für andere Stücke.';
  String get descriptionPracticing002 => 'spiele zu einer Aufnahme.';
  String get descriptionPracticing003 =>
      'spiele deine Stimme auf dem Klavier. Wenn dein Instrument das Klavier ist, singe.';
  String get descriptionPracticing004 =>
      'spiele mit Flatterzunge, beiße auf einen Korken (Gesang), oder überlege dir für dein Instrument etwas ähnliches.';
  String get descriptionPracticing005 =>
      'singe eine Phrase. Wenn möglich und/oder gewünscht, nimm ein (digitales) Klavier zur Hilfe.';
  String get descriptionPracticing006 => 'singe dein Stück und oktaviere gegebenenfalls.';
  String get descriptionPracticing007 =>
      'suche dir die herausforderndste Stelle des Stückes heraus und lerne sie zu singen. Für Sänger: Lerne die Begleitung zu singen, singe deine Stelle mental oder solmisiere sie.';
  String get descriptionPracticing008 => 'pfeife dein Stück.';
  String get descriptionPracticing009 => 'greife eine Stelle stumm oder flüstere die Stelle (Gesang).';
  String get descriptionPracticing010 =>
      'spiele eine Stelle in verschiedenen Tempi - mal sehr langsam, mal sehr schnell.';
  String get descriptionPracticing011 => 'transponiere eine Stelle in drei weitere Tonarten.';
  String get descriptionPracticing012 => 'übe eine herausfordernde Stelle im Loop.';
  String get descriptionPracticing013 => 'fange mitten in einer Stelle (an einem ungewöhnlichen Ort) an.';
  String get descriptionPracticing014 => 'spiele extrem leise oder übertrieben laut.';
  String get descriptionPracticing015 => 'baue in dein Stück ungewöhnliche Akzente ein.';
  String get descriptionPracticing016 =>
      'spiele auf einem Bein, in der Hocke oder auf einem Balanceboard. Nächstes Level: mit geschlossenen Augen.';
  String get descriptionPracticing017 => 'übertreibe die vorgegebene Artikulation.';
  String get descriptionPracticing018 =>
      'springe mitten in eine Aufnahme deines Stückes und höre nur 2 Sekunden lang zu. An dieser Stelle, bestenfalls mitten in der Phrase, steige ein und spiele mit.';
  String get descriptionPracticing019 =>
      'spiele die Stelle in einem suboptimalen Zustand: Uneingespielt, im Mittagstief etc. Glänze gleich beim ersten Mal!';
  String get descriptionPracticing020 => 'erweitere den Ambitus (Tonumfang) einer Stelle.';
  String get descriptionPracticing021 => 'oktaviere bestimmte Töne einer Stelle.';
  String get descriptionPracticing022 =>
      'nimm dich 10 Sekunden lang auf und höre die Aufnahme sofort an. Womit bist du zufrieden, was würdest du verbessern?';
  String get descriptionPracticing023 => 'welche Übung würdest du deinem*r besten Freund*in empfehlen?';
  String get descriptionPracticing024 =>
      'lehne dich an eine Wand oder einen Türrahmen. Spiele und beobachte deine Schultern und deinen Kopf, die die Wand berühren sollten. Wenn dir Spannungen auffallen, lass sie los.';
  String get descriptionPracticing025 =>
      'spiele eine Stelle, die du noch nicht kannst, vor dem Spiegel. Was passiert an der Stelle, an der du stolperst?';
  String get descriptionPracticing026 =>
      'spiele einen Ton zu verschiedenen Akkorden am Klavier und spüre, wie er sich anfühlt, wenn er stimmt.';
  String get descriptionPracticing027 =>
      'nimm eine Stelle auf, die du noch nicht kannst, und höre sie dir in halber Geschwindigkeit an. Was fällt dir auf?';
  String get descriptionPracticing028 =>
      'spiele gaaanz langsam, sehr bewusst sauber und entspannt. Spiele so langsam, dass du immer weißt, was du tun musst sowie alles hörst und spürst (wahrnehmen kannst).';
  String get descriptionPracticing029 =>
      'greife die Übung oder die Stelle erst stumm und bewusst, bevor du sie spielst.';
  String get descriptionPracticing030 => 'übe vor allem herausfordernde Griffverbindungen.';
  String get descriptionPracticing031 =>
      'achte bei eingeschliffenen Technikübungen auf die Intonation, den Klang und die Phrasierung.';
  String get descriptionPracticing032 =>
      'nimm dir eine Tongruppe und denke sie mental durch. Spiele sie dann ganz langsam und sauber sowie anschließend maximal schnell.';
  String get descriptionPracticing033 =>
      'übe differentiell. Beispiel Flöte: Greife ein Halbloch zu groß, zu klein, zu schief... Setze einen Finger zu weit weg und zu nah dran. Pendle dich über Unterschiede ein.';
  String get descriptionPracticing034 =>
      'teile dein Stück in Charakterabschnitte ein und notiere zu jedem eine Emotion und ihre Intensität.';
  String get descriptionPracticing035 =>
      'nimm dir einen kleinen Abschnitt auf und versuche, eine Emotion zu verkörpern. Höre dir die Aufnahme an, was irritiert dich?';
  String get descriptionPracticing036 =>
      'fühle dich in eine Situation hinein, die du mit deinem Stück assoziierst. Fühle dich beim Spielen genauso, wie du dir die Situation vorstellst.';
  String get descriptionPracticing037 => 'spiele mit Übertreibung: Maximale dynamische Unterschiede.';
  String get descriptionPracticing038 => 'spiele mit Übertreibung: Starke Unterschiede in der Artikulation.';
  String get descriptionPracticing039 =>
      'spiele mit Übertreibung: Maximale Agogik (freie künstlerische Tempoveränderungen).';
  String get descriptionPracticing040 => 'spiele mit Übertreibung: Maximale klangliche Unterschiede.';
  String get descriptionPracticing041 => 'bewege dich zu einer Aufnahme deines Stückes.';
  String get descriptionPracticing042 =>
      'stell dir ohne Instrument vor, dein Stück zu spielen oder zu singen und verändere deine Mimik passend dazu vor dem Spiegel.';
  String get descriptionPracticing043 =>
      'nimm dich mit dem Handy oder einem Aufnahmegerät auf. Höre dir die Aufnahme sofort an und markiere in den Noten, welche Stellen noch nicht so gut gelungen sind. Übe anschließend genau diese Stellen.';
  String get descriptionPracticing044 =>
      'nimm dich mit dem Handy oder einem Aufnahmegerät (inkl. Video) auf. Schau dir die Aufnahme sofort an und notiere dir, welche Stellen du überzeugend findest und welche noch nicht. Übe anschließend genau diese letzteren Stellen.';
  String get descriptionPracticing045 => 'gehe dein Stück mental durch. Welche Stellen sind noch nicht so präsent?';
  String get descriptionPracticing046 =>
      'singe dein Stück auswendig auf Notennamen durch. Welche Stellen laufen noch nicht so flüssig?';
  String get descriptionPracticing047 => 'mache immer dann eine Pause, wenn es gerade sehr gut läuft.';
  String get descriptionPracticing048 =>
      'teile dein Stück in Phrasen ein und übe von der herausfordernsten zur leichtesten.';
  String get descriptionPracticing049 => 'übe 5 Minuten und mache dann 5 Minuten Pause.';
  String get descriptionPracticing050 => 'spiele körperlich so entspannt, wie es dir möglich ist.';
  String get descriptionPracticing051 =>
      'nimm knifflige Stellen in Slow Motion auf und analysiere, was noch nicht so gut läuft (oder schaue dir ein Video in normaler Geschwindigkeit verlangsamt an).';
  String get descriptionPracticing052 => 'stell dir vor, wie du einen Takt langsam spielst.';
  String get descriptionPracticing053 => 'höre genau dann auf, wenn es am meisten Spaß macht.';
  String get descriptionPracticing054 =>
      'höre kurze Takte deiner Lieblingsaufnahme an und spiele sie dann direkt nach.';
  String get descriptionPracticing055 => 'erlaube dir, Fehler zu machen.';
  String get descriptionPracticing056 =>
      'notiere dir zu einer Stelle, die noch nicht ganz flüssig läuft, Lösungsstrategien und probiere sie aus.';
  String get descriptionPracticing057 =>
      'übe die herausforderndste Phrase des Stückes genau 5 Mal, und zwar in einem Tempo, in dem du alles richtig spielen kannst.';
  String get descriptionPracticing058 =>
      'spiele dein Stück auf einem Ton durch (immer die gleiche Tonhöhe). Achte auf die Phrasierung.';
  String get descriptionPracticing059 =>
      'übe in 15-Minuten-Einheiten (mit Stoppuhr) und mache nach jeder Einheit 5 min Pause.';
  String get descriptionPracticing060 => 'stoppe die Zeit, wie lange du heute insgesamt übst.';
  String get descriptionPracticing061 =>
      'spiele dein Stück einfach mal auswendig und schaue, wie viel schon möglich ist.';
  String get descriptionPracticing062 => 'spiele bewusst schnelle Stellen sehr langsam.';
  String get descriptionPracticing063 =>
      'rotiere mit deiner Aufmerksamkeit bei jedem Durchgang der Phrase auf einen anderen Aspekt (Intonation, Klang, Rhythmus etc.).';
  String get descriptionPracticing064 =>
      'übe eine Phrase vom Ende her: Beginne zum Beispiel mit dem letzten Takt und nimm schrittweise weitere Takte hinzu.';
  String get descriptionPracticing065 => 'übe eine Phrase rückwärts.';
  String get descriptionPracticing066 =>
      'übe am Produkt: Was kannst du genau jetzt verbessern, um das Ergebnis sofort auf ein anderes Level zu heben?';
  String get descriptionPracticing067 =>
      'spiele eine Phrase einmal in normaler Lautstärke, einmal sehr leise und einmal sehr laut. Wiederhole die Version, die dich am meisten herausgefordert hat, noch vier Mal.';
  String get descriptionPracticing068 =>
      'lerne den Anfang und das Ende von dem Stück, welches du gerade übst, auswendig.';
  String get descriptionPracticing069 => 'fange mit dem Stück an, welches du für einen baldigen Auftritt brauchst.';
  String get descriptionPracticing070 =>
      'variiere den Rhythmus deiner Phrase mindestens drei Mal (zum Beispiel punktiert, triolisch, geswingt).';
  String get descriptionPracticing071 =>
      'suche eine herausfordernde Stelle und steigere noch einmal bewusst den Schwierigkeitsgrad.';
  String get descriptionPracticing072 => 'lerne die herausforderndste Phrase deines Stückes auswendig.';
  String get descriptionRelaxation001 => 'atme vor dem Betreten des Überaums drei Mal so tief aus, wie du kannst.';
  String get descriptionRelaxation002 =>
      'nimm dir alle 10 Minuten Zeit für eine kurze Pause, in der du einen Schluck Wasser trinkst und etwas um dich herum entdeckst, das du wunderschön findest.';
  String get descriptionRelaxation003 =>
      'meditiere im Überaum erst 5 Minuten, bevor du dich mit deinem Instrument beschäftigst.';
  String get descriptionRelaxation004 =>
      'nimm dein Instrument in die Hand und mache die Augen zu. Spüre von den Zehen bis zum Scheitel deinen gesamten Körper und lasse unnötige Anspannungen fallen. Baue für solche Entspannungen Pausen in dein Stück ein.';
  String get descriptionRelaxation005 =>
      'überlege dir, wie viele Pausentage du bräuchtest, bis du von alleine wieder Lust hast zu üben. Definiere diese Anzahl der Tage ab heute als Pausentage. An jedem Pausentag, an dem du trotzdem übst, hast du deinen Plan übererfüllt - Glückwunsch!';
  String get descriptionRelaxation006 =>
      'fühle dich frei, indem du dir erlaubst, nichts beim Üben schaffen zu müssen. Was würdest du mit deinem Instrument tun, wenn du keine Ziele verfolgen müsstest, die dein Alltag von dir verlangt? Tue genau das zuerst. Es erinnert dich daran, dass du alles, was du tust, nicht tun musst.';
  String get descriptionRelaxation007 =>
      'höre dir dein Stück vorher einmal an. Spüre jetzt, ob du es am Instrument versuchen möchtest, oder ob du es heute nur hören möchtest. Du kannst es auch mehrmals hören.';
  String get descriptionRelaxation008 =>
      'baue vorhandenen Stress ab, indem du dich 5 Minuten lang schüttelst, stampfst oder liegst. Tue, was auch immer dir intuitiv in den Sinn kommt.';
  String get descriptionRelaxation009 =>
      'schaue 60 Sekunden lang so schnell du kannst (nur) mit den Augen hin und her.';
  String get descriptionRelaxation010 => 'summe zwischendurch Klänge und spüre sie (körperlich).';
  String get descriptionRelaxation011 => 'setze dich im Überaum zuerst hin, um 5 Minuten nichts zu tun.';
  String get descriptionRelaxation012 =>
      'mache diese Augenübung: Schaue mehrfach nach links, rechts, oben und unten. Deine Augen werden es dir danken!';
  String get descriptionRelaxation013 => 'achte besonders auf deine Atmung.';
  String get descriptionRelaxation014 =>
      'nimm eine Phrase mit Video auf und achte beim Anschauen auf unnötige Bewegungen direkt vor dem Beginn des Spielens.';
  String get descriptionRelaxation015 =>
      'nimm dein Spielen mit Video auf und achte beim Anschauen besonders auf deine Gesichtszüge während und zwischen dem Spielen.';
  String get descriptionRelaxation016 => 'nimm dir vorher 3 Minuten Zeit und lausche deinem eigenen Atem.';
  String get descriptionRelaxation017 => 'achte hin und wieder auf deinen Herzschlag.';
  String get descriptionRelaxation018 =>
      'lege dich auf den Boden und spanne alle Muskeln gleichzeitig für 10 Sekunden lang so stark wie möglich an. Spürst du eine Veränderung zum Ursprungszustand?';
  String get descriptionSelfCare001 =>
      'beginne dein Üben mit Körperübungen: Klopfmassage, Nacken kneten, Erdung, Dehnung.';
  String get descriptionSelfCare002 =>
      'frage dich: Wie geht es mir? Drücke diese Emotion auf deinem Instrument/mit deiner Stimme aus. Improvisiere, mache einfach irgendwelche Klänge, oder spiele ein passendes Stück.';
  String get descriptionSelfCare003 =>
      'frage dich: Was möchte ich ausdrücken? Wer bin ich und was möchte ich der Welt geben? Verkörpere das spontan intuitiv auf deinem Instrument/mit deiner Stimme. Improvisiere, mache einfach irgendwelche Klänge, oder spiele ein passendes Stück.';
  String get descriptionSelfCare004 =>
      'mache 10 Sekunden Pause, wenn du merkst, dass die Stelle, die du gerade übst, wieder schlechter wird. (Dein Gehirn lernt in den Pausen!)';
  String get descriptionSelfCare005 =>
      'achte auf deinen Körper: Schreibe dir Körperteile (Nacken, Schultern, Bauch, Füße, Wirbelsäule...) auf einen Zettel und achte während einer Phrase nacheinander auf die verschiedenen Bereiche.';
  String get descriptionSelfCare006 => 'überlege dir, welches Buch du heute Abend zum Einschlafen lesen willst.';
  String get descriptionSelfCare007 =>
      'überlege dir, welches Buch dich beim Üben am meisten weiterbringt und lade dich ein, es zu besorgen und zu lesen.';
  String get descriptionSelfCare008 => 'plane für heute deine ideale Bettgehzeit.';
  String get descriptionSelfCare009 => 'plane für heute, wann du Feierabend hast.';
  String get descriptionSelfCare010 => 'überlege dir, wie du die Zeit beim Üben ohne digitale Geräte gestalten kannst.';
  String get descriptionSelfCare011 => 'trinke vorher einen halben Liter Wasser.';
  String get descriptionSelfCare012 => 'frage dich, ob du heute ausschlafen konntest. Wenn nicht, versuche es morgen.';
  String get descriptionSelfCare013 => 'beiße vorher in eine Zitrone.';
  String get descriptionSelfCare014 => 'trinke einen Ingwershot oder esse rohen Ingwer.';
  String get descriptionSelfCare015 => 'mache vorher eine geführte Meditation.';
  String get descriptionSelfCare016 =>
      'überlege, nach welcher Mahlzeit du dich energiegeladen fühlst und nach welcher du zu müde bist, um zu üben.';
  String get descriptionSelfCare017 =>
      'überlege, ob du den Tag mit Sport angefangen hast. Wenn nicht, probiere es morgen.';
  String get descriptionSelfCare018 =>
      'mache einen Spaziergang ohne elektronische Geräte. Dein Gehirn braucht Langeweile, um sich zu sortieren. Lasse die Gedanken zu und beobachte sie nur.';
  String get descriptionSelfCare019 =>
      'überlege dir, wie du dir mehrere Stunden vor deinem nächsten Auftritt Zeit für dich nehmen und dafür sorgen kannst, dass du dich wohlfühlst.';
  String get descriptionSelfCare020 =>
      'achte darauf, deine Bedürfnisse vor dem Üben erfüllt zu haben oder in den Pausen zu erfüllen.';
  String get descriptionSelfCare021 => 'merke, wenn dein Kopf voll ist, und mache dann eine Pause.';
  String get descriptionSelfCare022 =>
      'plane, wann du einen Pausentag einlegen wirst (Empfehlung: einmal pro Woche) und trage ihn rot in den Kalender ein.';
  String get descriptionSelfCare023 => 'schalte vorher dein Smartphone in den Flugmodus oder schalte das Internet aus.';
  String get descriptionSelfCare024 => 'schreibe vorher und währenddessen alle übefremden Gedanken auf.';
  String get descriptionSelfCare025 =>
      'beginne heute mit ganz langen Tönen (Schlagzeug: Wirbel). Davon sollte mindestens einer dynamisch konstant, einer mit crescendo, einer mit diminuendo und einer sowohl aufsteigend als anschließend wieder abfallend sein.';
  String get descriptionSelfCare026 => 'spiele zu guter Letzt noch einmal dein Lieblingsstück oder Lieblingslied.';
  String get descriptionSelfCare027 =>
      'mache bei der Hälfte der Übezeit 5 Minuten Pause und benutze sie, indem du zum Beispiel ein Glas Wasser trinkst, lüftest oder dich bewegst.';
  String get descriptionSelfCare028 =>
      'schaue dich um: Ist der Raum ordentlich? Wenn nicht, kannst du ihn mit wenig Aufwand aufräumen?';
  String get descriptionSelfCare029 =>
      'überlege dir, wo du effektiv üben kannst: Zu Hause oder woanders? Übst du gern möglichst am selben Ort oder tut dir Abwechslung gut?';
  String get descriptionSelfCare030 => 'fokussiere dich allein auf den Spaß am Üben.';
  String get descriptionTeam001 => 'frage eine Person, ob sie dich beim Üben beobachtet. Welche Übetipps gibt sie dir?';
  String get descriptionTeam002 => 'schildere jemandem eine Übe-Baustelle und forscht gemeinsam nach Lösungen.';
  String get descriptionTeam003 =>
      'schildere jemandem ein Ziel und überlegt gemeinsam nach Wegen, wie man dorthin kommen könnte.';
  String get descriptionTeam004 =>
      'überlasse jemand anderem die Führung: Er/sie leitet dich (durch Ansagen oder Vormachen) an, wie du übst.';
  String get descriptionTeam005 =>
      'hole dir jemanden hinzu, der dir Grundtöne oder andere passende Liegetöne (Orgelpunkt) deines Stückes spielt. Spiele mit wachen Ohren dein Stück dazu.';
  String get descriptionTeam006 => 'schaue einer anderen Person beim Üben zu und schreibe auf, was dich inspiriert.';
  String get descriptionTeam007 => 'hole dir eine Person hinzu, (die du gerne magst) und mache mit ihr Kammermusik.';
  String get descriptionTeam008 => 'spiele mit jemandem gemeinsam dein Stück.';
  String get descriptionTeam009 => 'sprich mit jemand anderem über Übetiefs.';
  String get descriptionTeam010 =>
      'lass dir von einer anderen Person ihre Hände auf deine Schultern legen. Achtet gemeinsam darauf, wo du noch Spannungen loslassen kannst.';
  String get descriptionTeam011 => 'bitte jemanden, dich abzulenken, während du spielst.';
  String get descriptionTeam012 =>
      'bitte jemanden, beim Mitspielen zu einer Aufnahme manchmal etwas nach vorne zu spulen.';
  String get descriptionTeam013 =>
      'bitte jemanden, während du spielst zu greifen oder eine von beiden Händen zu übernehmen, je nach Instrument.';
  String get descriptionTeam014 => 'bitte jemanden, für 15 min kommentarlos deinem Üben zu lauschen.';
  String get descriptionTeam015 =>
      'erzähle anschließend jemandem, was und wie du heute geübt hast. Vielleicht bekommst du unerwartete Tipps?';
  String get descriptionTeam016 => 'finde jemanden zum gemeinsamen Üben.';
  String get descriptionTeam017 => 'nimm ein Video von dir auf und schicke es einer befreundeten Person.';
  String get descriptionTeam018 =>
      'spiele ein Stück oder Lied, das du gut kannst, einer Person vor, die du gern magst.';
  String get descriptionVision001 =>
      'lege dich hin und bleibe so lange liegen, bis du genau weißt, warum es sich für dich lohnt, aufzustehen und dein Instrument in die Hand zu nehmen.';
  String get descriptionVision002 =>
      'überlege dir, warum du morgen früh aufstehen willst. Was ist so anregend, dass du schon vor dem Wecker aufwachen wirst, weil du dich so sehr darauf freust?';
  String get descriptionVision003 =>
      'notiere dir ein Tagesziel. Etwas, das du leicht erreichen kannst und versuchst, in der ersten Tageshälfte zu erledigen. So fühlt sich die zweite Tageshälfte viel freier an.';
  String get descriptionVision004 =>
      'stell dich vor einen Spiegel und halte dir eine Motivationsrede, in der du begeistert erzählst, was du alles schon geschafft hast, dass du deshalb stolz auf dich bist, warum genau dieser Weg der richtige für dich ist und was deine Augen daran zum Leuchten bringen.';
  String get descriptionVision005 =>
      'notiere dir euphorische Schlüsselmomente aus der Vergangenheit. Haben sie eine Gemeinsamkeit? Was genau hat deine Augen zum Leuchten gebracht?';
  String get descriptionVision006 => 'überlege dir vorher dein Ziel und halte es währenddessen präsent.';

  String get filterAllCategories => 'Alle Kategorien';
  String get filterBookmarkDisable => 'Deaktiviere Lesezeichenfilter';
  String get filterBookmarkEnable => 'Aktiviere Lesezeichenfilter';
  String get filterSelectCategory => 'Kategorie wählen';

  String get flashCard => 'Übetipp';
  String get flashCardAddBookmark => 'Lesezeichen hinzufügen';
  String get flashCardRemoveBookmark => 'Lesezeichen entfernen';
  String get flashCardTitle => 'Wenn du heute übst,';

  String get flashCardsPageTitle => 'Übungstipps';
}
