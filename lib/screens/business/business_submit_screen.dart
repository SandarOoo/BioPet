import 'package:biopet/services/api_service.dart';
import 'package:flutter/material.dart';
import '../../services/business_service.dart';
import 'business_pending_screen.dart';


class BusinessSubmitScreen extends StatefulWidget {
  const BusinessSubmitScreen({
    super.key,
  });

  @override
  State<BusinessSubmitScreen> createState()
  => _BusinessSubmitScreenState();
}

class _BusinessSubmitScreenState
    extends State<BusinessSubmitScreen>{
  bool loading = false;
  final BusinessService service =
  BusinessService();

  Future<void> submit() async {

    setState(() {
      loading = true;
    });

    final token = await ApiService.getToken();

    if (token == null) {
      setState(() {
        loading = false;
      });
      return;
    }

    final success = await service.submitBusiness(token);

    setState(() {
      loading = false;
    });

    if (success) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const BusinessPendingScreen(),
        ),
      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Submit failed"),
        ),
      );

    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title:
        const Text(
            "Submit Application"
        ),
      ),
      body:
      Padding(
        padding:
        const EdgeInsets.all(20),
        child:
        Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children:[
            const Icon(
              Icons.store,
              size:80,
            ),
            const SizedBox(
                height:20
            ),
            const Text(
              "Your shop information is complete.\nSubmit for admin review.",
              textAlign:TextAlign.center,
            ),
            const SizedBox(
                height:30
            ),
            SizedBox(
              width:double.infinity,
              child:
              ElevatedButton(
                onPressed:
                loading
                    ? null
                    : submit,
                child:
                loading
                    ?
                const CircularProgressIndicator()
                    :
                const Text(
                    "Submit Application"
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}