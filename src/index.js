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
app.use('/api/proveedor', require('./routers/proveedor'));
app.use('/api/cotizacion', require('./routers/cotizacion'));
app.use('/api/producto', require('./routers/producto'));
app.use('/api/pedido', require('./routers/pedido'));
app.use('/api/metrica', require('./routers/metrica'));
app.use('/api/reporte', require('./routers/reporte'));
app.use('/api/usuario', require('./routers/usuario'));
app.use('/api/temperatura', require('./routers/temperatura'));
app.use('/api/humedad', require('./routers/humedad'));
app.use('/api/configuracion', require('./routers/configuracion'));