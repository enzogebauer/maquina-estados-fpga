-- Pratica 5: liga/desliga um LED com um unico botao
-- Cada aperto do botao inverte o LED. Para que um aperto longo conte
-- apenas uma vez, a FSM tambem lembra se o botao ainda esta apertado:
--
--   DESLIGADO --btn=1--> LIGANDO --btn=0--> LIGADO --btn=1--> DESLIGANDO --btn=0--> DESLIGADO
--   (LED=0)              (LED=1)            (LED=1)           (LED=0)
--
-- Maquina de Moore: led depende so do estado.
library ieee;
use ieee.std_logic_1164.all;

entity pratica5 is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        btn   : in  std_logic;   -- '1' = botao apertado
        led   : out std_logic
    );
end pratica5;

architecture fsm of pratica5 is
    type estado_t is (DESLIGADO, LIGANDO, LIGADO, DESLIGANDO);
    signal estado : estado_t;
begin

    process (clk, reset)
    begin
        if reset = '1' then
            estado <= DESLIGADO;
        elsif rising_edge(clk) then
            case estado is
                when DESLIGADO  => if btn = '1' then estado <= LIGANDO;    end if;
                when LIGANDO    => if btn = '0' then estado <= LIGADO;     end if;
                when LIGADO     => if btn = '1' then estado <= DESLIGANDO; end if;
                when DESLIGANDO => if btn = '0' then estado <= DESLIGADO;  end if;
            end case;
        end if;
    end process;

    led <= '1' when (estado = LIGANDO or estado = LIGADO) else '0';

end fsm;
