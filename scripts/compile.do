transcript on

# Always assume this script is called from sim/msim
# -> project root is ../../

if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work

# ------------------------------------------------------------
# Compile packages first
# ------------------------------------------------------------
vcom -2008 ../../rtl/pkg/can_constants_pkg.vhd
vcom -2008 ../../rtl/pkg/can_types_pkg.vhd

if {[file exists ../../rtl/pkg/can_crc_pkg.vhd]} {
    vcom -2008 ../../rtl/pkg/can_crc_pkg.vhd
}

# ------------------------------------------------------------
# Compile protocol blocks needed for CRC test
# ------------------------------------------------------------
vcom -2008 ../../rtl/protocol/can_crc_core.vhd

# ------------------------------------------------------------
# Compile unit testbench for CRC
# ------------------------------------------------------------
vcom -2008 ../../tb/unit/tb_can_crc.vhd

echo "Compilation finished successfully."