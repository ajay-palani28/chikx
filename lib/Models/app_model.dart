class CreateAccountModel {
  String fullName;
  String dob;
  String phone;
  String email;
  String password;
  String cpassword;
  String securityQuestion1;
  String securityAnswer1;
  String securityQuestion2;
  String securityAnswer2;

  CreateAccountModel({
    required this.fullName,
    required this.dob,
    required this.phone,
    required this.email,
    required this.password,
    required this.cpassword,
    required this.securityQuestion1,
    required this.securityAnswer1,
    required this.securityQuestion2,
    required this.securityAnswer2,
  });

  Map<String, dynamic> toJson() => {
    "fullName": fullName,
    "dob": dob,
    "phone": phone,
    "email": email,
    "password": password,
    "cpassword": cpassword,
    "securityQuestion1": securityQuestion1,
    "securityAnswer1": securityAnswer1,
    "securityQuestion2": securityQuestion2,
    "securityAnswer2": securityAnswer2,
  };
}

class LoginModel {
  String phone;
  String password;

  LoginModel({
    required this.phone,
    required this.password,
  });


  Map<String, dynamic> toJson() => {
    "phone": phone,
    "password": password,
  };
}

class AddFoodModel {
  String itemName;
  String category;
  int price;
  String description;
  String photo;

  AddFoodModel({
    required this.itemName,
    required this.category,
    required this.price,
    required this.description,
    required this.photo,
  });


  Map<String, dynamic> toJson() => {
    "itemName": itemName,
    "category": category,
    "price": price,
    "description": description,
    "photo": photo,
  };
}

class GetFoodsModel {
  String? id;
  String? itemName;
  String? category;
  int? price;
  String? description;
  String? photo;

  GetFoodsModel({
    required this.id,
     this.itemName,
     this.category,
     this.price,
     this.description,
     this.photo,
  });

  factory GetFoodsModel.fromJson(Map<String, dynamic> json) => GetFoodsModel(
    id: json["_id"],
    itemName: json["itemName"],
    category: json["category"],
    price: json["price"],
    description: json["description"],
    photo: json["photo"],
  );
}

class ProfileUploadModel {
  String fullName;
  String email;
  String phone;
  String profileImage;

  ProfileUploadModel({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.profileImage,
  });

  Map<String, dynamic> toJson() => {
    "fullName": fullName,
    "email": email,
    "phone": phone,
    "profileImage": profileImage,
  };
}

class GetProfileModel {
  String id;
  String name;
  String email;
  String phone;
  dynamic profileImage;

  GetProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
  });

  factory GetProfileModel.fromJson(Map<String, dynamic> json) => GetProfileModel(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    profileImage: json["profileImage"],
  );
}

class FavoriteModel {
  String? id;
  String? userId;
  GetFoodsModel? food;

  FavoriteModel({this.id, this.userId, this.food});

  factory FavoriteModel.fromJson(Map<String, dynamic> json) => FavoriteModel(
    id: json["_id"],
    userId: json["userId"],
    food: json["foodId"] != null ? GetFoodsModel.fromJson(json["foodId"]) : null,
  );
}

class ChatMessageModel {
  String? id;
  String? senderId;
  String? receiverId;
  String? senderType;
  String? receiverType;
  String? message;
  DateTime? createdAt;

  ChatMessageModel({
    this.id,
    this.senderId,
    this.receiverId,
    this.senderType,
    this.receiverType,
    this.message,
    this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => ChatMessageModel(
    id: json["_id"],
    senderId: json["senderId"],
    receiverId: json["receiverId"],
    senderType: json["senderType"],
    receiverType: json["receiverType"],
    message: json["message"],
    createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
  );
}

class ChatConversationModel {
  String? userId;
  String? fullName;
  String? email;
  String? phone;
  String? lastMessage;
  DateTime? lastMessageAt;

  ChatConversationModel({
    this.userId,
    this.fullName,
    this.email,
    this.phone,
    this.lastMessage,
    this.lastMessageAt,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) => ChatConversationModel(
    userId: json["userId"],
    fullName: json["userName"], // API uses userName
    email: json["email"],
    phone: json["phone"],
    lastMessage: json["lastMessage"], // API sends string "Hi"
    lastMessageAt: json["lastMessageAt"] != null ? DateTime.parse(json["lastMessageAt"]) : null,
  );
}

class PaymentHistoryModel {
  final String? userId;
  final num? totalSpent;
  final int? totalOrders;
  final List<TransactionModel> transactions;

  PaymentHistoryModel({
    this.userId,
    this.totalSpent,
    this.totalOrders,
    this.transactions = const [],
  });

  factory PaymentHistoryModel.fromJson(Map<String, dynamic> json) => PaymentHistoryModel(
    userId: json["userId"],
    totalSpent: json["totalSpent"],
    totalOrders: json["totalOrders"],
    transactions: json["transactions"] != null
        ? List<TransactionModel>.from(json["transactions"].map((x) => TransactionModel.fromJson(x)))
        : [],
  );
}

class TransactionModel {
  final String? id;
  final String? transactionId;
  final String? itemsSummary;
  final num? amount;
  final String? status;
  final DateTime? createdAt;

  TransactionModel({
    this.id,
    this.transactionId,
    this.itemsSummary,
    this.amount,
    this.status,
    this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
    id: json["id"],
    transactionId: json["transactionId"],
    itemsSummary: json["itemsSummary"],
    amount: json["amount"],
    status: json["status"],
    createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
  );
}

class UserModel {
  String? id;
  String? fullName;
  String? dob;
  String? phone;
  String? email;
  String? profileImage;
  String? createdAt;
  String? updatedAt;

  UserModel({
    this.id,
    this.fullName,
    this.dob,
    this.phone,
    this.email,
    this.profileImage,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"] ?? json["_id"],
    fullName: json["fullName"],
    dob: json["dob"],
    phone: json["phone"],
    email: json["email"],
    profileImage: json["profileImage"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );
}

class AdminDealModel {
  String? id;
  String? title;
  int? discountPercent;
  String? category;
  String? startDate;
  String? endDate;
  String? imageUrl;
  bool? isDealOfDay;
  bool? pushNotification;
  String? status;
  String? displayStatus;

  AdminDealModel({
    this.id,
    this.title,
    this.discountPercent,
    this.category,
    this.startDate,
    this.endDate,
    this.imageUrl,
    this.isDealOfDay,
    this.pushNotification,
    this.status,
    this.displayStatus,
  });

  factory AdminDealModel.fromJson(Map<String, dynamic> json) => AdminDealModel(
    id: json["id"] ?? json["_id"],
    title: json["title"],
    discountPercent: json["discountPercent"],
    category: json["category"],
    startDate: json["startDate"],
    endDate: json["endDate"],
    imageUrl: json["imageUrl"],
    isDealOfDay: json["isDealOfDay"],
    pushNotification: json["pushNotification"],
    status: json["status"],
    displayStatus: json["displayStatus"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "discountPercent": discountPercent,
    "category": category,
    "startDate": startDate,
    "endDate": endDate,
    "imageUrl": imageUrl,
    "isDealOfDay": isDealOfDay,
    "pushNotification": pushNotification,
    "status": status,
  };
}
