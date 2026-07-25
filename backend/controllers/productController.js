const Product = require("../models/Product");
const User = require("../models/User");

// =====================================================
// CREATE PRODUCT
// =====================================================
exports.createProduct = async (req, res) => {
  try {
    const {
      name,
      category,
      description,
      price,
      stock,
      image,
    } = req.body;

    if (!name || !category || price == null) {
      return res.status(400).json({
        success: false,
        message:
          "Name, category and price are required.",
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

    const product = await Product.create({
      name,
      category,
      description: description || "",
      price: Number(price),
      stock: Number(stock || 0),
      image: image || "",
      owner: req.user._id,
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
// =====================================================
exports.getMyProducts = async (req, res) => {
  try {
    const products = await Product.find({
      owner: req.user._id,
    }).sort({
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
exports.getAllProducts = async (req, res) => {
  try {
    const products = await Product.find()
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

    const product =
      await Product.findOne({
        _id: id,
        owner: req.user._id,
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
// =====================================================
exports.deleteProduct = async (req, res) => {
  try {
    const { id } = req.params;

    const product =
      await Product.findOneAndDelete({
        _id: id,
        owner: req.user._id,
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