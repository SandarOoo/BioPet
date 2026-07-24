const Classify = require("../models/breed");

// Create Classification
const createClassification = async (req, res) => {
  try {
    const { userId, imagePath, breeds } = req.body;

    if (!userId || !breeds || breeds.length === 0) {
      return res.status(400).json({
        success: false,
        message: "userId and breeds are required",
      });
    }

    const classification = new Classify({
      userId,
      imagePath,
      breeds,
    });

    const savedData = await classification.save();

    res.status(201).json({
      success: true,
      message: "Classification saved successfully",
      data: savedData,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Get User History
const getUserHistory = async (req, res) => {
  try {
    const userId = req.user._id;

    const history = await Classify.find({ userId }).sort({ createdAt: -1 });

    res.json({ success: true, data: history });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// Delete Classification
const deleteClassification = async (req, res) => {
  try {
    const deleted = await Classify.findOneAndDelete({
      _id: req.params.id,
      userId: req.user._id,
    });
    if (!deleted) {
      return res.status(404).json({ success: false, message: "Not found" });
    }
    res.json({ success: true, message: "Deleted" });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

module.exports = {
  createClassification,
  getUserHistory,
  deleteClassification,
};