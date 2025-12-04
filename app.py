from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def home():
    return f'''
    <h1>DevOps CI/CD Pipeline Project</h1>
    <p>Étudiant: Wassim Frigui</p>
    <p>Build ID: {os.getenv("BUILD_ID", "local")}</p>
    <p>Date: {os.getenv("BUILD_DATE", "N/A")}</p>
    <hr>
    <p>Cette application est déployée automatiquement via Jenkins</p>
    '''

@app.route('/health')
def health():
    return {"status": "healthy", "service": "wassim-frigui-app"}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
