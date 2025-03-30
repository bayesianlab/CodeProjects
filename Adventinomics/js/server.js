const express = require("express");
const mysql = require("mysql2");
const bodyParser = require("body-parser");
const cors = require("cors");

const db = mysql.createConnection({
    host: 'localhost',
    user: 'dillon', // Change if using a different user
    password: 'Zelzah12', // Replace with your MySQL root password
    database: 'adventinomics'
});

const app = express();
app.use(bodyParser.json());
app.use(cors());

app.post("/subscribe", (req, res) => {
    const { email } = req.body;

    const query = "INSERT INTO Subscribers (email) VALUES (?)";
    
    db.query(query, [email], (err, result) => {
        if (err) {
            return res.status(500).json({ error: "Error subscribing. This email is already registered." });
        }
        res.status(200).json({ message: "Subscription successful!" });
    });
});

// Start the server
const PORT = 5000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});