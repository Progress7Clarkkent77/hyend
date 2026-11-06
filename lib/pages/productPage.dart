import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ecommerce_routes.dart';

class ProductsPage extends StatelessWidget {
  ProductsPage({super.key});

  final nav = Get.find<EcommerceLiveNavController>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    int crossAxisCount = 2;

    if (width >= 1400) {
      crossAxisCount = 6;
    } else if (width >= 1100) {
      crossAxisCount = 5;
    } else if (width >= 800) {
      crossAxisCount = 4;
    } else if (width >= 600) {
      crossAxisCount = 3;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Products",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              nav.goTo(EcommerceLiveRoutes.cart);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _searchAndFilter(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 20,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: .72,
              ),
              itemBuilder: (_, index) => _productCard(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Search products...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip("All"),
                _filterChip("Newest"),
                _filterChip("Popular"),
                _filterChip("Price"),
                _filterChip("Featured"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: OutlinedButton(onPressed: () {}, child: Text(title)),
    );
  }

  Widget _productCard(int index) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        nav.goTo(EcommerceLiveRoutes.productDetails);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: const Center(
                  child: Text(
                    "IMAGE",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Premium Product ${index + 1}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "₦25,000",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.shopping_cart_outlined,
                            size: 18,
                          ),
                          label: const Text("Add"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
