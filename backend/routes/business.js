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

  // PRODUCT FUNCTIONS
  createProduct,
  getBusinessProducts,
  updateProduct,
  deleteProduct,
} = require("../controllers/businessController");


// =====================================================
// MULTER
// =====================================================

const upload = require("../middleware/upload");


// =====================================================
// BUSINESS PROFILE
// =====================================================

router.put(
  "/profile",
  protect,
  updateBusinessProfile
);


// =====================================================
// BUSINESS AGREEMENT
// =====================================================

router.put(
  "/agreement",
  protect,
  acceptAgreement
);


// =====================================================
// BUSINESS LOCATION
// =====================================================

router.put(
  "/location",
  protect,
  updateLocation
);


// =====================================================
// SUBMIT BUSINESS
// =====================================================

router.put(
  "/submit",
  protect,
  submitBusiness
);


// =====================================================
// MY SELLER PROFILE
// =====================================================

router.get(
  "/my-profile",
  protect,
  getMySellerProfile
);


// =====================================================
// CUSTOMER VIEW SELLER PROFILE
// =====================================================

router.get(
  "/seller/:sellerId",
  getSellerProfile
);


// =====================================================
// BUSINESS OWNER PRODUCTS
// =====================================================


// GET MY PRODUCTS
// GET /api/business/products

router.get(
  "/products",
  protect,
  getBusinessProducts
);


// ADD PRODUCT
// POST /api/business/products

router.post(
  "/products",
  protect,
  upload.single("image"),
  createProduct
);


// UPDATE PRODUCT
// PUT /api/business/products/:id

router.put(
  "/products/:id",
  protect,
  upload.single("image"),
  updateProduct
);


// DELETE PRODUCT
// DELETE /api/business/products/:id

router.delete(
  "/products/:id",
  protect,
  deleteProduct
);


module.exports = router;