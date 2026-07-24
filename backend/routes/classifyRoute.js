const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const {
  createClassification,
  getUserHistory,
  deleteClassification
} = require('../controllers/classifyController');

router.post('/', protect, createClassification);
router.get('/history', protect, getUserHistory);
router.delete('/:id', protect, deleteClassification);
module.exports = router;