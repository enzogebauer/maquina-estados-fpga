-- =====================================================================
-- Pratica 7 na placa DE0-CV: controle de luminosidade do LED por PWM
--
--   KEY(0)     : reset (botao)
--   SW(2..0)   : x em binario (ciclo de trabalho = x/7)
--   LEDR(0)    : LED com brilho controlado pelo PWM
--   LEDR(9..7) : repetem as chaves, para conferir o valor de x
--   HEX0       : mostra x em decimal
--
-- Por que o brilho muda: o LED pisca rapido demais para o olho ver.
-- O olho enxerga a MEDIA, entao quanto maior a fracao do tempo aceso
-- (x/7), mais forte parece o brilho.
--
-- Clock da FSM ~ 7 kHz. Como o periodo do PWM tem 7 ciclos, o LED
-- pisca a ~1 kHz, bem acima do que o olho percebe.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;

entity pratica7_de0cv is
    port (
        CLOCK_50 : in  std_logic;
        KEY      : in  std_logic_vector(0 downto 0);
        SW       : in  std_logic_vector(2 downto 0);
        LEDR     : out std_logic_vector(9 downto 0);
        HEX0     : out std_logic_vector(6 downto 0)
    );
end pratica7_de0cv;

architecture estrutural of pratica7_de0cv is
    signal clk_pwm : std_logic;                      -- clock da FSM (~7 kHz)
    signal reset   : std_logic;
    signal y       : std_logic;                      -- saida PWM
    signal valor   : std_logic_vector(3 downto 0);   -- x com 4 bits, para o display
begin
    reset <= not KEY(0);             -- botao solto = '1', apertado = '0'

    -- 50 MHz / (2 * 3_571) = ~7 kHz
    u_div : entity work.div_clk
        generic map (DIVISOR => 3_571)
        port map (clk_in => CLOCK_50, clk_out => clk_pwm);

    u_fsm : entity work.pratica7
        port map (clk => clk_pwm, reset => reset, x => SW, y => y);

    valor <= '0' & SW;               -- completa x (3 bits) com um '0' a esquerda

    u_hex : entity work.hex7seg
        port map (valor => valor, seg => HEX0);

    LEDR(0)          <= y;                   -- o LED "dimerizado"
    LEDR(6 downto 1) <= (others => '0');     -- LEDs nao usados ficam apagados
    LEDR(9 downto 7) <= SW;                  -- mostra as chaves
end estrutural;
