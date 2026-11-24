-- =====================================================================
-- Pratica Extra: FSM de CODIFICACAO (letra -> piscadas em Morse)
--
-- O usuario escolhe a letra nas chaves e aperta o botao. A maquina
-- acende o LED (ou buzzer) seguindo o codigo Morse da letra:
--
--   ponto = LED aceso por 1 unidade de tempo
--   traco = LED aceso por 3 unidades
--   entre dois simbolos da mesma letra = LED apagado por 1 unidade
--
-- Exemplo com a letra A (".-") e UNIDADE = 1 tick:
--
--   estado: OCIOSO | PONTO | PAUSA | TRACO TRACO TRACO | FIM ...
--   sinal :    0   |   1   |   0   |   1     1     1   |  0
--
-- Estados (maquina de MOORE: a saida "sinal" depende so do estado):
--   OCIOSO        sinal = 0   esperando o botao
--   PONTO         sinal = 1   mostrando um ponto
--   TRACO         sinal = 1   mostrando um traco
--   PAUSA         sinal = 0   espaco entre simbolos
--   FIM           sinal = 0   espaco depois da letra; espera soltar o botao
--
-- PONTO e TRACO duram mais de um clock. Para isso a FSM tem um
-- CONTADOR (cont) ao lado do registrador de estado. Isso e comum em
-- projetos reais e as vezes e chamado de FSMD (FSM + datapath): o
-- estado diz O QUE fazer, o contador diz HA QUANTO TEMPO.
-- A alternativa "pura" seria um estado para cada tick (TRACO1, TRACO2,
-- TRACO3...), como na pratica 3 (8 estados). Com 20 ticks por unidade
-- isso daria dezenas de estados, por isso o contador.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.morse_pkg.all;

entity morse_codificador is
    generic (
        UNIDADE : positive := 20    -- ticks de clock por unidade Morse
    );                              -- (20 ticks a 100 Hz = 200 ms)
    port (
        clk   : in  std_logic;
        reset : in  std_logic;                     -- assincrono, ativo em '1'
        ativo : in  std_logic;                     -- '0' = modo desligado
        letra : in  std_logic_vector(4 downto 0);  -- 0 = A ... 25 = Z
        btn   : in  std_logic;                     -- '1' = botao apertado
        sinal : out std_logic                      -- LED / buzzer
    );
end morse_codificador;

architecture fsm of morse_codificador is
    type estado_t is (OCIOSO, PONTO, TRACO, PAUSA, FIM);
    signal estado : estado_t;

    -- "Datapath": registradores auxiliares que a FSM controla.
    signal cont   : natural range 0 to 3 * UNIDADE - 1;   -- ticks no estado atual
    signal padrao : std_logic_vector(3 downto 0);         -- copia da letra
    signal pos    : natural range 0 to 3;                 -- simbolo atual (bit do padrao)
begin

    -- -----------------------------------------------------------------
    -- Registrador de estado + logica de proximo estado
    -- (mesma estrutura do slide: process(clk, reset) e um case)
    -- -----------------------------------------------------------------
    process (clk, reset)
        variable m : morse_t;   -- variavel: so uma "etiqueta" para o resultado da tabela
    begin
        if reset = '1' then
            -- Reset ASSINCRONO: age na hora, sem esperar o clock.
            estado <= OCIOSO;
            cont   <= 0;
            padrao <= (others => '0');
            pos    <= 0;

        elsif rising_edge(clk) then
            if ativo = '0' then
                -- Reset SINCRONO: so acontece na borda do clock. E usado
                -- quando o usuario troca de modo: a maquina para o que
                -- estava fazendo e volta ao inicio.
                estado <= OCIOSO;
                cont   <= 0;

            else
                case estado is

                    when OCIOSO =>
                        cont <= 0;
                        -- So aceita letra valida (0..25). As chaves 26..31 sao ignoradas.
                        if btn = '1' and to_integer(unsigned(letra)) <= 25 then
                            m := TABELA_MORSE(to_integer(unsigned(letra)));
                            -- Detalhe importante: a letra e COPIADA para "padrao".
                            -- Se o usuario mexer nas chaves no meio da transmissao,
                            -- a letra que esta saindo nao muda.
                            padrao <= m.padrao;
                            pos    <= m.tam - 1;               -- comeca pelo 1o simbolo
                            if m.padrao(m.tam - 1) = '1' then
                                estado <= TRACO;
                            else
                                estado <= PONTO;
                            end if;
                        end if;

                    when PONTO | TRACO =>
                        -- Quanto tempo este simbolo dura: 1 ou 3 unidades.
                        -- (Um "when" pode tratar dois estados juntos com "|".)
                        if (estado = PONTO and cont = UNIDADE - 1) or
                           (estado = TRACO and cont = 3 * UNIDADE - 1) then
                            cont <= 0;
                            if pos = 0 then
                                estado <= FIM;                 -- era o ultimo simbolo
                            else
                                pos    <= pos - 1;             -- proximo simbolo
                                estado <= PAUSA;
                            end if;
                        else
                            cont <= cont + 1;
                        end if;

                    when PAUSA =>
                        if cont = UNIDADE - 1 then
                            cont <= 0;
                            -- "pos" ja aponta para o proximo simbolo (foi
                            -- decrementado ao sair de PONTO/TRACO).
                            if padrao(pos) = '1' then
                                estado <= TRACO;
                            else
                                estado <= PONTO;
                            end if;
                        else
                            cont <= cont + 1;
                        end if;

                    when FIM =>
                        -- Espera 3 unidades (espaco entre letras do Morse)
                        -- E o botao ser solto. Sem esperar soltar, segurar o
                        -- botao faria a letra repetir sem parar (mesma ideia
                        -- dos estados "LIGANDO/DESLIGANDO" da pratica 5).
                        if cont < 3 * UNIDADE - 1 then
                            cont <= cont + 1;
                        elsif btn = '0' then
                            estado <= OCIOSO;
                        end if;

                end case;
            end if;
        end if;
    end process;

    -- -----------------------------------------------------------------
    -- Logica de saida (MOORE): depende so do estado.
    -- Fica fora do processo com clock porque e combinacional.
    -- -----------------------------------------------------------------
    sinal <= '1' when estado = PONTO or estado = TRACO else '0';

end fsm;
