-- =====================================================================
-- Pratica 7: PWM digital com ciclo de trabalho x/7
--
-- O periodo do PWM tem 7 ciclos de clock, entao a maquina tem 7
-- estados (E0..E6) que se repetem em fila; o estado diz em qual ciclo
-- do periodo estamos. A entrada x (0 a 7) diz quantos desses 7 ciclos
-- a saida y fica em '1'.
--
-- Como na figura do slide, y fica baixo no INICIO do periodo e alto
-- nos ULTIMOS x ciclos. Exemplo com x = 2 (2/7 = 28,6%):
--
--   estado:  E0 E1 E2 E3 E4 E5 E6 | E0 ...
--   y:        0  0  0  0  0  1  1 |  0 ...
--
-- Regra geral: y = '1' quando  indice do estado >= 7 - x
--   x = 0 -> nunca (0%)        x = 7 -> sempre (100%)
--
-- Maquina de MEALY: a saida depende do estado E da entrada x. Por isso
-- y responde na hora a uma mudanca de x, sem esperar o clock.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;      -- unsigned e to_integer, para tratar x como numero

entity pratica7 is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;                      -- assincrono, ativo em '1'
        x     : in  std_logic_vector(2 downto 0);   -- ciclo de trabalho (0..7)
        y     : out std_logic                       -- saida PWM
    );
end pratica7;

architecture fsm of pratica7 is
    type estado_t is (E0, E1, E2, E3, E4, E5, E6);
    signal estado : estado_t;
begin

    -- Registrador de estado + proximo estado: percorre os 7 estados em
    -- fila, um por borda de clock. A entrada x NAO altera as transicoes.
    process (clk, reset)
    begin
        if reset = '1' then
            estado <= E0;
        elsif rising_edge(clk) then
            case estado is
                when E0 => estado <= E1;
                when E1 => estado <= E2;
                when E2 => estado <= E3;
                when E3 => estado <= E4;
                when E4 => estado <= E5;
                when E5 => estado <= E6;
                when E6 => estado <= E0;   -- fim do periodo do PWM
            end case;
        end if;
    end process;

    -- Saida (Mealy), combinacional:
    --   estado_t'pos(estado)     -> posicao do estado no tipo (E0 = 0 ... E6 = 6)
    --   to_integer(unsigned(x))  -> x convertido de vetor de bits para inteiro
    -- y fica alto quando a posicao atual ja entrou nos ultimos x ciclos.
    y <= '1' when estado_t'pos(estado) >= 7 - to_integer(unsigned(x)) else '0';

end fsm;
