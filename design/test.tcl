####################################################################################################
# Test procedures
####################################################################################################
# test of PWM module for fan - configure core and set different speed of fan
proc test_fan {name base_addr} {
	fan_init $base_addr

	puts -nonewline "Test of $name, speed set to 0%"
	flush stdout
	exec sleep 2

	# set duty cycle to 50%
	fan_duty $base_addr 50
	puts -nonewline "..50%"
	flush stdout
	exec sleep 2

	# set duty cycle to 25%
	fan_duty $base_addr 25
	puts -nonewline "..25%"
	flush stdout
	exec sleep 2

	# set duty cycle to 0%
	fan_duty $base_addr 0
	puts -nonewline "..0%"
	flush stdout
	exec sleep 2

	# set duty cycle to 100%
	fan_duty $base_addr 100
	puts "..100%"
}

# test of SPI module - configure core and send one byte
proc test_spi {name base_addr data} {
	puts "Test of $name"
	# reset of SPI core
	mwr [expr $base_addr + 0x40] 0x0A
	# enable SPI core
	mwr [expr $base_addr + 0x60] 0x086
	# select CS (set to 0)
	mwr [expr $base_addr + 0x70] 0x0
	# sent data (1 byte)
	mwr [expr $base_addr + 0x68] $data
	# deselect CS (set to 1)
	mwr [expr $base_addr + 0x70] 0x1
}


####################################################################################################
# Connection to FPGA, loading bitstream and initialization
####################################################################################################
source init.tcl

####################################################################################################
# Test of GPIO LEDs
####################################################################################################
# LEDs are on GPIO_1, pin 2 - PL_LED1 (green on panel)
mwr 0x41210000 4
puts "Set PL_LED1 on"
exec sleep 5
# LEDs are on GPIO_1, pin 3 - PL_LED2 (red on panel)
mwr 0x41210000 8
puts "Set PL_LED2 on"
exec sleep 5
# LEDs are on GPIO_1, pin 4 - PL_LED3 (red on board)
mwr 0x41210000 16
puts "Set PL_LED3 on"
exec sleep 5
# turn off all LEDs
mwr 0x41210000 0
puts "Set all LEDs off"

####################################################################################################
# Test of VID generator
####################################################################################################
puts "Test of VID generator"
# send value of 0x23 and enable generation (mask 0x100)
mwr 0x43C50000 0x123
# wait some time or check if all data are sent
exec sleep 5
# disable generation
mwr 0x43C50000 0x0

####################################################################################################
# Test of FANs
####################################################################################################
source fan.tcl

# Timer 0 - FAN1 and FAN2
test_fan "FAN 1&2" $FAN_A
# Timer 1 - FAN3 and FAN4
test_fan "FAN 3&4" $FAN_B
# Timer 2 - FAN5 and FAN6
test_fan "FAN 5&6" $FAN_C

####################################################################################################
# Test of SPI modules
####################################################################################################
# SPI module 0
test_spi "SPI 0" 0x41E00000 0x12
# SPI module 1
test_spi "SPI 1" 0x41E10000 0x34
# SPI module 2
test_spi "SPI 2" 0x41E20000 0x56
# SPI module 3
test_spi "SPI 3" 0x41E30000 0x78
