class Product {


final String id;

final String name;

final String category;

final int price;

final int stock;

final String image;



Product({

required this.id,

required this.name,

required this.category,

required this.price,

required this.stock,

required this.image,

});



factory Product.fromJson(Map<String,dynamic> json){

return Product(

id:json["_id"],

name:json["name"],

category:json["category"],

price:json["price"],

stock:json["stock"],

image:json["image"] ?? "",


);

}


}