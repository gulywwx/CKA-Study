from flask import Flask, jsonify
import time

app = Flask(__name__)

# Track when the app started
start_time = time.time()

@app.route('/')
def home():
    uptime = int(time.time() - start_time)
    return jsonify({
        'version': '1.0',
        'status': 'healthy',
        'uptime_seconds': uptime,
        'message': 'Application v1.0 running smoothly'
    })

@app.route('/health')
def health():
    """Health check endpoint for readiness probe"""
    return jsonify({
        'status': 'healthy',
        'version': '1.0'
    }), 200

@app.route('/api/data')
def get_data():
    return jsonify({
        'data': [1, 2, 3, 4, 5],
        'version': '1.0'
    })

if __name__ == '__main__':
    print("Starting application v1.0...")
    app.run(host='0.0.0.0', port=8080, debug=False)
