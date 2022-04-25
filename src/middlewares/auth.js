
const config = require('../constantes.js'); 
const jwt = require('jsonwebtoken');


let verificarToken = (req, res, next)=>{
    let token = req.get('Autorization');
    jwt.verify(token, config.configToken.seed, (err, decoded)=>{
        if(err){
            return res.status(401).json({'msg':' Usted no se encuentra autorizado.'})
        }
        console.log('autorizado');
        next();
    } );
}

module.exports = verificarToken;