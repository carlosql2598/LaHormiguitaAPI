const mysql = require('mysql');
const port = require('./constantes');
// mysql://b2de383794b057:b5837737@us-cdbr-east-03.cleardb.com/heroku_f79b6a9307229c1?

//Configuración
const dbconfig = {
    host:  port.hostLocal,
    user: port.userLocal,
    password: port.passwordLocal,
    database: port.databaseLocal
};


//Creación de la conexión
var connection = mysql.createConnection(dbconfig);

//Establecer una nueva conexión
connection.connect( error => {
    if(error){
        console.log('Ocurrió un error en la conexión con la BD');
        connection = reconnect(connection);
    } else{ 
        console.log('Conexión exitosa con la BD');
    }
    
});


//Reconectando
function reconnect(connection){
    console.log('Reconectando conexión con la Base de datos.');

    //Destruyendo la conexión
    if(connection) connection.destroy();

    //Creando una nueva conexión
    var connection = mysql.createConnection(dbconfig);

    connection.connect(error => {
        if(error){
            setTimeout(reconnect, 2000);
        }else{
            console.log('Reconectado, nueva conexión estable.');
            return connection;
        }
    });

}


//Escuchando errores. 
connection.on( 'error', function(err){

    //- El servidor cierra la conexión.
    if(err.code === "PROTOCOL_CONNECTION_LOST"){    
        console.log("/!\\ No se puede establecer una conexión con la Base de Datos. /!\\ ("+err.code+")");
        connection = reconnect(connection);
    }

    //- Conexión cerrando.
    else if(err.code === "PROTOCOL_ENQUEUE_AFTER_QUIT"){
        console.log("/!\\ No se puede establecer una conexión con la Base de Datos. /!\\ ("+err.code+")");
        connection = reconnect(connection);
    }

    //- Error fatal: la variable de conexión debe volver a crearse.
    else if(err.code === "PROTOCOL_ENQUEUE_AFTER_FATAL_ERROR"){
        console.log("/!\\ No se puede establecer una conexión con la Base de Datos. /!\\ ("+err.code+")");
        connection = reconnect(connection);
    }

    //- Error porque ya se está estableciendo una conexión.
    else if(err.code === "PROTOCOL_ENQUEUE_HANDSHAKE_TWICE"){
        console.log("/!\\ No se puede establecer una conexión con la Base de Datos. /!\\ ("+err.code+")");
    }

    //- Otros casos.
    else{
        console.log("/!\\ No se puede establecer una conexión con la Base de Datos. /!\\ ("+err.code+")");
        connection = reconnect(connection);
    }
} );




module.exports = connection;