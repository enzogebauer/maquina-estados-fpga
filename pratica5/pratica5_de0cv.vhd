-- =====================================================================
-- Pratica 5 na placa DE0-CV (top-level do projeto Quartus)
--
--   KEY(0)  : reset (botao)
--   KEY(1)  : botao que liga/desliga o LED
--   LEDR(0) : LED controlado
--
-- A FSM roda a 100 Hz, ou seja, olha o botao a cada 10 ms. Um botao
-- mecanico "repica" (bounce): ao ser apertado, o contato abre e fecha
-- varias vezes durante alguns milissegundos. Amostrando so a cada
-- 10 ms, esse repique nao e visto como varios apertos.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;

entity pratica5_de0cv is
    port (
        CLOCK_50 : in  std_logic;
        KEY      : in  std_logic_vector(1 downto 0);
        LEDR     : out std_logic_vector(0 downto 0)
    );
end pratica5_de0cv;

architecture estrutural of pratica5_de0cv is
    signal clk_lento : std_logic;
    signal reset     : std_logic;
    signal btn       : std_logic;
begin
    -- Botoes da DE0-CV: soltos = '1', apertados = '0'. A FSM espera
    -- '1' = apertado, por isso as duas inversoes.
    reset <= not KEY(0);
    btn   <= not KEY(1);

    -- 50 MHz / (2 * 250_000) = 100 Hz
    u_div : entity work.div_clk
        generic map (DIVISOR => 250_000)
        port map (clk_in => CLOCK_50, clk_out => clk_lento);

    u_fsm : entity work.pratica5
        port map (clk => clk_lento, reset => reset, btn => btn, led => LEDR(0));
end estrutural;
