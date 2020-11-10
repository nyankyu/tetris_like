#!/bin/zsh

####################
#  global
####################
score_value=0


####################
#  block data
####################
# current block
b0_color='\e[41m\c'
b0_00=0 b0_10=0 b0_20=0 b0_30=0
b0_01=0 b0_11=0 b0_21=0 b0_31=0
b0_02=0 b0_12=0 b0_22=0 b0_32=0
b0_03=0 b0_13=0 b0_23=0 b0_33=0
b0_x=0 b0_y=0

# temp
t0_00=0 t0_10=0 t0_20=0 t0_30=0
t0_01=0 t0_11=0 t0_21=0 t0_31=0
t0_02=0 t0_12=0 t0_22=0 t0_32=0
t0_03=0 t0_13=0 t0_23=0 t0_33=0

b1_color='\e[41m\c'
b1_00=0 b1_10=0 b1_20=0 b1_30=0
b1_01=0 b1_11=0 b1_21=1 b1_31=0
b1_02=1 b1_12=1 b1_22=1 b1_32=0
b1_03=0 b1_13=0 b1_23=0 b1_33=0

b2_color='\e[42m\c'
b2_00=0 b2_10=0 b2_20=0 b2_30=0
b2_01=0 b2_11=1 b2_21=0 b2_31=0
b2_02=0 b2_12=1 b2_22=1 b2_32=1
b2_03=0 b2_13=0 b2_23=0 b2_33=0

b3_color='\e[43m\c'
b3_00=0 b3_10=0 b3_20=0 b3_30=0
b3_01=0 b3_11=1 b3_21=0 b3_31=0
b3_02=1 b3_12=1 b3_22=1 b3_32=0
b3_03=0 b3_13=0 b3_23=0 b3_33=0


####################
#  functions
####################
cls() {
	echo '\e[H\e[2J\c'
}

cursor() {
	echo '\e['$2';'$1'f\c'
}

new_screen() {
	echo '\e7\e[?47h\c'
}

exit_screen() {
	echo '\e[?47l\e8\c'
}

init_tty() {
	new_screen
	cls
}

quit_tty() {
	cls
	exit_screen
}

init_field_data() {
	for ((x = 1; x <= 23; x += 2)) {
		for ((y = 1; y <= 22; y++)) {
			if ((x == 1 || x == 23 || y == 1 || y == 22)) {
				eval "field_${x}_${y}"=9
			} else {
				eval "field_${x}_${y}"=0
			}
		}
	}
}

init_field() {
	cursor 1 1
	echo '\e[47m\c'
	echo '                        \c'
	for ((i = 2; i <= 21; i++)) {
		cursor 1 $i
		echo '  \c'
		cursor 23 $i
		echo '  \c'
	}
	cursor 1 $i
	echo '                        \c'

	cursor 30 2
	echo '\e[37;40m\c'
	echo 'NEXT\c'

	echo '\e[47m\c'
	for ((i = 3; i <= 8; i++)) {
		cursor 26 $i
		echo '            \c'
	}

	cursor 30 10
	echo '\e[37;40m\c'
	echo 'SCORE\c'
	cursor 26 11
	echo '\e[47m\c'
	echo '            \c'

	init_field_data

	add_score 0
	cursor 1 1
}

add_score() {
	((score_value += $1))
	cursor 28 11
	echo '\e[30;47m\c'
	printf '%8d' $score_value
}

# $1 output random number [min, max]
# $2 min
# $3 max
rand() {
	rand_val=$RANDOM
	rand_val=`expr $rand_val % 256 \* \( "$3" - "$2" + 1 \) / 256 + "$2"`
	eval $1=$rand_val
}

# $1 block type [1, 7]
set_currrent_blocks() {
	eval b0_color=\$b$1_color
	for ((x = 0; x < 4; x++)) {
		for ((y = 0; y < 4; y++)) {
			eval b0_$x$y=\$b$1_$x$y
		}
	}

	b0_x=9
	b0_y=2
	put_blocks
}

put_blocks() {
	echo $b0_color
	for ((x = 0; x < 4; x++)) {
		for ((y = 0; y < 4; y++)) {
			cursor $((b0_x + x * 2)) $((b0_y + y))
			eval b=\$b0_$x$y
			if (($b == 1)) echo '  \c'
		}
	}
}

rm_blocks() {
	echo '\e[40m\c'
	for ((x = 0; x < 4; x++)) {
		for ((y = 0; y < 4; y++)) {
			cursor $((b0_x + x * 2)) $((b0_y + y))
			eval b=\$b0_$x$y
			if (($b == 1)) echo '  \c'
		}
	}
}

evacuate_blocks() {
	for ((x = 0; x < 4; x++)) {
		for ((y = 0; y < 4; y++)) {
			eval t0_$x$y=\$b0_$x$y
		}
	}
}

# $1 1:left, 0:right
roll_blocks() {
	evacuate_blocks
	for ((x = 0; x < 4; x++)) {
		for ((y = 0; y < 4; y++)) {
			if (($1 == 1)) {
				bx=$((3 - y))
				by=$x
			} else {
				bx=$y
				by=$((3 - x))
			}
			eval b0_$x$y=\$t0_$bx$by
		}
	}
}

# $1 return value, 1:collision, 0:other
collision() {
	for ((x = 0; x < 4; x++)) {
		for ((y = 0; y < 4; y++)) {
			bx=$((b0_x + x * 2))
			by=$((b0_y + y))
			eval field=\$field_${bx}_${by}
			eval b=\$b0_$x$y
			if ((field != 0 && b != 0)) {
				eval $1=1
				return
			}
		}
	}
	eval $1=0
}


####################
#  initialize
####################
init_tty
init_field

set_currrent_blocks 3


####################
#  main loop
####################
while :
do
	key='timeout'
	read -s -k 1 -t 1 key

	case "$key" in
		timeout)
			# test rand()
			#rand var 1 100
			#add_score $var
			;;
		q)
			break
			;;
		h|D|4)
			rm_blocks
			((b0_x-=2))
			collision ret
			if ((ret == 1)) {
				((b0_x+=2))
			}
			put_blocks
			;;
		j|B|2)
			rm_blocks
			((b0_y+=1))
			collision ret
			if ((ret == 1)) {
				((b0_y-=1))
			}
			put_blocks
			;;
		k|A|8)
			rm_blocks
			((b0_y-=1))
			collision ret
			if ((ret == 1)) {
				((b0_y+=1))
			}
			put_blocks
			;;
		l|C|6)
			rm_blocks
			((b0_x+=2))
			collision ret
			if ((ret == 1)) {
				((b0_x-=2))
			}
			put_blocks
			;;
		d)
			rm_blocks
			roll_blocks 1
			collision ret
			if ((ret == 1)) {
				roll_blocks 0
			}
			put_blocks
			;;
		f)
			rm_blocks
			roll_blocks 0
			collision ret
			if ((ret == 1)) {
				roll_blocks 1
			}
			put_blocks
			;;
	esac
done

quit_tty
exit

