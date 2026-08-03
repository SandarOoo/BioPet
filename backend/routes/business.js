const express = require("express");
const router = express.Router();

const { protect } = require("../middleware/auth");

// =====================================================
// CONTROLLERS
// =====================================================

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
  updateProduct,
  deleteProduct,
} = require("../controllers/productController");

// =====================================================
// MULTER UPLOAD
// =====================================================

const multer = require("multer");

// Store uploaded image in memory.
// This is suitable if we save image as Base64 in MongoDB.
const storage = multer.memoryStorage();

const upload = multer({
  storage: storage,

  limits: {
    fileSize: 5 * 1024 * 1024, // 5 MB
  },

  fileFilter: (req, file, cb) => {
    // Accept only image MIME types
    if (file.mimetype && file.mimetype.startsWith("image/")) {
      cb(null, true);
    } else {
      cb(new Error("Only image files are allowed."));
    }
  },
});

// =====================================================
// BUSINESS PROFILE
// =====================================================

// Update business profile
router.put(
  "/profile",
  protect,
  updateBusinessProfile
);

// Accept business agreement
router.put(
  "/agreement",
  protect,
  acceptAgreement
);

// Update business location
router.put(
  "/location",
  protect,
  updateLocation
);

// Submit business application
router.put(
  "/submit",
  protect,
  submitBusiness
);

// =====================================================
// SELLER PROFILE
// =====================================================

// Business owner views own profile
router.get(
  "/my-profile",
  protect,
  getMySellerProfile
);

// Customer views public seller profile
router.get(
  "/seller/:sellerId",
  getSellerProfile
);

// =====================================================
// PRODUCTS
// =====================================================

// -----------------------------------------------------
// BUSINESS OWNER
// GET MY PRODUCTS
// GET /api/business/products
// -----------------------------------------------------

router.get(
  "/products",
  protect,
  getMyProducts
);

// -----------------------------------------------------
// BUSINESS OWNER
// CREATE PRODUCT
// POST /api/business/products
//
// Multipart form-data:
//
// name
// category
// price
// stock
// description
// image
// -----------------------------------------------------

router.post(
  "/products",
  protect,
  upload.single("image"),
  createProduct
);

// -----------------------------------------------------
// CUSTOMER
// GET ALL PRODUCTS
//
// GET /api/business/shop/products
// -----------------------------------------------------

router.get(
  "/shop/products",
  getAllProducts
);

// -----------------------------------------------------
// BUSINESS OWNER
// UPDATE PRODUCT
//
// PUT /api/business/products/:id
// -----------------------------------------------------

router.put(
  "/products/:id",
  protect,
  updateProduct
);

// -----------------------------------------------------
// BUSINESS OWNER
// DELETE PRODUCT
//
// DELETE /api/business/products/:id
// -----------------------------------------------------

router.delete(
  "/products/:id",
  protect,
  deleteProduct
);

// =====================================================
// MULTER ERROR HANDLER
// =====================================================

router.use((err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    console.error("MULTER ERROR:", err);

    return res.status(400).json({
      success: false,
      message: err.message,
    });
  }

  if (err) {
    console.error("UPLOAD ERROR:", err);

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }

  next();
});

module.exports = router;