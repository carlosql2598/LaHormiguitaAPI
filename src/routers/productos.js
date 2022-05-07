const {Router} = require('express');
const router = Router();
const mysql = require('../conexionbd');
const {check, validationResult} = require('express-validator');

router.post('/insertar', 
    [
        check('PROD_NOMBRE', 'La variable PROD_NOMBRE debe contener entre 1 y 45 caracteres.').isLength({min : 1, max : 45}),
        check('PROD_PRECIO', 'La variable PROD_PRECIO debe ser un entero positivo.').isInt(),
        check('ETI_ID', 'La variable ETI_ID debe ser un entero positivo.').isInt(),
        check('EST_ID', 'La variable EST_ID debe ser un entero positivo.').isInt(),
        
    ],
    (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({errors : errors.array()});
    }

    const query = 'INSERT INTO productos (prod_nombre, prod_precio, eti_id, est_id) VALUES (?, ?, ?, ?)';

    const {PROD_NOMBRE, PROD_PRECIO, ETI_ID, EST_ID} = req.query;

    mysql.query(query, [PROD_NOMBRE, PROD_PRECIO, ETI_ID, EST_ID], (err,rows) => {
        if (!err) {
            res.status(201).json({'status' : 201, 'message' : 'Solicitud ejecutada nexitosamente', 'error' : err});
        }
        else {
            res.status(500).json({'status' : 500, 'message' : 'Hubo un error en la consulta en la base de datos', 'error' : err});
        }
    })
});

router.put('/actualizar',
    [
        check('PROD_ID', 'La variable PROD_ID debe ser un entero positivo.').isInt(),
        check('PROD_NOMBRE', 'La variable PROD_NOMBRE debe contener entre 1 y 45 caracteres.').isLength({ min : 1, max : 45}),
        check('PROD_PRECIO', 'La variable PROD_PRECIO debe ser un entero positivo.').isInt(),
        check('ETI_ID', 'La variable ETI_ID debe ser un entero positivo.').isInt(),
        check('EST_ID', 'La variable EST_ID debe ser un entero positivo.').isInt(),
    ],
    (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()){
        return res.status(400).json({errors: errors.array()});
    }

    const queryUpdate = 'UPDATE productos SET prod_nombre = ?, prod_precio = ?, eti_id = ?, est_id = ? WHERE prod_id = ? ';// AND est_id = 1';

    const queryGetId = 'SELECT prod_id FROM productos WHERE prod_id = ?';

    const {PROD_NOMBRE, PROD_PRECIO, ETI_ID, EST_ID} = req.body;

    mysql.query(queryGetId, PROD_ID, (err, rows) => {
        if (!err) {
            if (rows.length == 0){
                res.status(404).json({'status': 404, 'message' : 'El producto no se encuentra registrado en la base de datos.', 'error' : err});
            }
            else {
                mysql.query(queryUpdate, [PROD_NOMBRE, PROD_PRECIO, ETI_ID, EST_ID], (err) => {
                    if (!err){
                        res.status(200).json({'status' : 200, 'message' : 'Solicitud ejecutada exitosamente.', 'error' : err});
                    }
                    else{
                        res.status(500).json({'status' : 500, 'message' : 'Hubo un error en la consulta en la base de datos', 'error' : err});
                    }
                })
            }
        }
        else{
            res.status(500).json({'status' : 500, 'message' : 'Hubo un error en la consulta en la base de datos', 'error' : err});
        }   
    })
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

    const queryDelete = 'UPDATE productos SET prod_estado = 0 WHERE prod_id = ?;'
    
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


router.get('/buscar/:BUSQ_PARAM??',
    (req, res) => {
    
    const query = 'SELECT * \
                    FROM productos \
                    WHERE prod_nombre like CONCAT("%", ?, "%") OR prod_precio like CONCAT("%", ?, "%");';

    const BUSQ_PARAM = req.params['BUSQ_PARAM'] != undefined ? req.params['BUSQ_PARAM'] : "";

    mysql.query(query, [BUSQ_PARAM, BUSQ_PARAM], (err, rows) => {
        if(!err) {
            res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": err, result: rows});
        }
        else {
            res.status(500).json({"status": 500, "message": "Hubo un error en la consulta en la base de datos.", "error": err});
        }
    });

});

module.exports = router;