import 'package:biopet/services/admin_service.dart';
import 'package:flutter/material.dart';

class AdminBusinessListScreen extends StatefulWidget {
  const AdminBusinessListScreen({super.key});

  @override
  State<AdminBusinessListScreen> createState() =>
      _AdminPendingBusinessScreenState();
}

class _AdminPendingBusinessScreenState
    extends State<AdminBusinessListScreen> {

  List businesses = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadBusinesses();
  }

  final AdminService service = AdminService();

  Future<void> loadBusinesses() async {
    try {
      businesses = await service.getPendingBusinesses();
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      loading = false;
    });
  }


  Future<void> showRejectDialog(Map<String, dynamic> business) async {

    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(

          title: const Text("Reject Business"),

          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Reject Reason",
              border: OutlineInputBorder(),
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {

                if (controller.text.trim().isEmpty) {
                  return;
                }

                final ok = await service.rejectBusiness(
                  business["_id"],
                  controller.text.trim(),
                );

                if (mounted) {
                  Navigator.pop(context);
                }

                if (ok) {

                  loadBusinesses();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Business Rejected"),
                      ),
                    );
                  }

                }

              },
              child: const Text("Reject"),
            ),

          ],
        );

      },
    );

  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Businesses"),
      ),

      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: businesses.length,
        itemBuilder: (context, index) {

          final item = businesses[index];

          final profile = item["businessProfile"];

          return Card(
            margin: const EdgeInsets.all(10),

            child: Padding(
              padding: const EdgeInsets.all(15),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(
                    profile["businessName"] ?? "",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(item["name"]),

                  Text(item["email"]),

                  Text(profile["address"] ?? ""),

                  const SizedBox(height: 15),

                  Row(
                    children: [

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),

                          onPressed: () async {

                            final ok = await service.approveBusiness(
                              item["_id"],
                            );

                            if (ok) {

                              loadBusinesses();

                              if(mounted){

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Business Approved"),
                                  ),
                                );

                              }

                            }

                          },
                          child: const Text("Approve"),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),

                          onPressed: () {
                            showRejectDialog(item);
                          },

                          child: const Text("Reject"),
                        ),
                      ),

                    ],
                  )

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}