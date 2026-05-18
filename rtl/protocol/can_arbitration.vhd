---------------------------------------------------------------
-- Author      : Stefan Kos
-- Date        : 18.05.2026
-- File        : can_arbitration.vhd
-- Version     : v1.0
--
-- Description : CAN arbitration unit.
--               This block implements bit-wise arbitration for
--               Classical CAN. During the arbitration field,
--               it compares the transmitted bit with the sampled
--               bus bit and detects arbitration loss when a
--               recessive bit is transmitted but a dominant bit
--               is observed on the bus.
--
-- Scope       : Classical CAN (CAN 2.0A/2.0B) only.
--               Arbitration is only evaluated during the
--               arbitration field. Outside this field, bit
--               mismatches are not treated as arbitration loss.
--
-- Dependencies: can_constants_pkg.vhd
--
-- Notes       : This unit does not perform any timing or
--               frame sequencing. It assumes that higher-level
--               protocol logic provides an arbitration enable
--               signal that is asserted only during the
--               arbitration field.
--
-- Tool / VHDL : VHDL-2008, tested with ModelSim.
---------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.can_constants_pkg.all;

entity can_arbitration is
	port (
		clk          : in  std_logic;
		rst          : in  std_logic;

		-- Control: asserted only during arbitration field
		arb_enable   : in  std_logic;

		-- Bit values at current arbitration bit time
		tx_bit       : in  std_logic;  -- bit driven by this node
		bus_sample   : in  std_logic;  -- bit observed on the bus

		-- Status outputs
		arb_active   : out std_logic;  -- '1' while node is still in arbitration
		arb_lost     : out std_logic   -- '1' after arbitration loss
	);
end entity can_arbitration;

architecture rtl of can_arbitration is

	signal r_arb_active : std_logic := '0';
	signal r_arb_lost   : std_logic := '0';

begin

	----------------------------------------------------------------
	-- Arbitration process
	--
	-- Rules (during arbitration field, arb_enable = '1'):
	-- - As long as the node transmits and observes the same bit,
	--   it remains arbitration active.
	-- - If the node transmits a recessive bit and observes a
	--   dominant bit on the bus, it loses arbitration immediately.
	-- - After arbitration loss, the node remains in "lost" state
	--   until arbitration is disabled (end of arbitration field).
	--
	-- Outside the arbitration field (arb_enable = '0'):
	-- - The unit is reset to "not active, not lost" state.
	----------------------------------------------------------------
	p_arbitration : process(clk)
	begin
		if rising_edge(clk) then

			if rst = '1' then
				r_arb_active <= '0';
				r_arb_lost   <= '0';

			elsif arb_enable = '0' then
				-- No arbitration in progress, reset internal state
				r_arb_active <= '0';
				r_arb_lost   <= '0';

			else
				-- Arbitration active
					if r_arb_lost = '1' then
					-- Once lost, stay lost until arb_enable is deasserted
					r_arb_active <= '0';

				else
					-- Initially, node is active when entering arbitration
					if r_arb_active = '0' then
						r_arb_active <= '1';
					end if;

					-- Check for arbitration loss condition:
					-- Tx recessive, bus dominant.
					if (tx_bit = C_CAN_RECESSIVE) and (bus_sample = C_CAN_DOMINANT) then
						r_arb_lost   <= '1';
						r_arb_active <= '0';
					end if;
				end if;
			end if;
		end if;
	end process p_arbitration;

	arb_active <= r_arb_active;
	arb_lost   <= r_arb_lost;

end architecture rtl;