#!/bin/bash
sed -i 's/CURRENT_ATTEMPTS=.*/CURRENT_ATTEMPTS=0/g' ip_logs/$PAM_RHOST
exit(0)