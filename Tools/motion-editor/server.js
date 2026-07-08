const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 3200;

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

const TOKENS_PATH = path.join(__dirname, '..', '..', 'Tokens', 'motion-tokens.json');

// GET motion tokens
app.get('/api/tokens', (req, res) => {
  try {
    const data = fs.readFileSync(TOKENS_PATH, 'utf8');
    res.json(JSON.parse(data));
  } catch (err) {
    res.status(500).json({ error: 'Could not read motion-tokens.json' });
  }
});

// PUT update motion tokens + regenerate Swift
app.put('/api/tokens', (req, res) => {
  try {
    fs.writeFileSync(TOKENS_PATH, JSON.stringify(req.body, null, 2), 'utf8');
    // Regenerate MotionToken.swift from updated JSON
    const { generate } = require('./generate-swift');
    generate();
    res.json({ success: true, swift: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`Motion Design System Editor running at http://localhost:${PORT}`);
});
