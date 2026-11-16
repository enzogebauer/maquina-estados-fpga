-- =====================================================================
-- Pratica 2 na placa DE0-CV (top-level do projeto Quartus)
--
--   KEY(0)       : reset (botao)
--   SW(0)        : sentido ('0' horario, '1' anti-horario)
--   LEDR(3..0)   : fases do motor (LEDR3 = A, LEDR2 = B, LEDR1 = C, LEDR0 = D)
--   GPIO_0(3..0) : as mesmas fases no conector de expansao, para ligar
--                  no driver do motor (ex.: ULN2003). O FPGA nao aguenta
--                  a corrente da bobina: NUNCA ligue o motor direto no pino.
--
-- A FSM anda 4 passos por segundo, para dar para acompanhar nos LEDs.
-- Para girar um motor de verdade, aumente a frequencia trocando o
-- DIVISOR (ex.: 125_000 -> 200 passos/s) e recompile.
-- =====================================================================
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
    signal clk_lento  : std_logic;   -- clock de passo do motor
    signal reset      : std_logic;
    signal a, b, c, d : std_logic;   -- fases vindas da FSM
begin
    reset <= not KEY(0);             -- botao solto = '1', apertado = '0'

    -- 50 MHz / (2 * 6_250_000) = 4 Hz -> 4 passos por segundo
    u_div : entity work.div_clk
        generic map (DIVISOR => 6_250_000)
        port map (clk_in => CLOCK_50, clk_out => clk_lento);

    u_fsm : entity work.pratica2
        port map (clk => clk_lento, reset => reset, sentido => SW(0),
                  a => a, b => b, c => c, d => d);

    -- "&" concatena os 4 bits num vetor: A fica no bit 3 e D no bit 0.
    LEDR   <= a & b & c & d;
    GPIO_0 <= a & b & c & d;
end estrutural;
