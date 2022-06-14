const {Router} = require('express');
const router = Router();
const mysql = require('../conexionbd');
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

router.get('/listar/:FECHA_INI?/:FECHA_FIN?', 
    [
        check('FECHA_INI', 'La variable FECHA_INI no cumple con el formato correcto (AAAA-MM-DD).').default('0001-01-01').isDate(),
        check('FECHA_FIN', 'La variable FECHA_FIN no cumple con el formato correcto (AAAA-MM-DD).').default('9999-12-31').isDate()
    ],
    async (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }
    
    const FECHA_INI = req.params['FECHA_INI'] != undefined ? req.params['FECHA_INI'] : "0001-01-01";
    const FECHA_FIN = req.params['FECHA_FIN'] != undefined ? req.params['FECHA_FIN'] : "9999-12-31";
    const query = 'SELECT rep_id, \
    rep_titulo, \
    rep_descripcion, \
    DATE_FORMAT(rep_fecha_ini, "%Y-%m-%d") AS rep_fecha_ini, \
    DATE_FORMAT(rep_fecha_fin, "%Y-%m-%d") AS rep_fecha_fin \
    FROM reportes \
    WHERE rep_fecha_ini >= ? and rep_fecha_fin <= ?;';

    await mysqlQuery(query, [FECHA_INI, FECHA_FIN])
    .then((rows) => {
        res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": null, result: rows});
    })
    .catch((error) => {
        res.status(error[0]).json(error[1]);
    });
});

router.get('/detalle/:ALM_ID/:REP_ID/:FECHA_INI/:FECHA_FIN', 
    [
        check('ALM_ID', 'La variable ALM_ID debe ser un entero positivo.').isInt(),
        check('REP_ID', 'La variable REP_ID debe ser un entero positivo.').isInt(),
        check('FECHA_INI', 'La variable FECHA_INI no cumple con el formato correcto (AAAA-MM-DD).').isDate(),
        check('FECHA_FIN', 'La variable FECHA_FIN no cumple con el formato correcto (AAAA-MM-DD).').isDate()
    ],
    async (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }
    
    const { ALM_ID, REP_ID, FECHA_INI, FECHA_FIN } = req.params;
    const queryAlm = 'SELECT COUNT(*) AS cantidad_almacenes FROM almacenes WHERE alm_id = ?;';
    const queryRep = 'SELECT COUNT(*) AS cantidad_reportes FROM reportes WHERE rep_id = ?;';
    const query = 'SELECT \
    p.prod_nombre, \
    r.rep_titulo, \
    r.rep_descripcion, \
    rp.rep_prod_cant_vendida, \
    rp.rep_prod_total_ingreso, \
    DATE_FORMAT(r.rep_fecha_ini, "%Y-%m-%d") AS fecha_ini, \
    DATE_FORMAT(r.rep_fecha_fin, "%Y-%m-%d") AS fecha_fin \
    FROM reportes r \
    INNER JOIN reportes_productos rp \
    ON r.rep_id = rp.rep_id \
    INNER JOIN productos p \
    ON p.prod_id = rp.prod_id \
    INNER JOIN almacenes_productos ap \
    ON ap.prod_id = p.prod_id \
    WHERE ap.alm_id = ? AND r.rep_id = ? AND r.rep_fecha_ini >= ? AND r.rep_fecha_fin <= ? \
    ORDER BY r.rep_fecha_reg DESC;';

    await mysqlQuery(queryAlm, ALM_ID)
    .then((rows) => {
        if(rows[0]['cantidad_almacenes'] <= 0) {
            res.status(404).json({"status": 404, "message": "No se encontró el ID del almacén", "error": "El ID del almacén no está registrado en la base de datos", result: null});
        }
    })
    .catch((error) => {
        res.status(error[0]).json(error[1]);
    });

    await mysqlQuery(queryRep, REP_ID)
    .then((rows) => {
        if(rows[0]['cantidad_reportes'] <= 0) {
            res.status(404).json({"status": 404, "message": "No se encontró el ID del reporte", "error": "El ID del reporte no está registrado en la base de datos", result: null});
        }
    })
    .catch((error) => {
        res.status(error[0]).json(error[1]);
    });

    await mysqlQuery(query, [ALM_ID, REP_ID, FECHA_INI, FECHA_FIN])
    .then((rows) => {
        res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": null, result: rows});
    })
    .catch((error) => {
        res.status(error[0]).json(error[1]);
    });
});

router.get('/detalle/:ALM_ID/:REP_ID/:FECHA_INI/:FECHA_FIN', 
    [
        check('ALM_ID', 'La variable ALM_ID debe ser un entero positivo.').isInt(),
        check('REP_ID', 'La variable REP_ID debe ser un entero positivo.').isInt(),
        check('FECHA_INI', 'La variable FECHA_INI no cumple con el formato correcto (AAAA-MM-DD).').isDate(),
        check('FECHA_FIN', 'La variable FECHA_FIN no cumple con el formato correcto (AAAA-MM-DD).').isDate()
    ],
    async (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }
    
    const { ALM_ID, REP_ID, FECHA_INI, FECHA_FIN } = req.params;
    const queryAlm = 'SELECT COUNT(*) AS cantidad_almacenes FROM almacenes WHERE alm_id = ?;';
    const queryRep = 'SELECT COUNT(*) AS cantidad_reportes FROM reportes WHERE rep_id = ?;';
    const query = 'SELECT \
    p.prod_nombre, \
    r.rep_titulo, \
    r.rep_descripcion, \
    rp.rep_prod_cant_vendida, \
    rp.rep_prod_total_ingreso, \
    DATE_FORMAT(r.rep_fecha_ini, "%Y-%m-%d") AS fecha_ini, \
    DATE_FORMAT(r.rep_fecha_fin, "%Y-%m-%d") AS fecha_fin \
    FROM reportes r \
    INNER JOIN reportes_productos rp \
    ON r.rep_id = rp.rep_id \
    INNER JOIN productos p \
    ON p.prod_id = rp.prod_id \
    INNER JOIN almacenes_productos ap \
    ON ap.prod_id = p.prod_id \
    WHERE ap.alm_id = 1 AND r.rep_fecha_ini >= ? AND r.rep_fecha_fin <= ? AND r.rep_id = 1 \
    ORDER BY r.rep_fecha_reg DESC;';

    await mysqlQuery(queryAlm, ALM_ID)
    .then((rows) => {
        if(rows[0]['cantidad_almacenes'] <= 0) {
            res.status(404).json({"status": 404, "message": "No se encontró el ID del almacén", "error": "El ID del almacén no está registrado en la base de datos", result: null});
        }
    })
    .catch((error) => {
        res.status(error[0]).json(error[1]);
    });

    await mysqlQuery(queryRep, REP_ID)
    .then((rows) => {
        if(rows[0]['cantidad_reportes'] <= 0) {
            res.status(404).json({"status": 404, "message": "No se encontró el ID del reporte", "error": "El ID del reporte no está registrado en la base de datos", result: null});
        }
    })
    .catch((error) => {
        res.status(error[0]).json(error[1]);
    });

    await mysqlQuery(query, [ALM_ID, REP_ID, FECHA_INI, FECHA_FIN])
    .then((rows) => {
        res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": null, result: rows});
    })
    .catch((error) => {
        res.status(error[0]).json(error[1]);
    });
});

module.exports = router;