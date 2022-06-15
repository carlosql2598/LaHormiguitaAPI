const {Router} = require('express');
const router = Router();
const mysql = require('../conexionbd');
const { createHash } = require('crypto');
const { check,validationResult } = require('express-validator');

function mysqlQuery(query, params=null) {
    return new Promise(function (resolve, reject) {
        mysql.query(query, params, (err, rows) => {
            if (err){
                reject([500, {'status': 500, 'message': 'Hubo un error en la consulta en la base de datos', 'error': err}]);
            }
            else {
                resolve(rows);
            }
        })
    });
}

router.post('/login', 
    [
        check('USER', 'La variable USER debe contener entre 1 y 45 caracteres.').isLength({min: 1, max: 45}),
        check('PASSWORD', 'La variable USER debe contener entre 1 y 85 caracteres.').isLength({min: 1, max: 85})
    ],
    async (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }
    
    const { USER, PASSWORD } = req.body;
    const query = "SELECT COUNT(*) AS cantidad_usuarios FROM usuarios WHERE usu_username = ? AND usu_contrasena = ?;";
    const hashedPassword = createHash('sha256').update(PASSWORD).digest('hex');
    let cantidad_usuarios = 0;

    await mysqlQuery(query, [USER, hashedPassword])
    .then((rows) => {
        cantidad_usuarios = rows[0]['cantidad_usuarios'];
    })
    .catch((error) => {
        res.status(error[0]).json(error[1]);
    });

    if (cantidad_usuarios > 0) {
        res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": null});
    }
    else {
        res.status(404).json({'status': 404, 'message': 'El usuario o contraseña son incorrectos', 'error': null});
    }
});

module.exports = router;