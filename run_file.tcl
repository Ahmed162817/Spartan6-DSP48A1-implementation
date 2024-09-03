create_project project_1 D:/VS_code/Verilog\ codes/project1_design -part xc7a35ticpg236-1L -force   

add_files ff_with_mux_design.v DSP_design.v   

synth_design -rtl -top spartan6_DSP > elab.log    

write_schematic elaborated_schematic.pdf -format pdf -force   

launch_runs synth_1 > synth.log

wait_on_run synth_1
open_run synth_1

write_schematic synthesized_schematic.pdf -format pdf -force    

write_verilog -force switch_LEDs_netlist.v      

launch_runs impl_1 -to_step write_bitstream 

wait_on_run impl_1
open_run impl_1

open_hw

connect_hw_server

 