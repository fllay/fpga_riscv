## kr260_led_counter.xdc
##
## Verified pin assignments for the KR260 Robotics Starter Kit carrier
## (K26 SOM, xck26-sfvc784-2LV-c). Unlike the KV260, the KR260 wires a
## 25 MHz oscillator and two user LEDs directly into PL pins -- confirmed
## against a working build (see README references).

# 25 MHz onboard oscillator -> PL clock input
create_clock -period 40.000 -name clk -waveform {0.000 20.000} [get_ports clk]
set_property PACKAGE_PIN C3 [get_ports clk]
set_property IOSTANDARD LVCMOS18 [get_ports clk]

# User LEDs (DS7/DS8)
set_property PACKAGE_PIN F8 [get_ports {led_out[0]}]
set_property PACKAGE_PIN E8 [get_ports {led_out[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led_out[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led_out[1]}]

## NOTE on the fan: the KR260's fan-enable line is normally driven from the
## PS (via EMIO through the PL) when running the stock Ubuntu image. This
## design doesn't include a PS block, so if you load this bitstream over
## JTAG while the board's default Linux image is already running, the fan
## may stop responding to the OS's speed control while this design is
## loaded. Not dangerous for a short debug session; just don't leave it
## loaded indefinitely under load, and reload the default application
## (or power-cycle) afterward to restore normal fan control.


create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk_IBUF_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 32 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {u_top/pc[0]} {u_top/pc[1]} {u_top/pc[2]} {u_top/pc[3]} {u_top/pc[4]} {u_top/pc[5]} {u_top/pc[6]} {u_top/pc[7]} {u_top/pc[8]} {u_top/pc[9]} {u_top/pc[10]} {u_top/pc[11]} {u_top/pc[12]} {u_top/pc[13]} {u_top/pc[14]} {u_top/pc[15]} {u_top/pc[16]} {u_top/pc[17]} {u_top/pc[18]} {u_top/pc[19]} {u_top/pc[20]} {u_top/pc[21]} {u_top/pc[22]} {u_top/pc[23]} {u_top/pc[24]} {u_top/pc[25]} {u_top/pc[26]} {u_top/pc[27]} {u_top/pc[28]} {u_top/pc[29]} {u_top/pc[30]} {u_top/pc[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 7 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {u_top/opcode[0]} {u_top/opcode[1]} {u_top/opcode[2]} {u_top/opcode[3]} {u_top/opcode[4]} {u_top/opcode[5]} {u_top/opcode[6]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 32 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {u_top/alu_res[0]} {u_top/alu_res[1]} {u_top/alu_res[2]} {u_top/alu_res[3]} {u_top/alu_res[4]} {u_top/alu_res[5]} {u_top/alu_res[6]} {u_top/alu_res[7]} {u_top/alu_res[8]} {u_top/alu_res[9]} {u_top/alu_res[10]} {u_top/alu_res[11]} {u_top/alu_res[12]} {u_top/alu_res[13]} {u_top/alu_res[14]} {u_top/alu_res[15]} {u_top/alu_res[16]} {u_top/alu_res[17]} {u_top/alu_res[18]} {u_top/alu_res[19]} {u_top/alu_res[20]} {u_top/alu_res[21]} {u_top/alu_res[22]} {u_top/alu_res[23]} {u_top/alu_res[24]} {u_top/alu_res[25]} {u_top/alu_res[26]} {u_top/alu_res[27]} {u_top/alu_res[28]} {u_top/alu_res[29]} {u_top/alu_res[30]} {u_top/alu_res[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 32 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {u_top/dbg_x1[0]} {u_top/dbg_x1[1]} {u_top/dbg_x1[2]} {u_top/dbg_x1[3]} {u_top/dbg_x1[4]} {u_top/dbg_x1[5]} {u_top/dbg_x1[6]} {u_top/dbg_x1[7]} {u_top/dbg_x1[8]} {u_top/dbg_x1[9]} {u_top/dbg_x1[10]} {u_top/dbg_x1[11]} {u_top/dbg_x1[12]} {u_top/dbg_x1[13]} {u_top/dbg_x1[14]} {u_top/dbg_x1[15]} {u_top/dbg_x1[16]} {u_top/dbg_x1[17]} {u_top/dbg_x1[18]} {u_top/dbg_x1[19]} {u_top/dbg_x1[20]} {u_top/dbg_x1[21]} {u_top/dbg_x1[22]} {u_top/dbg_x1[23]} {u_top/dbg_x1[24]} {u_top/dbg_x1[25]} {u_top/dbg_x1[26]} {u_top/dbg_x1[27]} {u_top/dbg_x1[28]} {u_top/dbg_x1[29]} {u_top/dbg_x1[30]} {u_top/dbg_x1[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 32 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {u_top/dbg_x2[0]} {u_top/dbg_x2[1]} {u_top/dbg_x2[2]} {u_top/dbg_x2[3]} {u_top/dbg_x2[4]} {u_top/dbg_x2[5]} {u_top/dbg_x2[6]} {u_top/dbg_x2[7]} {u_top/dbg_x2[8]} {u_top/dbg_x2[9]} {u_top/dbg_x2[10]} {u_top/dbg_x2[11]} {u_top/dbg_x2[12]} {u_top/dbg_x2[13]} {u_top/dbg_x2[14]} {u_top/dbg_x2[15]} {u_top/dbg_x2[16]} {u_top/dbg_x2[17]} {u_top/dbg_x2[18]} {u_top/dbg_x2[19]} {u_top/dbg_x2[20]} {u_top/dbg_x2[21]} {u_top/dbg_x2[22]} {u_top/dbg_x2[23]} {u_top/dbg_x2[24]} {u_top/dbg_x2[25]} {u_top/dbg_x2[26]} {u_top/dbg_x2[27]} {u_top/dbg_x2[28]} {u_top/dbg_x2[29]} {u_top/dbg_x2[30]} {u_top/dbg_x2[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 32 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {u_top/instruction[0]} {u_top/instruction[1]} {u_top/instruction[2]} {u_top/instruction[3]} {u_top/instruction[4]} {u_top/instruction[5]} {u_top/instruction[6]} {u_top/instruction[7]} {u_top/instruction[8]} {u_top/instruction[9]} {u_top/instruction[10]} {u_top/instruction[11]} {u_top/instruction[12]} {u_top/instruction[13]} {u_top/instruction[14]} {u_top/instruction[15]} {u_top/instruction[16]} {u_top/instruction[17]} {u_top/instruction[18]} {u_top/instruction[19]} {u_top/instruction[20]} {u_top/instruction[21]} {u_top/instruction[22]} {u_top/instruction[23]} {u_top/instruction[24]} {u_top/instruction[25]} {u_top/instruction[26]} {u_top/instruction[27]} {u_top/instruction[28]} {u_top/instruction[29]} {u_top/instruction[30]} {u_top/instruction[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 32 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {u_top/wr_data[0]} {u_top/wr_data[1]} {u_top/wr_data[2]} {u_top/wr_data[3]} {u_top/wr_data[4]} {u_top/wr_data[5]} {u_top/wr_data[6]} {u_top/wr_data[7]} {u_top/wr_data[8]} {u_top/wr_data[9]} {u_top/wr_data[10]} {u_top/wr_data[11]} {u_top/wr_data[12]} {u_top/wr_data[13]} {u_top/wr_data[14]} {u_top/wr_data[15]} {u_top/wr_data[16]} {u_top/wr_data[17]} {u_top/wr_data[18]} {u_top/wr_data[19]} {u_top/wr_data[20]} {u_top/wr_data[21]} {u_top/wr_data[22]} {u_top/wr_data[23]} {u_top/wr_data[24]} {u_top/wr_data[25]} {u_top/wr_data[26]} {u_top/wr_data[27]} {u_top/wr_data[28]} {u_top/wr_data[29]} {u_top/wr_data[30]} {u_top/wr_data[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 5 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {u_top/rd_addr[0]} {u_top/rd_addr[1]} {u_top/rd_addr[2]} {u_top/rd_addr[3]} {u_top/rd_addr[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 32 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {u_top/dbg_x3[0]} {u_top/dbg_x3[1]} {u_top/dbg_x3[2]} {u_top/dbg_x3[3]} {u_top/dbg_x3[4]} {u_top/dbg_x3[5]} {u_top/dbg_x3[6]} {u_top/dbg_x3[7]} {u_top/dbg_x3[8]} {u_top/dbg_x3[9]} {u_top/dbg_x3[10]} {u_top/dbg_x3[11]} {u_top/dbg_x3[12]} {u_top/dbg_x3[13]} {u_top/dbg_x3[14]} {u_top/dbg_x3[15]} {u_top/dbg_x3[16]} {u_top/dbg_x3[17]} {u_top/dbg_x3[18]} {u_top/dbg_x3[19]} {u_top/dbg_x3[20]} {u_top/dbg_x3[21]} {u_top/dbg_x3[22]} {u_top/dbg_x3[23]} {u_top/dbg_x3[24]} {u_top/dbg_x3[25]} {u_top/dbg_x3[26]} {u_top/dbg_x3[27]} {u_top/dbg_x3[28]} {u_top/dbg_x3[29]} {u_top/dbg_x3[30]} {u_top/dbg_x3[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list u_top/branch_taken]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list u_top/rf_wr_en]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_IBUF_BUFG]
