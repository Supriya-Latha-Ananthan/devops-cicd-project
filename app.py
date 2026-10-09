
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return """
    <!DOCTYPE html>
    <html>
    <head>
        <title>DevOps CI/CD Project</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            body {
                font-family: Arial, sans-serif;
                background: #101827;
                color: white;
                margin: 0;
                padding: 40px 20px;
            }
            main {
                max-width: 850px;
                margin: auto;
            }
            h1 { color: #60a5fa; }
            p, li { line-height: 1.8; color: #d1d5db; }
            .card {
                background: #1e293b;
                padding: 20px;
                border-radius: 12px;
                margin: 16px 0;
            }
            .status { color: #4ade80; font-weight: bold; }
            code { color: #93c5fd; }
        </style>
    </head>
    <body>
        <main>
            <h1>DevOps CI/CD Pipeline</h1>
            <p class="status">● Application is Live!</p>

            <div class="card">
                <h2>About This Project</h2>
                <p>This project demonstrates how DevOps practices
                automate application building and deployment.</p>
            </div>

            <div class="card">
                <h2>Technologies Used</h2>
                <ul>
                    <li>GitHub - Source code management</li>
                    <li>Jenkins - CI/CD pipeline automation</li>
                    <li>Docker - Application containerization</li>
                    <li>GHCR - Container image registry</li>
                    <li>AWS EC2 - Application hosting</li>
                    <li>Terraform - Infrastructure as Code</li>
                </ul>
            </div>

            <div class="card">
                <h2>How It Works</h2>
                <p>1. Push code to GitHub.</p>
                <p>2. Jenkins builds the Docker image.</p>
                <p>3. The image is pushed to GHCR.</p>
                <p>4. AWS EC2 pulls the image and runs the container.</p>
            </div>

            <div class="card">
                <h2>Project Goal</h2>
                <p>To demonstrate a repeatable deployment workflow
                that reduces manual effort and makes application
                updates easier.</p>
            </div>
        </main>
    </body>
    </html>
    """

@app.route("/health")
def health():
    return "Healthy"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
