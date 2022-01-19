const express = require('express');
const app = express();

app.set('port', 3000)

app.get('/', (req, res) => {
    res.send("Hola a todos")
})

app.listen(app.get('port'), () => {
    console.log("Aplicación corriendo en el puerto 3000")
})
