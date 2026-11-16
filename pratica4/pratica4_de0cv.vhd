-- =====================================================================
-- Pratica 4 na placa DE0-CV (top-level do projeto Quartus)
--
--   KEY(0)     : reset (botao)
--   SW(0)      : x ('1' progressivo, '0' regressivo)
--   LEDR(1..0) : codigo Gray atual
--
-- Clock da FSM = 1 Hz. Repare que so um LED muda a cada segundo:
-- essa e a propriedade do codigo Gray.
-- =====================================================================
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
    reset <= not KEY(0);             -- botao solto = '1', apertado = '0'

    -- 50 MHz / (2 * 25_000_000) = 1 Hz
    u_div : entity work.div_clk
        generic map (DIVISOR => 25_000_000)
        port map (clk_in => CLOCK_50, clk_out => clk_lento);

    -- A saida q da FSM vai direto para os dois LEDs.
    u_fsm : entity work.pratica4
        port map (clk => clk_lento, reset => reset, x => SW(0), q => LEDR);
end estrutural;
