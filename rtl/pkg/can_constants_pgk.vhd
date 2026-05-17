---------------------------------------------------------------
-- Author      : Stefan Kos
-- Date        : 17.05.2026
-- File        : can_constants_pkg.vhd
-- Version     : v1.1
--
-- Description : Package containing constants, generics and
--               configuration values for the CAN controller core.
--               This includes bit values for dominant/recessive,
--               frame field lengths, identifier widths and timing
--               related default settings.
--
-- Scope       : Classical CAN (CAN 2.0A/2.0B) only.
--               CAN FD and extended features are out of scope for v1.
--
-- Dependencies: None (base package for other CAN VHDL files).
--
-- Notes       : This package is intended to centralize all
--               "magic numbers" used by the core to keep the RTL
--               implementation readable and maintainable.
--
-- Tool / VHDL : VHDL-2008, tested with ModelSim.
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package can_constants_pkg is
	
	constant C_CAN_DOMINANT : std_logic := '0';
	constant C_CAN_RECESSIVE : std_logic := '1';
	
	constant C_CAN_ID_STD_WIDTH : natural := 11;
	constant C_CAN_MAX_DATA_BYTES : natural := 8;
	constant C_CAN_DLC_WITDH : natural := 4;
	constant C_CAN_CRC15_WIDTH : natural := 15;
	
	constant C_CAN_CRC_DELIM_LEN : natural := 1;
	constant C_CAN_ACK_LEN : natural := 1;
	constant C_CAN_ACK_DELIM_LEN : natural :=  1;
	constant C_CAN_EOF_LEN : natural := 7;
	constant C_CAN_INTERMISSION_LEN : natural := 3;
	
end package can_constants_pkg;