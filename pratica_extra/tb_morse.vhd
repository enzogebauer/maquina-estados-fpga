-- =====================================================================
-- Testbench da Pratica Extra (Conversor Morse)
--
-- Usa tempos CURTOS (generics) para a simulacao ficar rapida:
--   UNIDADE = 2 ticks      -> ponto = 2 clocks, traco = 6 clocks
--   LIMIAR_TRACO = 4 ticks -> aperto de 5 clocks ou mais vira traco
--   FIM_LETRA = 8 ticks    -> 8 clocks com o botao solto fecham a letra
-- Na placa os mesmos blocos usam 20 / 30 / 100 (ver morse_de0cv.vhd).
--
-- O que e conferido:
--   1) Modo codificar: as piscadas de varias letras, tick a tick.
--   2) Segurar o botao nao repete a letra.
--   3) Botao de funcao troca o modo uma vez por aperto.
--   4) Modo decodificar: varias letras, uma sequencia invalida e a
--      saida de Mealy "traco".
--   5) Voltar ao modo codificar funciona.
--
-- Todas as entradas mudam na borda de DESCIDA do clock, para nunca
-- mudarem junto com a borda de subida (onde as FSMs leem as entradas).
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_morse is
end tb_morse;

architecture sim of tb_morse is
    constant T   : time     := 20 ns;
    constant U   : positive := 2;      -- UNIDADE
    constant LIM : positive := 4;      -- LIMIAR_TRACO
    constant FL  : positive := 8;      -- FIM_LETRA

    signal clk      : std_logic := '0';
    signal reset    : std_logic := '1';
    signal func     : std_logic := '0';
    signal btn      : std_logic := '0';
    signal letra_sw : std_logic_vector(4 downto 0) := (others => '0');
    signal modo_dec : std_logic;
    signal sinal    : std_logic;
    signal traco    : std_logic;
    signal simbolos : natural range 0 to 5;
    signal letra    : std_logic_vector(4 downto 0);
    signal fim      : boolean := false;
begin
    dut : entity work.morse
        generic map (UNIDADE => U, LIMIAR_TRACO => LIM, FIM_LETRA => FL)
        port map (
            clk => clk, reset => reset, func => func, btn => btn,
            letra_sw => letra_sw, modo_dec => modo_dec, sinal => sinal,
            traco => traco, simbolos => simbolos, letra => letra
        );

    relogio : process
    begin
        while not fim loop
            clk <= '0'; wait for T / 2;
            clk <= '1'; wait for T / 2;
        end loop;
        wait;
    end process;

    estimulos : process

        -- Espera n bordas de descida (onde as entradas sao trocadas).
        procedure ciclos(n : natural) is
        begin
            for i in 1 to n loop
                wait until falling_edge(clk);
            end loop;
        end procedure;

        -- Aperta e solta o botao de funcao.
        procedure aperta_funcao is
        begin
            func <= '1'; ciclos(3);
            func <= '0'; ciclos(3);
        end procedure;

        -- MODO CODIFICAR: escolhe a letra, aperta o botao e confere o
        -- sinal ciclo a ciclo contra o que o Morse manda.
        --   idx    : codigo da letra (0 = A)
        --   codigo : a letra em Morse, ex. ".-"
        --   segura : por quantos ciclos o botao fica apertado
        procedure codifica(idx : natural; nome : character; codigo : string;
                           segura : positive) is
            variable esp  : string(1 to 80);   -- sinal esperado ('0'/'1')
            variable n    : natural := 0;
            variable lido : character;
        begin
            -- Monta a forma de onda esperada.
            for k in codigo'range loop
                if k /= codigo'left then                      -- pausa entre simbolos
                    for j in 1 to U loop n := n + 1; esp(n) := '0'; end loop;
                end if;
                if codigo(k) = '.' then
                    for j in 1 to U loop n := n + 1; esp(n) := '1'; end loop;
                else
                    for j in 1 to 3 * U loop n := n + 1; esp(n) := '1'; end loop;
                end if;
            end loop;
            for j in 1 to 3 * U loop n := n + 1; esp(n) := '0'; end loop;   -- depois da letra

            letra_sw <= std_logic_vector(to_unsigned(idx, 5));
            btn <= '1';
            -- Le o sinal no meio de cada ciclo (borda de descida).
            for k in 1 to n loop
                ciclos(1);
                if k = segura then btn <= '0'; end if;
                if sinal = '1' then lido := '1'; else lido := '0'; end if;
                assert lido = esp(k)
                    report "Codificar " & nome & ": ciclo " & integer'image(k) &
                           " sinal=" & lido & ", esperado " & esp(k)
                    severity error;
            end loop;
            btn <= '0';
            ciclos(2);
        end procedure;

        -- MODO DECODIFICAR: tecla uma sequencia e confere a letra.
        procedure tecla(codigo : string; esperado : natural; nome : string) is
        begin
            for k in codigo'range loop
                btn <= '1';
                if codigo(k) = '.' then ciclos(2); else ciclos(LIM + 3); end if;
                btn <= '0';
                ciclos(2);                              -- pausa curta entre simbolos
            end loop;
            ciclos(FL + 2);                             -- pausa longa: fecha a letra
            assert to_integer(unsigned(letra)) = esperado
                report "Decodificar " & codigo & ": deu codigo " &
                       integer'image(to_integer(unsigned(letra))) &
                       ", esperado " & integer'image(esperado) & " (" & nome & ")"
                severity error;
        end procedure;

    begin
        ciclos(1);
        reset <= '0';
        ciclos(2);

        -- ---------------- 1) Codificar ----------------
        assert modo_dec = '0' report "Depois do reset o modo deveria ser codificar" severity error;
        codifica( 0, 'A', ".-",   1);
        codifica( 4, 'E', ".",    1);
        codifica(19, 'T', "-",    1);
        codifica(16, 'Q', "--.-", 1);
        codifica(18, 'S', "...",  1);

        -- Chaves mudam no meio da transmissao: a letra que sai continua a mesma.
        letra_sw <= std_logic_vector(to_unsigned(13, 5));   -- N  -.
        btn <= '1'; ciclos(1); btn <= '0';
        letra_sw <= std_logic_vector(to_unsigned(4, 5));    -- troca para E no meio
        ciclos(3 * U + U + U + 3 * U + 2);
        -- (so confere que voltou ao repouso; a forma de onda de N foi
        --  copiada para "padrao" no inicio)
        assert sinal = '0' report "Sinal deveria estar apagado apos a letra" severity error;

        -- ---------------- 2) Segurar o botao ----------------
        -- E dura 1 + 3 unidades; segurando 30 ciclos so pode haver UM ponto.
        letra_sw <= std_logic_vector(to_unsigned(4, 5));
        btn <= '1';
        ciclos(U + 1);
        for k in 1 to 30 loop
            ciclos(1);
            assert sinal = '0' report "Segurar o botao repetiu a letra" severity error;
        end loop;
        btn <= '0';
        ciclos(3);

        -- ---------------- 3) Trocar para decodificar ----------------
        aperta_funcao;
        assert modo_dec = '1' report "Botao de funcao nao trocou para decodificar" severity error;
        assert to_integer(unsigned(letra)) = 31
            report "Ao entrar em decodificar o display deveria estar apagado" severity error;

        -- ---------------- 4) Decodificar ----------------
        tecla("...",  18, "S");
        tecla("-.-",  10, "K");
        tecla("--.-", 16, "Q");
        tecla("-",    19, "T");
        tecla(".",     4, "E");
        tecla(".-",    0, "A");
        tecla("..--", 30, "invalido: nao e letra");
        tecla(".-.-.", 30, "invalido: 5 simbolos");

        -- Saida de Mealy: com o botao apertado ha tempo suficiente, "traco"
        -- acende; ao soltar, apaga NA HORA, antes da proxima borda de clock.
        btn <= '1';
        ciclos(LIM + 2);
        assert traco = '1' report "traco deveria estar aceso" severity error;
        btn <= '0';
        wait for 1 ns;                                  -- bem antes da proxima borda
        assert traco = '0' report "traco (Mealy) deveria apagar na hora" severity error;
        ciclos(FL + 2);
        assert to_integer(unsigned(letra)) = 19 report "Deveria ter lido T" severity error;

        -- ---------------- 5) Voltar para codificar ----------------
        aperta_funcao;
        assert modo_dec = '0' report "Botao de funcao nao voltou para codificar" severity error;
        codifica(0, 'A', ".-", 1);

        report "FIM DA SIMULACAO - pratica extra (Morse)" severity note;
        fim <= true;
        wait;
    end process;
end sim;
