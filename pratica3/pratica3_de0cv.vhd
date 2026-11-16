-- =====================================================================
-- Pratica 3 na placa DE0-CV (top-level do projeto Quartus)
--
--   KEY(0)  : reset (botao)
--   LEDR(0) : saida y
--   LEDR(9) : clock lento da FSM, para comparar com y
--
-- Clock da FSM = 4 Hz (periodo de 0,25 s). Entao o LEDR0 fica
-- 2 ciclos = 0,5 s apagado e 6 ciclos = 1,5 s aceso. Da para contar
-- as piscadas do LEDR9: 2 com LEDR0 apagado, 6 com LEDR0 aceso.
-- =====================================================================
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
    reset <= not KEY(0);             -- botao solto = '1', apertado = '0'

    -- 50 MHz / (2 * 6_250_000) = 4 Hz
    u_div : entity work.div_clk
        generic map (DIVISOR => 6_250_000)
        port map (clk_in => CLOCK_50, clk_out => clk_lento);

    u_fsm : entity work.pratica3
        port map (clk => clk_lento, reset => reset, y => y);

    LEDR(0)          <= y;
    LEDR(8 downto 1) <= (others => '0');   -- LEDs nao usados ficam apagados
    LEDR(9)          <= clk_lento;
end estrutural;
