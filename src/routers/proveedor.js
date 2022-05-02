const {Router} = require('express');
const router = Router();
const mysql = require('../conexionbd');
const { check,validationResult } = require('express-validator');

router.post('/insertar', 
    [
        check('PROV_NOMBRE', 'La variable PROV_NOMBRE debe contener entre 1 y 45 caracteres.').isLength({min: 1, max: 45}),
        check('PROV_CELULAR', 'La variable PROV_CELULAR debe contener entre 12 caracteres (Ejm: +51987654321).').isLength({min: 12, max: 12}),
        check('PROV_RUC', 'La variable PROV_RUC debe contener entre 11 caracteres.').isLength({min: 11, max: 11})
    ],
    (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    
    const query = 'INSERT INTO proveedores (prov_nombre, prov_celular, prov_ruc) VALUES (?, ?, ?);';
    
    const { PROV_NOMBRE, PROV_CELULAR, PROV_RUC } = req.body;

    mysql.query(query, [PROV_NOMBRE, PROV_CELULAR, PROV_RUC], (err, rows) => {
        if(!err) {
            res.status(201).json({"status": 201, "message": "Solicitud ejecutada exitosamente.", "error": err});
        } 
        else {
            res.status(500).json({"status": 500, "message": "Hubo un error en la consulta en la base de datos.", "error": err});
        }
    } );
});


router.put('/actualizar', 
    [
        check('PROV_ID', 'La variable PROV_ID debe ser un entero positivo.').isInt(),
        check('PROV_NOMBRE', 'La variable PROV_NOMBRE debe contener entre 1 y 45 caracteres.').isLength({min: 1, max: 45}),
        check('PROV_CELULAR', 'La variable PROV_CELULAR debe contener entre 12 caracteres (Ejm: +51987654321).').isLength({min: 12, max: 12}),
        check('PROV_RUC', 'La variable PROV_RUC debe contener entre 11 caracteres.').isLength({min: 11, max: 11})
    ],
    (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    const queryUpdate = 'UPDATE proveedores SET prov_nombre = ?, prov_celular = ?, prov_ruc = ? WHERE prov_id = ?;';
    const queryGetId = 'SELECT prov_id FROM proveedores WHERE prov_id = ?';
    const { PROV_ID, PROV_NOMBRE, PROV_CELULAR, PROV_RUC } = req.body;
    
    mysql.query(queryGetId, [PROV_ID], (err, rows) => {
        if(!err) {
            if (rows.length === 0) {
                res.status(404).json({"status": 404, "message": "El proveedor no se encuentra registrado en la base de datos.", "error": err});
            }
            else {
                mysql.query(queryUpdate, [PROV_NOMBRE, PROV_CELULAR, PROV_RUC, PROV_ID], (err, rows) => {
                    if(!err) {
                        res.status(201).json({"status": 201, "message": "Solicitud ejecutada exitosamente.", "error": err});
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


router.delete('/eliminar/:PROV_ID', 
    [
        check('PROV_ID', 'La variable PROV_ID debe ser un entero positivo.').isInt()
    ],
    (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    const queryDelete = 'UPDATE proveedores SET prov_estado = 0 WHERE prov_id = ?;'
    const queryGetId = 'SELECT prov_id FROM proveedores WHERE prov_id = ?';
    const { PROV_ID } = req.params;
    
    mysql.query(queryGetId, [PROV_ID], (err, rows) => {
        if(!err) {
            if (rows.length === 0) {
                res.status(404).json({"status": 404, "message": "El proveedor no se encuentra registrado en la base de datos.", "error": err});
            }
            else {
                mysql.query(queryDelete, [PROV_ID], (err, rows) => {
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


//LISTAR Y BUSCAR LOS PROVEEDORES.

router.get('/buscar/:BUSQ_PARAM?',
    (req, res) => {

    const query = 'SELECT prov_id, prov_nombre, prov_celular, prov_ruc \
                    FROM proveedores \
                    WHERE (prov_nombre like CONCAT("%", ?, "%") OR prov_celular like CONCAT("%", ?, "%") OR prov_ruc like CONCAT("%", ?, "%")) AND prov_estado = 1;';

    const BUSQ_PARAM = req.params['BUSQ_PARAM'] != undefined ? req.params['BUSQ_PARAM'] : "";

    mysql.query(query, [BUSQ_PARAM, BUSQ_PARAM, BUSQ_PARAM], (err, rows) => {
        if(!err) {
            res.status(200).json({"status": 200, "message": "Solicitud ejecutada exitosamente.", "error": err, result: rows});
        }
        else {
            res.status(500).json({"status": 500, "message": "Hubo un error en la consulta en la base de datos.", "error": err});
        }
    });
});


router.get('/categorias_asociadas/:PROV_ID', 
    [
        check('PROV_ID', 'La variable PROV_ID debe ser un entero positivo.').isInt()
    ],
    (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    const queryBuscar = 'SELECT c.cat_id, c.cat_nombre, pc.prov_cat_id \
        FROM proveedores p \
        INNER JOIN proveedores_categorias pc \
        ON p.prov_id = pc.prov_id \
        INNER JOIN categorias c \
        ON c.cat_id = pc.cat_id \
        WHERE p.prov_id = ? AND c.cat_estado = 1;'

    const queryGetId = 'SELECT prov_id FROM proveedores WHERE prov_id = ?';
    const { PROV_ID } = req.params;
    
    mysql.query(queryGetId, [PROV_ID], (err, rows) => {
        if(!err) {
            if (rows.length === 0) {
                res.status(404).json({"status": 404, "message": "El proveedor no se encuentra registrado en la base de datos.", "error": err});
            }
            else {
                mysql.query(queryBuscar, [PROV_ID], (err, rows) => {
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


router.get('/categorias_no_asociadas/:PROV_ID', 
    [
        check('PROV_ID', 'La variable PROV_ID debe ser un entero positivo.').isInt()
    ],
    (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    const queryBuscar = 'SELECT cat_id, cat_nombre \
        FROM categorias \
        WHERE cat_id NOT IN (SELECT c.cat_id \
        FROM proveedores p \
        INNER JOIN proveedores_categorias pc \
        ON p.prov_id = pc.prov_id \
        INNER JOIN categorias c \
        ON c.cat_id = pc.cat_id \
        WHERE p.prov_id = ?) AND cat_estado = 1;'

    const queryGetId = 'SELECT prov_id FROM proveedores WHERE prov_id = ?';
    const { PROV_ID } = req.params;
    
    mysql.query(queryGetId, [PROV_ID], (err, rows) => {
        if(!err) {
            if (rows.length === 0) {
                res.status(404).json({"status": 404, "message": "El proveedor no se encuentra registrado en la base de datos.", "error": err});
            }
            else {
                mysql.query(queryBuscar, [PROV_ID], (err, rows) => {
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


router.delete('/eliminar_categoria/:PROV_ID', 
    [
        check('PROV_ID', 'La variable PROV_ID debe ser un entero positivo.').isInt()
    ],
    (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    const queryDelete = 'UPDATE categorias SET cat_estado = 0 WHERE cat_id = ?;'
    const queryGetId = 'SELECT prov_id FROM proveedores WHERE prov_id = ?';
    const { PROV_ID } = req.params;
    
    mysql.query(queryGetId, [PROV_ID], (err, rows) => {
        if(!err) {
            if (rows.length === 0) {
                res.status(404).json({"status": 404, "message": "El proveedor no se encuentra registrado en la base de datos.", "error": err});
            }
            else {
                mysql.query(queryDelete, [PROV_ID], (err, rows) => {
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
        check('PROV_ID', 'La variable PROV_ID debe ser un entero positivo.').isInt(),
        check('CAT_ID', 'La variable CAT_ID debe ser un entero positivo.').isInt()
    ],
    (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    
    const query = 'INSERT INTO proveedores_categorias (prov_id, cat_id) VALUES (?, ?);';
    
    const { PROV_ID, CAT_ID } = req.body;

    mysql.query(query, [PROV_ID, CAT_ID], (err, rows) => {
        if(!err) {
            res.status(201).json({"status": 201, "message": "Solicitud ejecutada exitosamente.", "error": err});
        } 
        else {
            res.status(500).json({"status": 500, "message": "Hubo un error en la consulta en la base de datos.", "error": err});
        }
    } );
});

module.exports = router;
