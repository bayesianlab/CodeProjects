const fs = require("fs");
const cheerio = require("cheerio");
const mysql = require("mysql2");
const express = require("express");
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use()

const html = fs.readFileSync("/home/dillon/CodeProjects/Adventinomics/html/notes.html", "utf8");
const $ = cheerio.load(html);
const bodyContent = $("body").html();


const connection = mysql.createConnection({
    host: "localhost",
    user: "dillon",
    password: "Zelzah12",
    database: "adventinomics"
});

connection.connect((err) => {   
    if (err) {
        console.error("Error connecting to MySQL:", err);
        return;
    }
    console.log("Connected to MySQL");
}
);