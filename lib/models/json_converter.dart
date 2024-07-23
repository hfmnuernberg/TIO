import 'package:tiomusic/util/constants.dart';

const Map<String, String> namechangingKeys = {
  "islandSessionID": "islandToolID",
  "sessionCounter": "toolCounter",
  "notes": "projects",
  "unsavedMetronomeSession": "quickMetronomeTool",
  "unsavedTunerSession": "quickTunerTool",
  "unsavedMediaPlayerSession": "quickMediaPlayerTool",
  "unsavedPianoSession": "quickPianoTool",
  "visitedSessionsCounter": "visitedToolsCounter",
  "audioFilePath": "relativePath",
  "path": "relativePath",
};

// TODO: can we completely remove this converter?
// can we assume that no user still has an old version now?

abstract class CustomJsonConverter {
  static void renameKeys(Map<String, dynamic> jsonMap) {
    _iterateMap(jsonMap);
  }

  static void _iterateMap(Map map) {
    namechangingKeys.forEach((oldKey, newKey) {
      if (map.containsKey(oldKey)) {
        map[newKey] = map[oldKey];
        map.remove(oldKey);
      }
    });

    map.forEach((key, value) {
      if (value is Map) {
        _iterateMap(value);
      } else if (value is List) {
        _iterateList(value);
      }
    });
  }

  static void _iterateList(List list) {
    for (var entry in list) {
      if (entry is Map) {
        _iterateMap(entry);
      } else if (entry is List) {
        _iterateList(entry);
      }
    }
  }

  static void checkIfJsonMapContainsOldRhythmVersion(Map<String, dynamic> jsonMap) {
    for (MapEntry<String, dynamic> mapEntry in jsonMap.entries) {
      if (mapEntry.key == 'projects') {
        List listOfNoteMaps = mapEntry.value;
        for (Map<String, dynamic> noteMap in listOfNoteMaps) {
          if (noteMap.containsKey('_blocks')) {
            List listOfBlockMaps = noteMap['_blocks'];
            for (Map<String, dynamic> blockMap in listOfBlockMaps) {
              if (blockMap.containsKey('_barsJson')) {
                _convertOldToNewBars(blockMap);
              }
            }
          }
        }
      } else if (mapEntry.key == 'quickMetronomeTool') {
        Map<String, dynamic> metronomeSessionMap = mapEntry.value;
        if (metronomeSessionMap.containsKey('_barsJson')) {
          _convertOldToNewBars(metronomeSessionMap);
        }
      }
    }
  }

  static void _convertOldToNewBars(Map<String, dynamic> metronomeBlockMap) {
    List<Map<String, dynamic>> listOfGroups = List.empty(growable: true);

    for (Map<String, dynamic> bar in metronomeBlockMap['_barsJson']) {
      String keyID = MetronomeParams.getNewKeyID();
      List polyBeats = List.empty();

      List beats;
      if (bar['isBreak']) {
        beats = List.filled(bar['numBeats'], "Muted");
      } else {
        beats = List.filled(bar['numBeats'], "Unaccented");
        if (beats.isNotEmpty) {
          beats[0] = "Accented";
        }
      }

      listOfGroups.add({
        "keyID": keyID,
        "beats": beats,
        "polyBeats": polyBeats,
        "beatLen": bar['beatLen'],
      });
    }

    MapEntry<String, dynamic> newRhythmGroupsEntry = MapEntry("rhythmGroups", listOfGroups);
    metronomeBlockMap.remove('_barsJson');
    metronomeBlockMap.addEntries([newRhythmGroupsEntry]);
  }
}
