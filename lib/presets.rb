DEFAULT_MAX_ATTEMPT = 3
DEFAULT_LOCK_TIME = 5

## clears ip from /var/log/ip_logs
DEFAULT_RESET_FAILED_TIME = 10

CONFIG_FILE = "/etc/ssh-mon/ssh_mon_config"
AUTH_LOG = "/var/log/auth.log"
IP_LOGS_DIR = "/var/log/blocked_ip_logs"

BLOCK_IP_SCRIPT = "/etc/ssh-mon/pam/block_ip.rb"
IPTABLES_LOG = "/var/log/iptables_log.txt"


# For Dev purpose
# CONFIG_FILE = "ssh_mon_config"
# AUTH_LOG = "auth.log"
# IP_LOGS_DIR = "ip_logs"

# BLOCK_IP_SCRIPT = "block_ip.rb"
# IPTABLES_LOG = "iptables_log.txt"
