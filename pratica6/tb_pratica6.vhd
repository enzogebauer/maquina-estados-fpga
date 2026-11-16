-- =====================================================================
-- Testbench da Pratica 6 (contador modulo 4 com sentido)
--
-- Conta para cima (s = '0'), depois troca o sentido no meio do caminho
-- (s = '1') e confere a contagem para baixo, incluindo as "voltas"
-- 3 -> 0 e 0 -> 3.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;

entity tb_pratica6 is
end tb_pratica6;

architecture sim of tb_pratica6 is
    constant T : time := 20 ns;
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';
    signal s     : std_logic := '0';
    signal q     : std_logic_vector(1 downto 0);
    signal fim   : boolean := false;

    -- Valores esperados apos cada borda de clock.
    type vet_t is array (natural range <>) of std_logic_vector(1 downto 0);
    --   crescente a partir de 0: 1, 2, 3, 0, 1, 2
    constant CRESCE   : vet_t := ("01", "10", "11", "00", "01", "10");
    --   decrescente a partir de 2 (onde a subida parou): 1, 0, 3, 2, 1, 0, 3
    constant DECRESCE : vet_t := ("01", "00", "11", "10", "01", "00", "11");
begin
    dut : entity work.pratica6
        port map (clk => clk, reset => reset, s => s, q => q);

    -- Gerador de clock (para quando fim = true)
    relogio : process
    begin
        while not fim loop
            clk <= '0'; wait for T / 2;
            clk <= '1'; wait for T / 2;
        end loop;
        wait;
    end process;

    estimulos : process
    begin
        wait for 5 ns;
        assert q = "00" report "reset deveria levar a 0" severity error;
        reset <= '0';

        s <= '0';                                  -- crescente
        for i in CRESCE'range loop
            wait until rising_edge(clk); wait for 1 ns;   -- le 1 ns apos a borda
            assert q = CRESCE(i) report "crescente errado no passo " & integer'image(i) severity error;
        end loop;

        s <= '1';                                  -- decrescente
        for i in DECRESCE'range loop
            wait until rising_edge(clk); wait for 1 ns;
            assert q = DECRESCE(i) report "decrescente errado no passo " & integer'image(i) severity error;
        end loop;

        report "FIM DA SIMULACAO - pratica 6" severity note;
        fim <= true;
        wait;
    end process;
end sim;
