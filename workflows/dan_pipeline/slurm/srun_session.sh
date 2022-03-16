#!/bin/bash

#### Do not modify below!!!
SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

##users=bmi-users
users=sharmalab
echo "srun --account ${users} -p beauty-only --job-name "InteractiveJob" --cpus-per-task 8  --time 24:00:00 --pty bash"
srun --account ${users} -p beauty-only --job-name "InteractiveJob" --cpus-per-task 8  --time 24:00:00 --pty bash



