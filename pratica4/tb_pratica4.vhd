-- =====================================================================
-- Testbench da Pratica 4 (contador Gray 2 bits progressivo/regressivo)
--
-- Primeiro conta para frente (x = '1'), depois inverte o sentido
-- (x = '0') e confere a sequencia de tras para frente.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;

entity tb_pratica4 is
end tb_pratica4;

architecture sim of tb_pratica4 is
    constant T : time := 20 ns;
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';
    signal x     : std_logic := '1';
    signal q     : std_logic_vector(1 downto 0);
    signal fim   : boolean := false;

    -- Valores esperados apos cada borda de clock.
    type vet_t is array (natural range <>) of std_logic_vector(1 downto 0);
    --   subindo a partir de 00: 01, 11, 10, 00, 01, 11
    constant SOBE  : vet_t := ("01", "11", "10", "00", "01", "11");
    --   descendo a partir de 11 (onde a subida parou): 01, 00, 10, 11, 01, 00, 10
    constant DESCE : vet_t := ("01", "00", "10", "11", "01", "00", "10");
begin
    dut : entity work.pratica4
        port map (clk => clk, reset => reset, x => x, q => q);

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
        assert q = "00" report "reset deveria levar a 00" severity error;
        reset <= '0';

        x <= '1';                                  -- progressivo
        for i in SOBE'range loop
            wait until rising_edge(clk); wait for 1 ns;   -- le 1 ns apos a borda
            assert q = SOBE(i) report "subida errada no passo " & integer'image(i) severity error;
        end loop;

        x <= '0';                                  -- regressivo
        for i in DESCE'range loop
            wait until rising_edge(clk); wait for 1 ns;
            assert q = DESCE(i) report "descida errada no passo " & integer'image(i) severity error;
        end loop;

        report "FIM DA SIMULACAO - pratica 4" severity note;
        fim <= true;
        wait;
    end process;
end sim;
