const express = require("express");

const router = express.Router();

const {
  getSellerOrders,
  getOrderById,
  updateOrderStatus,
} = require("../controllers/orderController");

const { protect } = require("../middleware/auth");

// Seller orders
router.get(
  "/seller",
  protect,
  getSellerOrders
);

// Single order
router.get(
  "/:id",
  protect,
  getOrderById
);

// Update status
router.put(
  "/:id/status",
  protect,
  updateOrderStatus
);

module.exports = router;