const {Router} = require('express');
const router = Router();
const mysql = require('../conexionbd');
const { check, validationResult } = require('express-validator');

function mysqlQuery(query, params=null) {
    return new Promise(function (resolve, reject) {
        mysql.query(query, params, (err, rows) => {
            if (!err){
                resolve(rows);
            }
            else {
                return reject([500, {'status': 500, 'message': 'Hubo un error en la consulta en la base de datos', 'error': err}]);
            }
        })
    });
}

router.post('/insertar',
    [
        check('TEMP_VALOR', 'La variable TEMP_VALOR debe ser un real positivo.').isFloat({min: 1}),
        check('ALM_ID', 'La variable ALM_ID debe ser un entero positivo.').isInt({min: 1})
    ],
    async (req, res) => {

    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({errors : errors.array()});
    }

    const { TEMP_VALOR, ALM_ID } = req.body;
    const queryAlmId = 'SELECT COUNT(*) AS almacenes_cantidad FROM almacenes WHERE alm_id = ?;';
    const queryInsert = 'INSERT temperaturas (temp_valor, alm_id) VALUES (?, ?);';

    let existId = true;

    // Comprueba que exista el ID del almacén
    await mysqlQuery(queryAlmId, ALM_ID)
    .then((rows)=> {
        if (rows[0]['almacenes_cantidad'] <= 0) {
            existId = false;
        }
    })
    .catch((error)=> {
        res.status(error[0]).json(error[1]);1
    });

    // Si no existe el ID, arroja un error
    if (!existId) {
        res.status(404).json({"status": 404, "message": "No se encontró el ID del almacén", "error": "El ID del almacén no está registrado en la base de datos", result: null});
    }
    else {
        await mysqlQuery(queryInsert, [TEMP_VALOR, ALM_ID])
        .then((rows)=> {
            res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": null, result: rows});
        })
        .catch((error)=> {
            res.status(error[0]).json(error[1]);
        });
    }
});

module.exports = router;