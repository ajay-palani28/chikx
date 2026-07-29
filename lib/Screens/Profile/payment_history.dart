import 'package:chikx/Models/app_model.dart';
import 'package:chikx/Provider/providers.dart';
import 'package:chikx/RiverPod/payment_pod.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  ConsumerState<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      Future.microtask(() {
        if (mounted) {
          ref.read(paymentProvider.notifier).getPaymentHistory(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);

    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textBrown),
            onPressed: () => Navigator.pop(context),
          ),
          title: CommonUI().myText(
            text: "Payment History",
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
          ),
          centerTitle: false,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 4.w),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: AppColors.textBrown, size: 20),
              ),
            ),
          ],
        ),
        body: _buildBody(paymentState),
      ),
    );
  }

  Widget _buildBody(PaymentState state) {
    if (state is PaymentLoadingState) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is PaymentSuccessState) {
      final history = state.history;
      return SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard("TOTAL SPENT", "₹${history.totalSpent?.toStringAsFixed(0) ?? '0'}", AppColors.textBrown),
                ),
                Gap(4.w),
                Expanded(
                  child: _buildSummaryCard("ORDERS", "${history.totalOrders ?? '0'}", AppColors.black),
                ),
              ],
            ),
            Gap(4.h),
            CommonUI().myText(
              text: "RECENT TRANSACTIONS",
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black54,
            ),
            Gap(2.h),
            if (history.transactions.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: CommonUI().myText(text: "No transactions found", color: Colors.black38),
                ),
              )
            else
              ...history.transactions.map((tx) => _buildTransactionCard(tx)).toList(),
          ],
        ),
      );
    } else if (state is PaymentErrorState) {
      return Center(child: Text("Error: ${state.exception}"));
    }
    return const SizedBox();
  }

  Widget _buildSummaryCard(String label, String value, Color valueColor) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF3E7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonUI().myText(
            text: label,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black45,
          ),
          Gap(1.h),
          CommonUI().myText(
            text: value,
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel tx) {
    String formattedDate = tx.createdAt != null 
        ? DateFormat('MMM dd, yyyy • HH:mm').format(tx.createdAt!) 
        : "N/A";
    
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonUI().myText(
                text: formattedDate,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black38,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: CommonUI().myText(
                  text: tx.status?.toUpperCase() ?? "SUCCESS",
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textBrown,
                ),
              ),
            ],
          ),
          Gap(1.h),
          CommonUI().myText(
            text: tx.itemsSummary ?? "Order Details",
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            maxLines: 2,
          ),
          Gap(1.5.h),
          const Divider(color: Colors.black12, height: 1),
          Gap(1.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonUI().myText(
                text: "Transaction ID: ${tx.transactionId ?? 'N/A'}",
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black45,
              ),
              CommonUI().myText(
                text: "₹${tx.amount ?? 0}",
                fontSize: 14.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
