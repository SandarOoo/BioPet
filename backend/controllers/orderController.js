const Order = require("../models/Order");
const Product = require("../models/Product");

// =====================================================
// CREATE ORDER
// =====================================================

exports.createOrder = async (req, res) => {
  try {
    const {
      items,
      shippingAddress,
      paymentMethod,
    } = req.body;

    if (!items || items.length === 0) {
      return res.status(400).json({
        success: false,
        message: "Cart is empty",
      });
    }

    let totalAmount = 0;

    const orderItems = [];

    for (const item of items) {
      const product = await Product.findById(item.product);

      if (!product) {
        return res.status(404).json({
          success: false,
          message: `Product not found: ${item.product}`,
        });
      }

      if (product.stock < item.quantity) {
        return res.status(400).json({
          success: false,
          message: `${product.name} does not have enough stock`,
        });
      }

      const subtotal =
        Number(product.price) *
        Number(item.quantity);

      totalAmount += subtotal;

      orderItems.push({
        product: product._id,
        name: product.name,
        image: product.image || "",
        price: product.price,
        quantity: item.quantity,
        subtotal,
      });
    }

    const orderNumber =
      "BP" +
      Date.now().toString().slice(-8);

    const order = await Order.create({
      orderNumber,

      customer: req.user._id,

      items: orderItems,

      totalAmount,

      shippingAddress,

      paymentMethod:
        paymentMethod || "COD",

      paymentStatus: "Pending",

      status: "Pending",
    });

    // Reduce stock
    for (const item of items) {
      await Product.findByIdAndUpdate(
        item.product,
        {
          $inc: {
            stock: -item.quantity,
          },
        }
      );
    }

    const populatedOrder =
      await Order.findById(order._id)
        .populate(
          "customer",
          "name email phone"
        )
        .populate(
          "items.product"
        );

    return res.status(201).json({
      success: true,

      message:
        "Order created successfully",

      order:
        populatedOrder,
    });

  } catch (error) {
    console.error(
      "CREATE ORDER ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};


// =====================================================
// GET MY ORDERS
// =====================================================

exports.getMyOrders = async (
  req,
  res
) => {
  try {
    const orders =
      await Order.find({
        customer:
          req.user._id,
      })
        .populate(
          "items.product"
        )
        .sort({
          createdAt: -1,
        });

    return res.status(200).json({
      success: true,
      orders,
    });

  } catch (error) {
    console.error(
      "GET MY ORDERS ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};


// =====================================================
// GET SINGLE ORDER
// =====================================================

exports.getOrderById = async (
  req,
  res
) => {
  try {
    const order =
      await Order.findOne({
        _id: req.params.id,

        customer:
          req.user._id,
      })
        .populate(
          "customer",
          "name email phone"
        )
        .populate(
          "items.product"
        );

    if (!order) {
      return res.status(404).json({
        success: false,
        message: "Order not found",
      });
    }

    return res.status(200).json({
      success: true,
      order,
    });

  } catch (error) {
    console.error(
      "GET ORDER ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};


// =====================================================
// CANCEL ORDER
// =====================================================

exports.cancelOrder = async (
  req,
  res
) => {
  try {
    const order =
      await Order.findOne({
        _id: req.params.id,

        customer:
          req.user._id,
      });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: "Order not found",
      });
    }

    if (
      order.status !==
      "Pending"
    ) {
      return res.status(400).json({
        success: false,

        message:
          "Only pending orders can be cancelled",
      });
    }

    order.status =
      "Cancelled";

    await order.save();

    // Restore stock
    for (
      const item of order.items
    ) {
      await Product.findByIdAndUpdate(
        item.product,
        {
          $inc: {
            stock:
              item.quantity,
          },
        }
      );
    }

    return res.status(200).json({
      success: true,

      message:
        "Order cancelled successfully",

      order,
    });

  } catch (error) {
    console.error(
      "CANCEL ORDER ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// =====================================================
// GET BUSINESS OWNER ORDERS
// =====================================================

// =====================================================
// GET BUSINESS OWNER ORDERS
// =====================================================

// =====================================================
// GET BUSINESS OWNER ORDERS
// =====================================================

exports.getBusinessOrders = async (req, res) => {
  try {
    const sellerId = req.user._id;

    // Product schema uses `seller`, not `owner`.
    const sellerProducts = await Product.find({
      seller: sellerId,
    }).select("_id");

    const productIds = sellerProducts.map(
      (product) => product._id
    );

    if (productIds.length === 0) {
      return res.status(200).json({
        success: true,
        orders: [],
      });
    }

    const productIdSet = new Set(
      productIds.map((id) => id.toString())
    );

    const orders = await Order.find({
      "items.product": {
        $in: productIds,
      },
    })
      .populate(
        "customer",
        "name email phone"
      )
      .populate({
        path: "items.product",
        select:
          "name image price stock category seller",
      })
      .sort({
        createdAt: -1,
      });

    const businessOrders = orders
      .map((order) => {
        const filteredItems =
          order.items.filter((item) => {
            if (!item.product) {
              return false;
            }

            return productIdSet.has(
              item.product._id.toString()
            );
          });

        return {
          _id: order._id,
          orderNumber: order.orderNumber,
          customer: order.customer,
          items: filteredItems,
          totalAmount: filteredItems.reduce(
            (total, item) =>
              total +
              Number(item.price) *
                Number(item.quantity),
            0
          ),
          shippingAddress:
            order.shippingAddress,
          paymentMethod:
            order.paymentMethod,
          paymentStatus:
            order.paymentStatus,
          status: order.status,
          createdAt: order.createdAt,
          updatedAt: order.updatedAt,
        };
      })
      .filter(
        (order) => order.items.length > 0
      );

    return res.status(200).json({
      success: true,
      orders: businessOrders,
    });
  } catch (error) {
    console.error(
      "GET BUSINESS ORDERS ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// =====================================================
// GET ALL ORDERS - ADMIN
// =====================================================

exports.getAllOrders = async (req, res) => {
  try {
    const orders = await Order.find()
      .populate(
        "customer",
        "name email phone"
      )
      .populate(
        "items.product"
      )
      .sort({
        createdAt: -1,
      });

    return res.status(200).json({
      success: true,
      orders,
    });
  } catch (error) {
    console.error(
      "GET ALL ORDERS ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};


// =====================================================
// UPDATE ORDER STATUS - BUSINESS OWNER
// =====================================================

exports.updateOrderStatus = async (req, res) => {
  try {
    const { status } = req.body;

    const allowedStatuses = [
      "Pending",
      "Confirmed",
      "Processing",
      "Shipped",
      "Delivered",
      "Cancelled",
    ];

    if (
      !status ||
      !allowedStatuses.includes(status)
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid order status",
        allowedStatuses,
      });
    }

    const order = await Order.findById(
      req.params.id
    ).populate({
      path: "items.product",
      select:
        "name image price stock category seller",
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: "Order not found",
      });
    }

    // Product schema uses `seller`, not `owner`.
    const isSellerOfOrder =
      order.items.some((item) => {
        const productSeller =
          item.product?.seller;

        if (!productSeller) {
          return false;
        }

        return (
          productSeller.toString() ===
          req.user._id.toString()
        );
      });

    if (!isSellerOfOrder) {
      return res.status(403).json({
        success: false,
        message:
          "You are not authorized to update this order",
      });
    }

    order.status = status;
    await order.save();

    const updatedOrder =
      await Order.findById(order._id)
        .populate(
          "customer",
          "name email phone"
        )
        .populate({
          path: "items.product",
          select:
            "name image price stock category seller",
        });

    return res.status(200).json({
      success: true,
      message:
        "Order status updated successfully",
      order: updatedOrder,
    });
  } catch (error) {
    console.error(
      "UPDATE ORDER STATUS ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// =====================================================
// GET ALL ORDERS - ADMIN DASHBOARD
// =====================================================

