
---

# Simulação do Problema dos Filósofos Jantando

Este projeto é uma simulação do clássico problema dos filósofos jantando, uma situação de sincronização concorrente. A solução utiliza o conceito proposto por Edsger W. Dijkstra para evitar deadlocks e starvation em um ambiente onde múltiplos filósofos (threads) compartilham recursos (hashis). O código é escrito em Lua e utiliza o módulo `lanes` para gerenciamento de threads.

## Índice

- [Descrição](#descrição)
- [Recursos](#recursos)
- [Como Funciona](#como-funciona)
- [Configuração do Ambiente](#configuração-do-ambiente)
- [Executando o Código](#executando-o-código)
- [Análise e Resultados](#análise-e-resultados)
- [Referências](#referências)
- [Contribuição](#contribuição)
- [Licença](#licença)

## Descrição

O problema dos filósofos jantando é um exemplo clássico de problemas de sincronização e concorrência. Ele envolve múltiplos filósofos sentados ao redor de uma mesa e compartilhando hashis. Cada filósofo deve alternar entre pensar e comer, mas para comer, precisa adquirir dois hashis. O desafio é garantir que os filósofos possam comer sem entrar em deadlock (bloqueio mútuo) ou starvation (fome indefinida).

Este projeto implementa uma solução usando Lua e o módulo `lanes` para criar threads e gerenciar a sincronização entre os filósofos.

## Recursos

- **Lua**: Linguagem de programação utilizada.
- **Lanes**: Módulo para gerenciamento de threads.
- **Arquivo CSV**: Registro de eventos para análise posterior.

## Como Funciona

### Abordagem de Dijkstra

O problema dos filósofos jantando é um exemplo fundamental de problemas de sincronização em sistemas concorrentes. A abordagem de Edsger W. Dijkstra para resolver o problema é notável por introduzir um método para evitar deadlocks e starvation.

1. **Evitar Deadlocks**:
   - **Solução**: Cada filósofo deve pegar os hashis na ordem crescente (do menor número para o maior). Isso evita ciclos de espera e, portanto, previne deadlocks.

2. **Evitar Starvation**:
   - **Solução**: Cada filósofo deve ter um tempo mínimo para tentar obter os hashis e deve liberar os hashis se não conseguir após um certo período, garantindo que todos tenham a chance de comer.

### Componentes Principais

1. **Constantes de Configuração**:
   - `NUM_FILOSOFOS`: Número de filósofos na simulação.
   - `MAX_ITERACOES`: Número máximo de iterações que cada filósofo realiza.
   - `TEMPO_MAXIMO_ESPERA`: Tempo máximo para tentar pegar os hashis antes de considerar deadlock.
   - `TEMPO_MAXIMO_ESPERA_STARVATION`: Tempo máximo para considerar starvation.

2. **Funções**:
   - `obter_tempo()`: Retorna o tempo atual no formato "HH:MM:SS".
   - `registrar_evento(linda, filosofo_id, acao, garfo1, garfo2)`: Registra eventos sobre o estado dos filósofos e hashis.
   - `filosofo(linda, id)`: Simula o comportamento de um filósofo, incluindo tentativas de pegar hashis e gerenciamento de deadlocks e starvation.
   - `processar_fila(linda, num_filosofos)`: Processa mensagens da fila e grava eventos em um arquivo CSV.
   - `criar_threads(linda)`: Cria e inicia threads para os filósofos.

3. **Execução**:
   - O script cria threads para cada filósofo e uma thread principal para processar a fila de eventos.
   - Cada filósofo tenta adquirir dois hashis e realiza suas ações (pensar, comer, largar hashis).
   - O script grava todos os eventos em um arquivo CSV e imprime uma mensagem de sucesso ao final.

## Configuração do Ambiente

1. **Instalação do Lua**:
   - Certifique-se de ter Lua 5.1 instalado. [Download Lua](https://www.lua.org/download.html)

2. **Instalação do Módulo `lanes`**:
   - Instale o módulo `lanes` se ainda não estiver instalado. Você pode encontrar instruções no [repositório oficial do Lanes](https://github.com/luapower/lanes).

3. **Configuração do Ambiente**:
   - Verifique se o `lua` e o `lanes` estão corretamente configurados no seu ambiente.

## Executando o Código

1. **Preparar o Ambiente**:
   - Assegure-se de que o Lua e o módulo `lanes` estejam instalados e configurados corretamente.

2. **Rodar o Script**:
   - Salve o código fornecido em um arquivo chamado `filosofos.lua`.
   - Execute o script com o seguinte comando:
     ```bash
     lua filosofos.lua
     ```

3. **Verificar Resultados**:
   - Após a execução, um arquivo CSV será gerado com o nome `saida_filosofos_<data>_<hora>.csv`, contendo os eventos registrados durante a simulação.

## Análise e Resultados

- **Deadlocks e Starvation**:
  - O código detecta e registra deadlocks e starvation, garantindo que cada filósofo possa eventualmente comer.
  
- **Resultados CSV**:
  - O arquivo CSV gerado contém informações sobre o tempo, filósofo, status e hashis usados, permitindo análise detalhada do comportamento dos filósofos.

## Referências

Para mais informações sobre o problema dos filósofos jantando e sua importância na computação, consulte o artigo [The Dining Philosophers](https://medium.com/great-moments-in-computing-history/the-dining-philosophers-2e3da2847bac) no Medium. Este artigo fornece uma visão geral do problema, histórico e soluções propostas, incluindo a abordagem de Dijkstra.

Adicionalmente, para práticas de desenvolvimento de software, controle de versão e colaboração, confira o artigo [Entre Forks e Segredos](https://www.deviante.com.br/noticias/entre-forks-e-segredos/) no Deviante.

## Contribuição

Se você deseja contribuir para o projeto, por favor siga estas diretrizes:

1. **Fork** o repositório.
2. **Crie** uma branch para sua modificação.
3. **Faça** suas alterações e adicione testes se possível.
4. **Envie** um pull request com uma descrição clara das mudanças.

## Licença

Este projeto está licenciado sob a [Licença MIT](LICENSE). Veja o arquivo LICENSE para mais detalhes.

---