from flask import Flask, render_template
import socket
import os

app = Flask(__name__)

@app.route('/')
def index():
    # Get pod hostname (container's hostname = pod name in K8s)
    # Fallback to environment variable or default
    hostname = socket.gethostname()

    # Optional: Override with environment variable if you want custom naming
    pod_name = os.environ.get('POD_NAME', hostname)

    return render_template('index.html', hostname=pod_name)

@app.route('/hostname')
def get_hostname():
    # Keep the /hostname endpoint for compatibility
    # (other services might expect it)
    hostname = socket.gethostname()
    pod_name = os.environ.get('POD_NAME', hostname)
    return pod_name

if __name__ == '__main__':
    # Run on 0.0.0.0 to be accessible outside the container
    # Use port 5000 (default Flask port)
    app.run(host='0.0.0.0', port=5000, debug=False)