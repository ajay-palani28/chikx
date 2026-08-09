import 'api_engine.dart';

typedef SuccessBlock = void Function(dynamic);
typedef FailureBlock<T> = void Function(Exception exception, T? data);

class ApiMethods {
  Future createAccount({
    required payload,
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
      ApiRequestType.POST,
      '${ApiManager().create_account}',
      payload: payload,
      showIndicator: true,
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  Future loginUser({
    required payload,
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
      ApiRequestType.PUT,
      '${ApiManager().login}',
      payload: payload,
      showIndicator: true,
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  Future addFoods({
    required payload,
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
      ApiRequestType.POST,
      '${ApiManager().addFood}',
      payload: payload,
      showIndicator: true,
      isWithToken: true
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  Future updateFood({
    required String foodId,
    required payload,
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
      ApiRequestType.PUT,
      '${ApiManager().adminUpdateFood}/$foodId',
      payload: payload,
      showIndicator: true,
      isWithToken: true
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  Future deleteFood({
    required String foodId,
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
      ApiRequestType.DELETE,
      '${ApiManager().adminDeleteFood}$foodId',
      showIndicator: true,
      isWithToken: true
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  Future getAdminUsers({
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
      ApiRequestType.GET,
      ApiManager().adminUsers,
      showIndicator: true,
      isWithToken: true,
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  Future adminDeleteUser({
    required String userId,
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
      ApiRequestType.DELETE,
      '${ApiManager().adminDeleteUser}/$userId',
      showIndicator: true,
      isWithToken: true,
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  Future getFoods({
    var food_category,
    var search,
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    String query = "";
    if (food_category != null) {
      query += "?food_category=$food_category";
    }
    if (search != null) {
      query += query.isEmpty ? "?search=$search" : "&search=$search";
    }

    var response = await ApiEngine().performRequest(
      ApiRequestType.GET,
      '${ApiManager().adminGetFood}$query',
      showIndicator: false,
      isWithToken: true
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  Future getAppVersion({
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
      ApiRequestType.GET,
      '${ApiManager().appVersion}',
      showIndicator: false,
      isWithToken: false,
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  Future profile({
    var userId,
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
        ApiRequestType.GET,
        '${ApiManager().userProfile}/$userId',
        showIndicator: false,
        isWithToken: true
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  Future profileUpload({
    var userId,
    required payload,
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
        ApiRequestType.PUT,
        '${ApiManager().userProfile}/$userId',
        payload: payload,
        showIndicator: false,
        isWithToken: true
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  Future addToFavorite({
    required payload,
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
        ApiRequestType.POST,
        '${ApiManager().putFavoriteFood}',
        payload: payload,
        showIndicator: true,
        isWithToken: true
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  Future getFavorite({
    required var userId,
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
        ApiRequestType.GET,
        '${ApiManager().getFavoriteFood}?userId=$userId',
        showIndicator: true,
        isWithToken: true
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  Future deleteFavoriteFood({
    required var foodId,
    required var userId,
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
        ApiRequestType.DELETE,
        '${ApiManager().deleteFavoriteFood}/$foodId?userId=$userId',
        showIndicator: true,
        isWithToken: true
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  // Chat APIs
  Future sendMessage({
    required var payload,
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
        ApiRequestType.POST,
        ApiManager().sendMessage,
        payload: payload,
        showIndicator: false,
        isWithToken: true
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  Future getMessages({
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
        ApiRequestType.GET,
        ApiManager().getMessages,
        showIndicator: false,
        isWithToken: true
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  // Admin Chat APIs
  Future getAdminConversations({
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
        ApiRequestType.GET,
        ApiManager().adminConversations,
        showIndicator: false,
        isWithToken: true
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  Future getAdminConversationByUser({
    required var userId,
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
        ApiRequestType.GET,
        '${ApiManager().adminChatByUser}/$userId',
        showIndicator: false,
        isWithToken: true
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  Future adminSendMessage({
    required var payload,
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
        ApiRequestType.POST,
        ApiManager().adminSendMessage,
        payload: payload,
        showIndicator: false,
        isWithToken: true
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  Future forgotPassword({
    required var payload,
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
      ApiRequestType.POST,
      '${ApiManager().forgotPassword}',
      payload: payload,
      showIndicator: true,
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  Future verifySecurityAnswers({
    required var payload,
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
      ApiRequestType.POST,
      '${ApiManager().verifySecurityAnswers}',
      payload: payload,
      showIndicator: true,
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  Future getPaymentHistory({
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
      ApiRequestType.GET,
      ApiManager().paymentHistory,
      showIndicator: false,
      isWithToken: true,
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  // Admin Deals APIs
  Future getDeals({
    String? status,
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
      ApiRequestType.GET,
      '${ApiManager().adminDeals}${status != null ? "?status=$status" : ""}',
      showIndicator: true,
      isWithToken: true,
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  Future upsertDeal({
    required String dealId,
    required dynamic payload,
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
      ApiRequestType.PUT,
      '${ApiManager().adminDeals}/$dealId',
      payload: payload,
      showIndicator: true,
      isWithToken: true,
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  Future deleteDeal({
    required String dealId,
    required SuccessBlock successBlock,
    required FailureBlock failureBlock,
  }) async {
    var response = await ApiEngine().performRequest(
      ApiRequestType.DELETE,
      '${ApiManager().adminDeals}/$dealId',
      showIndicator: true,
      isWithToken: true,
    );
    handleResponseCall(response, successBlock, failureBlock);
    return response;
  }

  void handleResponseCall(ApiResponse response, SuccessBlock successBlock,
      FailureBlock failureBlock) {
    switch (response.status) {
      case ApiResponseStatus.SUCCESS:
        successBlock(response.data);
        break;
      case ApiResponseStatus.FAILED:
        failureBlock(response.exception!, response.data);
        break;
    }
  }
}



class ApiManager {
  static const baseUrl = 'https://chikx-worker.kattukadha3.workers.dev/api';
  // static const baseUrl = 'http://10.0.2.2:8787/api';
  String create_account = '$baseUrl/register';
  String login = '$baseUrl/validate-user';
  String addFood = '$baseUrl/adminAddFood';
  String adminGetFood = '$baseUrl/adminGetFood';
  String adminUpdateFood = '$baseUrl/adminUpdateFood';
  String adminDeleteFood = '$baseUrl/adminDeleteFood/';

  String appVersion = '$baseUrl/app/version';

  String adminUsers = '$baseUrl/admin/users';
  String adminDeleteUser = '$baseUrl/admin/users';

  String putFavoriteFood = '$baseUrl/favorites';
  String getFavoriteFood = '$baseUrl/favorites';
  String deleteFavoriteFood = '$baseUrl/favorites';


  String sendMessage = '$baseUrl/chat/send';
  String getMessages = '$baseUrl/chat/messages';
  String adminConversations = '$baseUrl/admin/chat/conversations';
  String adminChatByUser = '$baseUrl/admin/chat';
  String adminSendMessage = '$baseUrl/admin/chat/send';
  String userProfile = '$baseUrl/profile';
  String forgotPassword = '$baseUrl/forgot-password';
  String verifySecurityAnswers = '$baseUrl/verify-security-answers';
  String paymentHistory = '$baseUrl/payments/history';
  String adminDeals = '$baseUrl/admin/deals';
} 
