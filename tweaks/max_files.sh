### Set up open file descriptor limits
echo "fs.file-max = 1000000" >> /etc/sysctl.conf
echo "ubuntu	soft	nofile	1000000" >> /etc/security/limits.conf
echo "ubuntu	hard	nofile	1000000" >> /etc/security/limits.conf

