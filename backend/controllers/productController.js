const Product = require("../models/Product");
const User = require("../models/User");

// =====================================================
// CREATE PRODUCT
// POST /api/business/products
// =====================================================
exports.createProduct = async (req, res) => {
  try {
    const {
      name,
      category,
      description,
      price,
      stock,
    } = req.body;

    if (!name || !category || price == null) {
      return res.status(400).json({
        success: false,
        message: "Name, category and price are required.",
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
        message:
          "Only business owners can create products.",
      });
    }

    // =====================================================
    // IMAGE
    // =====================================================

    let image = "";

    // If multer uploaded image
    if (req.file) {
      const mimeType =
        req.file.mimetype || "image/jpeg";

      const base64 =
        req.file.buffer.toString("base64");

      image =
        `data:${mimeType};base64,${base64}`;
    }

    // =====================================================
    // CREATE PRODUCT
    // IMPORTANT: seller, NOT owner
    // =====================================================

    const product = await Product.create({
      seller: req.user._id,
      name: name.trim(),
      category: category.trim(),
      description: description || "",
      price: Number(price),
      stock: Number(stock || 0),
      image,
    });

    return res.status(201).json({
      success: true,
      message: "Product created successfully.",
      product,
    });

  } catch (err) {
    console.error(
      "Create Product Error:",
      err
    );

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};


// =====================================================
// GET MY PRODUCTS
// BUSINESS OWNER
// GET /api/business/products
// =====================================================
exports.getMyProducts = async (req, res) => {
  try {
    const products = await Product.find({
      seller: req.user._id,
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
// GET /api/business/shop/products
// =====================================================
exports.getAllProducts = async (req, res) => {
  try {
    const products = await Product.find({
      seller: {
        $exists: true,
      },
    })
      .populate(
        "seller",
        "name email phone avatar businessProfile"
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
// GET SINGLE PRODUCT
// =====================================================
exports.getProductById = async (req, res) => {
  try {
    const { id } = req.params;

    const product = await Product.findById(id)
      .populate(
        "seller",
        "name email phone avatar businessProfile"
      );

    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Product not found.",
      });
    }

    return res.status(200).json({
      success: true,
      product,
    });

  } catch (err) {
    console.error(
      "Get Product By ID Error:",
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
// PUT /api/business/products/:id
// =====================================================
exports.updateProduct = async (req, res) => {
  try {
    const { id } = req.params;

    const {
      name,
      category,
      description,
      price,
      stock,
      image,
    } = req.body;

    // IMPORTANT: seller
    const product =
      await Product.findOne({
        _id: id,
        seller: req.user._id,
      });

    if (!product) {
      return res.status(404).json({
        success: false,
        message:
          "Product not found or unauthorized.",
      });
    }

    if (name !== undefined) {
      product.name = name;
    }

    if (category !== undefined) {
      product.category = category;
    }

    if (description !== undefined) {
      product.description = description;
    }

    if (price !== undefined) {
      product.price = Number(price);
    }

    if (stock !== undefined) {
      product.stock = Number(stock);
    }

    if (image !== undefined) {
      product.image = image;
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
      "Update Product Error:",
      err
    );

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};


// =====================================================
// DELETE PRODUCT
// DELETE /api/business/products/:id
// =====================================================
exports.deleteProduct = async (req, res) => {
  try {
    const { id } = req.params;

    // IMPORTANT: seller
    const product =
      await Product.findOneAndDelete({
        _id: id,
        seller: req.user._id,
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
      message: err.message,
    });
  }
};