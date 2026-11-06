import 'package:flutter/material.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    int crossAxisCount = 2;

    if (width >= 1400) {
      crossAxisCount = 6;
    } else if (width >= 1000) {
      crossAxisCount = 5;
    } else if (width >= 700) {
      crossAxisCount = 4;
    } else if (width >= 500) {
      crossAxisCount = 3;
    }

    final categories = [
      {"name": "Electronics", "count": "320 Products"},
      {"name": "Fashion", "count": "210 Products"},
      {"name": "Phones", "count": "180 Products"},
      {"name": "Beauty", "count": "95 Products"},
      {"name": "Sports", "count": "140 Products"},
      {"name": "Home & Living", "count": "250 Products"},
      {"name": "Computers", "count": "130 Products"},
      {"name": "Accessories", "count": "400 Products"},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Categories",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search categories...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: .85,
              ),
              itemBuilder: (_, index) {
                final category = categories[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(22),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                "IMAGE",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  category["name"]!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  category["count"]!,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
