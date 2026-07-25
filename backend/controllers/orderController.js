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