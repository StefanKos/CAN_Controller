---------------------------------------------------------------
-- Author      : Stefan Kos
-- Date        : 18.05.2026
-- File        : can_crc_core.vhd
-- Version     : v1.1
--
-- Description : Reusable CRC core for the CAN controller.
--               This module performs serial CRC calculation
--               over the incoming bit stream and is intended
--               to be used by both the transmit and receive
--               paths of the controller.
--
-- Scope       : Classical CAN (CRC-15) only.
--               CAN FD CRC handling is out of scope for v1.
--
-- Dependencies: can_constants_pkg.vhd
--               can_types_pkg.vhd
--
-- Notes       : This block only implements the CRC calculation
--               engine. It does not control frame sequencing,
--               field selection or CRC comparison logic.
--               Those responsibilities belong to higher-level
--               protocol blocks.
--
-- Tool / VHDL : VHDL-2008, tested with ModelSim.
---------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.can_constants_pkg.all;
use work.can_types_pkg.all;

entity can_crc_core is
	port (
		clk         : in  std_logic;
		rst         : in  std_logic;
		crc_reset   : in  std_logic;
		crc_enable  : in  std_logic;
		data_bit    : in  std_logic;
		crc_reg_out : out t_can_crc15
	);
end entity can_crc_core;

architecture rtl of can_crc_core is

	signal crc_reg : t_can_crc15 := (others => '0');

begin

    ----------------------------------------------------------------
    -- CRC register process
    -- Updates the internal CRC register when crc_enable is asserted.
    -- The actual CAN CRC-15 feedback logic is to be inserted here.
    ----------------------------------------------------------------
	p_crc_reg : process(clk)
		variable crc_next : t_can_crc15;
		variable feedback : std_logic;
	begin
		if rising_edge(clk) then
			if rst = '1' then
				crc_reg <= (others => '0');

			elsif crc_reset = '1' then
				crc_reg <= (others => '0');

			elsif crc_enable = '1' then
				crc_next := crc_reg;
				feedback := data_bit xor crc_reg(C_CAN_CRC15_WIDTH-1);

                -- Shift register update placeholder
				crc_next(C_CAN_CRC15_WIDTH-1 downto 1) := crc_reg(C_CAN_CRC15_WIDTH-2 downto 0);
				crc_next(0) := '0';

                -- Polynomial tap logic to be completed
                -- Example structure:
                -- if feedback = '1' then
                --     crc_next(bit_index) := crc_next(bit_index) xor '1';
                -- end if;

				crc_reg <= crc_next;
			end if;
		end if;
	end process p_crc_reg;

	crc_reg_out <= crc_reg;

end architecture rtl;