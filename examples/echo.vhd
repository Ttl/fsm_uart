library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity echo is
    Port ( rx : in  STD_LOGIC;
           tx : out  STD_LOGIC;
           clk : in  STD_LOGIC);
end echo;

architecture Behavioral of echo is

-- Implementation parameters
constant CLK_FREQ : integer := 32;
constant SER_FREQ : integer := 115200;
constant PARITY : boolean := true;

-- UART signals
signal uart_tx_req, uart_tx_end, uart_rx_ready : std_logic;
signal uart_rx_tx_data : std_logic_vector(7 downto 0);

-- FSM states
type statetype is (s_rx, s_tx);
signal state, next_state : statetype := s_rx;

-- Transmission delay, wait for 2^10=1024 clock cycles before responding
-- to make sure that receiver catches the beginning
signal tx_delay, tx_delay_next : std_logic_vector(10 downto 0);

component uart is
generic (
	CLK_FREQ		: integer := CLK_FREQ;		-- Main frequency (MHz)
	SER_FREQ		: integer := SER_FREQ;		-- Baud rate (bps)
	PARITY_BIT 	: boolean := PARITY			-- RS232 parity bit
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

begin

u1 : uart 
generic map(
	CLK_FREQ		=> CLK_FREQ,		-- Main frequency (MHz)
	SER_FREQ		=> SER_FREQ,		-- Baud rate (bps)
	PARITY_BIT 	=> PARITY			-- RS232 parity bit
)
port map(
	-- Control
	clk => clk,
	rst => '0',
	-- External Interface
	rx	=> rx,
	tx	=> tx,
	-- uPC Interface
	tx_req => uart_tx_req,
	tx_end => uart_tx_end,
	tx_data => uart_rx_tx_data,
	rx_ready	=> uart_rx_ready,
	rx_data => uart_rx_tx_data
);


process(clk)

begin

if rising_edge(clk) then
	state <= next_state;
	tx_delay <= tx_delay_next;
end if;

end process;

process(state, uart_rx_ready, uart_tx_end, tx_delay)

begin
uart_tx_req <= '0';
tx_delay_next <= (others => '0');

case state is 

	when s_rx =>
		next_state <= s_rx;
		-- Received data
		if uart_rx_ready = '1' then
			-- Echo it back
			next_state <= s_tx;
		end if;
	
	when s_tx =>
		next_state <= s_tx;
		if tx_delay(10) = '1' then
			-- Start TX
			uart_tx_req <= '1';
			-- Hold tx_req
			--tx_delay_next <= tx_delay;
		else
			tx_delay_next <= std_logic_vector(unsigned(tx_delay) + 1);
		end if;
		-- Transmission done
		if uart_tx_end = '1' then
			next_state <= s_rx;
		end if;
		
end case;
end process;

end Behavioral;

