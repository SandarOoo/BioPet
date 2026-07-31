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
      getAllUsers,
      changeUserRole,
      deleteUserAdmin,
      getPaymentOverview,
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

// =====================================================
// USER MANAGEMENT - ADMIN ONLY
// =====================================================

// Get all users
// GET /api/admin/users
router.get(
  "/users",
  protect,
  adminOnly,
  getAllUsers
);

// Change user role
// PUT /api/admin/users/:id/role
router.put(
  "/users/:id/role",
  protect,
  adminOnly,
  changeUserRole
);

// Permanently delete user
// DELETE /api/admin/users/:id
router.delete(
  "/users/:id",
  protect,
  adminOnly,
  deleteUserAdmin
);

router.get(
  "/payment-overview",
  protect,
  adminOnly,
  getPaymentOverview
);

module.exports = router;