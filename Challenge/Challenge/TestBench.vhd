LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY TestBench IS
END TestBench;
 
ARCHITECTURE behavior OF TestBench IS 
   --Inputs
   signal clock : std_logic := '0';
   signal reset : std_logic := '0';
   signal width : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal pwm : std_logic;

   -- Clock period definitions
   constant clock_period : time := 5 us;
	
	signal complete : boolean := false;
BEGIN
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.PulseWidthMod PORT MAP (
          clock => clock,
          reset => reset,
          width => width,
          pwm => pwm
        );

   -- Clock process definitions
   clock_process :process
   begin
		while not complete loop
			clock <= '0';
			wait for clock_period/2;
			clock <= '1';
			wait for clock_period/2;
		end loop;
		wait;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		
      --wait for clock_period * 256;
		width <= (others => '0'); -- 0/255
		
      wait for clock_period * 256;
		width <= "00000001"; -- 1/255
		
      wait for clock_period * 256;
		width <= "01100100"; -- 100/255

      wait for clock_period * 256;
		width <= "11111111"; --255/255
		
		wait for clock_period * 256;
		complete <= true; --end
		wait;
   end process;
END;
