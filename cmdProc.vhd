library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;


entity cmdProc is
Port (
            -- System
            clk:    in std_logic;
            reset:  in std_logic;
            
            -- DPCP Interface
            dataReady:   in std_ulogic;
            byte:   in std_logic_vector (7 downto 0);
            maxIndex:   in std_logic_vector (11 downto 0);
            dataResults:   in std_logic_vector (55 downto 0);
            seqDone:   in std_ulogic;
            start:   out std_ulogic;
            numWords:   out std_logic_vector (11 downto 0);
            
            -- Transmitter 
            dataout:   out std_logic_vector (7 downto 0);
            txNow:   out std_ulogic;
            txDone:   in std_ulogic;
            
            -- Receiver 
            rdone:   out std_ulogic;
            rdatain:   in std_logic_vector (7 downto 0);
            rvalid:   in std_ulogic;
            roe:   in std_ulogic;
            rfe:   in std_ulogic;
            rinitiateNow: out std_ulogic;
            rfinishInt: in std_ulogic
            

 );
end cmdProc;

architecture Receiver of cmdProc is
    type stateType is (IDLE, RECEIVING, RECEIVED, COMPLETE);
    type logical_type is (TRUE, FALSE);
    
    signal currentState, nextState: stateType;
    signal bit_count : integer range 0 to 8 := 0; --8 bit counter for received data
    signal valid_reg : std_ulogic := '0'; -- internal signal to drive valid output
    signal received_data : std_logic_vector(7 downto 0); -- stores received byte
    
begin  -- next state logic
 receiverNextState: process(currentState, rdatain, bit_count)--add signals in here)
begin
-- defaults
    nextState <= currentState;
    valid_reg <= '0';
    rdone <= '0';
    
    case currentState is
        when IDLE =>
            if rdatain /= "00000000" then --check if data is available
                bit_count <= bit_count +1; -- include the bit that has already been sent
                nextState <= RECEIVING;    
            end if;
            
        when RECEIVING =>
            if bit_count = 7 then --check if whole byte has been received
                if rvalid = '1' then --valid signal is given by Rx
                    nextState <= RECEIVED;
                end if;
            end if;   
            
        when RECEIVED =>
            rdone <= '1'; --tells rx that data has been read and to clear register
            rinitiateNow <= '1'; -- tells interface to do its thing
            -- need to add if statements to determine oe and fe
            if roe = '1' then
                nextState <= IDLE;
            end if;
            if rfe = '1' then
                nextState <= IDLE;
            end if;
            if rfinishInt = '1' then --received from Tx, internal finish signal
                nextState <= COMPLETE;
            end if;
            
        when others =>
            nextState <= IDLE;
     end case;
 end process;
 
 -- bit count process
process(clk, rdatain)
begin
    if rising_edge(clk) then
        if reset = '1' or currentState = IDLE then
            bit_count <= 0;
        elsif currentState = RECEIVING and rdatain /= "00000000" then -- detect bit input
            bit_count <= bit_count + 1;
        end if;
     end if;
 end process;
    
stateRegister: process(clk, reset)
begin
    if rising_edge(clk) then
        if (reset = '1') then
            currentState <= IDLE;
        else
            currentState <= nextState;
        end if;
    end if;
   end process;
    
 -- assign outputs
 dataout <= received_data;

end Receiver;


