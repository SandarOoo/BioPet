import 'dart:convert';
import 'package:biopet/services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class BusinessService {
  final String baseUrl =dotenv.env['BASE_URL'] ?? "";

  // get_products

  Future<List<Product>> getProducts() async {

    final token = await ApiService.getToken();

    final response = await http.get(
      Uri.parse(
          "${ApiService.baseUrl}/business/products"
      ),
      headers:{
        "Authorization":"Bearer $token"
      },
    );


    final data = jsonDecode(response.body);


    if(response.statusCode == 200){

      return (data["products"] as List)
          .map(
              (item)=>Product.fromJson(item)
      )
          .toList();

    }else{

      throw Exception(
          data["message"] ?? "Failed to load products"
      );

    }

  }



  Future<bool> addProduct(
      Map body
      ) async{
    final token =
    await ApiService.getToken();


    final response =
    await http.post(

        Uri.parse(
            "${ApiService.baseUrl}/business/createProducts"
        ),

        headers:{
          "Authorization":
          "Bearer $token",
          "Content-Type":
          "application/json"
        },
        body: jsonEncode(body));
    final data=jsonDecode(response.body);
    return data["success"];
  }

  Future<bool> deleteProduct(String id) async {


    final token =
    await ApiService.getToken();


    final response =
    await http.delete(

      Uri.parse(
        "${ApiService.baseUrl}/api/business/products/$id",
      ),


      headers:{
        "Authorization":"Bearer $token"
      },


    );


    final data=jsonDecode(response.body);


    return data['success']==true;

  }


  Future<bool> acceptAgreement(String token) async {
    final response = await http.put(Uri.parse("$baseUrl/api/business/agreement"),
    headers: {
      "Content-Type":"application/json",
      "Authorization":"Bearer $token",
    },
      body: jsonEncode({"accepted": true})
    );
    
    final data = jsonDecode(response.body);

    if(response.statusCode== 200 && data["success"]== true){
      return true;
    }
    return false;
  }

  Future<bool> updateLocation(
      String token,
      double latitude,
      double longitude,
      ) async {

    final response = await http.put(

      Uri.parse(
          "$baseUrl/api/business/location"
      ),

      headers:{
        "Content-Type":"application/json",
        "Authorization":"Bearer $token"
      },

      body: jsonEncode({

        "latitude": latitude,
        "longitude": longitude

      }),

    );


    final data = jsonDecode(response.body);


    return response.statusCode == 200 &&
        data["success"] == true;

  }

  Future<bool> submitBusiness(String token) async {

    final response = await http.put(

      Uri.parse(
          "$baseUrl/api/business/submit"
      ),

      headers:{
        "Authorization":"Bearer $token",
        "Content-Type":"application/json",
      },

    );


    final data = jsonDecode(response.body);


    return response.statusCode == 200 &&
        data["success"] == true;

  }
}