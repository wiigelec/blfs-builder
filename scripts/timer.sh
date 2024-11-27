#!/bin/bash
####################################################################
# 
# timer.sh
#
####################################################################

source $SCRIPT_DIR/common-defs

SPACE="\t\t\t"


####################################################################
# TIME BUILD
####################################################################

function time_build
{
	### LOOP ###
	while : ; do

		# check pid still active
		[[ ! -e /proc/$pid ]] && break

		# write time to file
		minutes=$((SECONDS / 60))
		seconds=$((SECONDS % 60))

		echo "$minutes:$seconds" > $BLD_TIME
	done

	### SAVE BUILD TIME ###

	get_total_time

	echo "$tot_mins:$tot_secs" > $CUMU_TIME
	
}


####################################################################
# TIME PACKAGE
####################################################################

function time_package
{
	### LOOP ###
        while : ; do

                # check pid still active
                [[ ! -e /proc/$pid ]] && break

		# package build complete
		[[ -f $target ]] && exit

                # write time to file
                minutes=$((SECONDS / 60))
                seconds=$((SECONDS % 60))

		echo "$package $minutes:$seconds" > $PKG_TIME
        done	
}


####################################################################
# TIMER MANAGER
####################################################################

function timer_manager
{
	### INITIALIZE FILES ###

	if [[ ! -f $ELAP_TIME ]]; then
		echo "Package build times:" > $ELAP_TIME
		echo "" >> $ELAP_TIME
		echo "" >> $ELAP_TIME
		echo "" >> $ELAP_TIME
		echo "--------------------------------------------------------------------" >> $ELAP_TIME
		echo "Elapsed build time: " >> $ELAP_TIME
	fi
	[[ ! -f $CUMU_TIME ]] && echo "0:0" > $CUMU_TIME
		

	### LOOP ###
        while : ; do

                # check pid still active
                [[ ! -e /proc/$pid ]] && break

		### PACKAGE BUILD TIME ###
		pkgline=""
		[[ -f $PKG_TIME ]] && pkgline=$(cat $PKG_TIME)
		if [[ ! -z $pkgline ]]; then

			# GET TIMES
			package=${pkgline% *}
			pkg_time=${pkgline#* }
			pkg_mins=${pkg_time%:*}
			pkg_secs=${pkg_time#*:}

			# seconds padding
			[ $pkg_secs -lt 10 ] && pkg_secs="0$pkg_secs"

			t="$pkg_mins:$pkg_secs"
			write_line=$(printf "$package: %35s" $t)

			# NEW PACKAGE
			new="$(grep -n $package: $ELAP_TIME)"
			if [[ -z $new ]]; then

				# insert new line
				sed -i "$(( $(wc -l < $ELAP_TIME)-3 ))a $write_line" $ELAP_TIME

			# EXISTING PACKAGE
			else
				# replace old line
				sed -i "$(( $(wc -l < $ELAP_TIME)-3 ))s/^.*$/$write_line/" $ELAP_TIME
				
			fi
		fi


		### TOTAL BUILD TIME ###

		# get cumulative times
		tot_mins=""
		tot_secs=""
		get_total_time
		[[ -z $tot_mins ]] || [[ -z $tot_secs ]] && continue

		# seconds padding
		[ $tot_secs -lt 10 ] && tot_secs="0$tot_secs"

		# replace old line
		t="$tot_mins:$tot_secs"
		write_line=$(printf "Elapsed build time: %21s" $t)
		sed -i "$(( $(wc -l < $ELAP_TIME) ))s/^.*$/$write_line/" $ELAP_TIME
	done
	
}

#------------------------------------------------------------------#
function get_total_time
{
	# build time
        bldline=""
        [[ -f $BLD_TIME ]] && bldline=$(cat $BLD_TIME)
	[[ -z $bldline ]] && return
        bld_mins=${bldline%:*}
        bld_secs=${bldline#*:}

	# cumulative time
        cmlline=""
        [[ -f $CUMU_TIME ]] && cmlline=$(cat $CUMU_TIME)
	[[ -z $cmlline ]] && return
        cml_mins=${cmlline%:*}
        cml_secs=${cmlline#*:}

	# total time
        tot_mins=$(($bld_mins + $cml_mins))
        tot_secs=$(($bld_secs + $cml_secs))

	# seconds overflow
	if [ $tot_secs -ge 60 ]; then
		((tot_mins++))
		tot_secs=$(($tot_secs % 60))
	fi

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
