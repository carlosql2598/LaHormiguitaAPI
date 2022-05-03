const {Router} = require('express');
const router = Router();
const mysql = require('../conexionbd');
const { check,validationResult } = require('express-validator');

router.post('/insertar', 
    [
        check('COT_CANTIDAD', 'La variable COT_CANTIDAD debe ser un número entero positivo.').isInt(),
        check('USU_ID', 'La variable USU_ID debe ser un número entero positivo').isInt(),
        check('PROD_ID', 'La variable PROD_ID debe ser un número entero positivo').isInt(),
        check('PROV_IDS', 'La variable PROV_IDS debe ser un array de números enteros positivos.').isArray()
    ],
    (req, res) => {
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }
    
    const queryFunction = 'SELECT FUN_INSERTAR_COTIZACION_Y_OBTENER_ID(?, ?, ?) AS ULTIMO_ID;';
    const { COT_CANTIDAD, USU_ID, PROD_ID, PROV_IDS } = req.body;

    mysql.query(queryFunction, [COT_CANTIDAD, USU_ID, PROD_ID], (err, rows) => {
        if(!err) {
            let queryValues = [];
            let queryInserts = "INSERT INTO cotizaciones_proveedores (cot_id, prov_id) VALUES";
            const ultimo_id = rows[0]["ULTIMO_ID"];

            for (let i = 0; i < PROV_IDS.length; i++) {
                if (i == PROV_IDS.length - 1) {
                    queryInserts = queryInserts + ' (?, ?);';
                }
                else {
                    queryInserts = queryInserts + ' (?, ?),';
                }
                
                queryValues.push(ultimo_id, PROV_IDS[i]);
            }

            mysql.query(queryInserts, queryValues, (err, rows) => {
                if(!err) {
                    res.status(201).json({"status": 201, "message": "Solicitud ejecutada exitosamente.", "error": err});
                } 
                else {
                    res.status(500).json({"status": 500, "message": "Hubo un error en la consulta en la base de datos.", "error": err});
                }
            });

        } 
        else {
            res.status(500).json({"status": 500, "message": "Hubo un error en la consulta en la base de datos.", "error": err});
        }
    });
});

module.exports = router;
