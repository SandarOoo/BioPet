const mongoose = require("mongoose");

const productSchema = new mongoose.Schema(
  {
    // ========================================================
    // SELLER / BUSINESS OWNER
    // ========================================================

    seller: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    // ========================================================
    // PRODUCT NAME
    // ========================================================

    name: {
      type: String,
      required: true,
      trim: true,
    },

    // ========================================================
    // CATEGORY
    // ========================================================

    category: {
      type: String,
      required: true,
      trim: true,
    },

    // ========================================================
    // PRICE
    // ========================================================

    price: {
      type: Number,
      required: true,
      min: 0,
    },

    // ========================================================
    // STOCK
    // ========================================================

    stock: {
      type: Number,
      default: 0,
      min: 0,
    },

    // ========================================================
    // DESCRIPTION
    // ========================================================

    description: {
      type: String,
      default: "",
      trim: true,
    },

    // ========================================================
    // IMAGE
    //
    // Stored as Base64 string:
    //
    // data:image/jpeg;base64,...
    //
    // ========================================================

    image: {
      type: String,
      default: "",
    },
  },

  {
    timestamps: true,
  }
);

module.exports = mongoose.model(
  "Product",
  productSchema
);