const Product = require("../models/Product");
const User = require("../models/User");

// =====================================================
// CREATE PRODUCT
// =====================================================

exports.createProduct = async (req, res) => {
  try {
    console.log("======================================");
    console.log("CREATE PRODUCT");
    console.log("BODY:", req.body);
    console.log("FILE:", req.file);
    console.log("======================================");

    const {
      name,
      category,
      description,
      price,
      stock,
    } = req.body;

    // =====================================================
    // VALIDATION
    // =====================================================

    if (
      !name ||
      !category ||
      price === undefined ||
      price === null ||
      price === ""
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Name, category and price are required.",
      });
    }

    // =====================================================
    // IMAGE REQUIRED
    // =====================================================

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message:
          "Product image is required.",
      });
    }

    // =====================================================
    // FIND USER
    // =====================================================

    const user = await User.findById(
      req.user._id
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found.",
      });
    }

    // =====================================================
    // CHECK ROLE
    // =====================================================

    if (
      user.role !== "business_owner"
    ) {
      return res.status(403).json({
        success: false,
        message:
          "Only business owners can create products.",
      });
    }

    // =====================================================
    // CONVERT IMAGE TO BASE64
    // =====================================================

    const imageBase64 =
      `data:${req.file.mimetype};base64,` +
      req.file.buffer.toString("base64");

    console.log(
      "Image MIME:",
      req.file.mimetype
    );

    console.log(
      "Image Size:",
      req.file.size
    );

    console.log(
      "Base64 Image Length:",
      imageBase64.length
    );

    // =====================================================
    // CREATE PRODUCT
    // =====================================================

    const product =
      await Product.create({
        name: name.trim(),

        category:
          category.trim(),

        description:
          description
            ? description.trim()
            : "",

        price: Number(price),

        stock:
          stock !== undefined &&
          stock !== ""
            ? Number(stock)
            : 0,

        image: imageBase64,

        owner:
          req.user._id,
      });

    // =====================================================
    // SUCCESS
    // =====================================================

    return res.status(201).json({
      success: true,

      message:
        "Product created successfully.",

      product,
    });

  } catch (err) {

    console.error(
      "Create Product Error:",
      err
    );

    return res.status(500).json({
      success: false,

      message:
        err.message ||
        "Failed to create product.",
    });
  }
};


// =====================================================
// GET MY PRODUCTS
// =====================================================

exports.getMyProducts =
  async (req, res) => {

    try {

      const products =
        await Product.find({
          owner:
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
        "Get My Products Error:",
        err
      );

      return res.status(500).json({
        success: false,
        message: err.message,
      });
    }
  };


// =====================================================
// GET ALL PRODUCTS
// CUSTOMER SHOP
// =====================================================

exports.getAllProducts =
  async (req, res) => {

    try {

      const products =
        await Product.find()
        .populate(
          "owner",
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
        "Get All Products Error:",
        err
      );

      return res.status(500).json({
        success: false,
        message: err.message,
      });
    }
  };


// =====================================================
// UPDATE PRODUCT
// =====================================================

exports.updateProduct =
  async (req, res) => {

    try {

      const { id } =
        req.params;

      const {
        name,
        category,
        description,
        price,
        stock,
      } = req.body;

      const product =
        await Product.findOne({
          _id: id,
          owner:
            req.user._id,
        });

      if (!product) {

        return res.status(404).json({
          success: false,

          message:
            "Product not found or unauthorized.",
        });
      }

      // =====================================================
      // UPDATE TEXT FIELDS
      // =====================================================

      if (
        name !== undefined
      ) {
        product.name =
          name.trim();
      }

      if (
        category !== undefined
      ) {
        product.category =
          category.trim();
      }

      if (
        description !== undefined
      ) {
        product.description =
          description.trim();
      }

      if (
        price !== undefined
      ) {
        product.price =
          Number(price);
      }

      if (
        stock !== undefined
      ) {
        product.stock =
          Number(stock);
      }

      // =====================================================
      // UPDATE IMAGE IF NEW IMAGE PROVIDED
      // =====================================================

      if (req.file) {

        const imageBase64 =
          `data:${req.file.mimetype};base64,` +
          req.file.buffer.toString(
            "base64"
          );

        product.image =
          imageBase64;
      }

      // =====================================================
      // SAVE
      // =====================================================

      await product.save();

      return res.status(200).json({

        success: true,

        message:
          "Product updated successfully.",

        product,
      });

    } catch (err) {

      console.error(
        "Update Product Error:",
        err
      );

      return res.status(500).json({

        success: false,

        message:
          err.message,
      });
    }
  };


// =====================================================
// DELETE PRODUCT
// =====================================================

exports.deleteProduct =
  async (req, res) => {

    try {

      const { id } =
        req.params;

      const product =
        await Product.findOneAndDelete({
          _id: id,
          owner:
            req.user._id,
        });

      if (!product) {

        return res.status(404).json({

          success: false,

          message:
            "Product not found or unauthorized.",
        });
      }

      return res.status(200).json({

        success: true,

        message:
          "Product deleted successfully.",
      });

    } catch (err) {

      console.error(
        "Delete Product Error:",
        err
      );

      return res.status(500).json({

        success: false,

        message:
          err.message,
      });
    }
  };