-- Pratica 5 na placa DE0-CV
--   KEY(0)  : reset (ativo em '0')
--   KEY(1)  : botao que liga/desliga o LED
--   LEDR(0) : LED controlado
-- A FSM roda a 100 Hz: amostrar o botao a cada 10 ms ja filtra o
-- repique (bounce) mecanico, que dura poucos milissegundos.
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
    reset <= not KEY(0);
    btn   <= not KEY(1);

    u_div : entity work.div_clk
        generic map (DIVISOR => 250_000)             -- 50 MHz -> 100 Hz
        port map (clk_in => CLOCK_50, clk_out => clk_lento);

    u_fsm : entity work.pratica5
        port map (clk => clk_lento, reset => reset, btn => btn, led => LEDR(0));
end estrutural;
