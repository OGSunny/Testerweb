const express = require('express');
const multer = require('multer'); // For handling file uploads
const { exec } = require('child_process'); // To run the deobfuscator tool
const fs = require('fs');
const path = require('path');

const app = express();
const upload = multer({ dest: 'uploads/' }); // Save uploaded files here

app.use(express.static('public')); // Serve your frontend files

// The main API endpoint
app.post('/deobfuscate', upload.single('luaFile'), (req, res) => {
    if (!req.file) return res.status(400).send('No file uploaded.');

    const inputPath = req.file.path;
    const outputPath = `${inputPath}_clean.lua`;

    // COMMAND: This is where we run the "Engine" (e.g., De4Lua or SixZensED)
    // You must download the deobfuscator repo and place it in a folder named 'engine'
    const command = `node ./engine/index.js --input ${inputPath} --output ${outputPath}`;

    console.log(`Processing file: ${req.file.originalname}...`);

    exec(command, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error: ${error.message}`);
            return res.status(500).json({ error: "Deobfuscation failed.", details: stderr });
        }

        // Read the result file and send it back to the user
        fs.readFile(outputPath, 'utf8', (err, data) => {
            if (err) return res.status(500).send("Could not read output file.");
            
            res.json({ 
                originalName: req.file.originalname,
                deobfuscatedCode: data,
                logs: stdout 
            });

            // Cleanup: Delete files after sending to save space
            fs.unlinkSync(inputPath);
            fs.unlinkSync(outputPath);
        });
    });
});

app.listen(3000, () => console.log('Server running on port 3000'));
