-- =====================================================================
-- Pratica 2: motor de passo unipolar no modo WAVE
--
-- No modo wave apenas UMA bobina (fase) fica energizada por vez.
-- Cada estado da maquina corresponde a uma fase ligada:
--
--   FA: a=1   FB: b=1   FC: c=1   FD: d=1
--
--   sentido = '0' (horario)      : FA -> FB -> FC -> FD -> FA ...
--   sentido = '1' (anti-horario) : FA -> FD -> FC -> FB -> FA ...
--
--   reset : volta ao estado inicial (fase A)
--   clk   : cada borda de subida e um passo; a frequencia do clock
--           define a velocidade do motor
--
-- Maquina de MOORE: as saidas dependem so do estado. A entrada
-- "sentido" influencia apenas qual sera o PROXIMO estado.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;

entity pratica2 is
    port (
        clk     : in  std_logic;
        reset   : in  std_logic;        -- assincrono, ativo em '1'
        sentido : in  std_logic;
        a, b, c, d : out std_logic      -- fases 1 a 4 do motor
    );
end pratica2;

architecture fsm of pratica2 is
    type estado_t is (FA, FB, FC, FD);  -- um estado por fase energizada
    signal estado : estado_t;
begin

    -- Registrador de estado + logica de proximo estado
    process (clk, reset)
    begin
        if reset = '1' then
            estado <= FA;                       -- estado inicial: fase A
        elsif rising_edge(clk) then
            -- Em cada estado, "sentido" decide entre o vizinho da frente
            -- (horario) e o vizinho de tras (anti-horario).
            case estado is
                when FA => if sentido = '0' then estado <= FB; else estado <= FD; end if;
                when FB => if sentido = '0' then estado <= FC; else estado <= FA; end if;
                when FC => if sentido = '0' then estado <= FD; else estado <= FB; end if;
                when FD => if sentido = '0' then estado <= FA; else estado <= FC; end if;
            end case;
        end if;
    end process;

    -- Saidas (Moore): cada fase so vale '1' no seu proprio estado,
    -- garantindo que nunca ha duas bobinas ligadas ao mesmo tempo.
    a <= '1' when estado = FA else '0';
    b <= '1' when estado = FB else '0';
    c <= '1' when estado = FC else '0';
    d <= '1' when estado = FD else '0';

end fsm;
