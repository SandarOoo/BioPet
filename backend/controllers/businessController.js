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


// =============================
// GET PUBLIC SELLER PROFILE
// =============================
exports.getSellerProfile = async (req, res) => {
  try {
    const { sellerId } = req.params;

    const seller = await User.findOne({
      _id: sellerId,
      role: "business_owner",
    }).select(
      "name email avatar businessProfile"
    );

    if (!seller) {
      return res.status(404).json({
        success: false,
        message: "Seller not found.",
      });
    }

    // Only approved sellers can be viewed publicly
    if (
      seller.businessProfile?.verificationStatus !==
      "approved"
    ) {
      return res.status(403).json({
        success: false,
        message:
          "This seller is not approved yet.",
      });
    }

    return res.json({
      success: true,

      seller: {
        id: seller._id,
        name: seller.name,
        email: seller.email,
        avatar: seller.avatar,

        businessProfile:
          seller.businessProfile,
      },
    });

  } catch (err) {
    console.error(
      "Get Seller Profile Error:",
      err
    );

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};


// =============================
// GET SELLER PROFILE FOR OWNER
// =============================
// Seller himself can view his own profile
exports.getMySellerProfile = async (req, res) => {
  try {
    const user = await User.findById(
      req.user._id
    ).select(
      "name email phone avatar role businessProfile"
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found.",
      });
    }

    if (user.role !== "business_owner") {
      return res.status(403).json({
        success: false,
        message:
          "Only business owners can access seller profile.",
      });
    }

    return res.json({
      success: true,

      seller: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        avatar: user.avatar,
        role: user.role,

        businessProfile:
          user.businessProfile,
      },
    });

  } catch (err) {
    console.error(
      "Get My Seller Profile Error:",
      err
    );

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};


// ============================================================
// UPDATE SELLER / BUSINESS PROFILE
// ============================================================

// =============================
// UPDATE BUSINESS PROFILE
// =============================
exports.updateBusinessProfile = async (req, res) => {
  try {
    const {
      businessName,
      businessType,
      address,
      description,
      latitude,
      longitude,
    } = req.body;

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
        message: "Only business owners can update business profile.",
      });
    }

    // Update only provided fields
    if (businessName !== undefined) {
      user.businessProfile.businessName = businessName;
    }

    if (businessType !== undefined) {
      user.businessProfile.businessType = businessType;
    }

    if (address !== undefined) {
      user.businessProfile.address = address;
    }

    if (description !== undefined) {
      user.businessProfile.description = description;
    }

    if (latitude !== undefined) {
      user.businessProfile.latitude = latitude;
    }

    if (longitude !== undefined) {
      user.businessProfile.longitude = longitude;
    }

    await user.save();

    return res.status(200).json({
      success: true,
      message: "Business profile updated successfully.",
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        avatar: user.avatar,
        businessProfile: user.businessProfile,
      },
      businessProfile: user.businessProfile,
    });
  } catch (err) {
    console.error(
      "UPDATE BUSINESS PROFILE ERROR:",
      err
    );

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};