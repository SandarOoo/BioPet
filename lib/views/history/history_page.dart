import 'dart:io';

import 'package:biopet/models/history.dart';
import 'package:biopet/providers/history_provider.dart';
import 'package:biopet/services/api_service.dart';
import 'package:biopet/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();

    // load history when page opens
    Future.microtask(() async {
      final userId = await ApiService.getUserId();
      if (userId != null && userId.isNotEmpty) {
        context.read<HistoryProvider>().loadHistory(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,

      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.lightTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Classification History',
          style: TextStyle(
            color: AppColors.lightTextColor,
            fontSize: 16,
          ),
        ),
      ),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : !provider.hasHistory
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: provider.historyList.length,
        itemBuilder: (context, index) {
          return HistoryCard(
            item: provider.historyList[index],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: Color(0xFFD4E1F4)),
          SizedBox(height: 20),
          Text(
            'No Classifications Yet',
            style: TextStyle(
              color: Color(0xFFD4E1F4),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Start classifying pets to see them appear here',
            style: TextStyle(
              color: Color(0xFF58A6FF),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final EachClassifying item;

  const HistoryCard({super.key, required this.item});

  /// Safe image loader (network + local + error fallback)
  Widget buildImage(String path) {
    if (path.isEmpty) {
      return _errorBox("No Image");
    }

    // NETWORK IMAGE
    if (path.startsWith('http')) {
      return Image.network(
        path,
        height: 400,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _errorBox("Image Unavailable"),
      );
    }

    // LOCAL FILE IMAGE
    return Image.file(
      File(path),
      height: 400,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _errorBox("Image Not Found"),
    );
  }

  Widget _errorBox(String text) {
    return Container(
      height: 400,
      color: Colors.grey.shade700,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<HistoryProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // IMAGE + DELETE BUTTON
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: buildImage(item.imagePath),
              ),

              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: Colors.white,
                      content: const Text(
                        "Are you sure you want to delete this item?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  final userId = await ApiService.getUserId();

                  if (userId != null && userId.isNotEmpty) {
                    await provider.removeEntry(userId, item);
                  }
                },
              ),
            ],
          ),

          // DETAILS
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [

                // NAME + DATE
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.breeds.isNotEmpty
                            ? item.breeds.first.name
                            : "Unknown",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.formatDate(item.timestamp),
                        style: const TextStyle(
                          color: AppColors.faintTextColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // ACCURACY BADGE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "${item.breeds.isNotEmpty ? item.breeds.first.acc : 0}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}