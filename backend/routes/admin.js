const express = require("express");
const router = express.Router();

const { protect, adminOnly } = require("../middleware/auth");

const {
    getPendingBusinesses,
    approveBusiness,
    rejectBusiness
} = require("../controllers/adminController");


// pending list
router.get(
    "/businesses/pending",
    protect,
    adminOnly,
    getPendingBusinesses
);


// approve
router.put(
    "/businesses/:userId/approve",
    protect,
    adminOnly,
    approveBusiness
);


// reject
router.put(
    "/businesses/:userId/reject",
    protect,
    adminOnly,
    rejectBusiness
);


module.exports = router;