const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs');
const path = require('path');

const app = express();
const port = 8080;
const ipFile = path.join(__dirname, 'ip');
const logFile = path.join(__dirname, 'access.log');

app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static('public'));
app.use('/scripts', express.static('scripts'));

// Ensure files exist
if (!fs.existsSync(ipFile)) fs.writeFileSync(ipFile, '');
if (!fs.existsSync(logFile)) fs.writeFileSync(logFile, '');

// GET /ip - Serve the raw IP list for scripts and LOG THE REQUEST
app.get('/ip', (req, res) => {
    const clientIp = req.headers['x-forwarded-for'] || req.socket.remoteAddress;
    const cleanIp = clientIp.replace(/^.*:/, ''); // Get just the IPv4 part
    const timestamp = new Date().toLocaleString('en-GB', { timeZone: 'Asia/Jakarta' });
    
    // Check if IP is in the authorized list
    const data = fs.readFileSync(ipFile, 'utf8');
    const isAuthorized = data.includes(cleanIp);
    const status = isAuthorized ? "ALLOWED" : "DENIED";

    // Log the hit
    const logEntry = `[${timestamp}] IP: ${cleanIp} | Status: ${status}\n`;
    fs.appendFileSync(logFile, logEntry);

    res.sendFile(ipFile);
});

// GET /api/logs - Return recent logs
app.get('/api/logs', (req, res) => {
    if (!fs.existsSync(logFile)) return res.json([]);
    const data = fs.readFileSync(logFile, 'utf8');
    const lines = data.split('\n').filter(line => line.trim() !== '').reverse();
    res.json(lines.slice(0, 50)); // Return last 50 hits
});

// GET /api/list - Return IP list as JSON for the UI
app.get('/api/list', (req, res) => {
    const data = fs.readFileSync(ipFile, 'utf8');
    const lines = data.split('\n').filter(line => line.trim() !== '');
    const list = lines.map(line => {
        const parts = line.split(/\s+/);
        if (parts.length >= 4) {
            return { username: parts[1], expired: parts[2], ip: parts[3] };
        }
        return null;
    }).filter(item => item !== null);
    res.json(list);
});

// POST /api/add - Add a new IP
app.post('/api/add', (req, res) => {
    const { ip, username, expired } = req.body;
    if (ip && username && expired) {
        const newLine = `### ${username} ${expired} ${ip}\n`;
        fs.appendFileSync(ipFile, newLine);
        res.redirect('/');
    } else {
        res.status(400).send('Missing fields');
    }
});

// POST /api/delete - Delete an IP
app.post('/api/delete', (req, res) => {
    const { ip } = req.body;
    let data = fs.readFileSync(ipFile, 'utf8');
    const lines = data.split('\n').filter(line => !line.includes(ip) && line.trim() !== '');
    fs.writeFileSync(ipFile, lines.join('\n') + (lines.length > 0 ? '\n' : ''));
    res.redirect('/');
});

app.listen(port, '0.0.0.0', () => {
    console.log(`IZIN API running on port ${port}`);
});
