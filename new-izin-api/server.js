const express = require('express');
const fs = require('fs');
const path = require('path');
const net = require('net');
const https = require('https');

const app = express();
const port = Number(process.env.PORT || process.env.IZIN_PORT || 7888);
const host = process.env.HOST || process.env.IZIN_HOST || '0.0.0.0';
const ipFile = path.join(__dirname, 'ip');
const logFile = path.join(__dirname, 'access.log');

app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(express.static('public'));
app.use('/scripts', express.static('scripts'));

// Ensure files exist
if (!fs.existsSync(ipFile)) fs.writeFileSync(ipFile, '');
if (!fs.existsSync(logFile)) fs.writeFileSync(logFile, '');

function parseIpList() {
    const data = fs.readFileSync(ipFile, 'utf8');
    return data
        .split('\n')
        .map(line => line.trim())
        .filter(Boolean)
        .map(line => {
            const parts = line.split(/\s+/);
            if (parts.length < 4) return null;
            if (parts[0] !== '###') return null;
            return { username: parts[1], expired: parts[2], ip: parts[3] };
        })
        .filter(item => item && net.isIP(item.ip) === 4);
}

function writeIpList(list) {
    const content = list
        .map(item => `### ${item.username} ${item.expired} ${item.ip}`)
        .join('\n');
    fs.writeFileSync(ipFile, content ? `${content}\n` : '');
}

function cleanUsername(value) {
    return String(value || '')
        .trim()
        .replace(/\s+/g, '-')
        .replace(/[^A-Za-z0-9._-]/g, '');
}

function cleanDate(value) {
    const expired = String(value || '').trim();
    return /^\d{4}-\d{2}-\d{2}$/.test(expired) ? expired : '';
}

function getClientIp(req) {
    const forwarded = String(req.headers['x-forwarded-for'] || '').split(',')[0].trim();
    const rawIp = forwarded || req.socket.remoteAddress || '';
    const cleanIp = rawIp.replace(/^::ffff:/, '').replace(/^.*:/, '');
    return net.isIP(cleanIp) === 4 ? cleanIp : rawIp;
}

function sendScriptFile(res, relativePath, downloadName) {
    const filePath = path.join(__dirname, 'scripts', relativePath);
    if (!fs.existsSync(filePath)) {
        return res.status(404).send('Script not found');
    }

    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    res.setHeader('Content-Disposition', `inline; filename="${downloadName}"`);
    res.sendFile(filePath);
}

// Short installer aliases, so clients can use simple wget URLs.
app.get('/xray', (req, res) => sendScriptFile(res, 'Vpn/xray.zip', 'xray'));
app.get('/vpn', (req, res) => sendScriptFile(res, 'Vpn/vpn.zip', 'vpn'));
app.get('/install', (req, res) => {
    const filePath = path.join(__dirname, 'scripts', 'install.sh');
    if (!fs.existsSync(filePath)) {
        return res.status(404).send('Script not found');
    }
    let content = fs.readFileSync(filePath, 'utf8');
    
    const hostWithPort = req.headers.host;
    const protocol = req.secure || req.headers['x-forwarded-proto'] === 'https' ? 'https' : 'http';
    const serverUrl = `${protocol}://${hostWithPort}`;

    content = content.replace(/http:\/\/64\.235\.61\.22/g, serverUrl);
    
    const injection = `\n# Save license server URL\nmkdir -p /etc/xray\necho "${serverUrl}" > /etc/xray/license_server\n`;
    content = content.replace('Green="\\e[92;1m"', `Green="\\e[92;1m"\n${injection}`);

    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    res.setHeader('Content-Disposition', `inline; filename="install.sh"`);
    res.send(content);
});
app.get('/fix-izin', (req, res) => sendScriptFile(res, 'fix-izin.sh', 'fix-izin.sh'));
app.get('/update', (req, res) => sendScriptFile(res, 'update.sh', 'update.sh'));

// GET /ip - Serve the raw IP list for scripts and LOG THE REQUEST
app.get('/ip', (req, res) => {
    const cleanIp = getClientIp(req);
    const timestamp = new Date().toLocaleString('en-GB', { timeZone: 'Asia/Jakarta' });
    
    // Check if IP is in the authorized list
    const isAuthorized = parseIpList().some(item => item.ip === cleanIp);
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
    res.json(parseIpList());
});

// POST /api/add - Add a new IP
app.post('/api/add', (req, res) => {
    const ip = String(req.body.ip || '').trim();
    const username = cleanUsername(req.body.username);
    const expired = cleanDate(req.body.expired);

    if (net.isIP(ip) !== 4 || !username || !expired) {
        return res.status(400).send('Invalid ip, username, or expired date');
    }

    const list = parseIpList();
    const existingIndex = list.findIndex(item => item.ip === ip);
    const newItem = { username, expired, ip };

    if (existingIndex >= 0) {
        list[existingIndex] = newItem;
    } else {
        list.push(newItem);
    }

    writeIpList(list);
    res.redirect('/');
});

// POST /api/delete - Delete an IP
app.post('/api/delete', (req, res) => {
    const ip = String(req.body.ip || '').trim();
    if (net.isIP(ip) !== 4) {
        return res.status(400).send('Invalid ip');
    }

    const list = parseIpList().filter(item => item.ip !== ip);
    writeIpList(list);
    res.redirect('/');
});

function startTelegramBot(token, adminChatId) {
    let offset = 0;
    const url = `https://api.telegram.org/bot${token}/getUpdates`;
    const sendMessageUrl = `https://api.telegram.org/bot${token}/sendMessage`;

    function sendTelegramMessage(chatId, text) {
        const payload = JSON.stringify({
            chat_id: chatId,
            text: text,
            parse_mode: 'HTML'
        });
        
        const req = https.request(sendMessageUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(payload)
            }
        });
        req.on('error', (e) => console.error("Error sending message:", e));
        req.write(payload);
        req.end();
    }

    function pollUpdates() {
        https.get(`${url}?offset=${offset}&timeout=30`, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                try {
                    const response = JSON.parse(data);
                    if (response.ok && response.result.length > 0) {
                        for (const update of response.result) {
                            offset = update.update_id + 1;
                            handleUpdate(update);
                        }
                    }
                } catch (e) {
                    console.error("Error parsing update:", e);
                }
                setTimeout(pollUpdates, 1000);
            });
        }).on('error', (err) => {
            console.error("Telegram polling error:", err);
            setTimeout(pollUpdates, 5000);
        });
    }

    function handleUpdate(update) {
        if (!update.message || !update.message.text) return;
        const msg = update.message;
        const chatId = String(msg.chat.id);
        const text = msg.text.trim();

        if (chatId !== String(adminChatId)) {
            sendTelegramMessage(chatId, "⚠️ Unauthorized access!");
            return;
        }

        const args = text.split(/\s+/);
        const command = args[0].toLowerCase();

        if (command === '/start' || command === '/help') {
            const helpMsg = `<b>Si Cepat VPN - Admin Bot</b>\n\n` +
                `Commands:\n` +
                `• <code>/add [ip] [username] [YYYY-MM-DD]</code> - Add whitelisted IP\n` +
                `• <code>/delete [ip]</code> - Delete whitelisted IP\n` +
                `• <code>/list</code> - List all whitelisted IPs\n` +
                `• <code>/logs</code> - Show last 10 access hits`;
            sendTelegramMessage(chatId, helpMsg);
        } else if (command === '/add') {
            if (args.length < 4) {
                sendTelegramMessage(chatId, "❌ Usage: <code>/add [ip] [username] [YYYY-MM-DD]</code>");
                return;
            }
            const ip = args[1];
            const username = cleanUsername(args[2]);
            const expired = cleanDate(args[3]);

            if (net.isIP(ip) !== 4 || !username || !expired) {
                sendTelegramMessage(chatId, "❌ Invalid IP, Username, or Date format (YYYY-MM-DD).");
                return;
            }

            const list = parseIpList();
            const existingIndex = list.findIndex(item => item.ip === ip);
            const newItem = { username, expired, ip };

            if (existingIndex >= 0) {
                list[existingIndex] = newItem;
            } else {
                list.push(newItem);
            }

            writeIpList(list);
            sendTelegramMessage(chatId, `✅ Successfully authorized IP: <code>${ip}</code> for user <b>${username}</b> until <b>${expired}</b>.`);
        } else if (command === '/delete') {
            if (args.length < 2) {
                sendTelegramMessage(chatId, "❌ Usage: <code>/delete [ip]</code>");
                return;
            }
            const ip = args[1];
            if (net.isIP(ip) !== 4) {
                sendTelegramMessage(chatId, "❌ Invalid IP address.");
                return;
            }

            const list = parseIpList();
            const filtered = list.filter(item => item.ip !== ip);
            
            if (list.length === filtered.length) {
                sendTelegramMessage(chatId, `⚠️ IP <code>${ip}</code> was not whitelisted.`);
                return;
            }

            writeIpList(filtered);
            sendTelegramMessage(chatId, `✅ Successfully removed IP: <code>${ip}</code> from whitelist.`);
        } else if (command === '/list') {
            const list = parseIpList();
            if (list.length === 0) {
                sendTelegramMessage(chatId, "📭 Whitelist is currently empty.");
                return;
            }
            let listMsg = "<b>Authorized IP List:</b>\n";
            list.forEach(item => {
                const isExpired = new Date(item.expired) < new Date();
                const status = isExpired ? "🔴 Expired" : "🟢 Active";
                listMsg += `• <code>${item.ip}</code> - <b>${item.username}</b> (Exp: ${item.expired}) [${status}]\n`;
            });
            sendTelegramMessage(chatId, listMsg);
        } else if (command === '/logs') {
            if (!fs.existsSync(logFile)) {
                sendTelegramMessage(chatId, "📭 Access logs are empty.");
                return;
            }
            const data = fs.readFileSync(logFile, 'utf8');
            const lines = data.split('\n').filter(line => line.trim() !== '').reverse().slice(0, 10);
            if (lines.length === 0) {
                sendTelegramMessage(chatId, "📭 Access logs are empty.");
                return;
            }
            let logsMsg = "<b>Recent Access Logs:</b>\n";
            lines.forEach(line => {
                logsMsg += `• ${line}\n`;
            });
            sendTelegramMessage(chatId, logsMsg);
        } else {
            sendTelegramMessage(chatId, "❓ Unknown command. Type /help for help.");
        }
    }

    pollUpdates();
    console.log("Telegram Bot long polling started.");
}

const botConfigFile = path.join(__dirname, 'bot_config.json');

function initBot() {
    let token = null;
    let adminChatId = null;

    if (fs.existsSync(botConfigFile)) {
        try {
            const config = JSON.parse(fs.readFileSync(botConfigFile, 'utf8'));
            token = config.token;
            adminChatId = config.adminChatId;
        } catch (e) {
            console.error("Error reading bot_config.json:", e);
        }
    } else if (fs.existsSync('/etc/bot/.bot.db')) {
        try {
            const dbData = fs.readFileSync('/etc/bot/.bot.db', 'utf8').trim();
            const match = dbData.match(/^#bot#\s+(\S+)\s+(\S+)/);
            if (match) {
                token = match[1];
                adminChatId = match[2];
            }
        } catch (e) {
            console.error("Error reading /etc/bot/.bot.db:", e);
        }
    }

    if (token && adminChatId) {
        console.log(`Initializing Telegram Bot with Admin ID: ${adminChatId}`);
        startTelegramBot(token, adminChatId);
    } else {
        console.log("Telegram Bot integration skipped (no token/adminChatId found in bot_config.json or /etc/bot/.bot.db).");
    }
}

app.listen(port, host, () => {
    console.log(`IZIN API running on ${host}:${port}`);
    initBot();
});
