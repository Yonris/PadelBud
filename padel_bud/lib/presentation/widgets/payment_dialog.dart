import 'package:flutter/material.dart';
import 'package:padel_bud/core/payment_service.dart';
import 'package:padel_bud/core/app_localizations.dart';

class PaymentDialog extends StatefulWidget {
  final String productId;
  final String amount;
  final String description;
  final String? startTime;
  final String? endTime;
  final VoidCallback onPaymentSuccess;

  const PaymentDialog({
    required this.productId,
    required this.amount,
    required this.description,
    this.startTime,
    this.endTime,
    required this.onPaymentSuccess,
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  bool _processing = false;
  final _paymentService = PaymentService();

  Future<void> _handlePayment() async {
    setState(() => _processing = true);

    try {
      await _paymentService.processPayment(
        productId: widget.productId,
        description: widget.description,
      );

      if (mounted) {
        widget.onPaymentSuccess();
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).paymentSuccessful),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _processing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).paymentFailed}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.credit_card_rounded,
                color: Color(0xFF1E88E5),
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).confirmPayment,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            if (widget.startTime != null && widget.endTime != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${widget.startTime} - ${widget.endTime}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.startTime != null && widget.endTime != null)
              const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context).amount,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.amount,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _processing ? null : _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _processing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context).completePayment,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: _processing ? null : () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context).cancel,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
