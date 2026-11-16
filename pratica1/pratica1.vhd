-- Pratica 1: contador modulo 6 (0 a 5)
-- Maquina de Moore: a saida depende apenas do estado atual.
library ieee;
use ieee.std_logic_1164.all;

entity pratica1 is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;                     -- assincrono, ativo em '1'
        q     : out std_logic_vector(2 downto 0)   -- contagem 0..5
    );
end pratica1;

architecture fsm of pratica1 is
    type estado_t is (S0, S1, S2, S3, S4, S5);
    signal estado : estado_t;
begin

    -- Registrador de estado + logica de proximo estado
    process (clk, reset)
    begin
        if reset = '1' then
            estado <= S0;
        elsif rising_edge(clk) then
            case estado is
                when S0 => estado <= S1;
                when S1 => estado <= S2;
                when S2 => estado <= S3;
                when S3 => estado <= S4;
                when S4 => estado <= S5;
                when S5 => estado <= S0;
            end case;
        end if;
    end process;

    -- Logica de saida (Moore)
    with estado select
        q <= "000" when S0,
             "001" when S1,
             "010" when S2,
             "011" when S3,
             "100" when S4,
             "101" when S5;

end fsm;
