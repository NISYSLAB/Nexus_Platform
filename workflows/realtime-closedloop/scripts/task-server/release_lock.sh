echo "Release lock /tmp/synergy/bmi_transfer_lock ..."
rm -rf /tmp/synergy/bmi_transfer_lock || "Failed to release lock: /tmp/synergy/bmi_transfer_lock ..."
ls /tmp/synergy/*