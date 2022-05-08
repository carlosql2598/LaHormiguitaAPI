const {Router} = require('express');
const router = Router();
const mysql = require('../conexionbd');
const {check, validationResult} = require('express-validator');

router.post('/insertar', 
    [
        check('PROD_NOMBRE', 'La variable PROD_NOMBRE debe contener entre 1 y 45 caracteres.').isLength({min : 1, max : 45}),
        check('PROD_PRECIO', 'La variable PROD_PRECIO debe ser un entero positivo.').isFloat(),
        check('PROD_STOCK', 'La variable PROD_STOCK debe ser un entero positivo.').isInt(),
        check('PROD_ETIQUETA', 'La variable PROD_ETIQUETA debe ser un entero positivo.').isLength({ min : 8, max : 12}),
        check('ALM_ID', 'La variable ALM_ID debe ser un entero positivo.').isInt()
        
    ],
    (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({errors : errors.array()});
    }

    const queryInsert = 'CALL PRC_REGISTRAR_PRODUCTO(@P_ERROR_MESSAGE, @P_EXIST_ERROR, ?, ?, ?, ?, ?);';
    const querySelect = 'SELECT @P_ERROR_MESSAGE, @P_EXIST_ERROR;';

    const { PROD_NOMBRE, PROD_PRECIO, PROD_STOCK, PROD_ETIQUETA, ALM_ID } = req.body;
    
    mysql.query(queryInsert, [PROD_NOMBRE, PROD_PRECIO, PROD_STOCK, PROD_ETIQUETA, ALM_ID], (err, rows) => {
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
        check('PROD_PRECIO', 'La variable PROD_PRECIO debe ser un entero positivo.').isFloat(),
        check('PROD_STOCK', 'La variable PROD_STOCK debe ser un entero positivo.').isInt(),
        check('PROD_ETIQUETA', 'La variable PROD_ETIQUETA debe ser un entero positivo.').isLength({ min : 8, max : 12})
    ],
    (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()){
        return res.status(400).json({errors: errors.array()});
    }

    const queryUpdate = 'CALL PRC_ACTUALIZAR_PRODUCTO(@P_ERROR_MESSAGE, @P_EXIST_ERROR, ?, ?, ?, ?, ?, ?);';
    const querySelect = 'SELECT @P_ERROR_MESSAGE, @P_EXIST_ERROR;';

    const { ALM_PROD_ID, PROD_ID, PROD_NOMBRE, PROD_PRECIO, PROD_STOCK, PROD_ETIQUETA } = req.body;

    mysql.query(queryUpdate, [ALM_PROD_ID, PROD_ID, PROD_NOMBRE, PROD_PRECIO, PROD_STOCK, PROD_ETIQUETA], (err, rows) => {
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
    
    const query = 'SELECT p.prod_id, p.prod_nombre, p.prod_precio, ap.alm_prod_id, ap.alm_prod_stock, p.prod_fecha, es.est_nombre, p.prod_etiqueta, p.prod_es_activo \
                    FROM productos p \
                    INNER JOIN estados es\
                    ON p.est_id = es.est_id \
                    INNER JOIN almacenes_productos ap \
                    ON p.prod_id = ap.prod_id \
                    WHERE (prod_nombre like CONCAT("%", ?, "%") OR prod_precio like CONCAT("%", ?, "%")) AND ap.alm_id = ? \
                    ORDER BY p.prod_id DESC;';

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

module.exports = router;