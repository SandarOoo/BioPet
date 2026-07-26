class BusinessOrder {
  final String id;
  final String orderNumber;

  final Customer customer;

  final List<BusinessOrderItem> items;

  final double totalAmount;

  final ShippingAddress shippingAddress;

  final String paymentMethod;
  final String paymentStatus;
  final String status;

  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessOrder({
    required this.id,
    required this.orderNumber,
    required this.customer,
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusinessOrder.fromJson(
      Map<String, dynamic> json,
      ) {
    return BusinessOrder(
      id: json['_id'] ?? '',

      orderNumber:
      json['orderNumber'] ?? '',

      customer:
      Customer.fromJson(
        json['customer'] ?? {},
      ),

      items:
      (json['items'] as List? ?? [])
          .map(
            (item) =>
            BusinessOrderItem.fromJson(
              item,
            ),
      )
          .toList(),

      totalAmount:
      (json['totalAmount'] ?? 0)
          .toDouble(),

      shippingAddress:
      ShippingAddress.fromJson(
        json['shippingAddress'] ?? {},
      ),

      paymentMethod:
      json['paymentMethod'] ?? '',

      paymentStatus:
      json['paymentStatus'] ?? '',

      status:
      json['status'] ?? '',

      createdAt:
      DateTime.tryParse(
        json['createdAt'] ?? '',
      ) ??
          DateTime.now(),

      updatedAt:
      DateTime.tryParse(
        json['updatedAt'] ?? '',
      ) ??
          DateTime.now(),
    );
  }
}


// =====================================================
// CUSTOMER
// =====================================================

class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory Customer.fromJson(
      Map<String, dynamic> json,
      ) {
    return Customer(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}


// =====================================================
// ORDER ITEM
// =====================================================

class BusinessOrderItem {
  final String productId;
  final String name;
  final String image;

  final double price;
  final int quantity;
  final double subtotal;

  BusinessOrderItem({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory BusinessOrderItem.fromJson(
      Map<String, dynamic> json,
      ) {
    final product =
    json['product'] is Map
        ? json['product']
    as Map<String, dynamic>
        : null;

    return BusinessOrderItem(
      productId:
      product?['_id'] ??
          json['product'] ??
          '',

      name:
      json['name'] ??
          product?['name'] ??
          '',

      image:
      json['image'] ??
          product?['image'] ??
          '',

      price:
      (json['price'] ?? 0)
          .toDouble(),

      quantity:
      json['quantity'] ?? 0,

      subtotal:
      (json['subtotal'] ??
          ((json['price'] ?? 0) *
              (json['quantity'] ?? 0)))
          .toDouble(),
    );
  }
}


// =====================================================
// SHIPPING ADDRESS
// =====================================================

class ShippingAddress {
  final String name;
  final String phone;
  final String address;

  ShippingAddress({
    required this.name,
    required this.phone,
    required this.address,
  });

  factory ShippingAddress.fromJson(
      Map<String, dynamic> json,
      ) {
    return ShippingAddress(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
    );
  }
}