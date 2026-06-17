const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
  },
  password: {
    type: String,
    required: true,
    minlength: 6,
  },
  phone: {
    type: String,
    default: '',

  },
  avatar: {
    type: String,
    default: '',
  },
  role: {
    type: String,
    enum: ['user', 'business_owner', 'admin'],
    default: 'user',
  },
  isVerified: {
    type: Boolean,
    default: false,
  },
  businessProfile: {
    businessName: { type: String, default: '' },
    businessType: {
      type: String,
      enum: ['vet_clinic', 'pet_shop', 'grooming', 'other', ''],
      default: '',
    },
    address: { type: String, default: '' },
    latitude: { type: Number, default: null },
    longitude: { type: Number, default: null },
    description: { type: String, default: '' },
    isVerified: { type: Boolean, default: false },
  },
  pets: [{
    name: String,
    species: {
      type: String,
      enum: ['dog', 'cat', 'other'],
    },
    breed: String,
    age: Number,
    photo: String,
  }],
  isActive: { type: Boolean, default: true },
  isBlocked: { type: Boolean, default: false },
}, { timestamps: true });

// Password Hash
userSchema.pre('save', async function () {
  if (!this.isModified('password')) return;

  this.password = await bcrypt.hash(this.password, 10);
});

// Password Check
userSchema.methods.matchPassword = async function(entered) {
  return await bcrypt.compare(entered, this.password);
};

module.exports = mongoose.model('User', userSchema);