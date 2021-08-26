# ADV7513-I2C_controller
#VHDL Controller for ADV7513, Cyclone V VGA throught HDMI is the main goal

This is a personal project in which my goals are to have an Architecture that have a full comunication hardware with the ADV7513 installed in my Cyclone V FPGA.
The comunication is done by transmission half-duplex through I2C in between FPGA and the Chip to command the AD7513. Bellow it is what is done so far :

-VHDL Implementions:
 *Write from FPGA to ADV7513 Through I2C
 *VGA 640x480@60 25.175 MHZ
-ModelSim test done for both of them

-Next steps :
 *Creation of the state machine to power up the ADV7513 by writing on its registers
 *Get VGA to print in the screen
 *Set VGA to read its pixels from a memory implemented on the board
