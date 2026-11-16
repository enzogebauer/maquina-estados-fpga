# Cria (ou recria) o projeto Quartus de uma pratica para a placa DE0-CV.
# Uso: quartus_sh -t criar_projeto.tcl <n>     (n = 1..7, rodar dentro da pasta praticaN)
package require ::quartus::project

set n    [lindex $quartus(args) 0]
set proj "pratica$n"
set top  "pratica${n}_de0cv"

if {[project_exists $proj]} {
    project_open $proj -force
} else {
    project_new $proj -overwrite
}

set_global_assignment -name FAMILY "Cyclone V"
set_global_assignment -name DEVICE 5CEBA4F23C7
set_global_assignment -name TOP_LEVEL_ENTITY $top
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name VHDL_INPUT_VERSION VHDL_2008
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
set_global_assignment -name SDC_FILE de0cv.sdc

# Arquivos de projeto
foreach f [list div_clk.vhd hex7seg.vhd ${proj}.vhd ${top}.vhd] {
    set_global_assignment -name VHDL_FILE $f
}

# Simulacao RTL com ModelSim (Tools > Run Simulation Tool > RTL Simulation)
set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (VHDL)"
set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
set_global_assignment -name EDA_TEST_BENCH_ENABLE_STATUS TEST_BENCH_MODE -section_id eda_simulation
set_global_assignment -name EDA_NATIVELINK_SIMULATION_TEST_BENCH tb_$proj -section_id eda_simulation
set_global_assignment -name EDA_TEST_BENCH_NAME tb_$proj -section_id eda_simulation
set_global_assignment -name EDA_DESIGN_INSTANCE_NAME dut -section_id tb_$proj
set_global_assignment -name EDA_TEST_BENCH_MODULE_NAME tb_$proj -section_id tb_$proj
set_global_assignment -name EDA_TEST_BENCH_RUN_SIM_FOR "10 us" -section_id tb_$proj
set_global_assignment -name EDA_TEST_BENCH_FILE tb_${proj}.vhd -section_id tb_$proj

# Pinos da DE0-CV
set pinos {
    CLOCK_50 M9
    KEY[0] U7   KEY[1] W9
    SW[0] U13   SW[1] V13   SW[2] T13
    LEDR[0] AA2 LEDR[1] AA1 LEDR[2] W2  LEDR[3] Y3  LEDR[4] N2
    LEDR[5] N1  LEDR[6] U2  LEDR[7] U1  LEDR[8] L2  LEDR[9] L1
    HEX0[0] U21 HEX0[1] V21 HEX0[2] W22 HEX0[3] W21 HEX0[4] Y22 HEX0[5] Y21 HEX0[6] AA22
    GPIO_0[0] N16 GPIO_0[1] B16 GPIO_0[2] M16 GPIO_0[3] C16
}
foreach {sinal pino} $pinos {
    set_location_assignment PIN_$pino -to $sinal
}

export_assignments
project_close
