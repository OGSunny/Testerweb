import fs from 'fs';
import path from 'path';

export default function handler(req, res) {
  try {
    const scriptPath = path.join(process.cwd(), 'scripts', 'forge.lua');
    const scriptContent = fs.readFileSync(scriptPath, 'utf8');

    res.setHeader('Content-Type', 'text/plain');
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Cache-Control', 'no-cache');
    res.status(200).send(scriptContent);
  } catch (error) {
    console.error('Error loading Forge script:', error);
    res.status(500).send('-- Error loading script');
  }
}
