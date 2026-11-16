-- =====================================================================
-- Pratica 1 na placa DE0-CV (top-level do projeto Quartus)
--
-- Este arquivo nao tem logica de maquina de estados: ele so liga a FSM
-- (pratica1.vhd) aos recursos fisicos da placa.
--
--   CLOCK_50   : clock de 50 MHz da placa
--   KEY(0)     : reset (botao)
--   LEDR(2..0) : contagem em binario
--   HEX0       : contagem em decimal
--
-- Os nomes das portas (CLOCK_50, KEY, LEDR, HEX0) sao os mesmos usados
-- no arquivo .qsf para associar cada sinal a um pino do FPGA.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;

entity pratica1_de0cv is
    port (
        CLOCK_50 : in  std_logic;
        KEY      : in  std_logic_vector(0 downto 0);
        LEDR     : out std_logic_vector(2 downto 0);
        HEX0     : out std_logic_vector(6 downto 0)
    );
end pratica1_de0cv;

architecture estrutural of pratica1_de0cv is
    signal clk_lento : std_logic;                      -- clock de 1 Hz para a FSM
    signal reset     : std_logic;                      -- reset ativo em '1'
    signal q         : std_logic_vector(2 downto 0);   -- saida da FSM
    signal valor     : std_logic_vector(3 downto 0);   -- q com 4 bits, para o display
begin
    -- Os botoes da DE0-CV valem '1' soltos e '0' apertados. A FSM espera
    -- reset ativo em '1', por isso a inversao.
    reset <= not KEY(0);

    -- Divisor de clock: 50 MHz / (2 * 25_000_000) = 1 Hz.
    -- "entity work.xxx" instancia direto a entidade, sem declarar component.
    u_div : entity work.div_clk
        generic map (DIVISOR => 25_000_000)
        port map (clk_in => CLOCK_50, clk_out => clk_lento);

    -- A maquina de estados da pratica, rodando no clock lento.
    u_fsm : entity work.pratica1
        port map (clk => clk_lento, reset => reset, q => q);

    -- O decodificador recebe 4 bits; completa q (3 bits) com um '0' a esquerda.
    valor <= '0' & q;

    u_hex : entity work.hex7seg
        port map (valor => valor, seg => HEX0);

    LEDR <= q;   -- mostra a mesma contagem em binario nos LEDs
end estrutural;
