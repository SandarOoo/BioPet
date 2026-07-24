const express = require("express");
const router = express.Router();

const { protect } = require("../middleware/auth");
const {
  acceptAgreement,
  updateLocation,
  submitBusiness
} = require("../controllers/businessController");

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

module.exports = router;