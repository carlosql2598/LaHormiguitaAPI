const {Router} = require('express');
const router = Router();
const mysql = require('../conexionbd');
const {check, validationResult} = require('express-validator');

router.post('/insertar', 
    [
        check('PROD_NOMBRE', 'La variable PROD_NOMBRE debe contener entre 1 y 45 caracteres.').isLength({min : 1, max : 45}),
        check('PROD_PRECIO', 'La variable PROD_PRECIO debe ser un entero positivo.').isFloat(),
        check('PROD_COSTO', 'La variable PROD_COSTO debe ser un real positivo.').isFloat(),
        check('PROD_STOCK', 'La variable PROD_STOCK debe ser un real positivo.').isInt(),
        check('PROD_ETIQUETA', 'La variable PROD_ETIQUETA debe contener entre 1 y 45 caracteres.').isLength({ min : 8, max : 12}),
        check('ALM_ID', 'La variable ALM_ID debe ser un entero positivo.').isInt()
        
    ],
    (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({errors : errors.array()});
    }

    const queryInsert = 'CALL PRC_REGISTRAR_PRODUCTO(@P_ERROR_MESSAGE, @P_EXIST_ERROR, ?, ?, ?, ?, ?, ?);';
    const querySelect = 'SELECT @P_ERROR_MESSAGE, @P_EXIST_ERROR;';

    const { PROD_NOMBRE, PROD_PRECIO, PROD_COSTO, PROD_STOCK, PROD_ETIQUETA, ALM_ID } = req.body;
    
    mysql.query(queryInsert, [PROD_NOMBRE, PROD_PRECIO, PROD_COSTO, PROD_STOCK, PROD_ETIQUETA, ALM_ID], (err, rows) => {
        if (!err) {
            mysql.query(querySelect, (err, rows) => {
                if (!err){
                    if (rows[0]['@P_EXIST_ERROR'] == 0) // No hay error
                    {
                        res.status(200).json({'status': 200, 'message': 'Solicitud ejecutada exitosamente.', 'error': err});
                    }
                    else {
                        res.status(404).json({'status': 404, 'message': rows[0]['@P_ERROR_MESSAGE'], 'error': err});
                    }
                }
                else{
                    res.status(500).json({'status': 500, 'message': 'Hubo un error en la consulta en la base de datos', 'error': err});
                }
            })
        }
        else{
            res.status(500).json({'status': 500, 'message': 'Hubo un error en la consulta en la base de datos', 'error': err});
        }   
    });
});

router.put('/actualizar',
    [
        check('ALM_PROD_ID', 'La variable ALM_ID debe ser un entero positivo.').isInt(),
        check('PROD_ID', 'La variable PROD_ID debe ser un entero positivo.').isInt(),
        check('PROD_NOMBRE', 'La variable PROD_NOMBRE debe contener entre 1 y 45 caracteres.').isLength({ min : 1, max : 45}),
        check('PROD_PRECIO', 'La variable PROD_PRECIO debe ser un real positivo.').isFloat(),
        check('PROD_COSTO', 'La variable PROD_COSTO debe ser un real positivo.').isFloat(),
        check('PROD_STOCK', 'La variable PROD_STOCK debe ser un entero positivo.').isInt(),
        check('PROD_ETIQUETA', 'La variable PROD_ETIQUETA debe ser un entero positivo.').isLength({ min : 8, max : 12})
    ],
    (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()){
        return res.status(400).json({errors: errors.array()});
    }

    const queryUpdate = 'CALL PRC_ACTUALIZAR_PRODUCTO(@P_ERROR_MESSAGE, @P_EXIST_ERROR, ?, ?, ?, ?, ?, ?, ?);';
    const querySelect = 'SELECT @P_ERROR_MESSAGE, @P_EXIST_ERROR;';

    const { ALM_PROD_ID, PROD_ID, PROD_NOMBRE, PROD_PRECIO, PROD_COSTO, PROD_STOCK, PROD_ETIQUETA } = req.body;

    mysql.query(queryUpdate, [ALM_PROD_ID, PROD_ID, PROD_NOMBRE, PROD_PRECIO, PROD_COSTO, PROD_STOCK, PROD_ETIQUETA], (err, rows) => {
        if (!err) {
            mysql.query(querySelect, (err, rows) => {
                if (!err){
                    if (rows[0]['@P_EXIST_ERROR'] == 0) // No hay error
                    {
                        res.status(200).json({'status': 200, 'message': 'Solicitud ejecutada exitosamente.', 'error': err});
                    }
                    else {
                        res.status(404).json({'status': 404, 'message': rows[0]['@P_ERROR_MESSAGE'], 'error': err});
                    }
                }
                else{
                    res.status(500).json({'status': 500, 'message': 'Hubo un error en la consulta en la base de datos', 'error': err});
                }
            })
        }
        else{
            res.status(500).json({'status': 500, 'message': 'Hubo un error en la consulta en la base de datos', 'error': err});
        }   
    });
});

router.delete('/eliminar/:PROD_ID',
    [
        check('PROD_ID', 'La variable PROD_ID debe ser un entero positivo.').isInt()
    ],
    (req, res) => {

    const errors = validationResult(req);

    if (!errors.isEmpty()){
        return res.status(400).json({errors: errors.array()});
    }

    const queryDelete = 'UPDATE productos SET prod_es_activo = 0 WHERE prod_id = ?;'
    const queryGetId = 'SELECT prod_id FROM productos WHERE prod_id = ?';
    
    const { PROD_ID } = req.params;

    mysql.query(queryGetId, [PROD_ID], (err, rows) => {
        if(!err) {
            if (rows.length === 0) {
                res.status(404).json({"status": 404, "message": "El producto no se encuentra registrado en la base de datos.", "error": err});
            }
            else {
                mysql.query(queryDelete, [PROD_ID], (err, rows) => {
                    if(!err) {
                        res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": err});
                    }
                    else {
                        res.status(500).json({"status": 500, "message": "Hubo un error en la consulta en la base de datos", "error": err});
                    }
                });
            }
        }
        else {
            res.status(500).json({"status": 500, "message": "Hubo un error en la consulta en la base de datos.", "error": err});
        }
    });

});

router.get('/restablecer/:PROD_ID',
    [
        check('PROD_ID', 'La variable PROD_ID debe ser un entero positivo.').isInt()
    ],
    (req, res) => {

    const errors = validationResult(req);

    if (!errors.isEmpty()){
        return res.status(400).json({errors: errors.array()});
    }

    const queryDelete = 'UPDATE productos SET prod_es_activo = 1 WHERE prod_id = ?;'
    const queryGetId = 'SELECT prod_id FROM productos WHERE prod_id = ?';
    
    const { PROD_ID } = req.params;

    mysql.query(queryGetId, [PROD_ID], (err, rows) => {
        if(!err) {
            if (rows.length === 0) {
                res.status(404).json({"status": 404, "message": "El producto no se encuentra registrado en la base de datos.", "error": err});
            }
            else {
                mysql.query(queryDelete, [PROD_ID], (err, rows) => {
                    if(!err) {
                        res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": err});
                    }
                    else {
                        res.status(500).json({"status": 500, "message": "Hubo un error en la consulta en la base de datos", "error": err});
                    }
                });
            }
        }
        else {
            res.status(500).json({"status": 500, "message": "Hubo un error en la consulta en la base de datos.", "error": err});
        }
    });

});

router.get('/buscar/:ALM_ID/:BUSQ_PARAM??',
    [
        check('ALM_ID', 'La variable ALM_ID debe ser un entero positivo.').isInt()
    ],
    (req, res) => {
    
    const query = 'SELECT p.prod_id, p.prod_nombre, p.prod_precio, ap.alm_prod_id, ap.alm_prod_stock, p.prod_fecha, es.est_nombre, p.prod_etiqueta, p.prod_es_activo, p.prod_costo \
                    FROM productos p \
                    INNER JOIN estados es\
                    ON p.est_id = es.est_id \
                    INNER JOIN almacenes_productos ap \
                    ON p.prod_id = ap.prod_id \
                    WHERE (p.prod_nombre like CONCAT("%", ?, "%") OR p.prod_precio like CONCAT("%", ?, "%") OR p.prod_etiqueta like CONCAT("%", ?, "%")) AND ap.alm_id = ? \
                    ORDER BY p.prod_id DESC;';

    var { ALM_ID, BUSQ_PARAM } = req.params;

    BUSQ_PARAM = BUSQ_PARAM != undefined ? BUSQ_PARAM : "";

    mysql.query(query, [BUSQ_PARAM, BUSQ_PARAM, BUSQ_PARAM, ALM_ID], (err, rows) => {
        if(!err) {
            res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": err, result: rows});
        }
        else {
            res.status(500).json({"status": 500, "message": "Hubo un error en la consulta en la base de datos.", "error": err});
        }
    });

});

router.get('/categorias_asociadas/:PROD_ID',
    [
        check('PROD_ID', 'La variable PROD_ID debe ser un entero positivo.').isInt()
    ],
    (req, res) => {

    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    const queryBuscar = 'SELECT c.cat_id, c.cat_nombre, pc.prod_cat_id, p.prod_id \
        FROM productos p \
        INNER JOIN productos_categorias pc \
        ON p.prod_id = pc.prod_id \
        INNER JOIN categorias c \
        ON c.cat_id = pc.cat_id \
        WHERE p.prod_id = ? AND c.cat_estado = 1;'

    const queryGetId = 'SELECT prod_id FROM productos WHERE prod_id = ?';
    const { PROD_ID } = req.params;

    mysql.query(queryGetId, [PROD_ID], (err, rows) => {
        if(!err) {
            if (rows.length === 0) {
                res.status(404).json({"status": 404, "message": "El producto no se encuentra registrado en la base de datos.", "error": err});
            }
            else {
                mysql.query(queryBuscar, [PROD_ID], (err, rows) => {
                    if(!err) {
                        res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": err, result: rows});
                    }
                    else {
                        res.status(500).json({"status": 500, "message": "Hubo un error en la consulta en la base de datos.", "error": err});
                    }
                });
            }
        }
        else {
            res.status(500).json({"status": 500, "message": "Hubo un error en la consulta en la base de datos.", "error": err});
        }
    });
});

router.get('/categorias_no_asociadas/:PROD_ID', 
    [
        check('PROD_ID', 'La variable PROD_ID debe ser un entero positivo.').isInt()
    ],
    (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    const queryBuscar = 'SELECT cat_id, cat_nombre \
        FROM categorias \
        WHERE cat_id NOT IN (SELECT c.cat_id \
        FROM productos p \
        INNER JOIN productos_categorias pc \
        ON p.prod_id = pc.prod_id \
        INNER JOIN categorias c \
        ON c.cat_id = pc.cat_id \
        WHERE p.prod_id = ? AND c.cat_estado = 1) AND cat_estado = 1;'

    const queryGetId = 'SELECT prod_id FROM productos WHERE prod_id = ?';
    const { PROD_ID } = req.params;
    
    mysql.query(queryGetId, [PROD_ID], (err, rows) => {
        if(!err) {
            if (rows.length === 0) {
                res.status(404).json({"status": 404, "message": "El producto no se encuentra registrado en la base de datos.", "error": err});
            }
            else {
                mysql.query(queryBuscar, [PROD_ID], (err, rows) => {
                    if(!err) {
                        res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": err, result: rows});
                    }
                    else {
                        res.status(500).json({"status": 500, "message": "Hubo un error en la consulta en la base de datos.", "error": err});
                    }
                });
            }
        }
        else {
            res.status(500).json({"status": 500, "message": "Hubo un error en la consulta en la base de datos.", "error": err});
        }
    });
});

router.delete('/eliminar_categoria/:PROD_CAT_ID', 
    [
        check('PROD_CAT_ID', 'La variable PROD_CAT_ID debe ser un entero positivo.').isInt()
    ],
    (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    const queryDelete = 'DELETE FROM productos_categorias WHERE prod_cat_id = ?;'
    const queryGetId = 'SELECT prod_cat_id FROM productos_categorias WHERE prod_cat_id = ?';
    const { PROD_CAT_ID } = req.params;
    
    mysql.query(queryGetId, [PROD_CAT_ID], (err, rows) => {
        if(!err) {
            if (rows.length === 0) {
                res.status(404).json({"status": 404, "message": "No se encontró el registro en la base de datos.", "error": err});
            }
            else {
                mysql.query(queryDelete, [PROD_CAT_ID], (err, rows) => {
                    if(!err) {
                        res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": err});
                    }
                    else {
                        res.status(500).json({"status": 500, "message": "Hubo un error en la consulta en la BD.", "error": err});
                    }
                });
            }
        }
        else {
            res.status(500).json({"status": 500, "message": "Hubo un error en la consulta en la base de datos.", "error": err});
        }
    });
});


router.post('/agregar_categoria', 
    [
        check('PROD_ID', 'La variable PROD_ID debe ser un entero positivo.').isInt(),
        check('CAT_ID', 'La variable CAT_ID debe ser un entero positivo.').isInt()
    ],
    (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    
    const query = 'INSERT INTO productos_categorias (prod_id, cat_id) VALUES (?, ?);';
    
    const { PROD_ID, CAT_ID } = req.body;

    mysql.query(query, [PROD_ID, CAT_ID], (err, rows) => {
        if(!err) {
            res.status(201).json({"status": 201, "message": "Solicitud ejecutada exitosamente.", "error": err});
        } 
        else {
            if (err["code"] == "ER_NO_REFERENCED_ROW_2") {
                res.status(404).json({"status": 404, "message": "El producto o la categoria no se encuentran registrados en la base de datos.", "error": null});
            }
            else {
                res.status(500).json({"status": 500, "message": "Hubo un error en la consulta en la base de datos.", "error": err});
            }
        }
    } );
});

router.get('/por_reabastecer_irc/:ALM_ID/:BUSQ_PARAM?',
    [
        check('ALM_ID', 'La variable ALM_ID debe ser un entero positivo.').isInt()
    ],
    (req, res) => {
    
    const query = 'SELECT p.prod_id, p.prod_nombre, p.prod_costo, es.est_nombre, p.prod_es_activo, pe.ped_fecha, \
    ap.alm_prod_stock AS prod_stock, \
    SUM(pp.ped_prod_cantidad) AS prod_vendidos, \
    ((SUM(pp.ped_prod_cantidad) + ap.alm_prod_stock)/2) AS stock_promedio, \
    TRUNCATE( (p.prod_costo * SUM(pp.ped_prod_cantidad)) / ((SUM(pp.ped_prod_cantidad)+ap.alm_prod_stock)/2), 2) AS IRS \
    FROM productos p \
    INNER JOIN estados es \
    ON p.est_id = es.est_id \
    INNER JOIN almacenes_productos ap \
    ON p.prod_id = ap.prod_id \
    INNER JOIN pedidos_productos pp \
    ON pp.prod_id = p.prod_id \
    INNER JOIN pedidos pe \
    ON pe.ped_id = pp.ped_id \
    WHERE (p.prod_nombre like CONCAT("%", ?, "%") OR p.prod_costo like CONCAT("%", ?, "%")) AND  \
    ap.alm_id = ? \
    GROUP BY p.prod_id \
    ORDER BY IRS DESC;';

    var { ALM_ID, BUSQ_PARAM } = req.params;

    BUSQ_PARAM = BUSQ_PARAM != undefined ? BUSQ_PARAM : "";

    mysql.query(query, [BUSQ_PARAM, BUSQ_PARAM, ALM_ID], (err, rows) => {
        if(!err) {
            res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": err, result: rows});
        }
        else {
            res.status(500).json({"status": 500, "message": "Hubo un error en la consulta en la base de datos.", "error": err});
        }
    });

});

router.get('/irc_por_producto/:ALM_ID/:PROD_ID',
    [
        check('ALM_ID', 'La variable ALM_ID debe ser un entero positivo.').isInt(),
        check('PROD_ID', 'La variable PROD_ID debe ser un entero positivo.').isInt()
    ],
    (req, res) => {
    
    const query = 'SELECT p.prod_nombre, p.prod_costo, pe.ped_fecha, \
    SUM(pp.ped_prod_cantidad) AS prod_vendidos, \
    ((SUM(pp.ped_prod_cantidad) + ap.alm_prod_stock)/2) AS stock_promedio, \
    TRUNCATE( (p.prod_costo * SUM(pp.ped_prod_cantidad)) / ((SUM(pp.ped_prod_cantidad)+ap.alm_prod_stock)/2), 2) AS IRS \
    FROM productos p \
    INNER JOIN almacenes_productos ap \
    ON p.prod_id = ap.prod_id \
    INNER JOIN pedidos_productos pp \
    ON pp.prod_id = p.prod_id \
    INNER JOIN pedidos pe \
    ON pe.ped_id = pp.ped_id \
    WHERE ap.alm_id = ? AND p.prod_id = ? \
    GROUP BY pe.ped_id \
    ORDER BY IRS DESC;';

    var { ALM_ID, PROD_ID } = req.params;

    mysql.query(query, [ALM_ID, PROD_ID], (err, rows) => {
        if(!err) {
            res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": err, result: rows});
        }
        else {
            res.status(500).json({"status": 500, "message": "Hubo un error en la consulta en la base de datos.", "error": err});
        }
    });

});

module.exports = router;