library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Counter is
    Port ( reset : in  STD_LOGIC;
           clock : in  STD_LOGIC;
           delay_1s : out  STD_LOGIC);
end Counter;

architecture Behavioral of Counter is
	signal count : natural range 0 to 200;
begin
	timer:
   process (reset, clock)
   begin
      if (reset = '1') then
         count <= 1;
      elsif rising_edge(clock) then
			count <= count+1;
      end if;
   end process;
	
	-- output statements
		--if clock = this then do that
		--use for delays
	delay_1s <= '1' when count = 1 else '0';

end Behavioral;
