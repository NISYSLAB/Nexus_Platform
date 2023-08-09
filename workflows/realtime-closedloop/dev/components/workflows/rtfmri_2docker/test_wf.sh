#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# tests the two component workflow with 10 existing files
#### Main starts
./parse_and_submit.sh /labs/mahmoudilab/synergy_remote_data1/DEV-emory_siemens_scanner_in_dir_processed/EBDM_RT_040520231_run2.csv_20230405_13_57_20.zip 2>&1 | tee -a test_wf.log

./parse_and_submit.sh /labs/mahmoudilab/synergy_remote_data1/DEV-emory_siemens_scanner_in_dir_processed/EBDM_RT_040520231_run2.csv_20230405_13_58_38.zip 2>&1 | tee -a test_wf.log

./parse_and_submit.sh /labs/mahmoudilab/synergy_remote_data1/DEV-emory_siemens_scanner_in_dir_processed/EBDM_RT_040520231_run2.csv_20230405_13_59_44.zip 2>&1 | tee -a test_wf.log

./parse_and_submit.sh /labs/mahmoudilab/synergy_remote_data1/DEV-emory_siemens_scanner_in_dir_processed/EBDM_RT_040520231_run2.csv_20230405_14_01_06.zip 2>&1 | tee -a test_wf.log

./parse_and_submit.sh /labs/mahmoudilab/synergy_remote_data1/DEV-emory_siemens_scanner_in_dir_processed/EBDM_RT_040520231_run2.csv_20230405_14_02_27.zip 2>&1 | tee -a test_wf.log

./parse_and_submit.sh /labs/mahmoudilab/synergy_remote_data1/DEV-emory_siemens_scanner_in_dir_processed/EBDM_RT_040520231_run2.csv_20230405_14_03_33.zip 2>&1 | tee -a test_wf.log

./parse_and_submit.sh /labs/mahmoudilab/synergy_remote_data1/DEV-emory_siemens_scanner_in_dir_processed/EBDM_RT_040520231_run2.csv_20230405_14_04_49.zip 2>&1 | tee -a test_wf.log
 
./parse_and_submit.sh /labs/mahmoudilab/synergy_remote_data1/DEV-emory_siemens_scanner_in_dir_processed/EBDM_RT_040520231_run2.csv_20230405_14_06_05.zip 2>&1 | tee -a test_wf.log

./parse_and_submit.sh /labs/mahmoudilab/synergy_remote_data1/DEV-emory_siemens_scanner_in_dir_processed/EBDM_RT_040520231_run2.csv_20230405_14_07_24.zip 2>&1 | tee -a test_wf.log
 
./parse_and_submit.sh /labs/mahmoudilab/synergy_remote_data1/DEV-emory_siemens_scanner_in_dir_processed/EBDM_RT_040520231_run2.csv_20230405_14_08_45.zip 2>&1 | tee -a test_wf.log
 
./parse_and_submit.sh /labs/mahmoudilab/synergy_remote_data1/DEV-emory_siemens_scanner_in_dir_processed/EBDM_RT_040520231_run2.csv_20230405_14_10_04.zip 2>&1 | tee -a test_wf.log
 
./parse_and_submit.sh /labs/mahmoudilab/synergy_remote_data1/DEV-emory_siemens_scanner_in_dir_processed/EBDM_RT_040520231_run2.csv_20230405_14_11_24.zip 2>&1 | tee -a test_wf.log


