-- Pratica 2 na placa DE0-CV
--   KEY(0)       : reset (ativo em '0')
--   SW(0)        : sentido ('0' horario, '1' anti-horario)
--   LEDR(3..0)   : fases A, B, C, D (LEDR3 = A ... LEDR0 = D)
--   GPIO_0(3..0) : as mesmas fases, para ligar no driver do motor (ex.: ULN2003)
-- A FSM anda 4 passos por segundo; para o motor real, aumente a frequencia
-- (ex.: DIVISOR => 125_000 -> 200 passos/s).
library ieee;
use ieee.std_logic_1164.all;

entity pratica2_de0cv is
    port (
        CLOCK_50 : in  std_logic;
        KEY      : in  std_logic_vector(0 downto 0);
        SW       : in  std_logic_vector(0 downto 0);
        LEDR     : out std_logic_vector(3 downto 0);
        GPIO_0   : out std_logic_vector(3 downto 0)
    );
end pratica2_de0cv;

architecture estrutural of pratica2_de0cv is
    signal clk_lento  : std_logic;
    signal reset      : std_logic;
    signal a, b, c, d : std_logic;
begin
    reset <= not KEY(0);

    u_div : entity work.div_clk
        generic map (DIVISOR => 6_250_000)           -- 50 MHz -> 4 Hz
        port map (clk_in => CLOCK_50, clk_out => clk_lento);

    u_fsm : entity work.pratica2
        port map (clk => clk_lento, reset => reset, sentido => SW(0),
                  a => a, b => b, c => c, d => d);

    LEDR   <= a & b & c & d;
    GPIO_0 <= a & b & c & d;
end estrutural;
