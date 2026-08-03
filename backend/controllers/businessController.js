const User = require("../models/User");
const Product = require("../models/Product");


// ============================================================
// ACCEPT BUSINESS AGREEMENT
// PUT /api/business/agreement
// ============================================================

exports.acceptAgreement = async (
  req,
  res
) => {
  try {

    const {
      accepted,
    } = req.body;

    if (accepted !== true) {
      return res.status(400).json({
        success: false,
        message:
          "You must accept the agreement.",
      });
    }

    const user =
      await User.findById(
        req.user._id
      );

    if (!user) {
      return res.status(404).json({
        success: false,
        message:
          "User not found.",
      });
    }

    if (
      user.role !==
      "business_owner"
    ) {
      return res.status(403).json({
        success: false,
        message:
          "Only business owners can accept the agreement.",
      });
    }

    if (
      user.businessProfile
        .agreementAccepted
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Agreement already accepted.",
      });
    }

    user.businessProfile
        .agreementAccepted =
      true;

    if (
      !user.businessProfile
        .verificationStatus
    ) {
      user.businessProfile
          .verificationStatus =
        "draft";
    }

    await user.save();

    return res.json({
      success: true,

      message:
        "Agreement accepted successfully.",

      businessProfile:
        user.businessProfile,
    });

  } catch (err) {

    console.error(
      "Accept Agreement Error:",
      err
    );

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};


// ============================================================
// UPDATE BUSINESS LOCATION
// PUT /api/business/location
// ============================================================

exports.updateLocation = async (
  req,
  res
) => {
  try {

    const {
      latitude,
      longitude,
    } = req.body;

    if (
      latitude == null ||
      longitude == null
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Latitude and longitude are required.",
      });
    }

    const user =
      await User.findById(
        req.user._id
      );

    if (!user) {
      return res.status(404).json({
        success: false,
        message:
          "User not found.",
      });
    }

    if (
      user.role !==
      "business_owner"
    ) {
      return res.status(403).json({
        success: false,
        message:
          "Only business owners can update location.",
      });
    }

    if (
      !user.businessProfile
        .agreementAccepted
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Please accept agreement first.",
      });
    }

    user.businessProfile.latitude =
      Number(latitude);

    user.businessProfile.longitude =
      Number(longitude);

    await user.save();

    return res.json({
      success: true,

      message:
        "Business location updated successfully.",

      businessProfile:
        user.businessProfile,
    });

  } catch (err) {

    console.error(
      "Update Location Error:",
      err
    );

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};


// ============================================================
// SUBMIT BUSINESS APPLICATION
// PUT /api/business/submit
// ============================================================

exports.submitBusiness = async (
  req,
  res
) => {
  try {

    const user =
      await User.findById(
        req.user._id
      );

    if (!user) {
      return res.status(404).json({
        success: false,
        message:
          "User not found.",
      });
    }

    if (
      user.role !==
      "business_owner"
    ) {
      return res.status(403).json({
        success: false,
        message:
          "Only business owners can submit application.",
      });
    }

    if (
      !user.businessProfile
        .agreementAccepted
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Please accept agreement first.",
      });
    }

    if (
      user.businessProfile.latitude ==
        null ||
      user.businessProfile.longitude ==
        null
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Please select business location first.",
      });
    }

    if (
      user.businessProfile
        .verificationStatus ===
      "pending"
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Application already submitted.",
      });
    }

    user.businessProfile
        .verificationStatus =
      "pending";

    user.businessProfile
        .submittedAt =
      new Date();

    await user.save();

    return res.json({
      success: true,

      message:
        "Business application submitted successfully.",

      businessProfile:
        user.businessProfile,
    });

  } catch (err) {

    console.error(
      "Submit Business Error:",
      err
    );

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};


// ============================================================
// GET PUBLIC SELLER PROFILE
// GET /api/business/seller/:sellerId
// ============================================================

exports.getSellerProfile =
  async (
    req,
    res
  ) => {
    try {

      const {
        sellerId,
      } = req.params;

      const seller =
        await User.findOne({
          _id: sellerId,

          role:
            "business_owner",
        }).select(
          "name email avatar businessProfile"
        );

      if (!seller) {
        return res.status(404).json({
          success: false,
          message:
            "Seller not found.",
        });
      }

      // Only approved sellers
      // can be viewed publicly.

      if (
        seller.businessProfile
          ?.verificationStatus !==
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


// ============================================================
// GET SELLER PROFILE FOR OWNER
// GET /api/business/my-profile
// ============================================================

exports.getMySellerProfile =
  async (
    req,
    res
  ) => {
    try {

      const user =
        await User.findById(
          req.user._id
        ).select(
          "name email phone avatar role businessProfile"
        );

      if (!user) {
        return res.status(404).json({
          success: false,
          message:
            "User not found.",
        });
      }

      if (
        user.role !==
        "business_owner"
      ) {
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
// UPDATE BUSINESS PROFILE
// PUT /api/business/profile
// ============================================================

exports.updateBusinessProfile =
  async (
    req,
    res
  ) => {
    try {

      const {
        businessName,
        businessType,
        address,
        description,
        latitude,
        longitude,
      } = req.body;

      const user =
        await User.findById(
          req.user._id
        );

      if (!user) {
        return res.status(404).json({
          success: false,
          message:
            "User not found.",
        });
      }

      if (
        user.role !==
        "business_owner"
      ) {
        return res.status(403).json({
          success: false,
          message:
            "Only business owners can update business profile.",
        });
      }

      // ------------------------------------------
      // UPDATE ONLY PROVIDED FIELDS
      // ------------------------------------------

      if (
        businessName !==
        undefined
      ) {
        user.businessProfile
            .businessName =
          businessName.trim();
      }

      if (
        businessType !==
        undefined
      ) {
        user.businessProfile
            .businessType =
          businessType.trim();
      }

      if (
        address !==
        undefined
      ) {
        user.businessProfile
            .address =
          address.trim();
      }

      if (
        description !==
        undefined
      ) {
        user.businessProfile
            .description =
          description.trim();
      }

      if (
        latitude !==
        undefined
      ) {
        user.businessProfile
            .latitude =
          Number(latitude);
      }

      if (
        longitude !==
        undefined
      ) {
        user.businessProfile
            .longitude =
          Number(longitude);
      }

      await user.save();

      return res.status(200).json({
        success: true,

        message:
          "Business profile updated successfully.",

        user: {
          id: user._id,

          name: user.name,

          email: user.email,

          phone: user.phone,

          role: user.role,

          avatar: user.avatar,

          businessProfile:
            user.businessProfile,
        },

        businessProfile:
          user.businessProfile,
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


// ============================================================
// ADD PRODUCT
// POST /api/business/products
//
// Multipart fields:
//
// name
// category
// price
// stock
// description
//
// Image field:
//
// image
// ============================================================

exports.addProduct = async (
  req,
  res
) => {
  try {

    console.log(
      "================================="
    );

    console.log(
      "ADD PRODUCT REQUEST"
    );

    console.log(
      "================================="
    );

    console.log(
      "USER ID:",
      req.user?._id
    );

    console.log(
      "BODY:",
      req.body
    );

    console.log(
      "FILE:",
      req.file
        ? {
            name:
              req.file.originalname,

            mimetype:
              req.file.mimetype,

            size:
              req.file.size,
          }
        : "NO FILE"
    );

    // ========================================================
    // AUTH
    // ========================================================

    if (!req.user) {
      return res.status(401).json({
        success: false,
        message:
          "Authentication required.",
      });
    }

    // ========================================================
    // GET USER
    // ========================================================

    const user =
      await User.findById(
        req.user._id
      );

    if (!user) {
      return res.status(404).json({
        success: false,
        message:
          "User not found.",
      });
    }

    // ========================================================
    // CHECK BUSINESS OWNER
    // ========================================================

    if (
      user.role !==
      "business_owner"
    ) {
      return res.status(403).json({
        success: false,
        message:
          "Only business owners can add products.",
      });
    }

    // ========================================================
    // GET FORM DATA
    // ========================================================

    const {
      name,
      category,
      price,
      stock,
      description,
    } = req.body;

    // ========================================================
    // VALIDATE NAME
    // ========================================================

    if (
      !name ||
      !name.trim()
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Product name is required.",
      });
    }

    // ========================================================
    // VALIDATE CATEGORY
    // ========================================================

    if (
      !category ||
      !category.trim()
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Product category is required.",
      });
    }

    // ========================================================
    // VALIDATE PRICE
    // ========================================================

    const parsedPrice =
      Number(price);

    if (
      Number.isNaN(
        parsedPrice
      ) ||
      parsedPrice <= 0
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Invalid product price.",
      });
    }

    // ========================================================
    // VALIDATE STOCK
    // ========================================================

    const parsedStock =
      Number(
        stock ?? 0
      );

    if (
      Number.isNaN(
        parsedStock
      ) ||
      parsedStock < 0
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Invalid product stock.",
      });
    }

    // ========================================================
    // IMAGE REQUIRED
    // ========================================================

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message:
          "Product image is required.",
      });
    }

    // ========================================================
    // CONVERT IMAGE TO BASE64
    // ========================================================

    const imageBase64 =
      `data:${req.file.mimetype};base64,` +
      req.file.buffer.toString(
        "base64"
      );

    // ========================================================
    // CREATE PRODUCT
    // ========================================================

    const product =
      await Product.create({

        seller:
          user._id,

        name:
          name.trim(),

        category:
          category.trim(),

        price:
          parsedPrice,

        stock:
          parsedStock,

        description:
          description
            ? description.trim()
            : "",

        image:
          imageBase64,
      });

    // ========================================================
    // SUCCESS
    // ========================================================

    console.log(
      "PRODUCT CREATED:",
      product._id
    );

    return res.status(201).json({

      success: true,

      message:
        "Product added successfully.",

      product,
    });

  } catch (err) {

    console.error(
      "ADD PRODUCT ERROR:",
      err
    );

    return res.status(500).json({

      success: false,

      message:
        err.message ||
        "Failed to add product.",
    });
  }
};


// ============================================================
// GET BUSINESS OWNER PRODUCTS
// GET /api/business/products
// ============================================================

exports.getBusinessProducts =
  async (
    req,
    res
  ) => {
    try {

      if (!req.user) {
        return res.status(401).json({
          success: false,
          message:
            "Authentication required.",
        });
      }

      const products =
        await Product.find({
          seller:
            req.user._id,
        })
          .sort({
            createdAt: -1,
          });

      return res.status(200).json({

        success: true,

        products,
      });

    } catch (err) {

      console.error(
        "GET BUSINESS PRODUCTS ERROR:",
        err
      );

      return res.status(500).json({

        success: false,

        message:
          err.message ||
          "Failed to load products.",
      });
    }
  };


// ============================================================
// GET ALL SHOP PRODUCTS
// GET /api/business/shop/products
// ============================================================

exports.getShopProducts =
  async (
    req,
    res
  ) => {
    try {

      const products =
        await Product.find({
          stock: {
            $gt: 0,
          },
        })
          .populate(
            "seller",
            "name email businessProfile"
          )
          .sort({
            createdAt: -1,
          });

      return res.status(200).json({

        success: true,

        products,
      });

    } catch (err) {

      console.error(
        "GET SHOP PRODUCTS ERROR:",
        err
      );

      return res.status(500).json({

        success: false,

        message:
          err.message ||
          "Failed to load shop products.",
      });
    }
  };


// ============================================================
// UPDATE PRODUCT
// PUT /api/business/products/:id
// ============================================================

exports.updateProduct =
  async (
    req,
    res
  ) => {
    try {

      const {
        id,
      } = req.params;

      const {
        name,
        category,
        description,
        price,
        stock,
        image,
      } = req.body;

      const product =
        await Product.findOne({
          _id: id,

          seller:
            req.user._id,
        });

      if (!product) {
        return res.status(404).json({
          success: false,
          message:
            "Product not found.",
        });
      }

      // ------------------------------------------
      // UPDATE PROVIDED FIELDS
      // ------------------------------------------

      if (
        name !==
        undefined
      ) {
        product.name =
          name.trim();
      }

      if (
        category !==
        undefined
      ) {
        product.category =
          category.trim();
      }

      if (
        description !==
        undefined
      ) {
        product.description =
          description.trim();
      }

      if (
        price !==
        undefined
      ) {
        product.price =
          Number(price);
      }

      if (
        stock !==
        undefined
      ) {
        product.stock =
          Number(stock);
      }

      if (
        image !==
        undefined
      ) {
        product.image =
          image;
      }

      await product.save();

      return res.status(200).json({

        success: true,

        message:
          "Product updated successfully.",

        product,
      });

    } catch (err) {

      console.error(
        "UPDATE PRODUCT ERROR:",
        err
      );

      return res.status(500).json({

        success: false,

        message:
          err.message ||
          "Failed to update product.",
      });
    }
  };


// ============================================================
// DELETE PRODUCT
// DELETE /api/business/products/:id
// ============================================================

exports.deleteProduct =
  async (
    req,
    res
  ) => {
    try {

      const {
        id,
      } = req.params;

      const product =
        await Product.findOne({
          _id: id,

          seller:
            req.user._id,
        });

      if (!product) {
        return res.status(404).json({
          success: false,
          message:
            "Product not found.",
        });
      }

      await Product.findByIdAndDelete(
        id
      );

      return res.status(200).json({

        success: true,

        message:
          "Product deleted successfully.",
      });

    } catch (err) {

      console.error(
        "DELETE PRODUCT ERROR:",
        err
      );

      return res.status(500).json({

        success: false,

        message:
          err.message ||
          "Failed to delete product.",
      });
    }
  };