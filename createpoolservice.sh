cat >> /lib/systemd/system/pool.service <<EOF
[Unit]
Description=CoiniumServ pool service
After=network.target local-fs.target


[Service]
Type=simple
User=root
WorkingDirectory=/root/coiniumservyescrypt/build/bin/Release/
ExecStart=/usr/bin/mono /root/coiniumservyescrypt/build/bin/Release/CoiniumServ.exe
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl enable pool.service

# service pool start
# service pool status
# service pool restart
