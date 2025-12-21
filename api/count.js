
export default function handler(req, res) {
  // Allow requests from anywhere
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST');
  
  if (req.method === 'POST') {
    count++;
    return res.status(200).json({ 
      success: true, 
      total: count 
    });
  }
  
  if (req.method === 'GET') {
    return res.status(200).json({ 
      total: count 
    });
  }
  
  return res.status(405).json({ error: 'Method not allowed' });
}
