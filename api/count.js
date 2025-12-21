let count = 0;

export default function handler(req, res) {
  try {
    // CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    
    // Handle OPTIONS preflight
    if (req.method === 'OPTIONS') {
      return res.status(200).end();
    }
    
    // Handle POST - increment counter
    if (req.method === 'POST') {
      count++;
      return res.status(200).json({ 
        success: true, 
        total: count 
      });
    }
    
    // Handle GET - return current count
    if (req.method === 'GET') {
      return res.status(200).json({ 
        total: count 
      });
    }
    
    // Method not allowed
    return res.status(405).json({ error: 'Method not allowed' });
    
  } catch (error) {
    return res.status(500).json({ error: 'Server error', message: error.message });
  }
}
