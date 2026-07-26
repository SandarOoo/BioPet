const express = require("express");

const router = express.Router();

const {
  createOrder,
  getMyOrders,
  getOrderById,
  cancelOrder,
  getBusinessOrders,
  updateOrderStatus,
} = require(
  "../controllers/orderController"
);

const {
  protect,
} = require(
  "../middleware/auth"
);


// CREATE ORDER
router.post(
  "/",
  protect,
  createOrder
);


// GET MY ORDERS
router.get(
  "/my",
  protect,
  getMyOrders
);


// GET BUSINESS OWNER ORDERS
// MUST BE BEFORE /:id
router.get(
  "/business",
  protect,
  getBusinessOrders
);


// GET ORDER DETAIL
router.get(
  "/:id",
  protect,
  getOrderById
);

// UPDATE ORDER STATUS
router.put(
  "/:id/status",
  protect,
  updateOrderStatus
);


// CANCEL ORDER
router.put(
  "/:id/cancel",
  protect,
  cancelOrder
);


module.exports = router;