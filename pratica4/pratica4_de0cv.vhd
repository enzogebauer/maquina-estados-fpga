-- Pratica 4 na placa DE0-CV
--   KEY(0)     : reset (ativo em '0')
--   SW(0)      : x ('1' progressivo, '0' regressivo)
--   LEDR(1..0) : codigo Gray
-- Clock da FSM = 1 Hz.
library ieee;
use ieee.std_logic_1164.all;

entity pratica4_de0cv is
    port (
        CLOCK_50 : in  std_logic;
        KEY      : in  std_logic_vector(0 downto 0);
        SW       : in  std_logic_vector(0 downto 0);
        LEDR     : out std_logic_vector(1 downto 0)
    );
end pratica4_de0cv;

architecture estrutural of pratica4_de0cv is
    signal clk_lento : std_logic;
    signal reset     : std_logic;
begin
    reset <= not KEY(0);

    u_div : entity work.div_clk
        generic map (DIVISOR => 25_000_000)          -- 50 MHz -> 1 Hz
        port map (clk_in => CLOCK_50, clk_out => clk_lento);

    u_fsm : entity work.pratica4
        port map (clk => clk_lento, reset => reset, x => SW(0), q => LEDR);
end estrutural;
