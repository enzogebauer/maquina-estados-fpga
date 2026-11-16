-- Pratica 3 na placa DE0-CV
--   KEY(0)  : reset (ativo em '0')
--   LEDR(0) : saida y (2 ciclos apagado, 6 ciclos aceso)
--   LEDR(9) : clock lento da FSM (para comparar)
-- Clock da FSM = 4 Hz -> LED apagado 0,5 s e aceso 1,5 s.
library ieee;
use ieee.std_logic_1164.all;

entity pratica3_de0cv is
    port (
        CLOCK_50 : in  std_logic;
        KEY      : in  std_logic_vector(0 downto 0);
        LEDR     : out std_logic_vector(9 downto 0)
    );
end pratica3_de0cv;

architecture estrutural of pratica3_de0cv is
    signal clk_lento : std_logic;
    signal reset     : std_logic;
    signal y         : std_logic;
begin
    reset <= not KEY(0);

    u_div : entity work.div_clk
        generic map (DIVISOR => 6_250_000)           -- 50 MHz -> 4 Hz
        port map (clk_in => CLOCK_50, clk_out => clk_lento);

    u_fsm : entity work.pratica3
        port map (clk => clk_lento, reset => reset, y => y);

    LEDR(0)          <= y;
    LEDR(8 downto 1) <= (others => '0');
    LEDR(9)          <= clk_lento;
end estrutural;
