import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_package;
import 'package:path_provider/path_provider.dart';
import 'package:tiomusic/models/file_references.dart';
import 'dart:convert';

import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/rust_api/ffi.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:wav/wav.dart';

// In App File Directory
// The files of the user (audio and images) are stored in the "media" folder

// - Documents (get it with getApplicationDocumentsDirectory()) (json_data.txt lives here)
// ---- media

abstract class FileIO {
  static Future<String> get _appDirectory async {
    return (await getApplicationDocumentsDirectory()).path;
  }

  static String get _mediaFolder => "media";

  // this is called in main when starting the app
  static Future createMediaDirectory() async {
    // create the media folder if it does not exist
    final path = await _appDirectory;
    await Directory("$path/$_mediaFolder").create(recursive: true);
  }

  static Future<String> getAbsoluteFilePath(String relativeFilePath) async {
    String appDirectory = await _appDirectory;
    return "$appDirectory/$relativeFilePath";
  }

  static Future<String> getRelativeFilePath(String absoluteFilePath) async {
    String appDirectory = await _appDirectory;
    return absoluteFilePath.substring(appDirectory.length + 1);
  }

  // allocate new file
  static Future<File> _allocateNewFileInMediaFolder(String fileName) async {
    String absolutePath = await getAbsoluteFilePath("$_mediaFolder/$fileName");
    return File(absolutePath);
  }

  // get existing file or null
  static Future<File?> _getExistingFile(String relativeFilePath) async {
    String path = await getAbsoluteFilePath(relativeFilePath);
    var file = File(path);
    if (await file.exists()) {
      return file;
    } else {
      debugPrint("File not found! At path: $path");
      return null;
    }
  }

  // allocate local json file
  static Future<File> get _localJsonFile async {
    final path = await _appDirectory;
    return File('$path/json_data.txt');
  }

  // returns the relative path of the new file
  // returns null if we don't accept the file format
  static Future<String?> saveFileToAppStorage(BuildContext context, dynamic fileToSave, String newFileName,
      String? relativePathOfPreviousFile, ProjectLibrary projectLibrary,
      {List<String>? acceptedFormats, bool asString = false}) async {
    // check if file exists / can be accessed
    if (!await fileToSave.exists()) {
      // try again after delay, maybe file needs time to download
      await Future.delayed(const Duration(milliseconds: 500));

      if (!await fileToSave.exists()) {
        if (context.mounted) {
          await showFileNotAccessibleDialog(context, fileName: fileToSave.path);
        }
        return null;
      }
    }

    // this delay seems to prevent the following error when the "fileToSave" is not found immediately:
    // flutter: media player load wav failed: unsupported feature: core (probe): no suitable format reader found
    await Future.delayed(const Duration(milliseconds: 100));

    // check if we accept this file format
    var extension = path_package.extension(fileToSave.path).toLowerCase();
    if (acceptedFormats != null) {
      if (!acceptedFormats.contains(extension)) {
        if (context.mounted) {
          await showFormatNotSupportedDialog(context, extension);
        }
        return null;
      }
    }

    var nameAndExtension = newFileName + extension;

    // check if file with this name already exists
    int increment = 1;
    while (await _getExistingFile("$_mediaFolder/$nameAndExtension") != null) {
      newFileName = "${newFileName}_$increment";
      increment++;
      nameAndExtension = newFileName + extension;
    }

    final file = await _allocateNewFileInMediaFolder(nameAndExtension);
    final relativePath = await getRelativeFilePath(file.path);

    FileReferences.increaseFileReference(relativePath);
    if (relativePathOfPreviousFile != null) {
      FileReferences.decreaseFileReference(relativePathOfPreviousFile, projectLibrary);
    }

    if (asString) {
      await file.writeAsString(await fileToSave.readAsString());
    } else {
      await file.writeAsBytes(await fileToSave.readAsBytes());
    }

    return relativePath;
  }

  // saves recording to file
  // returns the relative path of the new file
  static Future<String?> writeSamplesToWaveFile(Float64List samples, String newFileName,
      String? relativePathOfPreviousFile, ProjectLibrary projectLibrary) async {
    var nameAndExtension = "$newFileName.wav";

    // check if file with this name already exists
    int increment = 1;
    while (await _getExistingFile("$_mediaFolder/$nameAndExtension") != null) {
      newFileName = "${newFileName}_$increment";
      increment++;
      nameAndExtension = "$newFileName.wav";
    }

    List<Float64List> listOfChannels = [samples];
    var wavFile = Wav(listOfChannels, await rustApi.getSampleRate(), WavFormat.float32);
    var relativePath = "$_mediaFolder/$nameAndExtension";

    await wavFile.writeFile(await getAbsoluteFilePath(relativePath));

    FileReferences.increaseFileReference(relativePath);
    if (relativePathOfPreviousFile != null) {
      FileReferences.decreaseFileReference(relativePathOfPreviousFile, projectLibrary);
    }

    if (await _getExistingFile(relativePath) == null) {
      return null;
    } else {
      return relativePath;
    }
  }

  // reads data from json file and returning a json String
  static Future<String?> readJsonDataFromSave() async {
    try {
      final file = await _localJsonFile;
      final jsonString = await file.readAsString();

      return jsonString;
    } catch (e) {
      debugPrint("Error getting the jsonString from the json file: $e");
      return null;
    }
  }

  // saves data of the ProjectLibrary to the json file
  static void saveProjectLibraryToJson(ProjectLibrary projectLibrary) async {
    Map<String, dynamic> jsonMap = projectLibrary.toJson();
    String jsonString = jsonEncode(jsonMap);

    (await _localJsonFile).writeAsString(jsonString);
  }

  // deletes the json file
  static void deleteLocalJsonFile() async {
    try {
      final file = await _localJsonFile;

      if (await file.exists()) {
        await file.delete();
        debugPrint("Local json file deleted!");
      }
    } catch (e) {
      debugPrint("Error: Could not delete local json file: $e");
    }
  }

  // looking for file and delets it if it exists
  static void deleteFile(String relativePath) async {
    final file = File(await getAbsoluteFilePath(relativePath));
    if (await file.exists()) {
      await file.delete();
    } else {
      throw Exception("Could not delete file. File not found at path: $relativePath");
    }
  }

  static Future<List<FileSystemEntity>> getAllMediaFiles() async {
    // the files in the media folder should only be media files, so we don't need to check which format they are
    final mediaDir = Directory(await getAbsoluteFilePath(_mediaFolder));
    return await mediaDir.list().toList();
  }

  // this is to prevent a conflict between the path package and flutter packages in other files
  static String getFileName(String path) {
    return path_package.basename(path);
  }

  static String getFileNameWithoutExtension(String path) {
    return path_package.basenameWithoutExtension(path);
  }
}
