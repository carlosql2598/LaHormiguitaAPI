const {Router} = require('express');
const router = Router();
const mysql = require('../conexionbd');
const { check,validationResult } = require('express-validator');

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

router.get('/obtener_temp_hum/:ALM_ID',
    [
        check('ALM_ID', 'La variable ALM_ID debe ser un entero positivo.').isInt()
    ],
    async (req, res) => {

    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({errors : errors.array()});
    }

    const { ALM_ID } = req.params;
    const queryAlmId = 'SELECT COUNT(*) AS almacenes_cantidad FROM almacenes WHERE alm_id = ?;';
    const querySelect = 'SELECT temp_limite, hum_limite FROM configuraciones WHERE alm_id = ? LIMIT 1;';

    let existId = true;

    // Comprueba que exista el ID del pedido
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
        // Obtiene los detalles del pedido
        await mysqlQuery(querySelect, [ALM_ID])
        .then((rows)=> {
            res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": null, result: rows[0]});
        })
        .catch((error)=> {
            res.status(error[0]).json(error[1]);
        });
    }
});

router.put('/actualizar_temp_hum',
    [
        check('TEMP_VALUE', 'La variable TEMP_VALUE debe ser un entero positivo.').isFloat({min: 0, max: 1000}),
        check('HUM_VALUE', 'La variable HUM_VALUE debe ser un entero positivo.').isFloat({min: 0, max: 100}),
        check('ALM_ID', 'La variable ALM_ID debe ser un entero positivo.').isInt({min: 1})
    ],
    async (req, res) => {

    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({errors : errors.array()});
    }

    const { TEMP_VALUE, HUM_VALUE, ALM_ID } = req.body;
    const queryAlmId = 'SELECT COUNT(*) AS almacenes_cantidad FROM almacenes WHERE alm_id = ?;';
    const queryUpdate = 'UPDATE configuraciones SET temp_limite = ?, hum_limite = ? WHERE alm_id = ?;';

    let existId = true;

    // Comprueba que exista el ID del pedido
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
        // Obtiene los detalles del pedido
        await mysqlQuery(queryUpdate, [TEMP_VALUE, HUM_VALUE, ALM_ID])
        .then((rows)=> {
            res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": null, result: null});
        })
        .catch((error)=> {
            res.status(error[0]).json(error[1]);
        });
    }
});

module.exports = router;
