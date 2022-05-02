const express = require('express');
const bodyParser = require('body-parser');
const PORT = process.env.PORT || 3000;
const app = express();
const cors = require("cors");

// git push heroku main = Para subir los cambios a heroku.

app.use(bodyParser.json());
app.set('json spaces', 2);


app.listen(PORT, ()=> console.log(`Servidor ejecutandose en el puerto ${PORT}`));


//Configuraciones
app.use(cors());


//routers
app.use('/api/', require('./routers/index'));
app.use('/api/proveedor',require('./routers/proveedor'));
// app.use('/api/usuario', require('./routers/usuario'));
// app.use('/api/order', require('./routers/order'));
// app.use('/api/calificacion', require('./routers/calificacion'));
// app.use('/api/categoria', require('./routers/categoria'));