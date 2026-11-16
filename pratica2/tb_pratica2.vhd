-- Testbench da Pratica 2 (motor de passo, modo wave)
library ieee;
use ieee.std_logic_1164.all;

entity tb_pratica2 is
end tb_pratica2;

architecture sim of tb_pratica2 is
    constant T : time := 20 ns;
    signal clk     : std_logic := '0';
    signal reset   : std_logic := '1';
    signal sentido : std_logic := '0';
    signal a, b, c, d : std_logic;
    signal fases   : std_logic_vector(3 downto 0);
    signal fim     : boolean := false;

    type vet_t is array (natural range <>) of std_logic_vector(3 downto 0);
    -- fases = A & B & C & D
    constant HORARIO     : vet_t := ("0100", "0010", "0001", "1000", "0100", "0010", "0001", "1000");
    constant ANTIHORARIO : vet_t := ("0001", "0010", "0100", "1000", "0001", "0010", "0100", "1000");
begin
    dut : entity work.pratica2
        port map (clk => clk, reset => reset, sentido => sentido,
                  a => a, b => b, c => c, d => d);

    fases <= a & b & c & d;

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
        wait for 15 ns;
        assert fases = "1000" report "estado inicial deveria ser a fase A" severity error;
        reset <= '0';

        -- sentido horario
        sentido <= '0';
        for i in HORARIO'range loop
            wait until rising_edge(clk); wait for 1 ns;
            assert fases = HORARIO(i)
                report "horario: fase errada no passo " & integer'image(i) severity error;
        end loop;

        -- sentido anti-horario (parte da fase A)
        sentido <= '1';
        for i in ANTIHORARIO'range loop
            wait until rising_edge(clk); wait for 1 ns;
            assert fases = ANTIHORARIO(i)
                report "anti-horario: fase errada no passo " & integer'image(i) severity error;
        end loop;

        -- reset no meio do movimento
        sentido <= '0';
        wait until rising_edge(clk); wait for 1 ns;   -- vai para B
        reset <= '1'; wait for 2 ns;
        assert fases = "1000" report "reset nao voltou para a fase A" severity error;
        reset <= '0';
        wait for 3 * T;

        report "FIM DA SIMULACAO - pratica 2" severity note;
        fim <= true;
        wait;
    end process;
end sim;
