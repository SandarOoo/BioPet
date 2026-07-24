const Product = require("../models/product");

// UPDATE PRODUCT
exports.updateProduct = async (req, res) => {
  try {
    const { id } = req.params;


    const {
      name,
      category,
      description,
      price,
      stock,
      image,
    } = req.body;



    const product = await Product.findOne({
      _id: id,
      owner: req.user._id,
    });

    if (!product) {

      return res.status(404).json({

        success:false,

        message:"Product not found or you are not the owner."

      });

    }



    if(name !== undefined){
      product.name = name;
    }


    if(category !== undefined){
      product.category = category;
    }


    if(description !== undefined){
      product.description = description;
    }


    if(price !== undefined){
      product.price = Number(price);
    }


    if(stock !== undefined){
      product.stock = Number(stock);
    }


    if(image !== undefined){
      product.image = image;
    }



    await product.save();



    return res.status(200).json({

      success:true,

      message:"Product updated successfully.",

      product

    });



  } catch(err){


    console.error("Update Product Error:",err);


    return res.status(500).json({

      success:false,

      message:err.message

    });


  }

};

// CREATE PRODUCT
exports.createProduct = async(req,res)=>{

try{


const product = await Product.create({

    owner:req.user._id,

    name:req.body.name,

    category:req.body.category,

    image:req.body.image,

    price:req.body.price,

    stock:req.body.stock,

    description:req.body.description

});


res.json({

success:true,

message:"Product created",

product

});


}catch(err){

res.status(500).json({

success:false,

message:err.message

});

}

};


// GET OWNER PRODUCTS

exports.getMyProducts = async(req,res)=>{

try{


const products =
await Product.find({
    owner:req.user._id
});


res.json({

success:true,

products

});


}catch(err){

res.status(500).json({

success:false,
message:err.message

});

}


};





// DELETE PRODUCT

exports.deleteProduct = async(req,res)=>{

try{


await Product.findOneAndDelete({

_id:req.params.id,

owner:req.user._id

});


res.json({

success:true,
message:"Deleted"

});


}catch(err){

res.status(500).json({

success:false,
message:err.message

});

}

};