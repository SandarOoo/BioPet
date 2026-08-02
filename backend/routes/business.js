const express = require("express");
const router = express.Router();

const { protect } = require("../middleware/auth");
const {
  acceptAgreement,
  updateLocation,
  submitBusiness,
  getMySellerProfile,
  updateBusinessProfile
} = require("../controllers/businessController");

router.put(
  "/profile",
  protect,
  updateBusinessProfile
);

router.put("/agreement", protect, acceptAgreement);
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

router.get( "/my-profile", protect, getMySellerProfile );
// ==========================================
// PUBLIC SELLER PROFILE //
==========================================
// Customer views seller profile
router.get( "/seller/:sellerId", getSellerProfile );


module.exports = router;