import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_session.dart';

/// ApiHelper class to handle API requests with automatic user_id inclusion
/// This utility makes it easy to make authenticated API calls throughout the app
class ApiHelper {
  static const String baseUrl = 'http://34.93.230.130:5001';

  /// Make a GET request with automatic user_id inclusion
  static Future<http.Response> get(String endpoint, {Map<String, String>? additionalHeaders}) async {
    final userId = await UserSession.getUserId();
    
    final headers = {
      'Content-Type': 'application/json',
      if (userId != null) 'user_id': userId,
      ...?additionalHeaders,
    };

    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }

  /// Make a POST request with automatic user_id inclusion
  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
    bool includeUserIdInBody = false,
  }) async {
    final userId = await UserSession.getUserId();
    
    final headers = {
      'Content-Type': 'application/json',
      if (userId != null) 'user_id': userId,
      ...?additionalHeaders,
    };

    Map<String, dynamic> requestBody = body ?? {};
    
    // Optionally include user_id in the request body
    if (includeUserIdInBody && userId != null) {
      requestBody['user_id'] = userId;
    }

    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(requestBody),
    );
  }

  /// Make a PUT request with automatic user_id inclusion
  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
    bool includeUserIdInBody = false,
  }) async {
    final userId = await UserSession.getUserId();
    
    final headers = {
      'Content-Type': 'application/json',
      if (userId != null) 'user_id': userId,
      ...?additionalHeaders,
    };

    Map<String, dynamic> requestBody = body ?? {};
    
    // Optionally include user_id in the request body
    if (includeUserIdInBody && userId != null) {
      requestBody['user_id'] = userId;
    }

    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(requestBody),
    );
  }

  /// Make a DELETE request with automatic user_id inclusion
  static Future<http.Response> delete(String endpoint, {Map<String, String>? additionalHeaders}) async {
    final userId = await UserSession.getUserId();
    
    final headers = {
      'Content-Type': 'application/json',
      if (userId != null) 'user_id': userId,
      ...?additionalHeaders,
    };

    return await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }

  /// Get current user_id for manual API operations
  static Future<String?> getCurrentUserId() async {
    return await UserSession.getUserId();
  }

  /// Check if user is authenticated (has user_id)
  static Future<bool> isAuthenticated() async {
    final userId = await UserSession.getUserId();
    return userId != null && userId.isNotEmpty;
  }

  /// Upload image file to extract-card endpoint
  static Future<http.Response> uploadImageForCardExtraction(
    List<int> imageBytes,
    String fileName,
  ) async {
    final userId = await UserSession.getUserId();
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/extract-card'),
    );

    // Add user_id to the request
    request.fields['user_id'] = userId;

    // Add the image file
    request.files.add(
      http.MultipartFile.fromBytes(
        'image', // field name expected by the backend
        imageBytes,
        filename: fileName,
      ),
    );

    // Send the request
    var streamedResponse = await request.send();
    
    // Convert streamed response to regular response
    return await http.Response.fromStream(streamedResponse);
  }
}