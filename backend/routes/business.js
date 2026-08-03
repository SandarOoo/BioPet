const express = require("express");
const router = express.Router();

const { protect } = require("../middleware/auth");
const upload = require("../middleware/upload");

const {
  acceptAgreement,
  updateLocation,
  submitBusiness,
  getMySellerProfile,
  getSellerProfile,
  updateBusinessProfile,
} = require("../controllers/businessController");

const {
  addProduct,
  getBusinessProducts,
  deleteProduct,
  updateProduct,
  getShopProducts,
} = require("../controllers/productController");

// ============================================================
// BUSINESS PROFILE
// ============================================================

router.put(
  "/profile",
  protect,
  updateBusinessProfile
);

// ============================================================
// BUSINESS AGREEMENT
// ============================================================

router.put(
  "/agreement",
  protect,
  acceptAgreement
);

// ============================================================
// BUSINESS LOCATION
// ============================================================

router.put(
  "/location",
  protect,
  updateLocation
);

// ============================================================
// SUBMIT BUSINESS
// ============================================================

router.put(
  "/submit",
  protect,
  submitBusiness
);

// ============================================================
// MY SELLER PROFILE
// ============================================================

router.get(
  "/my-profile",
  protect,
  getMySellerProfile
);

// ============================================================
// PUBLIC SELLER PROFILE
// ============================================================

router.get(
  "/seller/:sellerId",
  getSellerProfile
);

// ============================================================
// ADD PRODUCT
// POST /api/business/products
//
// Flutter:
// Multipart field name = image
// ============================================================

router.post(
  "/products",
  protect,
  upload.single("image"),
  addProduct
);

// ============================================================
// GET BUSINESS OWNER PRODUCTS
// GET /api/business/products
// ============================================================

router.get(
  "/products",
  protect,
  getBusinessProducts
);

// ============================================================
// DELETE PRODUCT
// DELETE /api/business/products/:id
// ============================================================

router.delete(
  "/products/:id",
  protect,
  deleteProduct
);

// ============================================================
// UPDATE PRODUCT
// PUT /api/business/products/:id
// ============================================================

router.put(
  "/products/:id",
  protect,
  updateProduct
);

// ============================================================
// CUSTOMER SHOP PRODUCTS
// GET /api/business/shop/products
// ============================================================

router.get(
  "/shop/products",
  getShopProducts
);

module.exports = router;