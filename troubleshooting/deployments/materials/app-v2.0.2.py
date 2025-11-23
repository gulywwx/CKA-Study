from flask import Flask, jsonify
import time
import random

app = Flask(__name__)

# Track when the app started
start_time = time.time()

@app.route('/')
def home():
    uptime = int(time.time() - start_time)
    return jsonify({
        'version': '2.0',
        'status': 'healthy',
        'uptime_seconds': uptime,
        'message': 'Application v2.0 with new features'
    })

@app.route('/health')
def health():
    """
    BUG: Health check has flaky logic that fails most of the time
    This simulates a broken health check or database connection issue
    """
    # Simulate flaky health check - fails 80% of the time
    if random.random() < 0.8:
        return jsonify({
            'status': 'unhealthy',
            'version': '2.0',
            'error': 'Database connection failed'
        }), 500
    
    return jsonify({
        'status': 'healthy',
        'version': '2.0'
    }), 200

@app.route('/api/data')
def get_data():
    return jsonify({
        'data': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        'version': '2.0',
        'new_feature': 'extended data'
    })

if __name__ == '__main__':
    print("Starting application v2.0...")
    app.run(host='0.0.0.0', port=8080, debug=False)
