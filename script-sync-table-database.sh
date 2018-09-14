#!/bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOG_PATH="$CURRENT_DIR/log_backup"

rm -rf $LOG_PATH
touch $LOG_PATH

log_message() {
	now=$(date +'%Y-%m-%d %H:%M:%S')
    echo -e "$now: $1" >> $LOG_PATH
	echo -e "$now: $1"
}

log_message "\n\n\n\n\n\n\n"
for i in {1..5}
do
    log_message "===============*****************===================="
done

DB_HOST=192.168.100.10
DB_USER=root
DB_PASS=password
DB_NAME=database

cd "/home/nntai/"

log_message "/* ---------------------------------- */"
log_message "/* ---------------------------------- */"
log_message "Dump small table..."
LIST_TABLE=(table_tes1 table_test2 table_test3 table_test4 table_test5 table_test6)
for i in "${!LIST_TABLE[@]}"; do
	log_message "==============================================================================="
	CMD="/usr/bin/mysqldump -h'$DB_HOST' -u'$DB_USER' -p'$DB_PASS' $DB_NAME ${LIST_TABLE[$i]} > /home/nntai/${LIST_TABLE[$i]}.sql"
	log_message "Backup full table ${LIST_TABLE[$i]}..."
	eval $CMD
	log_message "Sleep 1s before importing..."
	sleep 1
	CMD="/usr/bin/mysql -u'$DB_USER' -p'$DB_PASS' $DB_NAME < /home/nntai/${LIST_TABLE[$i]}.sql"
	eval $CMD
	log_message "Sleep 2s before dumping next table!"
	sleep 2
	rm -rf '/home/nntai/${LIST_TABLE[$i]}.sql'
done

log_message "/* ---------------------------------- */"
log_message "/* ---------------------------------- */"
log_message "Dump large table..."
LIST_TABLE=(tables_test7 table_test8 tables_test9 table_test10 table_test11 table_test12)
#LIST_TABLE=(cdr)
for i in "${!LIST_TABLE[@]}"; do
	log_message "==============================================================================="
	COLUMN_NAME_ID="id"
	if [ "${LIST_TABLE[$i]}" = "tables_test7" ] || [ "${LIST_TABLE[$i]}" = "tables_test9" ]
	then
		COLUMN_NAME_ID="id"
	fi
	MAX_ID=$(/usr/bin/mysql -u$DB_USER -p$DB_PASS $DB_NAME -s -N <<< "SELECT MAX($COLUMN_NAME_ID) FROM ${LIST_TABLE[$i]}")
	log_message "Max $COLUMN_NAME_ID of ${LIST_TABLE[$i]} ===> $MAX_ID"
	CMD="/usr/bin/mysqldump -h'$DB_HOST' -u'$DB_USER' -p'$DB_PASS' $DB_NAME ${LIST_TABLE[$i]} --no-create-info --skip-triggers --where='$COLUMN_NAME_ID > $MAX_ID' > /home/nntai/${LIST_TABLE[$i]}.sql"	
	log_message "Backup missing data of ${LIST_TABLE[$i]}..."
	eval $CMD
	log_message "Sleep 1s before importing..."
	sleep 1
	CMD="/usr/bin/mysql -u'$DB_USER' -p'$DB_PASS' $DB_NAME < /home/nntai/${LIST_TABLE[$i]}.sql"
	eval $CMD
	log_message "Sleep 2s before dumping next table!"
	sleep 2
	rm -rf '/home/nntai/${LIST_TABLE[$i]}.sql'
done

