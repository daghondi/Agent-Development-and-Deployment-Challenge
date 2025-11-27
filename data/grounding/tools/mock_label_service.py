"""Simple mock label generator service.
Run with: python mock_label_service.py

Returns a JSON {label_url, label_id} for POST /generateLabel
"""
from flask import Flask, request, jsonify
import uuid

app = Flask(__name__)

@app.route('/generateLabel', methods=['POST'])
def generate_label():
    payload = request.json or {}
    order_id = payload.get('order_id', 'unknown')
    sku = payload.get('sku', 'unknown')
    label_id = str(uuid.uuid4())
    label_url = f"https://mock-carrier.example.com/labels/{label_id}.pdf"
    return jsonify({
        'label_id': label_id,
        'label_url': label_url
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)
