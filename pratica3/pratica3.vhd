-- Pratica 3: gerador de sinal
-- y fica 2 ciclos de clock em nivel baixo (2T0) e 6 ciclos em nivel alto (6T0).
-- Periodo total = 8 ciclos -> 8 estados. Maquina de Moore.
library ieee;
use ieee.std_logic_1164.all;

entity pratica3 is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        y     : out std_logic
    );
end pratica3;

architecture fsm of pratica3 is
    type estado_t is (L1, L2, H1, H2, H3, H4, H5, H6);
    signal estado : estado_t;
begin

    process (clk, reset)
    begin
        if reset = '1' then
            estado <= L1;
        elsif rising_edge(clk) then
            case estado is
                when L1 => estado <= L2;
                when L2 => estado <= H1;
                when H1 => estado <= H2;
                when H2 => estado <= H3;
                when H3 => estado <= H4;
                when H4 => estado <= H5;
                when H5 => estado <= H6;
                when H6 => estado <= L1;
            end case;
        end if;
    end process;

    -- Saida (Moore): baixa em L1 e L2, alta nos outros 6 estados
    y <= '0' when (estado = L1 or estado = L2) else '1';

end fsm;
