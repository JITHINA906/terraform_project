
const express = require("express");
const mysql = require("mysql2/promise");

const app = express();
app.use(express.json());

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 5
});

// Health endpoint
app.get("/health", async (_req, res) => {
  try {
    await pool.query("SELECT 1");
    res.json({ status: "ok", db: "connected" });
  } catch (error) {
    console.error("Health check failed:", error.message);
    res.status(500).json({ status: "error", db: "disconnected" });
  }
});

// Get all items
app.get("/items", async (_req, res) => {
  try {
    const [rows] = await pool.query("SELECT * FROM items");
    res.json(rows);
  } catch (error) {
    console.error("GET /items failed:", error.message);
    res.status(500).json({ error: "Unable to retrieve items" });
  }
});

// Add an item
app.post("/items", async (req, res) => {
  try {
    const { name } = req.body;

    if (!name || typeof name !== "string" || !name.trim()) {
      return res.status(400).json({
        error: "A valid item name is required"
      });
    }

    const [result] = await pool.query(
      "INSERT INTO items (name) VALUES (?)",
      [name.trim()]
    );

    console.log(`Item created: ${result.insertId}`);

    res.status(201).json({
      id: result.insertId,
      name: name.trim()
    });
  } catch (error) {
    console.error("POST /items failed:", error.message);
    res.status(500).json({ error: "Unable to create item" });
  }
});

// Initialize database before starting server
async function startServer() {
  for (let i = 0; i < 15; i++) {
    try {
      await pool.query(`
        CREATE TABLE IF NOT EXISTS items (
          id INT AUTO_INCREMENT PRIMARY KEY,
          name VARCHAR(255) NOT NULL
        )
      `);

      console.log("Database connected and items table ready");

      app.listen(3000, "0.0.0.0", () => {
        console.log("Application listening on port 3000");
      });

      return;
    } catch (error) {
      console.log(`Database connection attempt ${i + 1} failed`);
      await new Promise(resolve => setTimeout(resolve, 2000));
    }
  }

  console.error("Could not connect to database after 15 attempts");
  process.exit(1);
}

startServer();
