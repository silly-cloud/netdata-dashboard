# netdata-monitoring

Basic system monitoring setup using [Netdata](https://www.netdata.cloud/). Built as part of the [roadmap.sh DevOps path](https://roadmap.sh/projects/simple-monitoring-dashboard).

## What it does

- Installs Netdata on Ubuntu/Debian and starts the monitoring dashboard
- Configures a CPU alert (warn > 80%, critical > 90%)
- Generates synthetic CPU, memory, and disk I/O load to verify the dashboard
- Cleans up and fully removes Netdata when done

## Scripts

| Script | Purpose |
|---|---|
| `setup.sh` | Install Netdata, configure alert, start dashboard |
| `test_dashboard.sh` | Generate system load to verify metrics are visible |
| `cleanup.sh` | Stop and fully remove Netdata |

## Usage

```bash
# 1. Install and start Netdata
sudo bash setup.sh

# 2. Open dashboard in browser, then run load test
sudo bash test_dashboard.sh

# 3. Remove Netdata when done
sudo bash cleanup.sh
```

## Dashboard

After running `setup.sh`, access the dashboard at:

```
http://<your-ip>:19999
```

Find your IP with `hostname -I | awk '{print $1}'`.

## Requirements

- Ubuntu or Debian
- Root / sudo access
- `wget` (pre-installed on most systems)
