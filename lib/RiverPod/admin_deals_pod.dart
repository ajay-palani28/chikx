import 'package:chikx/Models/app_model.dart';
import 'package:chikx/Network/api_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

abstract class AdminDealsState {}

class AdminDealsInitialState extends AdminDealsState {}

class AdminDealsLoadingState extends AdminDealsState {}

class AdminDealsSuccessState extends AdminDealsState {
  final List<AdminDealModel> deals;
  AdminDealsSuccessState(this.deals);
}

class AdminDealsErrorState extends AdminDealsState {
  final String message;
  AdminDealsErrorState(this.message);
}

class AdminDealsActionLoadingState extends AdminDealsState {
  final List<AdminDealModel> deals;
  AdminDealsActionLoadingState(this.deals);
}

class AdminDealsNotifier extends StateNotifier<AdminDealsState> {
  AdminDealsNotifier() : super(AdminDealsInitialState());

  List<AdminDealModel> _allDeals = [];

  Future<void> fetchDeals({String? status}) async {
    state = AdminDealsLoadingState();
    await ApiMethods().getDeals(
      status: status,
      successBlock: (data) {
        try {
          List<dynamic> list = [];
          if (data is Map) {
            if (data['data'] is List) {
              list = data['data'];
            } else if (data['data'] is Map && data['data']['deals'] is List) {
              list = data['data']['deals'];
            } else if (data['deals'] is List) {
              list = data['deals'];
            }
          }
          
          _allDeals = list.map((e) => AdminDealModel.fromJson(e)).toList();
          state = AdminDealsSuccessState(_allDeals);
        } catch (e) {
          state = AdminDealsErrorState("Parsing error: ${e.toString()}");
        }
      },
      failureBlock: (exception, data) {
        state = AdminDealsErrorState(exception.toString());
      },
    );
  }

  Future<void> upsertDeal(AdminDealModel deal, BuildContext context) async {
    final dealId = deal.id ?? const Uuid().v4();
    final previousDeals = List<AdminDealModel>.from(_allDeals);
    state = AdminDealsActionLoadingState(previousDeals);

    await ApiMethods().upsertDeal(
      dealId: dealId,
      payload: deal.toJson(),
      successBlock: (data) {
        fetchDeals();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(deal.id == null ? "Deal created successfully" : "Deal updated successfully")),
        );
      },
      failureBlock: (exception, data) {
        state = AdminDealsSuccessState(previousDeals);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save deal: ${exception.toString()}")),
        );
      },
    );
  }

  Future<void> deleteDeal(String dealId, BuildContext context) async {
    final previousDeals = List<AdminDealModel>.from(_allDeals);
    state = AdminDealsActionLoadingState(previousDeals);

    await ApiMethods().deleteDeal(
      dealId: dealId,
      successBlock: (data) {
        _allDeals.removeWhere((d) => d.id == dealId);
        state = AdminDealsSuccessState(List.from(_allDeals));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Deal deleted successfully")),
        );
      },
      failureBlock: (exception, data) {
        state = AdminDealsSuccessState(previousDeals);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete deal: ${exception.toString()}")),
        );
      },
    );
  }
}
