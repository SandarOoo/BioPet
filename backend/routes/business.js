const express = require("express");
const router = express.Router();

const { protect } = require("../middleware/auth");

const {
  acceptAgreement,
  updateLocation,
  submitBusiness,
  getMySellerProfile,
  getSellerProfile, // ဒီနေရာမှာ ထည့်ပါ
  updateBusinessProfile,
} = require("../controllers/businessController");

router.put("/profile", protect, updateBusinessProfile);

router.put("/agreement", protect, acceptAgreement);

router.put("/location", protect, updateLocation);

router.put("/submit", protect, submitBusiness);

router.get("/my-profile", protect, getMySellerProfile);

// Customer views a seller's public profile
router.get("/seller/:sellerId", getSellerProfile);

module.exports = router;