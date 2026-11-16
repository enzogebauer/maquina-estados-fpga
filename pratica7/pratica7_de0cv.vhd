-- Pratica 7 na placa DE0-CV: controle de luminosidade do LED por PWM
--   KEY(0)     : reset (ativo em '0')
--   SW(2..0)   : x (ciclo de trabalho = x/7)
--   LEDR(0)    : LED com brilho controlado pelo PWM
--   LEDR(9..7) : mostra o valor de x
--   HEX0       : mostra x em decimal
-- Clock da FSM ~ 7 kHz -> PWM ~ 1 kHz (rapido o bastante para o olho
-- ver brilho constante em vez de piscar).
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
    signal clk_pwm : std_logic;
    signal reset   : std_logic;
    signal y       : std_logic;
    signal valor   : std_logic_vector(3 downto 0);
begin
    reset <= not KEY(0);

    u_div : entity work.div_clk
        generic map (DIVISOR => 3_571)               -- 50 MHz -> ~7 kHz
        port map (clk_in => CLOCK_50, clk_out => clk_pwm);

    u_fsm : entity work.pratica7
        port map (clk => clk_pwm, reset => reset, x => SW, y => y);

    valor <= '0' & SW;

    u_hex : entity work.hex7seg
        port map (valor => valor, seg => HEX0);

    LEDR(0)          <= y;
    LEDR(6 downto 1) <= (others => '0');
    LEDR(9 downto 7) <= SW;
end estrutural;
