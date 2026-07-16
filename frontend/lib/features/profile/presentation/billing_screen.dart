import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../../models/invoice.dart';
import '../billing_provider.dart';

class BillingScreen extends ConsumerWidget {
  const BillingScreen({super.key});

  // Dynamic date formatting for the receipt modal
  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Generates and saves receipt text file to workspace root (Windows/Mobile/Desktop) or simulates on Web
  Future<void> _downloadInvoiceFile(BuildContext context, Invoice invoice) async {
    final loc = AppLocalizations.of(context)!;
    final invoiceText = '''
==================================================
              ${loc.billingReceiptHeader}              
==================================================
${loc.billingReceiptNumber}:  ${invoice.id}
${loc.billingReceiptTransactionDate}:${_formatDateTime(invoice.date)}
${loc.billingReceiptPlanType}:       ${invoice.planName}
${loc.billingReceiptPaymentStatus}:  ${invoice.status.toUpperCase()}
${loc.billingReceiptPaymentMethod}:  ${invoice.paymentMethod}
==================================================
${loc.billingReceiptSummary}
==================================================
${loc.billingReceiptPlanPrice}:        ₹${invoice.amount.toStringAsFixed(2)}
${loc.billingReceiptTaxGst}:                ₹${invoice.tax.toStringAsFixed(2)}
--------------------------------------------------
${loc.billingReceiptTotalCharged}:                  ₹${invoice.total.toStringAsFixed(2)}
==================================================
${loc.billingReceiptThankYou}
${loc.billingReceiptContactSupport}
==================================================
''';

    if (kIsWeb) {
      // Simulation on Web
      await Future.delayed(const Duration(milliseconds: 600));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.billingInvoiceDownloaded('${invoice.id}.txt')),
            backgroundColor: AppColors.success,
          ),
        );
      }
      return;
    }

    try {
      // Write to project workspace folder directly (highly realistic mockup!)
      const workspacePath = 'C:\\Users\\ayesh\\OneDrive\\Desktop\\aura\\Aura-AI\\frontend';
      final directory = Directory(workspacePath);
      if (await directory.exists()) {
        final file = File('$workspacePath\\${invoice.id}.txt');
        await file.writeAsString(invoiceText);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.billingInvoiceSaved(file.path)),
              backgroundColor: AppColors.success,
              action: SnackBarAction(
                label: loc.billingInvoiceClose,
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      } else {
        throw Exception('Workspace directory not found');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Simulated download: Saved receipt text to memory ($e)'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    }
  }

  void _showInvoiceDialog(BuildContext context, Invoice invoice, Color accentColor, bool isDark) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) {
        final titleColor = isDark ? Colors.white : AppColors.lightTextPrimary;
        final bodyColor = isDark ? Colors.white70 : AppColors.lightTextSecondary;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: isDark ? const Color(0xFF1E1C24) : Colors.white,
          title: Center(
            child: Text(
              loc.billingInvoiceTitle,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: titleColor,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      loc.billingInvoicePaidSuccess,
                      style: GoogleFonts.outfit(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildInvoiceField(loc.billingInvoiceId, invoice.id, bodyColor),
                _buildInvoiceField(loc.billingInvoiceDate, _formatDateTime(invoice.date), bodyColor),
                _buildInvoiceField(loc.billingInvoicePlan, invoice.planName, bodyColor),
                _buildInvoiceField(loc.billingInvoicePaymentMethod, invoice.paymentMethod, bodyColor),
                const Divider(height: 32),
                _buildInvoiceField(loc.billingInvoiceSubtotal, '₹${invoice.amount.toStringAsFixed(2)}', bodyColor),
                _buildInvoiceField(loc.billingInvoiceTaxGst, '₹${invoice.tax.toStringAsFixed(2)}', bodyColor),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.billingInvoiceTotalAmount,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: titleColor,
                      ),
                    ),
                    Text(
                      '₹${invoice.total.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                loc.billingInvoiceClose,
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                _downloadInvoiceFile(context, invoice);
              },
              icon: const Icon(Icons.download_rounded, size: 16),
              label: Text(
                loc.billingInvoiceDownload,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInvoiceField(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref, Color accentColor, bool isDark) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: isDark ? const Color(0xFF1E1C24) : Colors.white,
          title: Text(
            loc.billingDowngradeTitle,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
          content: Text(
            loc.billingDowngradeMessage,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                loc.billingKeepSubscription,
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(billingProvider.notifier).cancelSubscription();
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.billingCancelledSuccess),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
              child: Text(
                loc.billingDowngrade,
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final billing = ref.watch(billingProvider);
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
          loc.billingTitle,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Current Plan Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: billing.isPremium
                      ? LinearGradient(
                          colors: [
                             accentColor,
                             accentColor.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: billing.isPremium ? null : cardColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: billing.isPremium ? Colors.transparent : borderColor,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                       color: billing.isPremium
                           ? accentColor.withValues(alpha: 0.25)
                           : Colors.black.withValues(alpha: 0.01),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.billingCurrentPlan,
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: billing.isPremium ? Colors.white70 : AppColors.lightTextSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          billing.plan == SubscriptionPlan.pro
                              ? loc.billingProTier
                              : (billing.plan == SubscriptionPlan.premium ? loc.billingPremiumTier : loc.billingFreeTier),
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: billing.isPremium ? Colors.white : (isDark ? Colors.white : AppColors.lightTextPrimary),
                          ),
                        ),
                        Icon(
                          billing.plan == SubscriptionPlan.pro
                              ? Icons.workspace_premium_rounded
                              : (billing.isPremium ? Icons.diamond_rounded : Icons.lock_open_rounded),
                          color: billing.isPremium ? Colors.white : accentColor,
                          size: 32,
                        ),
                      ],
                    ),
                    if (billing.isPremium) ...[
                      const SizedBox(height: 12),
                      Text(
                        loc.billingRenewsOn(billing.nextBillingDate),
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 2. Usage limit counters
              Text(
                loc.billingUsageLimits,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Column(
                  children: [
                    _buildUsageBar(
                      title: loc.billingAiCompanionChats,
                      used: billing.chatUsed,
                      limit: billing.chatLimit,
                      isPremium: billing.isPremium,
                      accentColor: accentColor,
                      isDark: isDark,
                      unlimitedLabel: loc.billingUnlimited,
                    ),
                    const SizedBox(height: 16),
                    _buildUsageBar(
                      title: loc.billingMemoryIndexSlots,
                      used: billing.memoryUsed,
                      limit: billing.memoryLimit,
                      isPremium: billing.isPremium,
                      accentColor: accentColor,
                      isDark: isDark,
                      unlimitedLabel: loc.billingUnlimited,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 3. Payment Method Card or Upgrade Call to Action
              if (billing.isPremium) ...[
                Text(
                  loc.billingPaymentMethod,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        billing.paymentMethod.contains('Visa') ? Icons.credit_card_rounded : Icons.account_balance_wallet_rounded,
                        color: accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              billing.paymentMethod,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              loc.billingRenewsAutomatically,
                              style: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Change payment method simulation
                          ref.read(billingProvider.notifier).updatePaymentMethod('Visa **** 9876');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(loc.billingPaymentMethodUpdated('Visa **** 9876'))),
                          );
                        },
                        child: Text(
                          loc.billingUpdate,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
              ],

              // 4. Invoices billing history
              if (billing.invoices.isNotEmpty) ...[
                Text(
                  loc.billingHistory,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: billing.invoices.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final invoice = billing.invoices[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        title: Text(
                          invoice.planName,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : AppColors.lightTextPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${invoice.id} • ${_formatDateTime(invoice.date)}',
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₹${invoice.total.toStringAsFixed(0)}',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white70 : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: Icon(Icons.receipt_long_rounded, color: accentColor, size: 20),
                              onPressed: () => _showInvoiceDialog(context, invoice, accentColor, isDark),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 36),
              ],

              // 5. Actions: Upgrade / Downgrade or Cancel Buttons
              BouncingWidget(
                onTap: () {
                  if (billing.isPremium) {
                    _showCancelDialog(context, ref, accentColor, isDark);
                  } else {
                    context.push('/choose-plan');
                  }
                },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: billing.isPremium
                        ? null
                        : LinearGradient(
                            colors: [
                               accentColor,
                               accentColor.withValues(alpha: 0.8),
                             ],
                           ),
                     color: billing.isPremium ? Colors.redAccent.withValues(alpha: 0.12) : null,
                    border: billing.isPremium ? Border.all(color: Colors.redAccent, width: 1.5) : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    billing.isPremium ? loc.billingCancelPremium : loc.billingUpgradePlan,
                    style: GoogleFonts.outfit(
                      color: billing.isPremium ? Colors.redAccent : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsageBar({
    required String title,
    required int used,
    required int limit,
    required bool isPremium,
    required Color accentColor,
    required bool isDark,
    required String unlimitedLabel,
  }) {
    final double percent = isPremium ? 0.0 : (limit == 0 ? 0.0 : (used / limit).clamp(0.0, 1.0));
    final limitStr = isPremium ? unlimitedLabel : limit.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : AppColors.lightTextPrimary,
                ),
              ),
            ),
            Text(
              isPremium ? unlimitedLabel : '$used / $limitStr',
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: isPremium ? 0.0 : percent,
            minHeight: 8,
            backgroundColor: isDark ? const Color(0xFF2C2834) : AppColors.blueWhite,
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
          ),
        ),
      ],
    );
  }
}
