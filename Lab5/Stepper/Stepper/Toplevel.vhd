----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:45:45 04/30/2018 
-- Design Name: 
-- Module Name:    Stepper - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Stepper is
    Port ( Reset : in  STD_LOGIC;
           En : in  STD_LOGIC;
           Cw : in  STD_LOGIC;
           Clock : in  STD_LOGIC;
           output : out  STD_LOGIC_VECTOR (3 downto 0);
           debugLed : out  STD_LOGIC);
end Stepper;

architecture Behavioral of Stepper is

type StateType is (S0, S1, S2, S3);
signal State, nextState : StateType;

begin

debugLed <= Reset;

Synch:
process (reset, clock)
begin
	if (reset = '1') then
		state <= S0;
	elsif rising_edge(clock) then
		state <= nextstate;
	end if;
end process Synch;

combinational:
process(state, En, Cw)
begin
	output <= "0000";
	case state is
		when S0 => 
			output(0) <= '1';
			if (En = '1') then
				if (Cw = '1') then
					nextstate <= S1;
				else
					nextstate <= S3;
				end if;
			end if;
		when S1 => 
			output(2) <= '1';
			if (En = '1') then
				if (Cw = '1') then
					nextstate <= S2;
				else
					nextstate <= S0;
				end if;
			end if;
		when S2 => 
			output(1) <= '1';
			if (En = '1') then
				if (Cw = '1') then
					nextstate <= S3;
				else
					nextstate <= S1;
				end if;
			end if;
		when S3 => 
			output(3) <= '1';
			if (En = '1') then
				if (Cw = '1') then
					nextstate <= S0;
				else
					nextstate <= S2;
				end if;
			end if;
	end case;
end process combinational;
end Behavioral;

