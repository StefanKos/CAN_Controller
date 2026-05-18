---------------------------------------------------------------
-- Author      : Stefan Kos
-- Date        : 18.05.2026
-- File        : tb_can_crc.vhd
-- Version     : v1.0
--
-- Description : Testbench for the reusable CAN CRC core.
--               This testbench verifies the current basic
--               behavior of the CRC module, including reset,
--               crc_reset, crc_enable and serial data input
--               handling.
--
-- Scope       : Basic functional verification for the current
--               development stage of can_crc_core.vhd.
--               Full CRC-15 protocol verification is not yet
--               part of this testbench version.
--
-- Dependencies: can_constants_pkg.vhd
--               can_types_pkg.vhd
--               can_crc_core.vhd
--
-- Notes       : This testbench is intentionally written for the
--               current placeholder implementation of the CRC
--               core. It should be extended once the final
--               polynomial feedback logic is implemented.
--
-- Tool / VHDL : VHDL-2008, tested with ModelSim.
---------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.env.all;

library work;
use work.can_constants_pkg.all;
use work.can_types_pkg.all;

entity tb_can_crc is
end entity tb_can_crc;

architecture sim of tb_can_crc is

	constant C_CLK_PERIOD : time := 10 ns;

	signal clk         : std_logic := '0';
	signal rst         : std_logic := '0';
	signal crc_reset   : std_logic := '0';
	signal crc_enable  : std_logic := '0';
	signal data_bit    : std_logic := '0';
	signal crc_reg_out : t_can_crc15;

begin

	-- DUT instantiation
	uut : entity work.can_crc_core
		port map (
			clk         => clk,
			rst         => rst,
			crc_reset   => crc_reset,
			crc_enable  => crc_enable,
			data_bit    => data_bit,
			crc_reg_out => crc_reg_out
		);
		
	-- Clock generation
	p_clk : process
	begin
		while true loop
			clk <= '0';
			wait for C_CLK_PERIOD / 2;
			clk <= '1';
			wait for C_CLK_PERIOD / 2;
		end loop;
	end process p_clk;
	
	-- Stimulus process
	p_stim : process
		variable crc_before : t_can_crc15;
	begin
	
		-- Global reset
		rst <= '1';
		crc_reset <= '0';
		crc_enable <= '0';
		data_bit <= '0';
		wait for 3 * C_CLK_PERIOD;

		rst <= '0';
		wait for C_CLK_PERIOD;

		assert crc_reg_out = (others => '0')
			report "ERROR: CRC register not cleared after global reset."
			severity error;
			
		-- Check crc_reset
		crc_enable <= '1';
		data_bit <= '1';
		wait until rising_edge(clk);
		wait for 1 ns;

		crc_reset <= '1';
		wait until rising_edge(clk);
		wait for 1 ns;

		crc_reset <= '0';
		wait for 1 ns;

		assert crc_reg_out = (others => '0')
			report "ERROR: CRC register not cleared by crc_reset."
			severity error;
			
		-- Check hold behavior when crc_enable = '0'
		crc_before := crc_reg_out;
		crc_enable <= '0';
		data_bit <= '1';
		wait until rising_edge(clk);
		wait for 1 ns;

		assert crc_reg_out = crc_before
			report "ERROR: CRC register changed although crc_enable = '0'."
			severity error;
			
		-- Apply simple serial stimulus with crc_enable = '1'
		crc_enable <= '1';

		data_bit <= '1';
		wait until rising_edge(clk);
		wait for 1 ns;

		data_bit <= '0';
		wait until rising_edge(clk);
		wait for 1 ns;

		data_bit <= '1';
		wait until rising_edge(clk);
		wait for 1 ns;

		data_bit <= '1';
		wait until rising_edge(clk);
			wait for 1 ns;
			
		-- Informational check:
		-- with the current placeholder implementation, the register
		-- should not remain all-zero forever once enabled stimulus
		-- has been applied.
		assert crc_reg_out /= (others => '0')
			report "ERROR: CRC register did not change during enabled stimulus."
			severity error;

		report "tb_can_crc completed successfully." severity note;
		finish;
	end process p_stim;

end architecture sim;