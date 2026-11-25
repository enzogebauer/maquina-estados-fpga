-- =====================================================================
-- Pratica 7 na placa DE0-CV: controle de luminosidade do LED por PWM
--
--   KEY(0)     : reset (botao)
--   SW(2..0)   : x em binario (ciclo de trabalho = x/7)
--   LEDR(0)    : LED com brilho controlado pelo PWM
--   LEDR(9..7) : repetem as chaves, para conferir o valor de x
--   HEX0       : mostra x em decimal
--
-- Clock da FSM ~ 8,3 Hz (cada ciclo dura 0,12 s). Como o periodo do
-- PWM tem 7 ciclos, o periodo inteiro dura ~0,84 s (~1,2 Hz). Nessa
-- velocidade da para VER o LED piscar: em cada periodo ele fica aceso
-- durante x dos 7 ciclos (x = 0 sempre apagado, x = 7 sempre aceso).
--
-- Com um clock bem mais rapido (ex.: DIVISOR => 3_571, ~7 kHz) o LED
-- piscaria rapido demais para o olho, que enxergaria so a MEDIA: o
-- brilho pareceria mudar conforme x.
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
    signal clk_pwm : std_logic;                      -- clock da FSM (~8,3 Hz)
    signal reset   : std_logic;
    signal y       : std_logic;                      -- saida PWM
    signal valor   : std_logic_vector(3 downto 0);   -- x com 4 bits, para o display
begin
    reset <= not KEY(0);             -- botao solto = '1', apertado = '0'

    -- 50 MHz / (2 * 3_000_000) = ~8,3 Hz
    u_div : entity work.div_clk
        generic map (DIVISOR => 3_000_000)
        port map (clk_in => CLOCK_50, clk_out => clk_pwm);

    u_fsm : entity work.pratica7
        port map (clk => clk_pwm, reset => reset, x => SW, y => y);

    valor <= '0' & SW;               -- completa x (3 bits) com um '0' a esquerda

    u_hex : entity work.hex7seg
        port map (valor => valor, seg => HEX0);

    LEDR(0)          <= y;                   -- saida PWM
    LEDR(6 downto 1) <= (others => '0');     -- LEDs nao usados ficam apagados
    LEDR(9 downto 7) <= SW;                  -- mostra as chaves
end estrutural;
