import express from "express"
import cors from "cors"
import dotenv from "dotenv"
import serverless from "serverless-http"
import transactionRoutes from "./routes/transactions.js"



dotenv.config()

const app = express()
app.use(cors({
    origin: "https://www.finbloom.work.gd",
    methods: ["GET", "POST", "PUT", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"]
}))

app.get("/ping", (req, res) => {
  res.json({ message: "pong" });
});

app.use(express.json())
app.use("/api/transactions", transactionRoutes)

const PORT = process.env.PORT || 5000

app.get("/", (req, res) => {
    res.send("FinBloom API is running...")
})

// app.listen(PORT, "0.0.0.0", () => console.log(`server running on port ${PORT}`))

//Lambda needs a handler function
export const handler = serverless(app)