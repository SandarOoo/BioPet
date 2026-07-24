const express = require("express");

const router = express.Router();

const {
createProduct,
getMyProducts,
deleteProduct,
updateProduct
}=require("../controllers/productController");


const {
protect
}=require("../middleware/auth");



router.post(
"/createProducts",
protect,
createProduct
);

router.get(
"/products",
protect,
getMyProducts
);

router.put(
"/products/:id",
protect,
updateProduct
);



router.delete(
"/products/:id",
protect,
deleteProduct
);



module.exports=router;