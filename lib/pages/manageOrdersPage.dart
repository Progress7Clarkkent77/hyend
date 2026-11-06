import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyend/controllers/manageOrdersController.dart';
import 'package:hyend/models/orderModel.dart';
import 'package:hyend/pages/app_palette.dart';

import 'package:intl/intl.dart';

//==================================================
// SHARED HELPERS
//==================================================

Color _statusColor(AppPalette p, String status) {
  switch (status.toLowerCase()) {
    case 'delivered':
      return p.success;
    case 'cancelled':
      return p.danger;
    case 'shipping':
      return p.info;
    default:
      return p.warning;
  }
}

/// Safe even if an id is shorter than 8 characters.
String _shortId(String id) => id.length <= 8 ? id : id.substring(0, 8);

//==================================================
// MANAGE ORDERS
//==================================================

class ManageOrdersPage extends StatelessWidget {
  ManageOrdersPage({super.key});

  final ManageOrdersController ctrl = Get.put(ManageOrdersController());

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isDesktop = width > 900;

    return Obx(() {
      final p = AppPalette.current();

      return Scaffold(
        backgroundColor: p.bg,
        appBar: p.appBar('Manage Orders'),
        body: Obx(() {
          if (ctrl.isLoading.value) {
            return Center(child: CircularProgressIndicator(color: p.text));
          }

          if (ctrl.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 80, color: p.muted),
                  const SizedBox(height: 15),
                  Text(
                    'No Orders Found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: p.text,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: ctrl.orders.length,
            itemBuilder: (_, index) {
              final order = ctrl.orders[index];

              return _orderCard(p, order, isDesktop);
            },
          );
        }),
      );
    });
  }

  Widget _orderCard(AppPalette p, OrderModel order, bool isDesktop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: p.cardDecoration(),
      child: isDesktop ? _desktopLayout(p, order) : _mobileLayout(p, order),
    );
  }

  Widget _desktopLayout(AppPalette p, OrderModel order) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _productImage(p, order),
        const SizedBox(width: 20),
        Expanded(child: _orderInfo(p, order)),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _statusChip(p, order),
            const SizedBox(height: 12),
            _locationChip(p, order),
            const SizedBox(height: 18),
            _actionButtons(p, order),
          ],
        ),
      ],
    );
  }

  Widget _mobileLayout(AppPalette p, OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _productImage(p, order),
            const SizedBox(width: 15),
            Expanded(child: _orderInfo(p, order)),
          ],
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [_statusChip(p, order), _locationChip(p, order)],
        ),
        const SizedBox(height: 15),
        _actionButtons(p, order),
      ],
    );
  }

  Widget _productImage(AppPalette p, OrderModel order) {
    final image = order.items.isEmpty ? '' : order.items.first.image;

    return Container(
      width: 95,
      height: 95,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.tile,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
      ),
      child: image.isEmpty
          ? Icon(Icons.image_outlined, size: 40, color: p.muted)
          : Image.memory(base64Decode(image), fit: BoxFit.cover),
    );
  }

  Widget _orderInfo(AppPalette p, OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order #${_shortId(order.id).toUpperCase()}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: p.text,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          order.customerName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: p.text,
          ),
        ),
        const SizedBox(height: 5),
        Text(order.customerPhoneNumber, style: TextStyle(color: p.muted)),
        const SizedBox(height: 10),
        Text(
          '${order.items.length} Item(s)',
          style: TextStyle(fontWeight: FontWeight.w500, color: p.text),
        ),
        const SizedBox(height: 6),
        Text(
          '₦${order.totalAmount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: p.text,
          ),
        ),
        const SizedBox(height: 8),
        if (order.createdAt != null)
          Text(
            DateFormat('dd MMM yyyy • hh:mm a').format(order.createdAt!),
            style: TextStyle(color: p.muted, fontSize: 13),
          ),
      ],
    );
  }

  Widget _statusChip(AppPalette p, OrderModel order) {
    final color = _statusColor(p, order.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(.4)),
      ),
      child: Text(
        order.status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _locationChip(AppPalette p, OrderModel order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: p.tile,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        order.currentLocation.isEmpty
            ? 'Location Not Updated'
            : order.currentLocation,
        style: TextStyle(fontWeight: FontWeight.w600, color: p.text),
      ),
    );
  }

  Widget _actionButtons(AppPalette p, OrderModel order) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        OutlinedButton.icon(
          style: p.outlinedButton(),
          icon: const Icon(Icons.visibility_outlined),
          onPressed: () {
            Get.to(() => OrderDetailsPage(order: order));
          },
          label: const Text('View Details'),
        ),
        ElevatedButton.icon(
          style: p.primaryButton(radius: 14),
          icon: const Icon(Icons.edit_location_alt_outlined),
          onPressed: () {
            Get.to(() => UpdateOrderStatusPage(order: order));
          },
          label: const Text('Update Status'),
        ),
      ],
    );
  }
}

//==================================================
// ORDER DETAILS
//==================================================

class OrderDetailsPage extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isDesktop = width > 900;

    return Obx(() {
      final p = AppPalette.current();

      return Scaffold(
        backgroundColor: p.bg,
        appBar: p.appBar('Order Details'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _customerCard(p)),
                        const SizedBox(width: 20),
                        Expanded(flex: 3, child: _productsCard(p)),
                      ],
                    )
                  : Column(
                      children: [
                        _customerCard(p),
                        const SizedBox(height: 20),
                        _productsCard(p),
                      ],
                    ),
            ),
          ),
        ),
      );
    });
  }

  Widget _customerCard(AppPalette p) {
    final statusColor = _statusColor(p, order.status);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: p.cardDecoration(radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: p.text,
            ),
          ),
          const SizedBox(height: 20),
          _infoTile(p, Icons.person_outline, 'Customer', order.customerName),
          _infoTile(
            p,
            Icons.phone_outlined,
            'Phone',
            order.customerPhoneNumber,
          ),
          _infoTile(
            p,
            Icons.location_on_outlined,
            'Address',
            order.customerDeliveryAddress,
          ),
          _infoTile(
            p,
            Icons.route_outlined,
            'Current Location',
            order.currentLocation.isEmpty
                ? 'Not Updated'
                : order.currentLocation,
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: statusColor.withOpacity(.4)),
            ),
            child: Text(
              order.status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '₦${order.totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: p.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _productsCard(AppPalette p) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: p.cardDecoration(radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ordered Products',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: p.text,
            ),
          ),
          const SizedBox(height: 20),
          ...order.items.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: p.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: p.tile,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: item.image.isEmpty
                        ? Icon(Icons.image_outlined, color: p.muted)
                        : Image.memory(
                            base64Decode(item.image),
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: p.text,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Quantity: ${item.quantity}',
                          style: TextStyle(color: p.muted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₦${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: p.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 35, color: p.border),
          _totalRow(p, 'Subtotal', '₦${order.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          _totalRow(
            p,
            'Delivery Fee',
            '₦${order.deliveryFee.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 10),
          _totalRow(
            p,
            'Total Amount',
            '₦${order.totalAmount.toStringAsFixed(2)}',
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _infoTile(AppPalette p, IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: p.text),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: p.muted)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.w600, color: p.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(
    AppPalette p,
    String title,
    String value, {
    bool bold = false,
  }) {
    final style = TextStyle(
      color: p.text,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );

    return Row(
      children: [
        Text(title, style: style),
        const Spacer(),
        Text(value, style: style),
      ],
    );
  }
}

//==================================================
// UPDATE ORDER STATUS
//==================================================

class UpdateOrderStatusPage extends StatefulWidget {
  final OrderModel order;

  const UpdateOrderStatusPage({super.key, required this.order});

  @override
  State<UpdateOrderStatusPage> createState() => _UpdateOrderStatusPageState();
}

class _UpdateOrderStatusPageState extends State<UpdateOrderStatusPage> {
  final ctrl = Get.find<ManageOrdersController>();

  late String selectedStatus;
  late String selectedLocation;

  final List<String> orderStatuses = [
    'Processing',
    'Shipping',
    'Delivered',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();

    final rawStatus = widget.order.status.trim();

    selectedStatus = orderStatuses.contains(rawStatus)
        ? rawStatus
        : 'Processing';

    selectedLocation = widget.order.currentLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = AppPalette.current();

      return Scaffold(
        backgroundColor: p.bg,
        appBar: p.appBar('Update Order'),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: p.cardDecoration(radius: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Information',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: p.text,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Order #${_shortId(widget.order.id)}',
                      style: TextStyle(color: p.text),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.order.customerName,
                      style: TextStyle(color: p.muted),
                    ),
                    const SizedBox(height: 25),

                    /// STATUS DROPDOWN
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      dropdownColor: p.surface,
                      style: p.fieldStyle,
                      iconEnabledColor: p.muted,
                      decoration: p.input('Order Status', fill: p.tile),
                      items: orderStatuses
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          selectedStatus = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    /// LOCATION DROPDOWN
                    DropdownButtonFormField<String>(
                      // Guard: a saved location missing from the list would
                      // otherwise trip a Flutter assertion.
                      value: ctrl.trackingLocations.contains(selectedLocation)
                          ? selectedLocation
                          : null,
                      dropdownColor: p.surface,
                      style: p.fieldStyle,
                      iconEnabledColor: p.muted,
                      decoration: p.input('Current Location', fill: p.tile),
                      items: ctrl.trackingLocations
                          .map(
                            (location) => DropdownMenuItem(
                              value: location,
                              child: Text(location),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          selectedLocation = value;
                        });
                      },
                    ),

                    const SizedBox(height: 35),

                    /// SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        style: p.primaryButton(),
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save Changes'),
                        onPressed: () async {
                          await ctrl.updateOrder(
                            orderId: widget.order.id,
                            delivered:
                                selectedStatus.toLowerCase() == 'delivered',
                            currentLocation: selectedLocation,
                            status: selectedStatus,
                          );

                          Get.back();

                          AppPalette.snack(
                            'Success',
                            'Order updated successfully',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
