let philosophers = [];
let forks = [];
let events = [];
let currentTimeIndex = 0;
let startTime;

const NUM_PHILOSOPHERS = 5;
const RADIUS = 150;
const PHILOSOPHER_RADIUS = 20;
const FORK_LENGTH = 60;
const colors = ['#FF6347', '#4682B4', '#32CD32', '#FFD700', '#FF69B4'];

function preload() {
    // Carregar o arquivo CSV
    table = loadTable('evento.csv', 'csv', 'header', () => {
        console.log("Arquivo CSV carregado com sucesso.");
        processEvents();
    });
}

function setup() {
    createCanvas(600, 600);
    angleMode(DEGREES);
    startTime = millis();
    initializePhilosophers();
    initializeForks();
}

function draw() {
    background(255);
    translate(width / 2, height / 2);
    
    // Atualizar o tempo atual
    let elapsedTime = (millis() - startTime) / 1000; // em segundos

    // Verificar se é hora de processar o próximo evento
    if (currentTimeIndex < events.length) {
        let currentEvent = events[currentTimeIndex];
        let eventTime = timeToSeconds(currentEvent.timestamp);
        
        if (elapsedTime >= eventTime) {
            processEvent(currentEvent);
            currentTimeIndex++;
        }
    }

    // Desenhar garfos
    for (let i = 0; i < forks.length; i++) {
        let fork = forks[i];
        stroke(0);
        strokeWeight(4);
        line(fork.x1, fork.y1, fork.x2, fork.y2);
    }

    // Desenhar filósofos
    for (let i = 0; i < philosophers.length; i++) {
        let p = philosophers[i];
        fill(p.color);
        noStroke();
        ellipse(p.x, p.y, PHILOSOPHER_RADIUS * 2);

        // Desenhar estado de comer
        if (p.state === 'eating') {
            fill(255, 0, 0);
            ellipse(p.x, p.y, PHILOSOPHER_RADIUS / 2);
        }
    }
}

function initializePhilosophers() {
    for (let i = 0; i < NUM_PHILOSOPHERS; i++) {
        let angle = (i * 360) / NUM_PHILOSOPHERS;
        let x = RADIUS * cos(angle);
        let y = RADIUS * sin(angle);
        philosophers.push({
            id: i + 1,
            x: x,
            y: y,
            color: colors[i],
            state: 'thinking'
        });
    }
}

function initializeForks() {
    for (let i = 0; i < NUM_PHILOSOPHERS; i++) {
        let angle1 = (i * 360) / NUM_PHILOSOPHERS;
        let angle2 = ((i + 1) % NUM_PHILOSOPHERS) * 360 / NUM_PHILOSOPHERS;
        let x1 = (RADIUS - FORK_LENGTH) * cos(angle1);
        let y1 = (RADIUS - FORK_LENGTH) * sin(angle1);
        let x2 = (RADIUS - FORK_LENGTH) * cos(angle2);
        let y2 = (RADIUS - FORK_LENGTH) * sin(angle2);

        forks.push({ x1, y1, x2, y2 });
        forkStates.push({ taken: false });
    }
}

function processEvent(event) {
    let pIndex = getPhilosopherIndex(event.philosopher);
    
    if (pIndex !== -1) {
        let philosopher = philosophers[pIndex];
        
        if (event.status === 'está comendo') {
            philosopher.state = 'eating';
            
            // Pegar os garfos
            let forkIndices = event.forksUsed.match(/\d+/g).map(Number);
            forkIndices.forEach(idx => {
                forkStates[idx - 1].taken = true;
            });
        } else {
            philosopher.state = 'thinking';
            
            // Largar os garfos
            let forkIndices = event.forksUsed.match(/\d+/g).map(Number);
            forkIndices.forEach(idx => {
                forkStates[idx - 1].taken = false;
            });
        }

        // Mensagem de depuração para verificar o processamento dos eventos
        console.log(`Processando evento: ${event.philosopher} está ${philosopher.state}, garfos usados: ${event.forksUsed}`);
    } else {
        console.warn(`Filósofo não encontrado para o evento: ${event.philosopher}`);
    }
}


function processEvents() {
    for (let i = 0; i < table.getRowCount(); i++) {
        let row = table.getRow(i);
        let event = {
            timestamp: row.get('tempo'),
            philosopher: row.get('filosofo'),
            status: row.get('status'),
            forksUsed: row.get('garfos_usados')
        };
        events.push(event);
    }
}

function timeToSeconds(timestamp) {
    let [hours, minutes, seconds] = timestamp.split(':').map(Number);
    return hours * 3600 + minutes * 60 + seconds;
}
