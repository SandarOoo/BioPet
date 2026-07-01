const mongoose = require('mongoose');


const breedSchema = new mongoose.Schema({
    name: {type: String, required: true},
    acc: {type: Number, required: true}},{_id:false
});

const classifyingSchema = new mongoose.Schema({
    userId: {type: String, required: true},
    imagePath: {type: String, default:''},
    timestamp: {type: Date, default: Date.now},
    breeds: [breedSchema]
});

const breed = mongoose.model('breed',breedSchema);
const classifying = mongoose.model('classifying', classifyingSchema);

module.exports = {
    breed,classifying
};