const express = require("express");
const router = express.Router();

const { protect } = require("../middleware/auth");

const {
  acceptAgreement,
  updateLocation,
  submitBusiness,
  getMySellerProfile,
  getSellerProfile,
  updateBusinessProfile,
} = require("../controllers/businessController");

const {
  createProduct,
  getMyProducts,
  getAllProducts,
  getProductById,
  updateProduct,
  deleteProduct,
} = require("../controllers/productController");

// =====================================================
// BUSINESS PROFILE
// =====================================================

router.put(
  "/profile",
  protect,
  updateBusinessProfile
);

router.put(
  "/agreement",
  protect,
  acceptAgreement
);

router.put(
  "/location",
  protect,
  updateLocation
);

router.put(
  "/submit",
  protect,
  submitBusiness
);

router.get(
  "/my-profile",
  protect,
  getMySellerProfile
);

router.get(
  "/seller/:sellerId",
  getSellerProfile
);


// =====================================================
// BUSINESS OWNER PRODUCTS
// =====================================================

// Add product
router.post(
  "/products",
  protect,
  upload.single("image"),
  createProduct
);

// Owner's products
router.get(
  "/products",
  protect,
  getMyProducts
);

// Update product
router.put(
  "/products/:id",
  protect,
  updateProduct
);

// Delete product
router.delete(
  "/products/:id",
  protect,
  deleteProduct
);


// =====================================================
// CUSTOMER SHOP
// =====================================================

// All products
router.get(
  "/shop/products",
  getAllProducts
);

// Single product
router.get(
  "/shop/products/:id",
  getProductById
);


module.exports = router;