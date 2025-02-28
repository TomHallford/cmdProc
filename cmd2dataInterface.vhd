library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.common_pack.all;

entity cmd2dataInterface is
	Port(
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

end cmd2dataInterface;



architecture behav of cmd2dataInterface is

	-- States of the Interface--
	type Interface_State_Type is (IDLE, INITIATE, COMMUNICATE, COMPLETE);
	signal currentState : Interface_State_Type := IDLE;
	signal nextState    : Interface_State_Type;

	--InitiateToCommunication--
	signal sent : std_logic :='0';
	signal endReturn : std_logic :='0';

	--State Register--
	begin
    		seq: process(clk, reset)
        		begin
            			if reset = '1' then
                			currentState <= IDLE;
            			elsif rising_edge(clk) then
                			currentState <= nextState;
            			end if;
    		end process;
   
	--State Ouputs--
    		interface_current_State: process(currentState)
        		begin
            			case currentState is
                		when IDLE => --Nothing is gonna happen until --
					endReturn <= '0';
				when INITIATE =>--Sends start and the initial bit of data

					instart <= '1';
					sent <= '1';

                		when COMMUNICATE =>

					sent <= '0';
					instart <= '0';
			
					if indataReady = '1' then
						indataReadyint <= '1';
					else
						indataReadyint <= '0';
					end if;
				
                		when COMPLETE =>

                    			inseqDoneint <= '1';
					endReturn <= '1';

            			end case;
   		end process;

	--State Switchiing--     
    		interface_next_State: process(currentState, ininitiateNow, inseqDone, sent, endReturn)
        		begin
            			case currentState is
                		when IDLE =>
                    			if ininitiateNow = '1' then
                        			nextState <= INITIATE;
                    			else
                        			nextState <= IDLE;
                    			end if;
				when INITIATE =>
					if sent = '1' then
						nextState <= COMMUNICATE;
					else
						nextState <= INITIATE;
					end if;
                		when COMMUNICATE =>
                    			if inseqDone = '1' then
                        			nextState <= COMPLETE;
                    			else
                        			nextState <= COMMUNICATE;
                    			end if;
                		when COMPLETE =>
                    			if endReturn = '1' then
                        			nextState <= IDLE;
                    			else
                        			nextState <= COMPLETE;
                    			end if;
            			end case;
    		end process;
end behav;
