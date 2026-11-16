-- Testbench da Pratica 1 (contador modulo 6)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_pratica1 is
end tb_pratica1;

architecture sim of tb_pratica1 is
    constant T : time := 20 ns;
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';
    signal q     : std_logic_vector(2 downto 0);
    signal fim   : boolean := false;
begin
    dut : entity work.pratica1
        port map (clk => clk, reset => reset, q => q);

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
        -- reset inicial
        reset <= '1';
        wait for 5 ns;
        reset <= '0';

        -- duas voltas completas e mais um pouco: 0,1,2,3,4,5,0,1,...
        -- (na borda de subida ainda se le o valor do ciclo que esta terminando)
        for i in 0 to 14 loop
            wait until rising_edge(clk);
            assert q = std_logic_vector(to_unsigned(i mod 6, 3))
                report "contagem errada no ciclo " & integer'image(i)
                severity error;
        end loop;

        -- reset no meio da contagem volta para 0
        wait for 3 ns;
        reset <= '1';
        wait for 4 ns;
        assert q = "000" report "reset nao zerou o contador" severity error;
        reset <= '0';

        for i in 0 to 7 loop
            wait until rising_edge(clk);
            assert q = std_logic_vector(to_unsigned(i mod 6, 3))
                report "contagem errada apos o reset, ciclo " & integer'image(i)
                severity error;
        end loop;

        report "FIM DA SIMULACAO - pratica 1" severity note;
        fim <= true;
        wait;
    end process;
end sim;
