const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { protect } = require('../middleware/auth');
const router = express.Router();

const generateToken = (id) =>
  jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRE,
  });

// Register
router.post('/register', async (req, res) => {
  const { name, email, password, phone, role, businessProfile } = req.body;
  try {
    if (await User.findOne({ email })) {
      return res.status(400).json({ success: false, message: 'Email already exists' });
    }
    if (role === 'admin') {
      return res.status(403).json({ success: false, message: 'Cannot register as admin' });
    }
    const user = await User.create({
      name, email, password, phone,
      role: role || 'user',
      businessProfile: role === 'business_owner' ? businessProfile : {},
    });
    res.status(201).json({
      success: true,
      token: generateToken(user._id),
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        avatar: user.avatar,
      },
    });
  } catch (err) {
      console.error("REGISTER ERROR:", err);
      res.status(500).json({
        success: false,
        message: err.message,
      });
    }
});

// Login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.findOne({ email });
    if (!user || !(await user.matchPassword(password))) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
    if (user.isBlocked) {
      return res.status(403).json({ success: false, message: 'Account blocked' });
    }
    res.json({
      success: true,
      token: generateToken(user._id),
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        avatar: user.avatar,
        businessProfile: user.businessProfile,
      },
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Get Me
router.get('/me', protect, (req, res) => {
  res.json({ success: true, user: req.user });
});

module.exports = router;