const {Router} = require('express');
const router = Router();
const mysql = require('../conexionbd');
const { check,validationResult } = require('express-validator');

function send_response(status_code, message, error=null, res) {
    res.status(status_code).json({"status": status_code, "message": message, "error": error});
}

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




//LISTAR LOS COMENTARIOS HECHA POR UN USUARIO.
// router.get('/obtenerComentarios/:id', 
//     [ 
//         check('id', 'La variable id no es un número').notEmpty().isInt()
//     ],
//     (req, res) => {

//     const errors = validationResult(req);
//     if (!errors.isEmpty()) {
//         return res.status(400).json({ errors: errors.array()});
//     }

//     const {id} = req.params;

//     const query = 'SELECT U.USU_NOMBRES, U.USU_APELLIDOS, C.CA_CALIFICACION, C.CA_COMENTARIO, C.CA_FECHA  FROM USUARIOS U  INNER JOIN CALIFICACIONES C ON U.IDCLIENTE = C.IDCLIENTE  WHERE C.IDCLIENTE= ?;';


//     mysql.query(query, [id], (err, rows) => {
//         if(!err){
//             res.status(200).json(rows);
//         }else{
//             res.status(500).json({"mensaje":"Hubo un error en la consulta en la BD.", "status":500});
//         }
//     } );
    
// });




module.exports = router;
