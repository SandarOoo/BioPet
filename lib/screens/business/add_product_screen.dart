import 'package:flutter/material.dart';
import '../../services/business_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({
    super.key,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final descriptionController = TextEditingController();

  // IMPORTANT:
  // Backend enum uses lowercase values
  String category = "food";

  bool loading = false;

  final BusinessService service = BusinessService();

  // =========================
  // ADD PRODUCT
  // =========================

  Future<void> addProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final body = {
        "name": nameController.text.trim(),
        "category": category,
        "price": double.parse(
          priceController.text.trim(),
        ),
        "stock": int.parse(
          stockController.text.trim(),
        ),
        "description": descriptionController.text.trim(),
        "image": "",
      };

      print("================================");
      print("ADD PRODUCT");
      print("BODY: $body");
      print("================================");

      final success = await service.addProduct(body);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Product added successfully",
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Go back to Products screen
        Navigator.pop(context, true);
      }
    } catch (e) {
      print("ADD PRODUCT ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to add product: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Product",
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              // =========================
              // IMAGE PLACEHOLDER
              // =========================

              Container(
                height: 150,
                width: double.infinity,

                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(20),

                  color:
                  Colors.green.shade50,
                ),

                child: const Icon(
                  Icons.add_photo_alternate,
                  size: 60,
                  color: Colors.green,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // =========================
              // PRODUCT NAME
              // =========================

              TextFormField(
                controller: nameController,

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return "Please enter product name";
                  }

                  return null;
                },

                decoration: InputDecoration(
                  labelText: "Product Name",

                  prefixIcon: const Icon(
                    Icons.shopping_bag,
                  ),

                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              // =========================
              // CATEGORY
              // =========================

              DropdownButtonFormField<String>(
                value: category,

                items: const [
                  DropdownMenuItem(
                    value: "food",
                    child: Text("Food"),
                  ),

                  DropdownMenuItem(
                    value: "medicine",
                    child: Text("Medicine"),
                  ),

                  DropdownMenuItem(
                    value: "toy",
                    child: Text("Toy"),
                  ),

                  DropdownMenuItem(
                    value: "accessory",
                    child: Text("Accessory"),
                  ),

                  DropdownMenuItem(
                    value: "grooming",
                    child: Text("Grooming"),
                  ),

                  DropdownMenuItem(
                    value: "other",
                    child: Text("Other"),
                  ),
                ],

                onChanged: loading
                    ? null
                    : (value) {
                  if (value == null) return;

                  setState(() {
                    category = value;
                  });
                },

                decoration: InputDecoration(
                  labelText: "Category",

                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              // =========================
              // PRICE
              // =========================

              TextFormField(
                controller: priceController,

                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return "Please enter price";
                  }

                  if (double.tryParse(
                      value.trim()) ==
                      null) {
                    return "Please enter a valid price";
                  }

                  return null;
                },

                decoration: InputDecoration(
                  labelText: "Price",

                  prefixText: "MMK ",

                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              // =========================
              // STOCK
              // =========================

              TextFormField(
                controller: stockController,

                keyboardType:
                TextInputType.number,

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return "Please enter stock";
                  }

                  if (int.tryParse(
                      value.trim()) ==
                      null) {
                    return "Please enter a valid stock";
                  }

                  return null;
                },

                decoration: InputDecoration(
                  labelText: "Stock",

                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              // =========================
              // DESCRIPTION
              // =========================

              TextFormField(
                controller:
                descriptionController,

                maxLines: 4,

                decoration: InputDecoration(
                  labelText: "Description",

                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              // =========================
              // ADD BUTTON
              // =========================

              SizedBox(
                width: double.infinity,

                height: 55,

                child: ElevatedButton(
                  onPressed:
                  loading
                      ? null
                      : addProduct,

                  child: loading
                      ? const SizedBox(
                    width: 25,
                    height: 25,

                    child:
                    CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "Add Product",

                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}