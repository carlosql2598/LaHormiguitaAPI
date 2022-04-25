
const jwt = require('jsonwebtoken');
const config = require('../constantes.js');

const generarToken = (contrasenia, alias, )=> {
    const token = jwt.sign({contrasenia , alias }, config.tokenSeed , {expiresIn: config.tokenExpired } );

    return token;
};

module.exports = generarToken;
