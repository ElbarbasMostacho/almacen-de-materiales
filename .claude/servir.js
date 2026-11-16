// Servidor estático mínimo, solo para ver el sitio en esta máquina.
const http = require('http'), fs = require('fs'), path = require('path');
const raiz = path.resolve(__dirname, '..');
const tipos = { '.html': 'text/html; charset=utf-8', '.css': 'text/css', '.js': 'text/javascript', '.png': 'image/png', '.jpg': 'image/jpeg', '.svg': 'image/svg+xml' };
http.createServer((req, res) => {
  const ruta = path.join(raiz, decodeURIComponent(req.url.split('?')[0]).replace(/\/$/, '/index.html'));
  if (!ruta.startsWith(raiz)) { res.writeHead(403); return res.end(); }
  fs.readFile(ruta, (e, datos) => {
    if (e) { res.writeHead(404); return res.end('No encontrado'); }
    res.writeHead(200, { 'Content-Type': tipos[path.extname(ruta)] || 'application/octet-stream', 'Cache-Control': 'no-store' });
    res.end(datos);
  });
}).listen(process.env.PORT || 5178, '127.0.0.1');
