const {Router} = require('express');
const router = Router();
const mysql = require('../conexionbd');
const { check, validationResult } = require('express-validator');

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
    WHERE rep_fecha_ini >= ? and rep_fecha_fin <= ? \
    ORDER BY rep_fecha_reg DESC;';

    await mysqlQuery(query, [FECHA_INI, FECHA_FIN])
    .then((rows) => {
        res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": null, result: rows});
    })
    .catch((error) => {
        res.status(error[0]).json(error[1]);
    });
});

router.get('/generar/:ALM_ID/:FECHA', 
    [
        check('ALM_ID', 'La variable ALM_ID debe ser un entero positivo.').isInt(),
        check('FECHA', 'La variable FECHA no cumple con el formato correcto (AAAA-MM-DD).').isDate()
    ],
    async (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }
    
    const { ALM_ID, FECHA } = req.params;
    const queryAlm = 'SELECT COUNT(*) AS cantidad_almacenes FROM almacenes WHERE alm_id = ?;';
    const query = 'SELECT \
    p.prod_id, \
    p.prod_nombre, \
    TRUNCATE(pp.ped_prod_precio, 2) AS precio_unitario, \
    SUM(pp.ped_prod_cantidad) AS cantidad_vendida, \
    TRUNCATE(SUM(pp.ped_prod_cantidad) * TRUNCATE(pp.ped_prod_precio, 2), 2) AS ingreso_total, \
    TRUNCATE( (p.prod_costo * pp.ped_prod_cantidad ) , 2) AS prod_costo, \
    DATE_FORMAT(pe.ped_fecha, "%Y-%m-%d") AS ped_fecha \
    FROM pedidos pe \
    INNER JOIN pedidos_productos pp \
    ON pe.ped_id = pp.ped_id \
    INNER JOIN productos p \
    ON p.prod_id = pp.prod_id \
    INNER JOIN almacenes_productos ap \
    ON ap.prod_id = p.prod_id \
    WHERE ap.alm_id = ? AND ped_fecha > ? \
    GROUP BY p.prod_id \
    ORDER BY ped_fecha DESC;';

    await mysqlQuery(queryAlm, ALM_ID)
    .then((rows) => {
        if(rows[0]['cantidad_almacenes'] <= 0) {
            res.status(404).json({"status": 404, "message": "No se encontró el ID del almacén", "error": "El ID del almacén no está registrado en la base de datos", result: null});
        }
    })
    .catch((error) => {
        res.status(error[0]).json(error[1]);
    });

    await mysqlQuery(query, [ALM_ID, FECHA])
    .then((rows) => {
        res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": null, result: rows});
    })
    .catch((error) => {
        res.status(error[0]).json(error[1]);
    });
});

router.get('/detalle/:ALM_ID/:REP_ID', 
    [
        check('ALM_ID', 'La variable ALM_ID debe ser un entero positivo.').isInt(),
        check('REP_ID', 'La variable REP_ID debe ser un entero positivo.').isInt()
    ],
    async (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }
    
    const { ALM_ID, REP_ID } = req.params;
    const queryAlm = 'SELECT COUNT(*) AS cantidad_almacenes FROM almacenes WHERE alm_id = ?;';
    const queryRep = 'SELECT COUNT(*) AS cantidad_reportes FROM reportes WHERE rep_id = ?;';
    const query = 'SELECT \
    p.prod_nombre, \
    r.rep_titulo, \
    r.rep_descripcion, \
    rp.rep_prod_cant_vendida AS cantidad_vendida, \
    rp.rep_prod_total_ingreso AS ingreso_total, \
    TRUNCATE(rp.rep_prod_total_ingreso / rp.rep_prod_cant_vendida, 2) AS precio_unitario, \
    rp.rep_prod_costo AS prod_costo, \
    DATE_FORMAT(r.rep_fecha_ini, "%Y-%m-%d") AS fecha_ini, \
    DATE_FORMAT(r.rep_fecha_fin, "%Y-%m-%d") AS fecha_fin \
    FROM reportes r \
    INNER JOIN reportes_productos rp \
    ON r.rep_id = rp.rep_id \
    INNER JOIN productos p \
    ON p.prod_id = rp.prod_id \
    INNER JOIN almacenes_productos ap \
    ON ap.prod_id = p.prod_id \
    WHERE ap.alm_id = ? AND r.rep_id = ? \
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

    await mysqlQuery(query, [ALM_ID, REP_ID])
    .then((rows) => {
        res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": null, result: rows});
    })
    .catch((error) => {
        res.status(error[0]).json(error[1]);
    });
});

router.post('/insertar', 
    [
        check('REP_TITULO', 'La variable REP_TITULO debe contener entre 1 y 45 caracteres.').isLength({min: 1, max: 45}),
        check('REP_DESCRIPCION', 'La variable REP_DESCRIPCION debe contener al menos 1 caracter.').isLength({min: 1}),
        check('REP_FECHA_INI', 'La variable FECHA_INI no cumple con el formato correcto (AAAA-MM-DD).').isDate(),
        check('REP_FECHA_FIN', 'La variable FECHA_FIN no cumple con el formato correcto (AAAA-MM-DD).').isDate(),
        check('USU_ID', 'La variable USU_ID debe ser un entero positivo.').isInt({min: 1}),
        check('REPORTES_PRODUCTOS', 'Se debe enviar un array de reportes de productos (REPORTES_PRODUCTOS).').isArray(),
        check('REPORTES_PRODUCTOS.*.REP_PROD_CANT_VENDIDA', 'La variable REP_PROD_CANT_VENDIDA debe ser un entero positivo.').isInt({min: 1}),
        check('REPORTES_PRODUCTOS.*.REP_PROD_TOTAL_INGRESO', 'La variable REP_PROD_TOTAL_INGRESO debe ser un entero positivo.').isFloat({min: 1}),
        check('REPORTES_PRODUCTOS.*.REP_PROD_COSTO', 'La variable REP_PROD_COSTO debe ser un entero positivo.').isFloat({min: 1}),
        check('REPORTES_PRODUCTOS.*.PROD_ID', 'La variable PROD_ID debe ser un entero positivo.').isInt({min: 1})
    ],
    async (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }
    
    const { REP_TITULO, REP_DESCRIPCION, REP_FECHA_INI, REP_FECHA_FIN, USU_ID, REPORTES_PRODUCTOS } = req.body;
    const queryUsu = 'SELECT COUNT(*) AS cantidad_usuarios FROM usuarios WHERE usu_id = ?;';
    const queryProd = 'SELECT COUNT(*) AS cantidad_productos FROM productos WHERE prod_id = ?;';
    const queryFunction = 'SELECT FUN_INSERTAR_REPORTE_Y_OBTENER_ID(?, ?, ?, ?, ?) AS ULTIMO_ID;';
    let queryInserts = "INSERT INTO reportes_productos (rep_prod_cant_vendida, rep_prod_total_ingreso, rep_prod_costo, prod_id, rep_id) VALUES";
    let repId = 0;
    let queryValues = [];
    let cantidadUsuarios = 0;
    let errorProd = 0;
    let errorBd = false;
    let errorContent;
    let isSuccess = false;

    await mysqlQuery(queryUsu, USU_ID)
    .then((rows) => {
        cantidadUsuarios = rows[0]['cantidad_usuarios'];
    })
    .catch((error) => {
        errorBd = true;
        errorContent = error;
    });

    if (cantidadUsuarios > 0 && !errorBd) {
        await mysqlQuery(queryFunction, [REP_TITULO, REP_DESCRIPCION, REP_FECHA_INI, REP_FECHA_FIN, USU_ID])
        .then((rows) => {
            repId = rows[0]['ULTIMO_ID'];
        })
        .catch((error) => {
            errorBd = true;
            errorContent = error;
        });
    }

    if(repId > 0 && !errorBd) {
        for (let i = 0; i < REPORTES_PRODUCTOS.length; i++) {
            await mysqlQuery(queryProd, REPORTES_PRODUCTOS[i]['PROD_ID'])
            .then((rows) => {
                if (rows[0]['cantidad_productos'] <= 0) {
                    errorProd = REPORTES_PRODUCTOS[i]['PROD_ID'];
                }
            })
            .catch((error) => {
                errorBd = true;
                errorContent = error;
            });
        }
    }

    if(errorProd <= 0 && !errorBd) {
        for (let i = 0; i < REPORTES_PRODUCTOS.length; i++) {

            if (i == REPORTES_PRODUCTOS.length - 1) {
                queryInserts = queryInserts + ' (?, ?, ?, ?, ?);';
            }
            else {
                queryInserts = queryInserts + ' (?, ?, ?, ?, ?),';
            }
    
            queryValues.push(
                REPORTES_PRODUCTOS[i]['REP_PROD_CANT_VENDIDA'], 
                REPORTES_PRODUCTOS[i]['REP_PROD_TOTAL_INGRESO'],
                REPORTES_PRODUCTOS[i]['REP_PROD_COSTO'],
                REPORTES_PRODUCTOS[i]['PROD_ID'],
                repId
            );
        }
    
        await mysqlQuery(queryInserts, queryValues)
        .then((_) => {
            isSuccess = true;
        })
        .catch((error) => {
            errorBd = true;
            errorContent = error;
        });
    }

    if (cantidadUsuarios <= 0) {
        res.status(404).json({"status": 404, "message": "Ocurrión un problema al obtener el ID del usuario", "error": "No se econtró el ID del usuario en la base de datos", result: null});
    }
    else if (repId <= 0) {
        res.status(404).json({"status": 404, "message": "Ocurrión un problema al obtener el ID de la última inserción", "error": "No se econtró el ID insertado en la base de datos", result: null});
    }
    else if(errorProd > 0) {
        res.status(404).json({"status": 404, "message": `No se encontró el ID (${errorProd}) del producto`, "error": "No se pudo encontrar el ID del producto en la base de datos", result: null});
    }
    else if(errorBd) {
        res.status(errorContent[0]).json(errorContent[1]);
    }
    else if (isSuccess) {
        res.status(201).json({"status": 201, "message": "Solicitud ejecutada exitosamente.", "error": null});
    }
    else {
        res.status(500).json({"status": 500, "message": "Ocurrió un error inesperado, intente más tarde", "error": "Ocurrió un error no controlado, intente más tarde", result: null});
    }
});

module.exports = router;