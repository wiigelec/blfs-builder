#!/bin/bash
####################################################################
# 
# timer.sh
#
####################################################################

source $SCRIPT_DIR/common-defs


####################################################################
# TIME BUILD
####################################################################

function time_build
{
	### LOOP ###
	while true; do

		# check pid still active
		[[ ! -e /proc/$pid ]] && exit

		# write time to file
		minutes=$((SECONDS / 60))
		seconds=$((SECONDS % 60))

		echo "Total build time:	$minutes min. $seconds sec" > $BLDTIMER_FILE 
	done

	rm $BLDTIMER_FILE

}


####################################################################
# TIME PACKAGE
####################################################################

function time_package
{
	### LOOP ###
        while true; do

                # check pid still active
                [[ ! -e /proc/$pid ]] && exit

		# package build complete
		[[ -f $target ]] && exit

                # write time to file
                minutes=$((SECONDS / 60))
                seconds=$((SECONDS % 60))

		echo "$package:			$minutes min. $seconds sec" > $PKGTIMER_FILE 
        done	

	rm $PKGTIMER_FILE

}


####################################################################
# TIMER MANAGER
####################################################################

function timer_manager
{
	# init file
	echo "" > $ELAPTIME_FILE
	echo "" >> $ELAPTIME_FILE
	echo "--------------------------------------------------------" >> $ELAPTIME_FILE
	echo "Total build time: " >> $ELAPTIME_FILE
		
	### LOOP ###
        while true; do

                # check pid still active
                [[ ! -e /proc/$pid ]] && exit

		### PACKAGE BUILD TIME ###

		pkgline=""
		[[ -f $PKGTIMER_FILE ]] && pkgline=$(cat $PKGTIMER_FILE)

		if [[ ! -z $pkgline ]]; then

			# NEW PACKAGE
			new="$(grep -n ${pkgline%%:*} $ELAPTIME_FILE)"
			if [[ -z $new ]]; then

				# insert new line
				sed -i "$(( $(wc -l < $ELAPTIME_FILE)-3 ))a $pkgline" $ELAPTIME_FILE

			# EXISTING PACKAGE
			else
				# replace old line
				sed -i "$(( $(wc -l < $ELAPTIME_FILE)-3 ))s/^.*$/$pkgline/" $ELAPTIME_FILE
				
			fi
		fi


		### TOTAL BUILD TIME ###

		bldline=""
		[[ -f $BLDTIMER_FILE ]] && bldline=$(cat $BLDTIMER_FILE)
		if [[ ! -z $bldline ]]; then
				
			# replace old line
			sed -i "$(( $(wc -l < $ELAPTIME_FILE) ))s/^.*$/$bldline/" $ELAPTIME_FILE
		fi

	done
	
}


####################################################################
# MAIN
####################################################################

### PARSE PARAMS ###

pid=$2
target=$3
package=${target#*z-}

case $1 in
        BLD) time_build ;;
        PKG) time_package ;;
        MGR) timer_manager ;;

esac
