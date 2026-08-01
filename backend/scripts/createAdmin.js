require("dotenv").config({
  path: "../.env",
});
require("node:dns/promises").setServers(["1.1.1.1", "1.0.0.1"]);

const mongoose = require("mongoose");
const User = require("../models/User");

async function createAdmin() {
  try {
    await mongoose.connect(process.env.MONGO_URI);

    console.log("✅ MongoDB Connected");

    const email = "admin@biopet.com";

    let admin = await User.findOne({ email });

    if (admin) {
      admin.name = "BioPet Admin";
      admin.role = "admin";
      admin.isVerified = true;
      admin.isActive = true;
      admin.isBlocked = false;

      // Password ပြန် hash ဖြစ်အောင် plain password ပေး
      admin.password = "admin123";

      await admin.save();

      console.log("✅ Existing user updated as Admin");
    } else {
      await User.create({
        name: "BioPet Admin",
        email: "admin@biopet.com",
        password: "admin123",
        phone: "",
        role: "admin",
        isVerified: true,
        isActive: true,
        isBlocked: false,
      });

      console.log("✅ Admin account created");
    }

    console.log("");
    console.log("========== ADMIN LOGIN ==========");
    console.log("Email    : admin@biopet.com");
    console.log("Password : admin123");
    console.log("================================");

    process.exit();

  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}

createAdmin();