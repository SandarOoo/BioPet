const Order = require("../models/Order");

// GET SELLER ORDERS
exports.getSellerOrders = async (req, res) => {
  try {
    const orders = await Order.find({
      seller: req.user._id,
    })
      .populate("customer", "name email phone")
      .populate("items.product", "name image")
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      orders,
    });
  } catch (err) {
    console.error("Get Seller Orders Error:", err);

    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};

// GET SINGLE ORDER
exports.getOrderById = async (req, res) => {
  try {
    const order = await Order.findOne({
      _id: req.params.id,
      seller: req.user._id,
    })
      .populate("customer", "name email phone")
      .populate("items.product", "name image");

    if (!order) {
      return res.status(404).json({
        success: false,
        message: "Order not found",
      });
    }

    res.status(200).json({
      success: true,
      order,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};

// UPDATE ORDER STATUS
exports.updateOrderStatus = async (req, res) => {
  try {
    const { status } = req.body;

    const allowedStatuses = [
      "pending",
      "confirmed",
      "processing",
      "shipped",
      "delivered",
      "cancelled",
    ];

    if (!allowedStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: "Invalid order status",
      });
    }

    const order = await Order.findOne({
      _id: req.params.id,
      seller: req.user._id,
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: "Order not found",
      });
    }

    order.status = status;

    await order.save();

    res.status(200).json({
      success: true,
      message: "Order status updated",
      order,
    });
  } catch (err) {
    console.error("Update Order Status Error:", err);

    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};