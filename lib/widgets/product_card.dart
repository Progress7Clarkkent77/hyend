import 'package:flutter/material.dart';

//import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double price;
  final String offerTag;
  final Function onTap;
  final Function onAddToCart; // Updated to match the instantiation

  const ProductCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.offerTag,
    required this.onTap,
    required this.onAddToCart, // Updated to match the instantiation
  });

  String formatPrice(double price) {
    // Convert the price to an integer and then to a string
    String priceString = price.toStringAsFixed(0);

    // Use a regular expression to add commas
    RegExp regExp = RegExp(r'(?<=\d)(?=(\d{3})+(?!\d))');
    String formattedPrice = priceString.replaceAllMapped(
      regExp,
      (Match m) => ',',
    );

    return formattedPrice;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    final mainColor = isDarkMode ? Colors.black : Colors.black;
    final offerColor = isDarkMode ? Colors.black : Colors.black;

    return Stack(
      children: [
        InkWell(
          onTap: () {
            onTap(); // Main card tap navigates to details
          },
          child: Card(
            color: Colors.white,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.maxFinite,
                      height: 120,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    name,
                    style: TextStyle(fontSize: 16, color: mainColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'NG: ₦${formatPrice(price)}',
                    style: TextStyle(fontSize: 16, color: mainColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: offerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      offerTag,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Positioned "+" icon in the bottom right
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              // Print product details when the "+" icon is pressed
              // print('Product Name: $name');
              // print('Image URL: $imageUrl');
              // print('Price: ₦$price');
              onAddToCart(); // Calls the function to add the product to the cart
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent, // Make the background transparent
                border: Border.all(
                  color: Colors.black, // Set border color to black
                  width: 2.0, // Set border width to 2.0
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.add_shopping_cart,
                color: Colors.black,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProductCard1 extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double price;
  final String offerTag;
  final Function onTap;
  final Function onAddToCart;

  const ProductCard1({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.offerTag,
    required this.onTap,
    required this.onAddToCart,
  });

  String formatPrice(double price) {
    // Convert the price to an integer and then to a string
    String priceString = price.toStringAsFixed(0);

    // Use a regular expression to add commas
    RegExp regExp = RegExp(r'(?<=\d)(?=(\d{3})+(?!\d))');
    String formattedPrice = priceString.replaceAllMapped(
      regExp,
      (Match m) => ',',
    );

    return formattedPrice;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    final mainColor = isDarkMode ? Colors.black : Colors.black;
    final offerColor = isDarkMode ? Colors.grey[800] : Colors.green;

    return Stack(
      children: [
        InkWell(
          onTap: () {
            onTap();
          },
          child: Card(
            color: Colors.white,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.maxFinite,
                      height: 160,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    name,
                    style: TextStyle(fontSize: 16, color: mainColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'NG: ₦${formatPrice(price)}',
                    style: TextStyle(fontSize: 16, color: mainColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: offerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      offerTag,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Positioned "+" icon in the bottom right
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              // Print product details when the "+" icon is pressed
              // print('Product Name: $name');
              // print('Image URL: $imageUrl');
              // print('Price: ₦$price');
              onAddToCart(); // Calls the function to add the product to the cart
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent, // Make the background transparent
                border: Border.all(
                  color: Colors.black, // Set border color to black
                  width: 2.0, // Set border width to 2.0
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.add_shopping_cart,
                color: Colors.black,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProductCard2 extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double price;
  final String offerTag;
  final Function onTap;
  final Function onAddToCart;

  const ProductCard2({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.offerTag,
    required this.onTap,
    required this.onAddToCart,
  });

  String formatPrice(double price) {
    // Convert the price to an integer and then to a string
    String priceString = price.toStringAsFixed(0);

    // Use a regular expression to add commas
    RegExp regExp = RegExp(r'(?<=\d)(?=(\d{3})+(?!\d))');
    String formattedPrice = priceString.replaceAllMapped(
      regExp,
      (Match m) => ',',
    );

    return formattedPrice;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    final mainColor = isDarkMode ? Colors.black : Colors.black;
    final offerColor = isDarkMode ? Colors.grey[800] : Colors.green;

    return Stack(
      children: [
        InkWell(
          onTap: () {
            onTap();
          },
          child: Card(
            color: Colors.white,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.maxFinite,
                      height: 190,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    name,
                    style: TextStyle(fontSize: 16, color: mainColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'NG: ₦${formatPrice(price)}',
                    style: TextStyle(fontSize: 16, color: mainColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: offerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      offerTag,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Positioned "+" icon in the bottom right
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              // Print product details when the "+" icon is pressed
              // print('Product Name: $name');
              // print('Image URL: $imageUrl');
              // print('Price: ₦$price');
              onAddToCart(); // Calls the function to add the product to the cart
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent, // Make the background transparent
                border: Border.all(
                  color: Colors.black, // Set border color to black
                  width: 2.0, // Set border width to 2.0
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.add_shopping_cart,
                color: Colors.black,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
