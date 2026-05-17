---------------------------------------------------------------
-- Author      : Stefan Kos
-- Date        : 17.05.2026
-- File        : can_types_pkg.vhd
-- Version     : v1.1
--
-- Description : Package containing shared type definitions for
--               the CAN controller core.
--               This includes subtypes, enumerations, record
--               types and array types used across the RTL and
--               testbench environment.
--
-- Scope       : Classical CAN (CAN 2.0A/2.0B) only.
--               CAN FD and extended features are out of scope for v1.
--
-- Dependencies: can_constants_pkg.vhd
--
-- Notes       : This package is intended to centralize common
--               structural data definitions in order to improve
--               readability, modularity and consistency across
--               the CAN controller design.
--
-- Tool / VHDL : VHDL-2008, tested with ModelSim.
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.can_types_pkg.all;

package can_types_pkg is
	
	
    --------------------------------------------------------------------
    -- Subtypes
    --------------------------------------------------------------------
    subtype t_can_bit    is std_logic;
    subtype t_can_id_std is std_logic_vector(C_CAN_ID_STD_WIDTH-1 downto 0);
    subtype t_can_dlc    is std_logic_vector(C_CAN_DLC_WIDTH-1 downto 0);
    subtype t_can_crc15  is std_logic_vector(C_CAN_CRC15_WIDTH-1 downto 0);
    subtype t_can_data_byte is std_logic_vector(7 downto 0);

    --------------------------------------------------------------------
    -- Arrays
    --------------------------------------------------------------------
    type t_can_data_array is array (0 to C_CAN_MAX_DATA_BYTES-1) of t_can_data_byte;

    --------------------------------------------------------------------
    -- Protocol / frame processing states
    --------------------------------------------------------------------
    type t_can_bsp_state is (
        ST_IDLE,
        ST_SOF,
        ST_ARBITRATION,
        ST_CONTROL,
        ST_DATA,
        ST_CRC,
        ST_CRC_DELIM,
        ST_ACK,
        ST_ACK_DELIM,
        ST_EOF,
        ST_INTERMISSION,
        ST_ERROR
    );

    --------------------------------------------------------------------
    -- Error state model (simple v1 version)
    --------------------------------------------------------------------
    type t_can_error_state is (
        ERR_ACTIVE,
        ERR_PASSIVE,
        BUS_OFF
    );

    --------------------------------------------------------------------
    -- TX frame record
    --------------------------------------------------------------------
    type t_can_tx_frame is record
        id   : t_can_id_std;
        dlc  : t_can_dlc;
        data : t_can_data_array;
    end record;

    --------------------------------------------------------------------
    -- RX frame record
    --------------------------------------------------------------------
    type t_can_rx_frame is record
        id    : t_can_id_std;
        dlc   : t_can_dlc;
        data  : t_can_data_array;
        valid : std_logic;
    end record;
	
end package can_types_pkg;