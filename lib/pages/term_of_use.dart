import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// =====================================================================
/// TERMS OF USE / EULA GATE — PRE-LOGIN GATE VERSION
/// ---------------------------------------------------------------------
/// Shown as soon as AuthController.login() has verified the entered
/// email/password against Firebase Auth but found that the matching
/// e-users doc does not yet have 'termsAccepted' == true. Login is
/// intentionally left incomplete at that point — no FCM token save, no
/// presence update, no theme/chat setup, no navigation to '/home' — so
/// this screen is the only thing standing between the user and their
/// account.
///
/// On accept: writes 'termsAccepted' + 'termsAcceptedAt' to the user's
/// e-users doc, signs the user back out, and returns to '/login'. The
/// user must then log in again; on that second attempt
/// AuthController.login() will see termsAccepted == true and complete
/// the full login flow normally.
///
/// On decline: signs the user out and returns to '/login' without
/// recording acceptance, so the next login attempt hits this gate again.
///
/// Firestore (not SharedPreferences) is the source of truth here since
/// nothing on this screen runs before Firebase Auth already has a
/// signed-in user — this also means acceptance follows the account
/// across devices/reinstalls.
///
/// Wire-up: called via Get.off(() => const TermsOfUseScreen()) from
/// AuthController.login().
/// =====================================================================
class TermsOfUseScreen extends StatefulWidget {
  const TermsOfUseScreen({super.key});

  @override
  State<TermsOfUseScreen> createState() => _TermsOfUseScreenState();
}

class _TermsOfUseScreenState extends State<TermsOfUseScreen> {
  bool hasReadTerms = false;
  bool hasReadPrivacy = false;
  bool isSaving = false;

  bool get canContinue => hasReadTerms && hasReadPrivacy && !isSaving;

  Future<void> _acceptAndContinue() async {
    setState(() => isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('e-users').doc(user.uid).set({
        'termsAccepted': true,
        'termsAcceptedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    // The user only reached this screen because their prior login attempt
    // was intentionally left incomplete (see AuthController.login()) — no
    // presence/theme/chat setup was ever run for this session. Now that
    // termsAccepted is recorded, sign them back out and send them to the
    // login page so they log in again to actually complete the login flow.
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;
    setState(() => isSaving = false);
    Get.offAllNamed('/login');
  }

  void _decline() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Terms Required',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'You need to accept the Terms of Use to continue using Textido. '
          'You can review the terms again before deciding.',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Review Again'),
          ),
          TextButton(
            onPressed: () async {
              // User already has an account and is signed in at this
              // point, so declining signs them back out rather than
              // force-closing the app.
              await FirebaseAuth.instance.signOut();
              Get.offAllNamed('/login');
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Requirement: white background, black text
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- HEADER ----------------
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Colors.black,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Terms of Use',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Please read and accept before continuing',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Colors.black12),

            // ---------------- SCROLLABLE TERMS TEXT ----------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Text(
                  _termsOfUseText,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            const Divider(height: 1, color: Colors.black12),

            // ---------------- CHECKBOXES + ACTIONS ----------------
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildCheckRow(
                    value: hasReadTerms,
                    label: 'I have read and agree to the Textido Terms of Use.',
                    onChanged: (v) => setState(() => hasReadTerms = v ?? false),
                  ),
                  _buildCheckRow(
                    value: hasReadPrivacy,
                    label: 'I acknowledge that I have also read the Privacy Policy.',
                    onChanged: (v) =>
                        setState(() => hasReadPrivacy = v ?? false),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: canContinue ? _acceptAndContinue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        disabledBackgroundColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Accept & Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _decline,
                    child: Text(
                      'Decline',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckRow({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              activeColor: Colors.black,
              onChanged: onChanged,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 13),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
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

const String _termsOfUseText = '''
RealStore Terms of Use

Last Updated: October 6, 2026

Welcome to RealStore, an e-commerce platform operated by AfiaSplendid LTD ("AfiaSplendid," "RealStore," "we," "our," or "us").

RealStore provides customers with access to products offered directly by AfiaSplendid LTD.

By accessing, registering for, or using RealStore, you acknowledge that you have read, understood, and agree to these Terms of Use. If you do not agree with these Terms, you must not use RealStore.

1. Eligibility

You must be at least 18 years of age, or the minimum legal age required to enter into a binding commercial transaction in your jurisdiction, to place orders through RealStore.

If you are under the applicable age, you may only use RealStore with the involvement and permission of a parent or legal guardian where permitted by law.

2. Acceptance of These Terms

By accessing RealStore, creating an account, placing an order, or otherwise using our services, you agree to be bound by these Terms of Use, our Privacy Policy, and any additional policies or conditions displayed on RealStore.

3. About RealStore

RealStore is an e-commerce platform operated by AfiaSplendid LTD.

RealStore is designed to allow customers to:

- Browse products offered by AfiaSplendid LTD.
- View product information and pricing.
- Add products to a shopping cart.
- Place orders.
- Make payments through available payment methods.
- View order information.
- Receive updates regarding orders and delivery.
- Contact us regarding purchases, returns, refunds, or other customer-service matters.

RealStore is not an open marketplace for independent third-party sellers unless AfiaSplendid LTD expressly introduces such functionality in the future.

4. Products

We make reasonable efforts to ensure that product descriptions, images, specifications, availability, and prices displayed on RealStore are accurate and up to date.

However, product appearance may vary slightly from displayed images due to photography, screen settings, packaging changes, or manufacturer updates.

We reserve the right to:

- Correct product information or pricing errors.
- Update product descriptions.
- Change product availability.
- Limit quantities available for purchase.
- Remove products from the platform.
- Cancel orders affected by obvious pricing, inventory, or listing errors.

5. Product Availability

All products are subject to availability.

Adding an item to your cart does not guarantee that the item will remain available until checkout or payment is completed.

If a product becomes unavailable after an order is placed, we may contact you regarding available alternatives or provide an appropriate refund where applicable.

6. Prices

Product prices displayed on RealStore are subject to change without prior notice.

The price applicable to an order is generally the price displayed at the time the order is successfully placed, except where an obvious pricing or listing error has occurred.

Additional charges, including applicable delivery fees or other charges, may apply and will be displayed where applicable before order completion.

7. Orders

When you place an order through RealStore, you are submitting a request to purchase the selected products.

An order is not necessarily considered accepted until we confirm the order.

We reserve the right to refuse, cancel, or limit an order where:

- A product is unavailable.
- There is an obvious pricing or listing error.
- Payment cannot be successfully verified.
- We reasonably suspect fraud or unauthorized activity.
- The order violates applicable law or these Terms.
- Delivery to the provided location is not available.

If we cancel an order after payment has been received, we will provide an appropriate refund in accordance with our applicable refund process.

8. Customer Information

You are responsible for providing accurate information required to process your order.

This may include:

- Your name.
- Phone number.
- Email address.
- Delivery address.
- Payment or transaction information where required through the applicable payment provider.

Providing incorrect or incomplete information may result in delivery delays, failed delivery, or cancellation of an order.

9. Payments

RealStore may provide different payment methods through approved payment providers.

Payment information may be processed by third-party payment providers rather than being directly stored by RealStore.

You agree to provide accurate payment information and authorize applicable charges associated with your order.

We reserve the right to delay, reject, or cancel transactions where we reasonably suspect fraud, unauthorized payment activity, or other security concerns.

10. Delivery

We may provide delivery directly or through third-party logistics and delivery providers.

Delivery times may vary depending on:

- Product availability.
- Delivery location.
- Courier or logistics availability.
- Weather or other external conditions.
- Public holidays.
- Other circumstances outside our reasonable control.

Any delivery timeframe displayed on RealStore is an estimate unless expressly stated otherwise.

Customers are responsible for providing an accurate delivery address and ensuring that someone is available to receive an order where required.

11. Delivery Delays

We will make reasonable efforts to process and deliver orders within the communicated timeframe.

However, we are not responsible for delays caused by circumstances outside our reasonable control, including transportation disruptions, weather conditions, public emergencies, government restrictions, or third-party logistics failures.

Where significant delays occur, we may provide available updates to the customer.

12. Returns and Refunds

Returns and refunds are subject to our applicable Return and Refund Policy.

Where a return is permitted, customers may be required to:

- Contact us within the specified return period.
- Provide order information.
- Provide evidence of the issue where reasonably required.
- Return the product in the required condition.
- Follow the return instructions provided by RealStore.

Products may not be eligible for return where they have been used, damaged by the customer, altered, or otherwise fall outside the applicable return conditions, except where applicable law provides otherwise.

Nothing in these Terms limits any consumer rights that cannot legally be excluded.

13. Damaged, Incorrect, or Defective Products

If you receive a product that is damaged, defective, incomplete, or materially different from what you ordered, you should contact RealStore as soon as reasonably possible.

We may request photographs, videos, order details, or other information to assess the issue.

Depending on the circumstances and applicable law, we may provide a replacement, repair, refund, or another appropriate resolution.

14. Customer Responsibilities

Customers must not:

- Use RealStore for fraudulent or unlawful purposes.
- Provide false information.
- Attempt unauthorized access to RealStore.
- Interfere with the operation or security of the platform.
- Abuse return or refund processes.
- Use stolen or unauthorized payment methods.
- Attempt to exploit pricing, promotional, or technical errors.
- Resell products in violation of applicable restrictions or agreements.
- Use automated systems to interfere with RealStore without authorization.

15. Promotions and Discounts

RealStore may offer discounts, promotions, coupons, or other promotional campaigns.

Each promotion may have additional terms, eligibility requirements, expiration dates, quantity limits, or product restrictions.

Unless expressly stated otherwise, promotions cannot be combined and have no cash value.

We reserve the right to modify, suspend, or cancel a promotion where necessary.

16. Intellectual Property

RealStore, including its name, logo, software, design, graphics, product presentation, interface, and other original materials, is owned by or licensed to AfiaSplendid LTD and is protected by applicable intellectual property laws.

You may not copy, reproduce, modify, distribute, reverse engineer, or commercially exploit any part of RealStore without prior written permission.

Product names, trademarks, logos, images, and other materials belonging to third parties remain the property of their respective owners.

17. Privacy

Your use of RealStore is also subject to our Privacy Policy.

Our Privacy Policy explains how information associated with your use of RealStore may be collected, used, stored, processed, and protected.

18. Third-Party Services

RealStore may rely on third-party services, including payment providers, delivery companies, hosting providers, analytics services, or other technology providers.

These services may have their own terms and privacy policies.

We are not responsible for the independent actions, policies, availability, or failures of third-party services outside our reasonable control.

19. Availability of RealStore

We aim to keep RealStore available and functional, but we do not guarantee uninterrupted or error-free operation.

We may temporarily suspend or restrict access to RealStore for:

- Maintenance.
- Security updates.
- Technical issues.
- Platform improvements.
- Legal or regulatory requirements.
- Other operational reasons.

We may also modify, add, remove, or discontinue features.

20. Disclaimer

RealStore is provided on an "as is" and "as available" basis to the fullest extent permitted by applicable law.

We do not guarantee that:

- RealStore will always be available.
- Product information will always be completely error-free.
- All products will always remain in stock.
- Delivery estimates will always be met.
- The platform will always operate without technical problems.

21. Limitation of Liability

To the fullest extent permitted by applicable law, AfiaSplendid LTD and RealStore shall not be liable for indirect, incidental, consequential, special, or other damages arising from or related to:

- Use or inability to use RealStore.
- Delays outside our reasonable control.
- Third-party payment or delivery services.
- Unauthorized access caused by circumstances outside our reasonable control.
- Loss of data or profits.
- Technical interruptions or failures.

Nothing in these Terms excludes or limits liability that cannot legally be excluded or limited.

22. Changes to These Terms

We may update these Terms of Use from time to time.

Where significant changes are made, we may notify users through RealStore or require users to review and accept the updated Terms.

Your continued use of RealStore after the updated Terms become effective constitutes acceptance of the revised Terms, where permitted by law.

23. Governing Law

These Terms shall be governed by the applicable laws of the jurisdiction in which AfiaSplendid LTD operates, subject to any mandatory consumer rights and protections that may apply.

24. Contact Us

If you have questions regarding these Terms of Use, orders, products, returns, refunds, or other RealStore matters, please contact us:

AfiaSplendid LTD

Email: contact@afiasplendid.co.site

Website: https://afiasplendid.ltd
''';
