const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs');
const path = require('path');

const app = express();
const port = 8080;
const ipFile = path.join(__dirname, 'ip');

app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static('public'));
app.use('/scripts', express.static('scripts'));

// Ensure ip file exists
if (!fs.existsSync(ipFile)) {
    fs.writeFileSync(ipFile, '');
}

// GET /ip - Serve the raw IP list for scripts
app.get('/ip', (req, res) => {
    res.sendFile(ipFile);
});

// GET /api/list - Return IP list as JSON for the UI
app.get('/api/list', (req, res) => {
    const data = fs.readFileSync(ipFile, 'utf8');
    const lines = data.split('\n').filter(line => line.trim() !== '');
    const list = lines.map(line => {
        const parts = line.split(/\s+/);
        // Format: ### USERNAME EXPIRED IP
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
