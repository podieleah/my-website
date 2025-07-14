from flask import Flask, render_template
import os

app = Flask(__name__)

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/health')
def health():
    """Health check endpoint for monitoring"""
    return {'status': 'healthy', 'service': 'portfolio-site'}, 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
