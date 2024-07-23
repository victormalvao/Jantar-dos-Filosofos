-- Importa o módulo "lanes" e configura o ambiente
local lanes = require "lanes".configure()

-- Constantes de configuração
local NUM_FILOSOFOS = 5
local MAX_ITERACOES = 5
local TEMPO_MAXIMO_ESPERA = 5  -- Tempo máximo para tentar pegar os hashis antes de considerar deadlock
local TEMPO_MAXIMO_ESPERA_STARVATION = 8  -- Tempo máximo para considerar starvation

-- Função para obter o tempo atual no formato "HH:MM:SS"
local function obter_tempo()
    return os.date("%H:%M:%S")
end

-- Função para registrar eventos no sistema
-- Envia mensagens para o "linda" sobre o estado atual dos filósofos
local function registrar_evento(linda, filosofo_id, acao, garfo1, garfo2)
    local tempo_atual = obter_tempo()
    local mensagem = string.format("%s,Filósofo %d,%s", tempo_atual, filosofo_id, acao)
    if garfo1 and garfo2 then
        mensagem = string.format("%s,Garfo %d e Garfo %d", mensagem, garfo1, garfo2)
    end
    linda:send("fila", mensagem)
end

-- Função principal que simula o comportamento de um filósofo
-- Cada filósofo pensa, tenta pegar os hashis, come e depois larga os garfos
local function filosofo(linda, id)
    local garfo_esquerda = id
    local garfo_direita = (id % NUM_FILOSOFOS) + 1
    local iteracoes = 0

    while iteracoes < MAX_ITERACOES do
        registrar_evento(linda, id, "está pensando")
        os.execute("sleep 1")  -- Simula o tempo de pensamento

        -- Parte da solução de Dijkstra para evitar deadlock
        local inicio_espera = os.time()
        local pegou_garfo_esquerda = false
        local pegou_garfo_direita = false
        local tentativas = 0

        while not pegou_garfo_esquerda or not pegou_garfo_direita do
            local tempo_espera = os.time() - inicio_espera

            -- Verifica se o tempo máximo de espera foi excedido (deadlock)
            if tempo_espera > TEMPO_MAXIMO_ESPERA then
                registrar_evento(linda, id, "deadlock detectado", garfo_esquerda, garfo_direita)
                return
            end

            if not linda:get("garfo" .. garfo_esquerda) and not linda:get("garfo" .. garfo_direita) then
                -- Tenta pegar ambos os hashis
                linda:set("garfo" .. garfo_esquerda, true)
                linda:set("garfo" .. garfo_direita, true)
                pegou_garfo_esquerda = true
                pegou_garfo_direita = true
                registrar_evento(linda, id, "pegou garfos", garfo_esquerda, garfo_direita)
            else
                os.execute("sleep 1")  -- Aguarda um segundo antes de tentar novamente
                tentativas = tentativas + 1
                -- Verifica se o tempo máximo de espera para starvation foi excedido
                if tentativas * 1 > TEMPO_MAXIMO_ESPERA_STARVATION then
                    registrar_evento(linda, id, "starvation detectado", garfo_esquerda, garfo_direita)
                    return
                end
            end
        end

        -- O filósofo começa a comer
        registrar_evento(linda, id, "está comendo", garfo_esquerda, garfo_direita)
        os.execute("sleep 1")  -- Simula o tempo de refeição
        -- O filósofo larga os hashis
        linda:set("garfo" .. garfo_esquerda, nil)
        linda:set("garfo" .. garfo_direita, nil)
        registrar_evento(linda, id, "largou garfos", garfo_esquerda, garfo_direita)

        iteracoes = iteracoes + 1
    end

    -- Registra que o filósofo terminou sua execução
    registrar_evento(linda, id, "terminou sua execução")
end

-- Função para processar a fila de mensagens e gravar em um arquivo CSV
local function processar_fila(linda, num_filosofos)
    local arquivo_csv = io.open("saida_filosofos_" .. os.date("%Y-%m-%d_%H%M") .. ".csv", "w")
    arquivo_csv:write("tempo,filosofo,status,garfos_usados\n")

    local filosofos_terminados = 0

    while true do
        local chave, mensagem = linda:receive(1, "fila")
        if chave == "fila" then
            print("Processando item da fila:", mensagem)
            arquivo_csv:write(mensagem .. "\n")
            if string.find(mensagem, "terminou sua execução") then
                filosofos_terminados = filosofos_terminados + 1
                if filosofos_terminados == num_filosofos then
                    break
                end
            end
        end
    end

    arquivo_csv:close()
end

-- Função para criar e iniciar as threads dos filósofos
local function criar_threads(linda)
    local filosofo_threads = {}
    for i = 1, NUM_FILOSOFOS do
        filosofo_threads[i] = lanes.gen("*", filosofo)(linda, i)
    end
    return filosofo_threads
end

-- Criação da instância linda e threads
local linda = lanes.linda()
local thread_principal = lanes.gen("*", processar_fila)(linda, NUM_FILOSOFOS)
local filosofo_threads = criar_threads(linda)

-- Aguarda a execução das threads (aguarda 15 segundos)
os.execute("sleep 15")

-- Aguarda a finalização de todas as threads dos filósofos
for i = 1, NUM_FILOSOFOS do
    filosofo_threads[i]:join()
end

-- Envia a mensagem de encerramento para a fila
linda:send("fila", "ENCERRAMENTO")
thread_principal:join()

print("Dados dos filósofos registrados no arquivo CSV com sucesso!")
