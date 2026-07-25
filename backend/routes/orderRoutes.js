const express = require("express");

const router =
  express.Router();

const {
  createOrder,
  getMyOrders,
  getOrderById,
  cancelOrder,
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


// GET ORDER DETAIL
router.get(
  "/:id",
  protect,
  getOrderById
);


// CANCEL ORDER
router.put(
  "/:id/cancel",
  protect,
  cancelOrder
);


module.exports =
  router;