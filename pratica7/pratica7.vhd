-- Pratica 7: PWM digital com ciclo de trabalho x/7
-- O periodo do PWM tem 7 ciclos de clock -> 7 estados (E0..E6).
-- Como na figura do slide, y fica baixo no inicio do periodo e alto
-- nos ultimos x ciclos:  y = '1' quando indice(estado) >= 7 - x.
--   x = 0 -> 0/7 (0%)   ...   x = 2 -> 2/7 (28,6%)   ...   x = 7 -> 7/7 (100%)
-- Maquina de Mealy: a saida depende do estado e da entrada x.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pratica7 is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        x     : in  std_logic_vector(2 downto 0);
        y     : out std_logic
    );
end pratica7;

architecture fsm of pratica7 is
    type estado_t is (E0, E1, E2, E3, E4, E5, E6);
    signal estado : estado_t;
begin

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
                when E6 => estado <= E0;
            end case;
        end if;
    end process;

    -- Saida (Mealy): compara a posicao do estado com o ciclo de trabalho
    y <= '1' when estado_t'pos(estado) >= 7 - to_integer(unsigned(x)) else '0';

end fsm;
