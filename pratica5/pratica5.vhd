-- =====================================================================
-- Pratica 5: liga/desliga um LED com um unico botao
--
-- Cada APERTO do botao inverte o LED. O cuidado aqui: o clock e muito
-- mais rapido que o dedo, entao um aperto dura muitos ciclos de clock.
-- Se a maquina so tivesse 2 estados (ligado/desligado), ela ficaria
-- alternando sem parar enquanto o botao estivesse apertado.
--
-- Solucao: 4 estados. Alem de lembrar se o LED esta ligado, a maquina
-- lembra se o botao AINDA esta apertado e espera ele ser solto:
--
--   DESLIGADO --btn=1--> LIGANDO --btn=0--> LIGADO --btn=1--> DESLIGANDO --btn=0--> DESLIGADO
--    (led=0)             (led=1)            (led=1)            (led=0)
--    espera apertar      espera soltar      espera apertar     espera soltar
--
-- Maquina de MOORE: led depende so do estado.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;

entity pratica5 is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;   -- assincrono, ativo em '1'
        btn   : in  std_logic;   -- '1' = botao apertado
        led   : out std_logic
    );
end pratica5;

architecture fsm of pratica5 is
    type estado_t is (DESLIGADO, LIGANDO, LIGADO, DESLIGANDO);
    signal estado : estado_t;
begin

    -- Registrador de estado + logica de proximo estado
    process (clk, reset)
    begin
        if reset = '1' then
            estado <= DESLIGADO;           -- comeca com o LED apagado
        elsif rising_edge(clk) then
            -- Os "if" nao tem "else": se a condicao nao acontece, o
            -- estado simplesmente nao muda (a maquina fica esperando).
            case estado is
                when DESLIGADO  => if btn = '1' then estado <= LIGANDO;    end if;  -- apertou: liga
                when LIGANDO    => if btn = '0' then estado <= LIGADO;     end if;  -- soltou
                when LIGADO     => if btn = '1' then estado <= DESLIGANDO; end if;  -- apertou: desliga
                when DESLIGANDO => if btn = '0' then estado <= DESLIGADO;  end if;  -- soltou
            end case;
        end if;
    end process;

    -- Saida (Moore): LED aceso nos dois estados "ligados". O LED ja
    -- muda no instante em que o botao e apertado, nao quando e solto.
    led <= '1' when (estado = LIGANDO or estado = LIGADO) else '0';

end fsm;
