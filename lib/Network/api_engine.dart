import 'package:http/http.dart' as HTTP;
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../Screens/Login/login.dart';
import '../Utils/app_alerController.dart';
import '../Utils/appdata_helper.dart';

enum ApiRequestType { GET, POST, PUT, DELETE }
enum ApiResponseStatus { SUCCESS, FAILED }

class ApiResponse {
  ApiResponseStatus status;
  Exception? exception;
  String message;
  dynamic data;

  ApiResponse(this.status, this.data, {this.exception, this.message = ''});
}

class ApiEngine {
  final _jsonEncoder = const JsonEncoder();
  bool _showIndicator = false;

  Future<Map<String, String>> _preparedHeaders(bool isWithToken, bool isWithFireBaseToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print('Token: ${token}');
    String? firebaseToken= prefs.getString('fcmToken');
    var headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    if (isWithToken) {
      {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    if(isWithFireBaseToken){
      {
        headers['firebasetoken']= '$firebaseToken';
      }
    }
    return headers;
  }

  Future<ApiResponse> performRequest(ApiRequestType requestType, String url,
      {dynamic payload, bool isPayloadNeed = false, bool isWithToken=false,
        bool isWithFireBaseToken=false,
        bool showIndicator= true, String token=''})async{
    assert(url.isNotEmpty, 'Url must not be empty or null');
    if(requestType == ApiRequestType.POST || requestType == ApiRequestType.PUT){
      if(isPayloadNeed){
        assert(payload != null, 'For post and put request you must send payload');
      }
    }
    var headers= await _preparedHeaders(isWithToken, isWithFireBaseToken);
    _showIndicator=showIndicator;
    if(_showIndicator){
      AppAlertController().showProgressIndicator();
    }
    if(requestType == ApiRequestType.POST || requestType == ApiRequestType.PUT){
      if(payload != null){
      }
    }
    try{
      var actualUrl = Uri.parse(url);
      print('Url : ${actualUrl}');
      switch(requestType){
        case ApiRequestType.GET:
          var response= await HTTP.get(actualUrl, headers: headers);

          return handleResponse(response);
        case ApiRequestType.PUT:
          var body;
          var response;
          if(payload != null){
            body= jsonEncode(payload);
            response= await HTTP.put(actualUrl, headers: headers, body: body);
          }
          else{
            response= await HTTP.put(actualUrl, headers: headers);
          }
          return handleResponse(response);
        case ApiRequestType.POST:
          var body;
          var response;
          if(payload != null){
            body = jsonEncode(payload);
            response= await HTTP.post(actualUrl, headers: headers, body: body);
          }
          else{
            response= await HTTP.post(actualUrl, headers: headers);
          }
          return handleResponse(response);
        case ApiRequestType.DELETE:
          var body;
          var response;
          if(payload != null){
            body = _jsonEncoder.convert(payload);
            response= await HTTP.delete(actualUrl, headers: headers, body: body);
          }
          else{
            response= await HTTP.delete(actualUrl, headers: headers);
          }
          return handleResponse(response);
      }
    }
    catch(exception){
      BuildContext? ccc= AppDataHelper.rootContext;
      return commonExceptionResponse(exception);
    }
  }
  ApiResponse commonExceptionResponse(dynamic exception){
    var status= ApiResponseStatus.FAILED;
    var apiResponse= ApiResponse(status, null, exception: exception is Exception ? exception : Exception(exception.toString()));
    return apiResponse;
  }

  ApiResponse handleResponse(HTTP.Response response){
    AppAlertController().hideProgressIndicator();
    
    dynamic data;
    try {
      data = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e) {
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = response.body;
      }
    }

    String getMessage(dynamic data) {
      if (data is Map) {
        if (data['status'] is Map && data['status']['message'] != null) {
          return data['status']['message'].toString();
        }
        if (data['message'] != null) {
          return data['message'].toString();
        }
      }
      return "";
    }

    switch (response.statusCode){
      case 200:
      case 201:
      case 202:
      case 204:
        var status = ApiResponseStatus.SUCCESS;
        var apiResponse= ApiResponse(status, data);
        return apiResponse;

      case 401:
        var status = ApiResponseStatus.FAILED;
        _handleUnauthorized();
        var exception = Exception(getMessage(data).isNotEmpty ? getMessage(data) : 'Session expired. Please login again.');
        var apiResponse = ApiResponse(status, data, exception: exception);
        return apiResponse;

      case 502:
      case 504:
        var status= ApiResponseStatus.FAILED;
        var message = getMessage(data);
        var exception= Exception(message.isNotEmpty ? message : 'Server Error');
        var apiResponse= ApiResponse(status, data, exception: exception);
        return apiResponse;

      case 500:
        var status = ApiResponseStatus.FAILED;
        var exception= Exception('Requested resource was not found on this server');
        var apiResponse= ApiResponse(status, data, exception: exception);
        return apiResponse;
      case 404:
        var status = ApiResponseStatus.FAILED;
        var exception =
        Exception("The requested resource was not found on this server");
        var apiResponse = ApiResponse(status, data, exception: exception);
        return apiResponse;

      default:
        var status= ApiResponseStatus.FAILED;
        var message = getMessage(data);
        var exception= Exception(message.isNotEmpty ? message : 'An error occurred');
        var apiResponse= ApiResponse(status, data, exception: exception);
        return apiResponse;
    }
  }

  void _handleUnauthorized() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userId');
    prefs.remove('isAdmin');

    final navContext = AppDataHelper.navKey.currentContext;
    if (navContext != null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushAndRemoveUntil(
          navContext,
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
        );
      });
    }
  }
}
