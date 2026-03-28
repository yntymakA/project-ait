import 'package:flutter/material.dart';
import '../../../models/listing.dart';
import '../../core/theme/app_theme.dart';

class ListingDetailsScreen extends StatelessWidget {
  final Listing listing;

  const ListingDetailsScreen({required this.listing, super.key});

  @override
  Widget build(BuildContext context) {
    final currencySymbol = listing.currency == 'USD' ? '\$' : '₸';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(listing.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Toggle favorite
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Share link
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Carousel Header
            SizedBox(
              height: 300,
              child: listing.images.isNotEmpty
                  ? PageView.builder(
                      itemCount: listing.images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          listing.images[index].fileUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Placeholder(),
                        );
                      },
                    )
                  : const Placeholder(fallbackHeight: 300),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$currencySymbol${listing.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (listing.isNegotiable)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Negotiable', style: TextStyle(color: Colors.green)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    listing.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(listing.city, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(listing.description, style: const TextStyle(fontSize: 16, height: 1.5)),
                  
                  // Seller info would go here eventually.
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Open chat
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Message Seller'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
