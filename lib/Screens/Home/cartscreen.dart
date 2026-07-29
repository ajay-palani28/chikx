import 'dart:convert';
import 'package:chikx/Provider/providers.dart';
import 'package:chikx/RiverPod/cart_pod.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/app_token.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sizer/sizer.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key}); 

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  late Razorpay _razorpay;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _initUserId();
  }

  void _initUserId() async {
    _userId = await getUserId();
    if (_userId != null && mounted) {
      ref.read(cartProvider.notifier).getCart(_userId!, context);
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Successful!")),
    );
    ref.read(cartProvider.notifier).clearCart();
    Navigator.pop(context);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  void _openCheckout(double amount) {
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid amount")),
      );
      return;
    }

    var options = {
      'key': 'rzp_test_YOUR_ACTUAL_KEY_HERE', // TODO: REPLACE WITH YOUR RAZORPAY KEY
      'amount': (amount * 100).toInt(),
      'name': 'ChikX',
      'description': 'Order Payment',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': '9999999999', 'email': 'user@example.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open Razorpay: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: CommonUI().myText(
            text: "ChikX",
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.textBrown,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.black),
              onPressed: () {},
            ),
            Gap(2.w),
          ],
        ),
        body: cartItems.isEmpty
            ? _buildEmptyCart()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonUI().myText(
                          text: "Your Cart",
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.black,
                        ),
                        CommonUI().myText(
                          text: "${cartItems.length} items in your bag",
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return _buildCartItem(item, cartNotifier);
                      },
                    ),
                  ),
                  _buildPriceDetails(cartNotifier),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.black12),
          Gap(2.h),
          CommonUI().myText(
            text: "Your bag is empty",
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black38,
          ),
          Gap(2.h),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: CommonUI().myText(text: "Explore Menu", fontWeight: FontWeight.w800, color: AppColors.textBrown),
          )
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, CartNotifier notifier) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 25.w,
              height: 10.h,
              child: _buildImageWidget(item.food.photo ?? ""),
            ),
          ),
          Gap(4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonUI().myText(
                      text: item.food.itemName ?? "Unnamed",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.black26, size: 20),
                      onPressed: () {
                        if (_userId != null) {
                          notifier.removeFromCart(item.food.id ?? "", _userId!, context);
                        }
                      },
                    ),
                  ],
                ),
                CommonUI().myText(
                  text: "₹${item.food.price ?? 0}",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBrown,
                ),
                Gap(1.h),
                Row(
                  children: [
                    _buildQtyBtn(Icons.remove, () => notifier.updateQuantity(item.food.id ?? "", false)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: CommonUI().myText(
                        text: "${item.quantity}",
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    _buildQtyBtn(Icons.add, () => notifier.updateQuantity(item.food.id ?? "", true)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black12),
        ),
        child: Icon(icon, size: 16, color: AppColors.black),
      ),
    );
  }

  Widget _buildPriceDetails(CartNotifier notifier) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF3E7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          _buildPriceRow("Total Amount", "₹${notifier.subtotal.toStringAsFixed(2)}",  isTotal: true),
          Gap(3.h),
          CommonUI.buildButton(
            onPressed: () => _openCheckout(notifier.subtotal),
            width: double.infinity,
            height: 5.h,
            borderradius: 15,
            gradientfirst: AppColors.primary,
            gradientsecond: AppColors.primary,
            file: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance_wallet_outlined, color: AppColors.textBrown),
                Gap(2.w),
                CommonUI().myText(
                  text: "Pay with Razorpay",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textBrown,
                ),
              ],
            ),
          ),
          Gap(1.h),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isFree = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CommonUI().myText(
          text: label,
          fontSize: isTotal ? 15.sp : 13.sp,
          fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
          color: isTotal ? AppColors.black : Colors.black54,
        ),
        CommonUI().myText(
          text: value,
          fontSize: isTotal ? 15.sp : 13.sp,
          fontWeight: isTotal ? FontWeight.w900 : FontWeight.w800,
          color: isFree ? Colors.orange : (isTotal ? AppColors.black : AppColors.textBrown),
        ),
      ],
    );
  }

  Widget _buildImageWidget(String imageData) {
    if (imageData.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.fastfood, color: Colors.grey),
      );
    }
    if (imageData.startsWith('assets/')) {
      return Image.asset(imageData, fit: BoxFit.fill);
    }
    try {
      String base64Str = imageData;
      if (imageData.contains(',')) base64Str = imageData.split(',').last;
      return Image.memory(
        base64Decode(base64Str),
        fit: BoxFit.fill,
        errorBuilder: (c, e, s) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    } catch (e) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );
    }
  }
}
