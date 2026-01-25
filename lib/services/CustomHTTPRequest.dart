import 'dart:convert';
import 'dart:io';

import 'package:drms/screens/login_screen.dart';
import 'package:drms/services/session.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class CustomHTTPRequest {
  CustomHTTPRequest();

  // Common method to show loader dialog
  Future<void> _showLoader({bool canPop = false}) async {
    if (Get.overlayContext == null) return;

    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: canPop,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  // Common method to hide loader dialog
  void _hideLoader() {
    if (Get.isDialogOpen == true && Get.overlayContext != null) {
      Navigator.of(Get.overlayContext!).pop();
    }
  }

  // Common HttpClient / IOClient creator
  IOClient _buildIOClient() {
    final HttpClient httpClient = HttpClient()
      // TODO: REMOVE THIS IN PRODUCTION. Use proper certificates.
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    return IOClient(httpClient);
  }

  // Common header builder (for authenticated requests)
  Future<Map<String, String>> _buildAuthHeaders() async {
    final String? token = await Session.instance.getToken();

    return <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };
  }

  // Common auth error handler
  void _handleAuthError(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      Session.instance.logoutUserSession();
      Get.offAll(() => LoginScreen(), transition: Transition.leftToRightWithFade);
    }
  }

  Future<http.Response> post(String url, String body, {bool displayDialog = false}) async {
    if (displayDialog) {
      await _showLoader();
    }

    final IOClient ioClient = _buildIOClient();
    final headers = await _buildAuthHeaders();

    final http.Response response = await ioClient.post(Uri.parse(url), body: body, headers: headers);

    _handleAuthError(response.statusCode);

    if (displayDialog) {
      _hideLoader();
    }

    return response;
  }

  Future<http.Response> get(String url, {bool displayDialog = false}) async {
    if (displayDialog) {
      await _showLoader();
    }

    final IOClient ioClient = _buildIOClient();
    final headers = await _buildAuthHeaders();

    final http.Response response = await ioClient.get(Uri.parse(url), headers: headers);

    _handleAuthError(response.statusCode);

    if (displayDialog) {
      _hideLoader();
    }

    return response;
  }

  Future<Map<String, dynamic>> getLocation(String url, double lat, double lon) async {
    final IOClient ioClient = _buildIOClient();

    final uri = Uri.parse('$url?format=json&lat=$lat&lon=$lon');

    final http.Response response = await ioClient.get(uri, headers: {HttpHeaders.contentTypeHeader: 'application/json'});

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<http.Response> publicPost(String url, String body, {bool displayDialog = false}) async {
    if (displayDialog) {
      await _showLoader();
    }

    final IOClient ioClient = _buildIOClient();

    // If this truly is public, no token; if semi-public, inject from config/remote, not hard-coded.
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
      // TODO: move this token to secure config / remote, not hard-coded
      'authToken': 'aa9630752a305d95bb14cd8982506d628420eae9218da47f7e8e967d69ae5778',
    };

    final http.Response response = await ioClient.post(Uri.parse(url), body: body, headers: headers);

    _handleAuthError(response.statusCode);

    if (displayDialog) {
      _hideLoader();
    }

    return response;
  }
}
