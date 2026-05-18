transcript on

set TB_NAME tb_can_crc

# compile from sim/msim
do ../../scripts/compile.do

vsim -t ns work.$TB_NAME
add wave -r /*
run -all

echo "Simulation for $TB_NAME finished."