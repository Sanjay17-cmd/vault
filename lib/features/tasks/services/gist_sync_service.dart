import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/task_model.dart';

class GistSyncService {
  static const String _gistFileName = 'remindly.json';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('remindly_token');
  }

  static Future<String?> _getGistId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('remindly_gist_id');
  }

  static Future<void> _setGistId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('remindly_gist_id', id);
  }

  static Future<List<TaskModel>?> syncFromGist(List<TaskModel> localTasks) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return null;

    String? gistId = await _getGistId();
    if (gistId == null) {
      gistId = await _findOrCreateGist(token);
      if (gistId != null) {
        await _setGistId(gistId);
      } else {
        return null;
      }
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/gists/$gistId'),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final files = data['files'];
        if (files != null && files[_gistFileName] != null) {
          final content = files[_gistFileName]['content'];
          if (content != null) {
            final List<dynamic> remoteJson = json.decode(content);
            final List<TaskModel> remoteTasks = remoteJson.map((t) => TaskModel.fromJson(t)).toList();
            
            // Merge: remote wins for existing IDs, keep local-only items
            final remoteMap = {for (var t in remoteTasks) t.id: t};
            final localOnly = localTasks.where((t) => !remoteMap.containsKey(t.id)).toList();
            
            return [...remoteTasks, ...localOnly];
          }
        }
      }
    } catch (e) {
      debugPrint('Sync from Gist error: $e');
    }
    return null;
  }

  static Future<bool> pushToGist(List<TaskModel> tasks) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return false;

    String? gistId = await _getGistId();
    if (gistId == null) {
      gistId = await _findOrCreateGist(token);
      if (gistId != null) {
        await _setGistId(gistId);
      } else {
        return false;
      }
    }

    try {
      final content = json.encode(tasks.map((t) => t.toJson()).toList());
      final response = await http.patch(
        Uri.parse('https://api.github.com/gists/$gistId'),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'files': {
            _gistFileName: {
              'content': content,
            }
          }
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Push to Gist error: $e');
      return false;
    }
  }

  static Future<String?> _findOrCreateGist(String token) async {
    try {
      // Search existing gists
      final res = await http.get(
        Uri.parse('https://api.github.com/gists'),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> gists = json.decode(res.body);
        for (var gist in gists) {
          final files = gist['files'];
          if (files != null && files.containsKey(_gistFileName)) {
            return gist['id'];
          }
        }
      }

      // Create new gist
      final createRes = await http.post(
        Uri.parse('https://api.github.com/gists'),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'description': 'Remindly tasks sync for Vault',
          'public': false,
          'files': {
            _gistFileName: {
              'content': '[]',
            }
          }
        }),
      );

      if (createRes.statusCode == 201) {
        final newGist = json.decode(createRes.body);
        return newGist['id'];
      }
    } catch (e) {
      debugPrint('Find or Create Gist error: $e');
    }
    return null;
  }
}
