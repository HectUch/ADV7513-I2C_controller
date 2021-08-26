onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /hdmi_i2c/reset
add wave -noupdate /hdmi_i2c/SDA
add wave -noupdate /hdmi_i2c/SDA_o
add wave -noupdate /hdmi_i2c/SCL
add wave -noupdate /hdmi_i2c/addr_byte
add wave -noupdate /hdmi_i2c/base_addr_word
add wave -noupdate /hdmi_i2c/data_byte_word
add wave -noupdate /hdmi_i2c/busy
add wave -noupdate /hdmi_i2c/clk
add wave -noupdate /hdmi_i2c/clk_400khz
add wave -noupdate /hdmi_i2c/count_400khz
add wave -noupdate /hdmi_i2c/d_byte
add wave -noupdate /hdmi_i2c/on_going_transf
add wave -noupdate /hdmi_i2c/pstate
add wave -noupdate /hdmi_i2c/ready
add wave -noupdate /hdmi_i2c/sent_bit
add wave -noupdate /hdmi_i2c/slave_addr
add wave -noupdate /hdmi_i2c/slave_addr_word
add wave -noupdate /hdmi_i2c/start_count
add wave -noupdate /hdmi_i2c/start_transf
add wave -noupdate /hdmi_i2c/state
add wave -noupdate /hdmi_i2c/wr_bit
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {150365412 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {131072 ns}
