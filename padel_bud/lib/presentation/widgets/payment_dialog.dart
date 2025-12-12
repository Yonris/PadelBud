import 'package:flutter/material.dart';
import 'package:padel_bud/core/payment_service.dart';
import 'package:padel_bud/core/app_localizations.dart';

class PaymentDialog extends StatefulWidget {
  final String productId;
  final String amount;
  final String description;
  final String? startTime;
  final String? endTime;
  final Function() onPaymentSuccess;

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

class _PremiumGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF2E7D32).withValues(alpha: 0.08),
          const Color(0xFF1B5E20).withValues(alpha: 0.04),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(20),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
        await widget.onPaymentSuccess();
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 20,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context, isDarkMode),
                const SizedBox(height: 36),
                _buildDetailsSection(context, isDarkMode),
                const SizedBox(height: 40),
                _buildAmountSection(context, isDarkMode),
                const SizedBox(height: 44),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2E7D32).withValues(alpha: 0.12),
                const Color(0xFF1B5E20).withValues(alpha: 0.06),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.credit_card_rounded,
            color: Color(0xFF2E7D32),
            size: 40,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          AppLocalizations.of(context).confirmPayment,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: isDarkMode ? Colors.white : Colors.grey.shade900,
                letterSpacing: -0.8,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          widget.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context, bool isDarkMode) {
    if (widget.startTime == null || widget.endTime == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkMode
              ? Colors.green.shade800.withValues(alpha: 0.3)
              : Colors.green.shade200,
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.green.shade900.withValues(alpha: 0.4)
                  : Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.access_time_rounded,
              size: 22,
              color: Colors.green.shade600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (AppLocalizations.of(context).bookingTime ?? 'Booking Time').toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.startTime} - ${widget.endTime}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDarkMode ? Colors.green.shade300 : Colors.green.shade800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        const SizedBox(height: 14),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2E7D32),
              const Color(0xFF1B5E20),
            ],
          ).createShader(bounds),
          child: Text(
            widget.amount,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: _processing ? null : _handlePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              shadowColor: const Color(0xFF2E7D32).withValues(alpha: 0.5),
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: _processing
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Text(
                    AppLocalizations.of(context).completePayment,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: TextButton(
            onPressed: _processing ? null : () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              splashFactory: InkRipple.splashFactory,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).cancel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
