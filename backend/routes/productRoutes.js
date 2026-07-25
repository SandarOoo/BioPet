const express = require("express");

const router = express.Router();

const {
  createProduct,
  getMyProducts,
  deleteProduct,
  updateProduct,
  getAllProducts,
} = require("../controllers/productController");

const { protect } = require("../middleware/auth");

// =====================================================
// CUSTOMER SHOP
// GET /api/business/shop/products
// =====================================================
router.get(
  "/shop/products",
  getAllProducts
);

// =====================================================
// BUSINESS OWNER PRODUCTS
// =====================================================

// Create product
// POST /api/business/createProducts
router.post(
  "/createProducts",
  protect,
  createProduct
);

// Get my products
// GET /api/business/products
router.get(
  "/products",
  protect,
  getMyProducts
);

// Update product
// PUT /api/business/products/:id
router.put(
  "/products/:id",
  protect,
  updateProduct
);

// Delete product
// DELETE /api/business/products/:id
router.delete(
  "/products/:id",
  protect,
  deleteProduct
);

module.exports = router;