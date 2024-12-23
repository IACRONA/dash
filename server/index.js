const express = require("express");
const playerRouter = require("./routes/player.routes");
// const middlewareApiKey = require("./middlewares/apiKey");
const PORT = process.env.PORT || 8080;

const app = express();

app.use(express.json());
app.use("/api", playerRouter);

app.listen(PORT, () => console.log(`server started on ${PORT}`));
