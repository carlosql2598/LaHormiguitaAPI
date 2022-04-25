const {Router} = require('express');
const router = Router();

router.get('/', (req, res) => {
    res.json({"message": "Bienvenido al API", "status": 200});
});

module.exports = router;