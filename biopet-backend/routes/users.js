const router = require('express').Router();
const user = require('./models/User');
const {protect, adminOnly, businessOnly} = require('../middleware/auth');

// get all users
router.get('/', protect, adminOnly, async (req,res) => {
    try {
    const users = await user.find().select('-password');
    res.json({success: true, count: users.length,users});
} catch (err) {
    res.status(500).json({
        success: fales, message: err.message
    });
}});

//get single user

router.get('/:id', protect, async (req,res) => {
    try {
        const user = await user.findById(req.params.id).select('-password');
        if(!user) {
        return res.status(404).json({
            success: false, message: 'User not found'
        });
        }
        res.json({
            success:true, user
        });

    } catch (err) {
        res.status(500).json({
            success: false, message: err.message
        });
    }
})

//add new user
router.post('/', async (req,res) => {
    const user = new user(req.body);
    await user.save();
    res.status(201).json(user);
})

//update user data
router.put('/:id', protect, async (req,res) => {
    try {
    if(req.user.role !== 'admin' && req.user._id.toString() !== req.params.id) {
        return res.status(401).json({success: false, message: 'Unauthorized'})
    }

    const {password, role, ...updateData} = req.body;};


    const user = await user.findByIdAndUpdate(
    updateData,
    req.params.id, req.body, {
        new:true,
        runValidators:true
    }).select('-password');

    if(!user) {
    return res.status(404).json({success:false, message: 'User not found'});
}

    res.json({
        success:true, user
    });
} catch (err) {
    res.status(500).json({
        success: false, message: err.message
    });
}
});

router.delete('./:id',protect, adminOnly, async (req,res) => {
    try {
        const user = user.findByIdAndDelete(req.params.id);
        if (!user) {
        return res.status(404).json({
        success: false, message: 'User not found'
        });
        }

        res.json({
            success: true, message: 'User deleted'
        });
   } catch (error) {
    res.status(500).json({ success:false, message: err.message });
   }
});

router.put('./:id/block', protect, adminOnly, async (req,res) => {
    try {
        const user = await user.findById(req.params.id);
        if(!user) {
            return res.status(404).json({success: false,message: "User not found"});
        }

        user.isBlocked = !user.isBlocked;
        await user.save();
        res.json({
            success:true,
            message: user.isBlocked ? "Block": "Unblock",
            isBlocked: user.isBlocked
        });
    } catch (err) {
        res.status(500).json({ success: false,message: err.message });
    }
})
module.exports = router;