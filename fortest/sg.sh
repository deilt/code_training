read_file -type gateslib ${libname)
read_file -type verilog ${verilogname}
read_file -type sgdc ${sgdcname)
set_option top Top
current_goal cdc/cdc_verify_struct -top Top
source/tmpdata/ranwu_staff_3/ywxl3ll86θ/workspace/bin/cfg/sg_cfg
run_goal
write_report Ac_sync_group_detail > $pureName.rpt
save_project -force
gui_start
