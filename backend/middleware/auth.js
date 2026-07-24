const jwt = require('jsonwebtoken');
const User = require('../models/User');

const protect = async (req, res, next) => {
  let token;
  if (req.headers.authorization?.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
  }
  if (!token) {
    return res.status(401).json({ success: false, message: 'No token' });
  }
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = await User.findById(decoded.id).select('-password');
    if (req.user.isBlocked) {
      return res.status(403).json({ success: false, message: 'Account blocked' });
    }
    next();
  } catch {
    return res.status(401).json({ success: false, message: 'Token invalid' });
  }
};

const adminOnly = (req, res, next) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ success: false, message: 'Admin only' });
  }
  next();
};

const businessOnly = (req, res, next) => {
  if (!['business_owner', 'admin'].includes(req.user.role)) {
    return res.status(403).json({ success: false, message: 'Business owner only' });
  }
  next();
};

module.exports = { protect, adminOnly, businessOnly };