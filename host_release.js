const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 5050;
const WEB_DIR = path.join(__dirname, 'build', 'web');

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.mjs': 'application/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.wasm': 'application/wasm',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.mp4': 'video/mp4',
  '.webm': 'video/webm',
  '.ogg': 'video/ogg',
  '.mp3': 'audio/mpeg',
  '.wav': 'audio/wav',
};

const server = http.createServer((req, res) => {
  // CORS & Security headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Cross-Origin-Embedder-Policy', 'credentialless');
  res.setHeader('Cross-Origin-Opener-Policy', 'same-origin');

  let sanitizedUrl = req.url.split('?')[0];
  if (sanitizedUrl === '/') sanitizedUrl = '/index.html';

  let relativePath = decodeURIComponent(sanitizedUrl);
  let filePath = path.join(WEB_DIR, relativePath);

  // Check asset aliasing for videos
  if (!fs.existsSync(filePath) || !fs.statSync(filePath).isFile()) {
    // If requested /assets/videos/hanuman_intro.mp4, check assets/assets/videos
    const alt1 = path.join(WEB_DIR, 'assets', relativePath);
    const alt2 = path.join(WEB_DIR, 'assets', 'assets', 'videos', path.basename(relativePath));
    const alt3 = path.join(WEB_DIR, 'assets', 'videos', path.basename(relativePath));
    if (fs.existsSync(alt1) && fs.statSync(alt1).isFile()) {
      filePath = alt1;
    } else if (fs.existsSync(alt2) && fs.statSync(alt2).isFile()) {
      filePath = alt2;
    } else if (fs.existsSync(alt3) && fs.statSync(alt3).isFile()) {
      filePath = alt3;
    } else if (!path.extname(sanitizedUrl)) {
      filePath = path.join(WEB_DIR, 'index.html');
    }
  }

  fs.stat(filePath, (err, stats) => {
    if (err || !stats.isFile()) {
      // Fallback to index.html for SPA routes, but return 404 for missing media/files
      if (path.extname(filePath)) {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('Not Found');
        return;
      }
      filePath = path.join(WEB_DIR, 'index.html');
    }

    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';

    // Support HTTP Range requests (required for HTML5 MP4 video playback in browsers)
    const range = req.headers.range;
    if (range && stats) {
      const parts = range.replace(/bytes=/, '').split('-');
      const start = parseInt(parts[0], 10);
      const end = parts[1] ? parseInt(parts[1], 10) : stats.size - 1;
      const chunksize = end - start + 1;
      const stream = fs.createReadStream(filePath, { start, end });

      res.writeHead(206, {
        'Content-Range': `bytes ${start}-${end}/${stats.size}`,
        'Accept-Ranges': 'bytes',
        'Content-Length': chunksize,
        'Content-Type': contentType,
      });
      stream.pipe(res);
    } else {
      res.writeHead(200, {
        'Content-Length': stats ? stats.size : undefined,
        'Content-Type': contentType,
        'Accept-Ranges': 'bytes',
      });
      fs.createReadStream(filePath).pipe(res);
    }
  });
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`Shree Hanuman Chalisa release build is live at: http://127.0.0.1:${PORT}`);
});
