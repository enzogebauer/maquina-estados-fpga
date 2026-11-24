-- =====================================================================
-- Pratica Extra: Conversor Morse - pacote com as tabelas
--
-- Um "package" em VHDL guarda constantes, tipos e funcoes que varios
-- arquivos usam. Aqui ficam:
--   1) a tabela do codigo Morse (letra -> pontos e tracos);
--   2) a funcao que faz o caminho inverso (pontos e tracos -> letra);
--   3) a tabela das letras no display de 7 segmentos.
--
-- Nada aqui e maquina de estados: e tudo logica COMBINACIONAL (tabelas).
-- As FSMs (codificador, decodificador e seletor de modo) so consultam.
--
-- Como uma letra Morse e guardada (2 campos):
--   tam    : quantos simbolos a letra tem (1 a 4)
--   padrao : os simbolos, '0' = ponto e '1' = traco, ALINHADOS A
--            DIREITA. O primeiro simbolo fica no bit (tam - 1) e o
--            ultimo no bit 0. Bits acima de (tam - 1) ficam em '0'.
--
--   Exemplo: A = ".-"  -> tam = 2, padrao = "0001"
--                                              ^^ bit1 = '0' (ponto), bit0 = '1' (traco)
--            D = "-.." -> tam = 3, padrao = "0100"
--
-- Por que guardar "tam" separado? Porque so o padrao nao basta:
-- E = "." , I = "..", S = "..." e H = "...." tem todos padrao "0000".
-- O que diferencia uma letra da outra e a quantidade de simbolos.
--
-- Codigo das letras usado no projeto (5 bits, igual as chaves SW4..0):
--   0 = A, 1 = B, ... , 25 = Z
--   26 a 30 = invalido (display mostra "-")
--   31      = nada (display apagado)
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package morse_pkg is

    constant LETRA_INVALIDA : natural := 30;   -- sequencia que nao e letra
    constant LETRA_VAZIA    : natural := 31;   -- ainda nao ha letra

    -- "record" agrupa campos, como um struct em C.
    type morse_t is record
        tam    : natural range 0 to 4;
        padrao : std_logic_vector(3 downto 0);
    end record;

    type tabela_morse_t is array (0 to 25) of morse_t;

    -- Tabela do codigo Morse internacional, de A (0) a Z (25).
    constant TABELA_MORSE : tabela_morse_t := (
         0 => (tam => 2, padrao => "0001"),   -- A  .-
         1 => (tam => 4, padrao => "1000"),   -- B  -...
         2 => (tam => 4, padrao => "1010"),   -- C  -.-.
         3 => (tam => 3, padrao => "0100"),   -- D  -..
         4 => (tam => 1, padrao => "0000"),   -- E  .
         5 => (tam => 4, padrao => "0010"),   -- F  ..-.
         6 => (tam => 3, padrao => "0110"),   -- G  --.
         7 => (tam => 4, padrao => "0000"),   -- H  ....
         8 => (tam => 2, padrao => "0000"),   -- I  ..
         9 => (tam => 4, padrao => "0111"),   -- J  .---
        10 => (tam => 3, padrao => "0101"),   -- K  -.-
        11 => (tam => 4, padrao => "0100"),   -- L  .-..
        12 => (tam => 2, padrao => "0011"),   -- M  --
        13 => (tam => 2, padrao => "0010"),   -- N  -.
        14 => (tam => 3, padrao => "0111"),   -- O  ---
        15 => (tam => 4, padrao => "0110"),   -- P  .--.
        16 => (tam => 4, padrao => "1101"),   -- Q  --.-
        17 => (tam => 3, padrao => "0010"),   -- R  .-.
        18 => (tam => 3, padrao => "0000"),   -- S  ...
        19 => (tam => 1, padrao => "0001"),   -- T  -
        20 => (tam => 3, padrao => "0001"),   -- U  ..-
        21 => (tam => 4, padrao => "0001"),   -- V  ...-
        22 => (tam => 3, padrao => "0011"),   -- W  .--
        23 => (tam => 4, padrao => "1001"),   -- X  -..-
        24 => (tam => 4, padrao => "1011"),   -- Y  -.--
        25 => (tam => 4, padrao => "1100")    -- Z  --..
    );

    -- Pontos e tracos -> codigo da letra (0..25) ou LETRA_INVALIDA.
    function decodifica(tam : natural; padrao : std_logic_vector(3 downto 0))
        return natural;

    -- Codigo da letra (0..31) -> segmentos do display (ativos em '0').
    function letra_7seg(codigo : natural) return std_logic_vector;

end package morse_pkg;


package body morse_pkg is

    function decodifica(tam : natural; padrao : std_logic_vector(3 downto 0))
        return natural is
    begin
        -- Procura a letra na tabela. Em hardware esse "for" NAO e um laco
        -- que roda no tempo: o sintetizador cria 26 comparadores em
        -- paralelo (um por letra), e o resultado sai de uma vez.
        for i in TABELA_MORSE'range loop
            if TABELA_MORSE(i).tam = tam and TABELA_MORSE(i).padrao = padrao then
                return i;
            end if;
        end loop;
        return LETRA_INVALIDA;   -- 5 simbolos, ou combinacao sem letra (ex.: "..--")
    end function;

    function letra_7seg(codigo : natural) return std_logic_vector is
        -- Mesma convencao do hex7seg.vhd: "gfedcba", '0' acende.
        -- Varias letras sao APROXIMACOES (K, M, W, X), porque 7 segmentos
        -- nao desenham todas as letras. Algumas saem em minuscula (b, d, n, r, t).
        type tabela_seg_t is array (0 to 25) of std_logic_vector(6 downto 0);
        constant SEG : tabela_seg_t := (
             0 => "0001000",   -- A
             1 => "0000011",   -- b
             2 => "1000110",   -- C
             3 => "0100001",   -- d
             4 => "0000110",   -- E
             5 => "0001110",   -- F
             6 => "1000010",   -- G
             7 => "0001001",   -- H
             8 => "1001111",   -- I (barra a esquerda)
             9 => "1100001",   -- J
            10 => "0001010",   -- K (aproximado)
            11 => "1000111",   -- L
            12 => "1001000",   -- M (aproximado: "n" com teto)
            13 => "0101011",   -- n
            14 => "1000000",   -- O
            15 => "0001100",   -- P
            16 => "0011000",   -- q
            17 => "0101111",   -- r
            18 => "0010010",   -- S
            19 => "0000111",   -- t
            20 => "1000001",   -- U
            21 => "1100011",   -- v (u minusculo)
            22 => "1010101",   -- W (aproximado)
            23 => "0110110",   -- X (aproximado: tres barras)
            24 => "0010001",   -- y
            25 => "0100100"    -- Z
        );
    begin
        if codigo <= 25 then
            return SEG(codigo);
        elsif codigo = LETRA_VAZIA then
            return "1111111";            -- tudo apagado
        else
            return "0111111";            -- so o segmento g: "-"
        end if;
    end function;

end package body morse_pkg;
