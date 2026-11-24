import http.server
import json
import os
import re

PORT = 8000
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
WEB_DIR = os.path.join(BASE_DIR, "build", "web")
REPO_FILE = os.path.join(BASE_DIR, "lib", "data", "alert_repository.dart")

class CustomHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def do_GET(self):
        # Intercept config.json to dynamically reflect simulateError from alert_repository.dart
        if "config.json" in self.path:
            is_error = False
            try:
                if os.path.exists(REPO_FILE):
                    with open(REPO_FILE, "r", encoding="utf-8") as f:
                        code = f.read()
                        match = re.search(r"simulateError\s*=\s*(true|false)", code, re.IGNORECASE)
                        if match and match.group(1).lower() == "true":
                            is_error = True
            except Exception as e:
                pass

            payload = json.dumps({"simulateError": is_error}).encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(payload)))
            self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
            self.end_headers()
            self.wfile.write(payload)
            return

        super().do_GET()

    def end_headers(self):
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        super().end_headers()

if __name__ == "__main__":
    with http.server.ThreadingHTTPServer(("", PORT), CustomHandler) as httpd:
        print(f"Dev server listening on port {PORT}")
        httpd.serve_forever()
