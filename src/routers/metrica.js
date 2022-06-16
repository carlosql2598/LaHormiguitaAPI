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

router.get('/productos_mas_vendidos/:ALM_ID/:FECHA',
    [
        check('ALM_ID', 'La variable ALM_ID debe ser un entero positivo.').isInt(),
        check('FECHA', 'La variable FECHA no cumple con el formato correcto (AAAA-MM-DD).').isDate()
    ],
    async (req, res) => {

    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({errors : errors.array()});
    }

    const { ALM_ID, FECHA } = req.params;
    const queryAlmId = 'SELECT COUNT(*) AS almacenes_cantidad FROM almacenes WHERE alm_id = ?;';
    const querySelect = 'SELECT p.prod_nombre AS nombre_producto, SUM(pp.ped_prod_cantidad) AS cantidad_vendida \
    FROM pedidos pe \
    INNER JOIN pedidos_productos pp \
    ON pp.ped_id = pe.ped_id \
    INNER JOIN productos p \
    ON p.prod_id = pp.prod_id \
    INNER JOIN almacenes_productos ap \
    ON p.prod_id = ap.prod_id \
    WHERE ap.alm_id = ? AND pe.ped_fecha > ? \
    GROUP BY p.prod_id \
    ORDER BY cantidad_vendida DESC \
    LIMIT 5;';

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
        await mysqlQuery(querySelect, [ALM_ID, FECHA])
        .then((rows)=> {
            res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": null, result: rows});
        })
        .catch((error)=> {
            res.status(error[0]).json(error[1]);
        });
    }
});

router.get('/productos_mayor_ganancia/:ALM_ID/:FECHA',
    [
        check('ALM_ID', 'La variable ALM_ID debe ser un entero positivo.').isInt(),
        check('FECHA', 'La variable FECHA no cumple con el formato correcto (AAAA-MM-DD).').isDate()
    ],
    async (req, res) => {

    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({errors : errors.array()});
    }

    const { ALM_ID, FECHA } = req.params;
    const queryAlmId = 'SELECT COUNT(*) AS almacenes_cantidad FROM almacenes WHERE alm_id = ?';
    const querySelect = 'SELECT p.prod_nombre AS nombre_producto, \
    ROUND(SUM(pp.ped_prod_cantidad) * p.prod_precio, 2) AS ingreso_producto, \
    ROUND((SUM(pp.ped_prod_cantidad) + ap.alm_prod_stock) * p.prod_costo, 2) AS costo_producto, \
    e.est_nombre AS estado_producto \
    FROM pedidos pe \
    INNER JOIN pedidos_productos pp \
    ON pp.ped_id = pe.ped_id \
    INNER JOIN productos p \
    ON p.prod_id = pp.prod_id \
    INNER JOIN almacenes_productos ap \
    ON p.prod_id = ap.prod_id \
    INNER JOIN estados e \
    ON e.est_id = p.est_id \
    WHERE ap.alm_id = ? AND pe.ped_fecha > ? \
    GROUP BY p.prod_id \
    ORDER BY (ingreso_producto - costo_producto) DESC \
    LIMIT 5;';

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
        await mysqlQuery(querySelect, [ALM_ID, FECHA])
        .then((rows)=> {
            res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": null, result: rows});
        })
        .catch((error)=> {
            res.status(error[0]).json(error[1]);
        });
    }
});

router.get('/porcentaje_ventas/:ALM_ID/:FECHA',
    [
        check('ALM_ID', 'La variable ALM_ID debe ser un entero positivo.').isInt(),
        check('FECHA', 'La variable FECHA no cumple con el formato correcto (AAAA-MM-DD).').isDate()
    ],
    async (req, res) => {

    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({errors : errors.array()});
    }

    const { ALM_ID, FECHA } = req.params;
    const queryAlmId = 'SELECT COUNT(*) AS almacenes_cantidad FROM almacenes WHERE alm_id = ?';
    const querySelect = 'SELECT p.prod_nombre AS nombre_producto, \
    SUM(pp.ped_prod_cantidad) AS cantidad_vendida, \
    ( (SUM(pp.ped_prod_cantidad) / (ap.alm_prod_stock + SUM(pp.ped_prod_cantidad))) * 100 ) AS porcentaje_venta \
    FROM pedidos pe \
    INNER JOIN pedidos_productos pp \
    ON pe.ped_id = pp.ped_id \
    INNER JOIN productos p \
    ON p.prod_id = pp.prod_id \
    INNER JOIN almacenes_productos ap \
    ON ap.prod_id = p.prod_id \
    WHERE ap.alm_id = ? AND pe.ped_fecha > ? \
    GROUP BY p.prod_id \
    ORDER BY porcentaje_venta DESC \
    LIMIT 5;';

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
        await mysqlQuery(querySelect, [ALM_ID, FECHA])
        .then((rows)=> {
            res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": null, result: rows});
        })
        .catch((error)=> {
            res.status(error[0]).json(error[1]);
        });
    }
});

router.get('/margen_de_inversion/:ALM_ID/:FECHA',
    [
        check('ALM_ID', 'La variable ALM_ID debe ser un entero positivo.').isInt(),
        check('FECHA', 'La variable FECHA no cumple con el formato correcto (AAAA-MM-DD).').isDate()
    ],
    async (req, res) => {

    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({errors : errors.array()});
    }

    const { ALM_ID, FECHA } = req.params;
    const queryAlmId = 'SELECT COUNT(*) AS almacenes_cantidad FROM almacenes WHERE alm_id = ?';
    const querySelect = 'SELECT p.prod_nombre, \
    ROUND(SUM(pp.ped_prod_cantidad) * p.prod_precio, 2) AS ingresos_totales, \
    ROUND(SUM(pp.ped_prod_cantidad) * p.prod_costo, 2) AS costos_totales, \
    (SUM(pp.ped_prod_cantidad) + alm_prod_stock) AS stock_inicial, \
    alm_prod_stock AS stock_actual, \
    SUM(pp.ped_prod_cantidad) AS cantidad_vendida, \
    ROUND( ((SUM(pp.ped_prod_cantidad) + alm_prod_stock) *  p.prod_costo) + (alm_prod_stock * p.prod_costo) / 2, 2) AS costo_medio_inventario, \
    p.prod_costo AS costo_unitario \
    FROM pedidos pe \
    INNER JOIN pedidos_productos pp \
    ON pe.ped_id = pp.ped_id \
    INNER JOIN productos p \
    ON p.prod_id = pp.prod_id \
    INNER JOIN almacenes_productos ap \
    ON ap.prod_id = p.prod_id \
    WHERE ap.alm_id = ? AND pe.ped_fecha > ? \
    GROUP BY p.prod_id \
    ORDER BY ((ingresos_totales - costos_totales) / ingresos_totales) / costo_medio_inventario \
    LIMIT 5;';

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
        await mysqlQuery(querySelect, [ALM_ID, FECHA])
        .then((rows)=> {
            res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": null, result: rows});
        })
        .catch((error)=> {
            res.status(error[0]).json(error[1]);
        });
    }
});

// router.get('/productos_perdidas/:ALM_ID/:FECHA',
//     [
//         check('ALM_ID', 'La variable ALM_ID debe ser un entero positivo.').isInt(),
//         check('FECHA', 'La variable FECHA no cumple con el formato correcto (AAAA-MM-DD).').isDate()
//     ],
//     async (req, res) => {

//     const errors = validationResult(req);

//     if (!errors.isEmpty()) {
//         return res.status(400).json({errors : errors.array()});
//     }

//     const { ALM_ID, FECHA } = req.params;
//     const queryAlmId = 'SELECT COUNT(*) AS almacenes_cantidad FROM almacenes WHERE alm_id = ?';
//     const querySelect = 'SELECT p.prod_nombre, p.prod_precio, p.prod_costo, ap.alm_prod_stock \
//     FROM productos p \
//     INNER JOIN almacenes_productos ap \
//     ON p.prod_id = ap.prod_id \
//     WHERE ap.alm_id = ? \
//     GROUP BY p.prod_id \
//     ORDER BY (p.prod_costo * ap.alm_prod_stock) DESC;';

//     let existId = true;

//     // Comprueba que exista el ID del pedido
//     await mysqlQuery(queryAlmId, ALM_ID)
//     .then((rows)=> {
//         if (rows[0]['almacenes_cantidad'] <= 0) {
//             existId = false;
//         }
//     })
//     .catch((error)=> {
//         res.status(error[0]).json(error[1]);1
//     });

//     // Si no existe el ID, arroja un error
//     if (!existId) {
//         res.status(404).json({"status": 404, "message": "No se encontró el ID del almacén", "error": "El ID del almacén no está registrado en la base de datos", result: null});
//     }
//     else {
//         // Obtiene los detalles del pedido
//         await mysqlQuery(querySelect, [ALM_ID, FECHA])
//         .then((rows)=> {
//             res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": null, result: rows});
//         })
//         .catch((error)=> {
//             res.status(error[0]).json(error[1]);
//         });
//     }
// });

module.exports = router;