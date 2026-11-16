-- Pratica 2: motor de passo unipolar no modo wave (uma fase por vez)
--   reset   : volta ao estado inicial (fase A)
--   clk     : define a velocidade do motor
--   sentido : '0' = horario (A->B->C->D), '1' = anti-horario (A->D->C->B)
--   a,b,c,d : fases 1 a 4
-- Maquina de Moore.
library ieee;
use ieee.std_logic_1164.all;

entity pratica2 is
    port (
        clk     : in  std_logic;
        reset   : in  std_logic;
        sentido : in  std_logic;
        a, b, c, d : out std_logic
    );
end pratica2;

architecture fsm of pratica2 is
    type estado_t is (FA, FB, FC, FD);
    signal estado : estado_t;
begin

    process (clk, reset)
    begin
        if reset = '1' then
            estado <= FA;
        elsif rising_edge(clk) then
            case estado is
                when FA => if sentido = '0' then estado <= FB; else estado <= FD; end if;
                when FB => if sentido = '0' then estado <= FC; else estado <= FA; end if;
                when FC => if sentido = '0' then estado <= FD; else estado <= FB; end if;
                when FD => if sentido = '0' then estado <= FA; else estado <= FC; end if;
            end case;
        end if;
    end process;

    -- Saidas (Moore): apenas uma fase ativa em cada estado
    a <= '1' when estado = FA else '0';
    b <= '1' when estado = FB else '0';
    c <= '1' when estado = FC else '0';
    d <= '1' when estado = FD else '0';

end fsm;
