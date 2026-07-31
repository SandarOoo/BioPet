const express = require("express");
const router = express.Router();

const {
  protect,
  adminOnly,
} = require("../middleware/auth");

const {
  getPendingBusinesses,
  approveBusiness,
  rejectBusiness,
  getDashboardStats,
  getAllOrders,
  getAllProductsAdmin,
    deleteProductAdmin,
} = require("../controllers/adminController");

// =====================================================
// DASHBOARD STATISTICS
// =====================================================

router.get(
  "/dashboard/stats",
  protect,
  adminOnly,
  getDashboardStats
);

// =====================================================
// PENDING BUSINESSES
// =====================================================

router.get(
  "/businesses/pending",
  protect,
  adminOnly,
  getPendingBusinesses
);

// =====================================================
// APPROVE BUSINESS
// =====================================================

router.put(
  "/businesses/:userId/approve",
  protect,
  adminOnly,
  approveBusiness
);

// =====================================================
// REJECT BUSINESS
// =====================================================

router.put(
  "/businesses/:userId/reject",
  protect,
  adminOnly,
  rejectBusiness
);

// =====================================================
// GET ALL ORDERS - ADMIN
// =====================================================

router.get(
  "/orders",
  protect,
  adminOnly,
  getAllOrders
);

// =====================================================
// GET ALL PRODUCTS - ADMIN
// =====================================================

router.get(
  "/products",
  protect,
  adminOnly,
  getAllProductsAdmin
);

// =====================================================
// DELETE PRODUCT - ADMIN
// =====================================================

router.delete(
  "/products/:id",
  protect,
  adminOnly,
  deleteProductAdmin
);

module.exports = router;