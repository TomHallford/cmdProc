library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.common_pack.all;

entity TB_cmd2dataInterface is
end TB_cmd2dataInterface;


architecture TB of TB_cmd2dataInterface is

	component cmd2dataInterface is
		port( 
			clk: in std_logic; 
			reset: in std_logic; 
			instart: out std_logic; 
			innumWords: out std_logic_vector (11 downto 0); 
			indataReady: in std_logic; 
			inseqDone: in std_logic; 
			ininitiateNow: in std_logic; 
			indataReadyint: out std_logic;
			inseqDoneint: out std_logic 
		);	
	end component; 

	signal TB_clk: std_logic := '0';
	signal TB_clkPeriod: time := 10ns;

	signal TB_reset: std_logic := '0';
	signal TB_start: std_logic := '0';
	signal TB_numWords: std_logic_vector (11 downto 0);
	signal TB_dataReady: std_logic := '0';
	signal TB_seqDone: std_logic := '0';
	signal TB_initiateNow: std_logic := '0';
	signal TB_dataReadyint: std_logic := '0';
	signal TB_seqDoneint: std_logic := '0';

	begin

		--cmd2dataInterface instantiation--
		test_c2dInterface: cmd2dataInterface
			port map(
			clk => TB_clk,
			reset => TB_reset,
			instart => TB_start,
			innumWords => TB_numwords,
			indataReady => TB_dataReady,
			inseqDone => TB_seqDone,
			ininitiateNow => TB_initiateNow,
			indataReadyint => TB_dataReadyint,
			inseqDoneint => TB_seqDoneint
			);


		--clock cycle--
		tick_tock: process
		begin
			while true loop
				TB_clk <= '0';
				wait for TB_clkPeriod / 2;
				TB_clk <= '1';
				wait for TB_clkPeriod / 2;
			end loop;
		end process;

		
		--the test--
		test_process: process
		begin
			--reset--
			TB_reset <= '1';
			wait for 10ns;
			TB_reset <= '0';
			wait for 10ns;

			--begin--
			TB_numwords <= "010100010100";
			TB_initiateNow <= '1';
		
			--communicating--
			TB_dataReady <= '1';
			wait for 10ns;
			TB_dataReady <= '1';
			wait for 10ns;
			TB_dataReady <= '1';
			wait for 10ns;
			TB_dataReady <= '1';
			wait for 10ns;
			TB_dataReady <= '1';
			wait for 10ns;

			--end--
			TB_seqDone <= '0';
			wait;

				
		end process;
	
end TB;