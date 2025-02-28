library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.common_pack.all;


entity cmdProc is
Port (
	    --the following signals interact outside the entity cmdProc--
	    --the titles of signals is what outside component they interact with--
	    --note*** numWords, maxIndex and dataResults need to be changes to BCD array

            --System--
            clk:    in std_logic;
            reset:  in std_logic;
            
            -- Data Processor--
            dataReady:   in std_logic;
            byte:   in std_logic_vector (7 downto 0);
            maxIndex:   in std_logic_vector (11 downto 0);
            dataResults:   in std_logic_vector (55 downto 0);
            seqDone:   in std_logic;
            start:   out std_logic;
            numWords:   out std_logic_vector (11 downto 0);
            
            -- Transmitter-- 
            dataOut:   out std_logic_vector (7 downto 0);
            txNow:   out std_logic;
            txDone:   out std_logic;
            
            --Reciever-- 
            done:   out std_logic;
            dataIn:   in std_logic_vector (7 downto 0);
            valid:   in std_logic;
            oe:   in std_logic;
            fe:   in std_logic

 );
end cmdProc;


architecture Structure of cmdProc is
	
	component recieverInterface is
		port( --the word beginning "r" denoted the reciever--
			clk: in std_logic; --external related signal--
			reset: in std_logic; --external related signal--
			rdone: out std_logic; --external related signal--
			rdataIn: in std_logic_vector (7 downto 0); --external related signal--
			rvalid: in std_logic; --external related signal--
			roe: in std_logic; --external related signal--
			rfe: in std_logic; --external related signal--
			rinitiateNow: out std_logic; --internal related signal--
			rfinishInt: in std_logic --internal related signal--
		);
	end component;

	component cmd2dataInterface is
		port( --the word beginning "in" denoted the main interface--
			clk: in std_logic; --external related signal--
			reset: in std_logic; --external related signal--
			instart: out std_logic; --external related signal--
			innumWords: out std_logic_vector (11 downto 0); --external related signal--
			indataReady: in std_logic; --external related signal--
			inseqDone: in std_logic; --external related signal--
			ininitiateNow: in std_logic; --internal related signal--
			indataReadyint: out std_logic; --internal related signal--
			inseqDoneint: out std_logic --internal related signal--
		);	
	end component;

	component transmitterInterface is
		port(  --the word beginning t denoted the Transmitter--
			clk: in std_logic; --external related signal--
			reset: in std_logic; --external related signal--
			tdata: out std_logic_vector (7 downto 0); --external related signal--
			ttxNow: out std_logic; --external related signal--
			ttxDone: out std_logic; --external related signal--
			tbyte: in std_logic_vector (7 downto 0); --external related signal--	
			tmaxIndex: in std_logic_vector (11 downto 0); --external related signal--
			tdataResults: in std_logic_vector (55 downto 0); --external related signal--
			tdataReadyint: in std_logic; --internal related signal--
			tseqDoneint: in std_logic; --internal related signal--
			tfinishInt: out std_logic --internal related signal--
		);
	end component;

	--internal signals--
	signal initiateNow: std_logic := '0';
	signal dataReadyint: std_logic := '0';
	signal seqDoneint: std_logic := '0';
	signal finishInt: std_logic := '0';

	begin
	
		--reciever interface instantiation--
		recInt: recieverInterface
			port map(
				clk => clk,
				reset => reset,
				rdone => done,
				rdataIn => dataIn,
				rvalid => valid,
				roe => oe,
				rfe =>fe,
				rinitiateNow => initiateNow,
				rfinishInt => finishInt
			);

		cdInt: cmd2dataInterface
			port map(
				clk => clk,
				reset => reset,
				instart => start,
				innumWords => numWords,
				indataReady => dataReady,
				inseqDone => seqDone,
				ininitiateNow => initiateNow,
				indataReadyint => dataReadyint,
				inseqDoneint => seqDoneint
			);

		tranInt: transmitterInterface 
			port map(
				clk => clk,
				reset => reset,
				tdata => dataOut,
				ttxNow => txNow,
				ttxDone => txDone,
				tbyte => byte,
				tmaxIndex => maxIndex,
				tdataResults => dataResults,
				tdataReadyint => dataReadyint,
				tseqDoneint => seqDoneint,
				tfinishInt => finishInt
			);
end Structure;

