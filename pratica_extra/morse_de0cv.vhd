-- =====================================================================
-- Pratica Extra na placa DE0-CV: Conversor Morse
--
--   KEY(0)     : reset
--   KEY(1)     : botao Morse  (codificar: envia a letra;
--                              decodificar: tecla pontos e tracos)
--   KEY(2)     : botao de FUNCAO (troca codificar <-> decodificar)
--   SW(4..0)   : letra a codificar, em binario (0 = A, 1 = B, ... 25 = Z)
--
--   LEDR(0)    : sinal Morse (codificar: piscadas; decodificar: eco do botao)
--   LEDR(1)    : decodificar: acende quando o aperto ja conta como traco
--   LEDR(5..2) : decodificar: um LED por simbolo ja digitado
--   LEDR(9)    : modo (apagado = codificar, aceso = decodificar)
--   HEX0       : letra (das chaves ou a decodificada)
--   HEX1       : modo, "C" = codificar ou "d" = decodificar
--   GPIO_0(0)  : mesmo sinal de LEDR(0), para ligar um buzzer ativo
--
-- Clock das FSMs: 100 Hz (um tick a cada 10 ms).
--   Codificar  : unidade Morse = 20 ticks = 200 ms (ponto 0,2 s; traco 0,6 s)
--   Decodificar: aperto >= 30 ticks (0,3 s) e traco; pausa de 100 ticks (1 s)
--                fecha a letra.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.morse_pkg.all;

entity morse_de0cv is
    port (
        CLOCK_50 : in  std_logic;
        KEY      : in  std_logic_vector(2 downto 0);
        SW       : in  std_logic_vector(4 downto 0);
        LEDR     : out std_logic_vector(9 downto 0);
        HEX0     : out std_logic_vector(6 downto 0);
        HEX1     : out std_logic_vector(6 downto 0);
        GPIO_0   : out std_logic_vector(0 downto 0)
    );
end morse_de0cv;

architecture estrutural of morse_de0cv is
    signal clk      : std_logic;                     -- 100 Hz
    signal reset    : std_logic;
    -- Sincronizadores dos botoes (2 flip-flops em serie, ver abaixo)
    signal btn_meio, btn   : std_logic := '0';
    signal func_meio, func : std_logic := '0';

    signal modo_dec : std_logic;
    signal sinal    : std_logic;
    signal traco    : std_logic;
    signal simbolos : natural range 0 to 5;
    signal letra    : std_logic_vector(4 downto 0);
begin
    reset <= not KEY(0);              -- botoes da DE0-CV: solto = '1', apertado = '0'

    -- 50 MHz / (2 * 250_000) = 100 Hz
    u_div : entity work.div_clk
        generic map (DIVISOR => 250_000)
        port map (clk_in => CLOCK_50, clk_out => clk);

    -- -----------------------------------------------------------------
    -- Sincronizador: o botao muda em qualquer instante, sem respeitar o
    -- clock. Se ele mudar bem na borda, o flip-flop pode ficar um tempo
    -- "indeciso" (metaestabilidade). Passar por 2 flip-flops da tempo
    -- para o valor se firmar antes de chegar nas FSMs. Como o clock e de
    -- 100 Hz (amostra a cada 10 ms), isso tambem ignora o repique do botao.
    -- -----------------------------------------------------------------
    process (clk)
    begin
        if rising_edge(clk) then
            btn_meio  <= not KEY(1);
            btn       <= btn_meio;
            func_meio <= not KEY(2);
            func      <= func_meio;
        end if;
    end process;

    u_morse : entity work.morse
        generic map (UNIDADE => 20, LIMIAR_TRACO => 30, FIM_LETRA => 100)
        port map (
            clk      => clk,
            reset    => reset,
            func     => func,
            btn      => btn,
            letra_sw => SW,
            modo_dec => modo_dec,
            sinal    => sinal,
            traco    => traco,
            simbolos => simbolos,
            letra    => letra
        );

    -- Displays
    HEX0 <= letra_7seg(to_integer(unsigned(letra)));
    HEX1 <= letra_7seg(3) when modo_dec = '1' else letra_7seg(2);   -- "d" ou "C"

    -- LEDs
    LEDR(0) <= sinal;
    LEDR(1) <= traco;
    -- "Termometro": acende tantos LEDs quantos simbolos ja foram digitados.
    LEDR(2) <= '1' when simbolos >= 1 else '0';
    LEDR(3) <= '1' when simbolos >= 2 else '0';
    LEDR(4) <= '1' when simbolos >= 3 else '0';
    LEDR(5) <= '1' when simbolos >= 4 else '0';
    LEDR(8 downto 6) <= (others => '0');
    LEDR(9) <= modo_dec;

    GPIO_0(0) <= sinal;
end estrutural;
