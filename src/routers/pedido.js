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
        });
    });
}

router.get('/listar/:FECHA?',
    [
        check('FECHA', 'La variable FECHA no cumple con el formato correcto (AAAA-MM-DD).').default("0001-01-01").isDate()
    ],
    (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({errors : errors.array()});
    }

    const query = 'SELECT pc.ped_prod_id, SUM(pc.ped_prod_cantidad) AS cantidad_productos, ROUND(SUM(pr.prod_precio * pc.ped_prod_cantidad), 2) AS precio_total, pc.ped_id, date_format(p.ped_fecha, "%Y-%m-%d") AS pedido_fecha \
    FROM pedidos_productos pc \
    INNER JOIN pedidos p \
    ON p.ped_id = pc.ped_id \
    INNER JOIN productos pr \
    ON pr.prod_id = pc.prod_id \
    WHERE p.ped_fecha > ? \
    GROUP BY pc.ped_id \
    ORDER BY pedido_fecha DESC;';

    const FECHA = req.params['FECHA'] != undefined ? req.params['FECHA'] : "0001-01-01";

    mysql.query(query, FECHA, (err, rows) => {
        if(!err) {
            res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": err, result: rows});
        }
        else {
            res.status(500).json({"status": 500, "message": "Hubo un error en la consulta en la base de datos.", "error": err});
        }
    });

});

router.get('/detalle/:PED_ID',
    [
        check('PED_ID', 'La variable PED_ID debe ser un entero positivo.').isInt()
    ],
    async (req, res) => {

    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({errors : errors.array()});
    }
    
    const { PED_ID } = req.params;
    const querySelect = 'SELECT COUNT(*) AS cantidad_pedidos FROM pedidos WHERE ped_id = ?;';
    const queryDetails = 'SELECT p.prod_nombre, p.prod_precio, p.prod_costo, p.prod_etiqueta, ROUND(p.prod_precio * pc.ped_prod_cantidad, 2) AS precio_total, pc.ped_prod_cantidad AS cantidad_total \
    FROM pedidos_productos pc \
    INNER JOIN productos p \
    ON pc.prod_id = p.prod_id \
    WHERE pc.ped_id = ?;';

    let existId = true;

    // Comprueba que exista el ID del pedido
    await mysqlQuery(querySelect, PED_ID)
    .then((rows)=> {
        if (rows[0]['cantidad_pedidos'] <= 0) {
            existId = false;
        }
    })
    .catch((error)=> {
        res.status(error[0]).json(error[1]);
    });

    // Si no existe el ID, arroja un error
    if (!existId) {
        res.status(404).json({"status": 404, "message": "No se encontr?? el ID del pedido", "error": "El ID del pedido no est?? registrado en la base de datos", result: null});
    }
    else {
        // Obtiene los detalles del pedido
        await mysqlQuery(queryDetails, PED_ID)
        .then((rows)=> {
            res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": null, result: rows});
        })
        .catch((error)=> {
            res.status(error[0]).json(error[1]);
        });
    }

});

module.exports = router;