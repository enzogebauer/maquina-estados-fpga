-- =====================================================================
-- Pratica 1: contador modulo 6 (0 a 5)
--
-- Maquina de MOORE: a saida depende apenas do estado atual.
-- Cada valor da contagem e um estado: S0 -> S1 -> ... -> S5 -> S0.
-- Nao ha entrada de controle; a cada borda de subida do clock a
-- maquina simplesmente avanca para o proximo estado.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;   -- define std_logic e std_logic_vector

entity pratica1 is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;                     -- assincrono, ativo em '1'
        q     : out std_logic_vector(2 downto 0)   -- contagem 0..5 (3 bits)
    );
end pratica1;

architecture fsm of pratica1 is
    -- Tipo enumerado: da um nome a cada estado, como no slide da aula.
    -- O Quartus reconhece esse padrao como maquina de estados e escolhe
    -- sozinho a codificacao em bits (ver Tools > Netlist Viewers >
    -- State Machine Viewer).
    type estado_t is (S0, S1, S2, S3, S4, S5);
    signal estado : estado_t;   -- registrador que guarda o estado atual
begin

    -- Processo sequencial: registrador de estado + logica de proximo estado.
    -- A lista de sensibilidade tem clk e reset porque o reset e assincrono
    -- (age na hora, sem esperar o clock).
    process (clk, reset)
    begin
        if reset = '1' then
            estado <= S0;                  -- reset tem prioridade: volta ao 0
        elsif rising_edge(clk) then        -- so muda de estado na borda de subida
            case estado is
                when S0 => estado <= S1;
                when S1 => estado <= S2;
                when S2 => estado <= S3;
                when S3 => estado <= S4;
                when S4 => estado <= S5;
                when S5 => estado <= S0;   -- depois do 5 volta ao 0 (modulo 6)
            end case;
        end if;
    end process;

    -- Logica de saida (Moore): combinacional, traduz o estado para o
    -- numero binario correspondente. Fica fora do processo com clock.
    with estado select
        q <= "000" when S0,
             "001" when S1,
             "010" when S2,
             "011" when S3,
             "100" when S4,
             "101" when S5;

end fsm;
