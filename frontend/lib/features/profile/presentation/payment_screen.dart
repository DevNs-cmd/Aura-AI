import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/widgets/bouncing_widget.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String plan;
  final double price;

  const PaymentScreen({
    super.key,
    required this.plan,
    required this.price,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _selectedMethod = 'Card'; // 'Card', 'UPI', 'GooglePay', 'NetBanking'
  final _formKey = GlobalKey<FormState>();

  // Card Controllers
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  // UPI Controllers
  final _upiIdController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardHolderController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  void _submitPayment() {
    if (_selectedMethod == 'Card' || _selectedMethod == 'UPI') {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    String paymentMethodStr = 'GPay';
    if (_selectedMethod == 'Card') {
      final numberStr = _cardNumberController.text.replaceAll(' ', '');
      final last4 = numberStr.length >= 4 ? numberStr.substring(numberStr.length - 4) : '1234';
      paymentMethodStr = 'Visa **** $last4';
    } else if (_selectedMethod == 'UPI') {
      paymentMethodStr = 'UPI (${_upiIdController.text})';
    } else if (_selectedMethod == 'GooglePay') {
      paymentMethodStr = 'Google Pay';
    } else if (_selectedMethod == 'NetBanking') {
      paymentMethodStr = 'Net Banking';
    }

    // Go to Processing
    context.push('/payment-processing', extra: {
      'plan': widget.plan,
      'paymentMethod': paymentMethodStr,
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    final screenColor = isDark
        ? const Color(0xFF141318)
        : (themeState.hasMoodSelected
            ? themeState.moodTheme.background
            : AppColors.lightBackground);

    final cardColor = isDark
        ? const Color(0xFF1E1C24)
        : (themeState.hasMoodSelected
            ? themeState.moodTheme.cardColor
            : Colors.white);

    final borderColor = isDark
        ? const Color(0xFF2C2834)
        : (themeState.hasMoodSelected
            ? themeState.moodTheme.cardBorder
            : AppColors.lightCardBorder);

    return Scaffold(
      backgroundColor: screenColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          loc.paymentTitle,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  loc.paymentSelectMethod,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Payment Method Selector Rows
                _buildMethodSelector('Card', Icons.credit_card_rounded, isDark, cardColor, borderColor, accentColor, label: loc.paymentMethodCard),
                const SizedBox(height: 10),
                _buildMethodSelector('UPI', Icons.qr_code_scanner_rounded, isDark, cardColor, borderColor, accentColor, label: loc.paymentMethodUpi),
                const SizedBox(height: 10),
                _buildMethodSelector('GooglePay', Icons.payment_rounded, isDark, cardColor, borderColor, accentColor, label: loc.paymentMethodGooglePay),
                const SizedBox(height: 10),
                _buildMethodSelector('NetBanking', Icons.account_balance_rounded, isDark, cardColor, borderColor, accentColor, label: loc.paymentMethodNetBanking),

                const SizedBox(height: 28),

                // Active form fields based on selection
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _buildSelectedForm(isDark, borderColor),
                ),

                const SizedBox(height: 36),

                // Complete Payment Button
                BouncingWidget(
                  onTap: _submitPayment,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          accentColor,
                          accentColor.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      loc.paymentCompletePayment,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodSelector(
    String method,
    IconData icon,
    bool isDark,
    Color cardColor,
    Color borderColor,
    Color accentColor, {
    String? label,
  }) {
    final isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : borderColor,
            width: isSelected ? 2.0 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? accentColor : (isDark ? Colors.white60 : Colors.grey[600]),
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label ?? method,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? accentColor : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedForm(bool isDark, Color borderColor) {
    final loc = AppLocalizations.of(context)!;
    if (_selectedMethod == 'Card') {
      return Column(
        key: const ValueKey('FormCard'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _cardNumberController,
            label: loc.paymentCardNumber,
            hint: loc.paymentCardNumberHint,
            keyboard: TextInputType.number,
            isDark: isDark,
            validator: (value) {
              if (value == null || value.isEmpty) return loc.paymentCardNumberError;
              final raw = value.replaceAll(' ', '');
              if (raw.length < 16) return loc.paymentCardNumberLengthError;
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cardExpiryController,
                  label: loc.paymentExpiry,
                  hint: loc.paymentExpiryHint,
                  keyboard: TextInputType.datetime,
                  isDark: isDark,
                  validator: (value) {
                    if (value == null || value.isEmpty) return loc.paymentExpiryRequired;
                    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(value)) {
                      return loc.paymentExpiryFormat;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _cardCvvController,
                  label: loc.paymentCvv,
                  hint: loc.paymentCvvHint,
                  keyboard: TextInputType.number,
                  isDark: isDark,
                  obscure: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return loc.paymentCvvRequired;
                    if (value.length < 3) return loc.paymentCvvDigits;
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _cardHolderController,
            label: loc.paymentCardholder,
            hint: loc.paymentCardholderHint,
            keyboard: TextInputType.text,
            isDark: isDark,
            validator: (value) {
              if (value == null || value.isEmpty) return loc.paymentCardholderError;
              return null;
            },
          ),
        ],
      );
    } else if (_selectedMethod == 'UPI') {
      return Column(
        key: const ValueKey('FormUPI'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _upiIdController,
            label: loc.paymentUpiId,
            hint: loc.paymentUpiIdHint,
            keyboard: TextInputType.emailAddress,
            isDark: isDark,
            validator: (value) {
              if (value == null || value.isEmpty) return loc.paymentUpiIdError;
              if (!value.contains('@')) return loc.paymentUpiIdFormat;
              return null;
            },
          ),
        ],
      );
    } else if (_selectedMethod == 'GooglePay') {
      return Center(
        key: const ValueKey('FormGPay'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            loc.paymentGooglePayDesc,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
            ),
          ),
        ),
      );
    } else {
      return Center(
        key: const ValueKey('FormNetBanking'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            loc.paymentNetBankingDesc,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType keyboard,
    required bool isDark,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          obscureText: obscure,
          validator: validator,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.quicksand(
              fontSize: 13,
              color: isDark ? Colors.white24 : Colors.grey[400],
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF2C2834).withValues(alpha: 0.3) : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
