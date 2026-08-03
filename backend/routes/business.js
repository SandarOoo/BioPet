const express = require("express");

const router =
  express.Router();


// ============================================================
// MIDDLEWARE
// ============================================================

const {
  protect,
} = require("../middleware/auth");

const upload =
  require("../middleware/upload");


// ============================================================
// CONTROLLER
// ============================================================

const {
  acceptAgreement,

  updateLocation,

  submitBusiness,

  getMySellerProfile,

  getSellerProfile,

  updateBusinessProfile,

  addProduct,

  getBusinessProducts,

  getShopProducts,

  updateProduct,

  deleteProduct,

} = require(
  "../controllers/businessController"
);


// ============================================================
// BUSINESS PROFILE
// ============================================================

router.put(
  "/profile",
  protect,
  updateBusinessProfile
);


// ============================================================
// ACCEPT AGREEMENT
// ============================================================

router.put(
  "/agreement",
  protect,
  acceptAgreement
);


// ============================================================
// UPDATE LOCATION
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
// OWNER PROFILE
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
// CUSTOMER SHOP PRODUCTS
//
// GET /api/business/shop/products
// ============================================================

router.get(
  "/shop/products",
  getShopProducts
);


// ============================================================
// BUSINESS OWNER PRODUCTS
//
// GET /api/business/products
// ============================================================

router.get(
  "/products",
  protect,
  getBusinessProducts
);


// ============================================================
// ADD PRODUCT
//
// POST /api/business/products
//
// multipart/form-data
//
// image field = "image"
// ============================================================

router.post(
  "/products",
  protect,
  upload.single("image"),
  addProduct
);


// ============================================================
// UPDATE PRODUCT
//
// PUT /api/business/products/:id
// ============================================================

router.put(
  "/products/:id",
  protect,
  updateProduct
);


// ============================================================
// DELETE PRODUCT
//
// DELETE /api/business/products/:id
// ============================================================

router.delete(
  "/products/:id",
  protect,
  deleteProduct
);


// ============================================================
// EXPORT
// ============================================================

module.exports =
  router;