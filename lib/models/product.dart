class Product {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final int stock;
  final String image;

  final String ownerName;
  final String shopName;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.stock,
    required this.image,
    required this.ownerName,
    required this.shopName,
  });

  factory Product.fromJson(
      Map<String, dynamic> json,
      ) {

    final owner =
    json['owner'];

    String ownerName =
        '';

    String shopName =
        '';


    if (owner is Map) {

      ownerName =
          owner['name']
              ?.toString() ??
              '';

      final businessProfile =
      owner[
      'businessProfile'
      ];

      if (
      businessProfile
      is Map
      ) {

        shopName =
            businessProfile[
            'businessName'
            ]
                ?.toString() ??
                '';

      }

    }


    return Product(

      id:
      json['_id']
          ?.toString() ??
          '',

      name:
      json['name']
          ?.toString() ??
          '',

      category:
      json['category']
          ?.toString() ??
          '',

      description:
      json['description']
          ?.toString() ??
          '',

      price:
      double.tryParse(
        json['price']
            ?.toString() ??
            '0',
      ) ??
          0,

      stock:
      int.tryParse(
        json['stock']
            ?.toString() ??
            '0',
      ) ??
          0,

      image:
      json['image']
          ?.toString() ??
          '',

      ownerName:
      ownerName,

      shopName:
      shopName,

    );
  }
}