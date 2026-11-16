-- Pratica 6 na placa DE0-CV
--   KEY(0)     : reset (ativo em '0')
--   SW(0)      : sentido S ('0' crescente, '1' decrescente)
--   LEDR(1..0) : contagem em binario
--   HEX0       : contagem em decimal
-- Clock da FSM = 1 Hz.
library ieee;
use ieee.std_logic_1164.all;

entity pratica6_de0cv is
    port (
        CLOCK_50 : in  std_logic;
        KEY      : in  std_logic_vector(0 downto 0);
        SW       : in  std_logic_vector(0 downto 0);
        LEDR     : out std_logic_vector(1 downto 0);
        HEX0     : out std_logic_vector(6 downto 0)
    );
end pratica6_de0cv;

architecture estrutural of pratica6_de0cv is
    signal clk_lento : std_logic;
    signal reset     : std_logic;
    signal q         : std_logic_vector(1 downto 0);
    signal valor     : std_logic_vector(3 downto 0);
begin
    reset <= not KEY(0);

    u_div : entity work.div_clk
        generic map (DIVISOR => 25_000_000)          -- 50 MHz -> 1 Hz
        port map (clk_in => CLOCK_50, clk_out => clk_lento);

    u_fsm : entity work.pratica6
        port map (clk => clk_lento, reset => reset, s => SW(0), q => q);

    valor <= "00" & q;

    u_hex : entity work.hex7seg
        port map (valor => valor, seg => HEX0);

    LEDR <= q;
end estrutural;
