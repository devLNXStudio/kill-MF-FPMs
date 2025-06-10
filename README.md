This Bash script monitors PHP-FPM (FastCGI Process Manager) pools on your server and kills individual FPM processes that exceed a defined CPU usage threshold. It helps prevent rogue or stuck PHP scripts from overloading the server.

🚀 Features
Monitors only selected PHP-FPM pools (whitelisted).

Kills FPM processes using excessive CPU (over a defined limit).

Limits the number of kills per pool per run to avoid over-aggressive actions.

Logs all activity to /var/log/fpm-killer.log.

Sends alerts to a Discord channel via webhook.

🛠️ How to Use
Configure the script:
Open kill_mf_fpm.sh and modify the following variables:

bash
Kopiuj
Edytuj
CPU_LIMIT=125                # Max allowed CPU % per process (e.g. 125%)
MAX_KILLS=2                  # Maximum processes to kill per pool
WHITELIST=("devlnx_pl")      # Add your pool names here
DISCORD_WEBHOOK="https://discordapp.com/api/webhooks/..."  # Your Discord webhook URL
Make the script executable:

bash
Kopiuj
Edytuj
chmod +x kill_mf_fpm.sh
Run the script manually:

bash
Kopiuj
Edytuj
./kill_mf_fpm.sh
(Optional) Automate with cron:

Example to run every 5 minutes:

bash
Kopiuj
Edytuj
*/5 * * * * /path/to/kill_mf_fpm.sh
📲 How to Connect Discord Webhook
Go to your Discord server and create a new Webhook:

Server Settings → Integrations → Webhooks → New Webhook.

Choose the channel where alerts should be posted.

Copy the generated webhook URL.

Replace the placeholder in the script:

bash
Kopiuj
Edytuj
DISCORD_WEBHOOK="https://discord.com/api/webhooks/your_webhook_here"
The script will send a notification like:

yaml
Kopiuj
Edytuj
💀 Killed FPM PID=12345 (POOL: devlnx_pl, CPU: 138.2%) @ your-hostname 🖥️
📝 Notes
The script uses SIGTERM (kill -15) first, and falls back to SIGKILL (kill -9) if the process doesn’t stop.

The script depends on standard Unix utilities: ps, awk, grep, curl, bc, and kill.

Be sure to test the script in a controlled environment before using it in production.

