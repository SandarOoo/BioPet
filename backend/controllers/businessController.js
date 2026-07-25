const User = require("../models/User");

// =============================
// ACCEPT BUSINESS AGREEMENT
// =============================
exports.acceptAgreement = async (req, res) => {
  try {
    const { accepted } = req.body;

    if (accepted !== true) {
      return res.status(400).json({
        success: false,
        message: "You must accept the agreement.",
      });
    }

    const user = await User.findById(req.user._id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found.",
      });
    }

    if (user.role !== "business_owner") {
      return res.status(403).json({
        success: false,
        message: "Only business owners can accept the agreement.",
      });
    }

    if (user.businessProfile.agreementAccepted) {
      return res.status(400).json({
        success: false,
        message: "Agreement already accepted.",
      });
    }

    user.businessProfile.agreementAccepted = true;

    if (!user.businessProfile.verificationStatus) {
      user.businessProfile.verificationStatus = "draft";
    }

    await user.save();

    return res.json({
      success: true,
      message: "Agreement accepted successfully.",
      businessProfile: user.businessProfile,
    });

  } catch (err) {
    console.error("Accept Agreement Error:", err);

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};


// =============================
// UPDATE BUSINESS LOCATION
// =============================
exports.updateLocation = async (req, res) => {
  try {
    const { latitude, longitude } = req.body;

    if (latitude == null || longitude == null) {
      return res.status(400).json({
        success: false,
        message: "Latitude and longitude are required.",
      });
    }

    const user = await User.findById(req.user._id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found.",
      });
    }

    if (user.role !== "business_owner") {
      return res.status(403).json({
        success: false,
        message: "Only business owners can update location.",
      });
    }

    if (!user.businessProfile.agreementAccepted) {
      return res.status(400).json({
        success: false,
        message: "Please accept agreement first.",
      });
    }

    user.businessProfile.latitude = latitude;
    user.businessProfile.longitude = longitude;

    await user.save();

    return res.json({
      success: true,
      message: "Business location updated successfully.",
      businessProfile: user.businessProfile,
    });

  } catch (err) {
    console.error("Update Location Error:", err);

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};


// =============================
// SUBMIT BUSINESS APPLICATION
// =============================
exports.submitBusiness = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found.",
      });
    }

    if (user.role !== "business_owner") {
      return res.status(403).json({
        success: false,
        message: "Only business owners can submit application.",
      });
    }

    if (!user.businessProfile.agreementAccepted) {
      return res.status(400).json({
        success: false,
        message: "Please accept agreement first.",
      });
    }

    if (
      user.businessProfile.latitude == null ||
      user.businessProfile.longitude == null
    ) {
      return res.status(400).json({
        success: false,
        message: "Please select business location first.",
      });
    }

    if (user.businessProfile.verificationStatus === "pending") {
      return res.status(400).json({
        success: false,
        message: "Application already submitted.",
      });
    }

    user.businessProfile.verificationStatus = "pending";
    user.businessProfile.submittedAt = new Date();

    await user.save();

    return res.json({
      success: true,
      message: "Business application submitted successfully.",
      businessProfile: user.businessProfile,
    });

  } catch (err) {
    console.error("Submit Business Error:", err);

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};