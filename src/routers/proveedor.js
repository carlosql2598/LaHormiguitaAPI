const {Router} = require('express');
const router = Router();
const mysql = require('../conexionbd');
const { check,validationResult } = require('express-validator');

router.post('/insert', 
    [
        check('COM_COMMENTARY', 'La variable COM_COMMENTARY debe contener entre 1 y 100 caracteres.').isLength({min: 1,max: 100}),
        check('SIG_ID', 'La variable SIG_ID no es un número.').isEmpty()
    ],
    (req, res) => {
    
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    
    const query = 'INSERT INTO COMMENTS(COM_COMMENTARY, SIG_ID) VALUES (?, ?);';
    
    const {COM_COMMENTARY, SIG_ID} = req.body;

    mysql.query(query, [COM_COMMENTARY, SIG_ID], (err, rows) => {
        if(!err){
            res.status(201).json({"status": 201, "message": "Solicitud ejecutada exitosamente."});
        }else{
            res.status(500).json({"message": "Hubo un error en la consulta en la BD.", "status": 500, "error": err});
        }
    } );

    

});


//LISTAR TODOS LOS COMENTARIOS CON RESPECTO A UN PRODUCTO.

router.get('/getRandom', 
    // [
    //     check('id', 'La variable id no es un número').notEmpty().isInt()
    // ],
    (req, res)=> {
        
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }
    
        // const {id} = req.params;
    
        const query = 'SELECT COM_COMMENTARY FROM COMMENTS ORDER BY RAND() LIMIT 1';
    
    
        mysql.query(query, (err, rows) => {
            if(!err){
                res.status(200).json(rows);
            }else{
                res.status(500).json({"message": "Hubo un error en la consulta en la BD.", "status": 500, "error": err});
            }
        } );

    }

);




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
