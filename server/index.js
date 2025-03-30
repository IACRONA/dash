const express = require("express");
const playerRouter = require("./routes/player.routes");
const storeRouter = require("./routes/store.routes");
const infoRouter = require("./routes/info.routes");

// const middlewareApiKey = require("./middlewares/apiKey");
const PORT = process.env.PORT || 8080;

const https = require("https");
const fs = require("fs");

// const options = {
//   key: fs.readFileSync("ssl/key.pem"),
//   cert: fs.readFileSync("ssl/cert.pem"),
// };

const app = express();

app.use("/", (req, res, next) => {
  console.log(req.body);
  next();
});
app.use(express.json());
app.use("/api", playerRouter);
app.use("/api", storeRouter);
app.use("/api", infoRouter);

app.listen(PORT, () => console.log(`server started on ${PORT}`));

// https.createServer(options, app).listen(443, () => {
//   console.log("HTTPS сервер работает на порту 443");
// });
