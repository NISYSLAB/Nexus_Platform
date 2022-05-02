#!/bin/bash

source ./common_settings.sh

ps -eaf | grep java | grep jar | grep cromwell
