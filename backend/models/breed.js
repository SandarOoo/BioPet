const mongoose = require("mongoose");

const breedSchema = new mongoose.Schema(
  {
    name: String,
    acc: Number,
  },
  { _id: false }
);

const classifyingSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
  imagePath: String,
  createdAt: { type: Date, default: Date.now },
  breeds: [breedSchema],
});

const Classify = mongoose.model("Classify", classifyingSchema);
module.exports = Classify;
