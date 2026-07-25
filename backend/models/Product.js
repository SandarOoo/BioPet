const mongoose = require("mongoose");

const productSchema = new mongoose.Schema(
  {
    // Product owner
    owner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    // Product name
    name: {
      type: String,
      required: true,
      trim: true,
    },

    // Product category
    category: {
      type: String,
      required: true,
      trim: true,
    },

    // Product description
    description: {
      type: String,
      default: "",
      trim: true,
    },

    // Product price
    price: {
      type: Number,
      required: true,
      min: 0,
    },

    // Product stock
    stock: {
      type: Number,
      default: 0,
      min: 0,
    },

    // Product image
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