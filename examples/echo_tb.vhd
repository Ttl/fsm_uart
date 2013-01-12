LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
 
ENTITY echo_tb IS
END echo_tb;
 
ARCHITECTURE behavior OF echo_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT echo
    PORT(
         rx : IN  std_logic;
         tx : OUT  std_logic;
         clk : IN  std_logic
        );
    END COMPONENT;
    
	 component uart is
	generic (
		CLK_FREQ	: integer := 32;		-- Main frequency (MHz)
		SER_FREQ	: integer := 115200		-- Baud rate (bps)
	);
	port (
		-- Control
		clk			: in	std_logic;		-- Main clock
		rst			: in	std_logic;		-- Main reset
		-- External Interface
		rx			: in	std_logic;		-- RS232 received serial data
		tx			: out	std_logic;		-- RS232 transmitted serial data
		-- uPC Interface
		tx_req		: in	std_logic;						-- Request SEND of data
		tx_end		: out	std_logic;						-- Data SENDED
		tx_data		: in	std_logic_vector(7 downto 0);	-- Data to transmit
		rx_ready	: out	std_logic;						-- Received data ready to uPC read
		rx_data		: out	std_logic_vector(7 downto 0)	-- Received data 
	);
	end component;

   --Inputs
   signal rx : std_logic := '0';
   signal clk : std_logic := '0';

 	--Outputs
   signal tx : std_logic;

	-- UART signals
	signal uart_tx_req : std_logic := '0';
	signal uart_tx_end : std_logic := '0';
	signal uart_tx_data : std_logic_vector(7 downto 0) := (others => '0');
	signal uart_rx_ready : std_logic := '0';
	signal uart_rx_data : std_logic_vector(7 downto 0) := (others => '0');

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: echo PORT MAP (
          rx => rx,
          tx => tx,
          clk => clk
        );

	u1: uart
	generic map(
		CLK_FREQ => 32,
		SER_FREQ	=> 115200
	)
	port map(
		clk	=> clk,
		rst	=> '0',
		rx		=> '1',
		tx		=> rx,
		tx_req	=> uart_tx_req,
		tx_end	=> uart_tx_end,
		tx_data	=> uart_tx_data,
		rx_ready	=> uart_rx_ready,
		rx_data	=> uart_rx_data
	);
	
   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

	tx_proc : process
	begin
	wait for 1000us;
	uart_tx_data <= "01100101";
	wait for 10us;
	uart_tx_req <= '1';
	wait for 10us;
	uart_tx_req <= '0';

	wait for 1000us;
	uart_tx_data <= "00000000";
	wait for 10us;
	uart_tx_req <= '1';
	wait for 10us;
	uart_tx_req <= '0';


	end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
