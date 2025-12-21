let count = 0;

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  
  if (req.method === 'POST') {
    count++;
    return res.status(200).json({ success: true, count: count });
  }
  
  return res.status(200).json({ count: count });
}
