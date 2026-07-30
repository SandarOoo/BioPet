class BusinessOrder {
  final String id;
  final String orderNumber;
  final String status;
  final double totalAmount;
  final DateTime? createdAt;

  final CustomerInfo customer;

  final List<OrderItem> items;

  final ShippingAddress shippingAddress;

  BusinessOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.customer,
    required this.items,
    required this.shippingAddress,
  });

  factory BusinessOrder.fromJson(
      Map<String, dynamic> json,
      ) {
    return BusinessOrder(
      id: (
          json['_id'] ??
              json['id'] ??
              ''
      ).toString(),

      orderNumber: (
          json['orderNumber'] ??
              json['_id'] ??
              'Order'
      ).toString(),

      status: (
          json['status'] ??
              'pending'
      ).toString(),

      totalAmount:
      _toDouble(
        json['totalAmount'] ??
            json['total'] ??
            json['amount'] ??
            0,
      ),

      createdAt:
      _parseDate(
        json['createdAt'],
      ),

      customer:
      _parseCustomer(
        json['customer'],
      ),

      items:
      _parseItems(
        json['items'],
      ),

      shippingAddress:
      _parseShippingAddress(
        json['shippingAddress'],
      ),
    );
  }

  static double _toDouble(
      dynamic value,
      ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0.0;
  }

  static DateTime? _parseDate(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  static CustomerInfo _parseCustomer(
      dynamic value,
      ) {
    if (value is Map) {
      return CustomerInfo.fromJson(
        Map<String, dynamic>.from(value),
      );
    }

    return CustomerInfo(
      name: 'Customer',
      email: '',
      phone: '',
    );
  }

  static List<OrderItem> _parseItems(
      dynamic value,
      ) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) =>
          OrderItem.fromJson(
            Map<String, dynamic>.from(item),
          ),
    )
        .toList();
  }

  static ShippingAddress
  _parseShippingAddress(
      dynamic value,
      ) {
    if (value is Map) {
      return ShippingAddress.fromJson(
        Map<String, dynamic>.from(value),
      );
    }

    return ShippingAddress(
      name: '',
      phone: '',
      address: '',
    );
  }
}

// =====================================================
// CUSTOMER
// =====================================================

class CustomerInfo {
  final String name;
  final String email;
  final String phone;

  CustomerInfo({
    required this.name,
    required this.email,
    required this.phone,
  });

  factory CustomerInfo.fromJson(
      Map<String, dynamic> json,
      ) {
    return CustomerInfo(
      name: (
          json['name'] ??
              'Customer'
      ).toString(),

      email: (
          json['email'] ??
              ''
      ).toString(),

      phone: (
          json['phone'] ??
              ''
      ).toString(),
    );
  }
}

// =====================================================
// ORDER ITEM
// =====================================================

class OrderItem {
  final String productId;
  final String name;
  final String image;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromJson(
      Map<String, dynamic> json,
      ) {
    dynamic product =
    json['product'];

    String productId = '';

    if (product is Map) {
      productId = (
          product['_id'] ??
              product['id'] ??
              ''
      ).toString();
    } else {
      productId =
          product?.toString() ?? '';
    }

    return OrderItem(
      productId: productId,

      name: (
          json['name'] ??
              'Product'
      ).toString(),

      image: (
          json['image'] ??
              ''
      ).toString(),

      price:
      _toDouble(
        json['price'],
      ),

      quantity:
      _toInt(
        json['quantity'],
      ),
    );
  }

  static double _toDouble(
      dynamic value,
      ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0.0;
  }

  static int _toInt(
      dynamic value,
      ) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
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
      name: (
          json['name'] ??
              ''
      ).toString(),

      phone: (
          json['phone'] ??
              ''
      ).toString(),

      address: (
          json['address'] ??
              ''
      ).toString(),
    );
  }
}