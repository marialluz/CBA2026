&nbsp;
&nbsp;
<p align="center">
  <img width="800" src="./assets/conecta_logo.png" />
</p>

&nbsp;

# Reliability Analysis of LLM-Based Response and Speech Synthesis for Automotive Interfaces

![Python 3.11](https://img.shields.io/badge/Python-3.11-blue.svg)
![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688.svg)
![React 18](https://img.shields.io/badge/Frontend-React%2018-61DAFB.svg)
![Docker](https://img.shields.io/badge/Container-Docker-2496ED.svg)
![License MIT](https://img.shields.io/badge/License-MIT-green.svg)

### Authors: [Maria Luz](https://github.com/marialluz), [Thais Medeiros](https://github.com/thaisaraujom), [Morsinaldo Medeiros](https://github.com/Morsinaldo), [Marianne Silva](https://github.com/MarianneDiniz), [Dennis Brandao](https://scholar.google.com/citations?user=OxSKwvEAAAAJ&hl=pt-BR), and [Ivanovitch Silva](https://github.com/ivanovitchm)


## Abstract

Consulting automotive technical manuals while driving requires interfaces that prioritize agility and information accuracy. Although the use of voice assistants based on Large Language Models (LLMs) represents an alternative, the occurrence of inconsistent responses in technical domains constitutes an obstacle to system reliability. This work develops and evaluates two approaches to answer user queries regarding automotive manuals related to the BYD Dolphin Mini vehicle. The study compares a conversational agent fully configured on a managed platform (**Approach 1**) with an auditable Step-Back RAG pipeline developed under the Spec-kit methodology (**Approach 2**). Both solutions are compared to the assistance feature available in the manufacturer's official application. Validation employed the LLM-as-a-judge method for textual quality, in addition to metrics for speech synthesis. The results indicate that Approach 2 provides higher document fidelity compared to the others. Although the managed solution presented lower latency (1.6 s versus 5.0 s for Approach 2), the findings suggest that control over the retrieval pipeline favors grounding responses in official technical sources. This research concludes that transparency in pipeline control is important for transforming voice assistants into reliable safety tools in everyday driving contexts.


## Proposed Approaches

The study compares two architectures for answering natural-language questions about BYD Dolphin Mini manuals, plus the manufacturer's native AI Technician as a market reference. The figure below illustrates the pipeline of both approaches.

<p align="center">
  <img width="800" src="./assets/approach.png" />
</p>

### Approach 1 -- ElevenLabs Conversational AI (Managed Platform)

A conversational agent configured entirely through the ElevenLabs web interface. Manuals are uploaded directly to the platform, which handles speech recognition, RAG retrieval, LLM generation (Claude Haiku 4.5), and neural voice synthesis internally. The pipeline operates as a **black box**: retrieved chunks, search parameters, and the prompt sent to the LLM are not exposed to the developer.

### Approach 2 -- Auditable Step-Back RAG Pipeline (Custom)

A fully custom conversational agent with an auditable architecture, developed using the [Spec-kit](https://github.com/github/spec-kit) methodology. The pipeline provides **full transparency**: every retrieved chunk, prompt, and latency metric is logged at each interaction. Key components:

- **Speech Input**: Browser Web Speech API for transcription with user review before submission.
- **Step-Back RAG**: The user's question is reformulated into an abstract version by the LLM. Two independent vector searches (original + abstracted) are performed in Milvus, and the most relevant passages are concatenated as context for Claude Haiku 4.5.
- **Speech Output**: ElevenLabs API with voice cloning for neural synthesis, with a native Web Speech API fallback.


## Repository Structure

```text
METROAUTOMOTIVE2026-conversational-agents/
├── backend/                    # Python 3.11+ / FastAPI application
│   ├── app/
│   │   ├── main.py             # FastAPI entry point, Milvus init, CORS
│   │   ├── api/v1/             # REST endpoints (chat, health, tts, transcribe)
│   │   ├── services/           # RAG pipeline, LLM, embeddings, vector store, TTS
│   │   ├── ingestion/          # PDF loading and Milvus indexing
│   │   └── models/             # Pydantic schemas
│   ├── assets/                 # BYD Dolphin Mini manuals (PDF)
│   ├── ingest.py               # Standalone ingestion script
│   ├── tests/                  # Unit, contract, and integration tests
│   ├── pyproject.toml          # Dependencies and ruff config
│   └── Dockerfile
├── frontend/                   # React 18 / TypeScript / Vite
│   ├── src/
│   │   ├── components/         # Chat UI (ChatWindow, MessageBubble, SourceCitation, etc.)
│   │   ├── hooks/              # useChat, useSpeechInput, useSpeechOutput
│   │   ├── services/           # API client and TTS service
│   │   └── types/              # TypeScript interfaces
│   ├── tests/
│   ├── package.json
│   └── Dockerfile
├── paper/                      # LaTeX source (IEEE conference format)
├── docs/                       # Evaluation notebooks, results, and audio samples
├── specs/                      # Feature specification (Spec-kit artifacts)
│   └── 001-byd-chat-rag/       # Spec, plan, API contracts, tasks
├── .specify/                   # Spec-kit governance (constitution, templates)
├── assets/                     # Logo and pipeline diagrams
├── docker-compose.yml          # Full stack: Milvus + etcd + MinIO + backend + frontend
├── LICENSE
└── README.md
```


## Environment Setup

Use **Python 3.11+** for the backend and **Node.js 20+** for the frontend.

### 1. Clone the repository

```bash
git clone https://github.com/marialluz/byd-chat.git
cd byd-chat
```

### 2. Configure environment variables

```bash
# Backend
cp backend/.env.example backend/.env
# Edit backend/.env and set your API keys:
#   ANTHROPIC_API_KEY=sk-ant-...
#   OPENAI_API_KEY=sk-...

# Frontend
cp frontend/.env.example frontend/.env
# Optionally set VITE_ELEVENLABS_API_KEY for neural TTS
```

### 3a. Run with Docker (recommended)

```bash
docker compose up --build
```

This starts all services:

| Service      | Port    | Description                          |
|-------------|---------|--------------------------------------|
| **frontend** | 5173    | React chat interface                 |
| **backend**  | 8000    | FastAPI + Step-Back RAG pipeline     |
| **milvus**   | 19530   | Vector database (standalone)         |
| etcd         | 2379    | Configuration store for Milvus       |
| minio        | 9000    | Object storage for Milvus            |

### 3b. Run locally (without Docker)

**Backend:**

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -e .
```

Start Milvus separately (e.g., via Docker), then ingest the manuals and start the server:

```bash
python ingest.py
uvicorn app.main:app --reload --port 8000
```

**Frontend:**

```bash
cd frontend
npm install
npm run dev
```

Open http://localhost:5173 in the browser.


## Key Commands

```bash
# Backend
cd backend && source .venv/bin/activate
uvicorn app.main:app --reload --port 8000   # Development server
python ingest.py                             # Index PDFs into Milvus
pytest tests/ -v                             # Run tests
ruff check . && ruff format .                # Lint and format

# Frontend
cd frontend
npm run dev                                  # Development server
npm run test                                 # Run tests
npm run build                                # Production build
```


## Evaluation

The evaluation covers three dimensions: **response quality**, **latency**, and **speech synthesis fidelity**. The evaluation notebooks and data are available in the `docs/` directory.

### Response Quality (LLM-as-a-Judge)

Automated evaluation using GPT-4o with four weighted criteria:

| Criterion     | Weight | Description                              |
|--------------|--------|------------------------------------------|
| Fidelity     | 40%    | Accuracy relative to the manual content  |
| Safety       | 30%    | Presence of appropriate warnings         |
| Completeness | 20%    | Coverage of essential information        |
| Relevance    | 10%    | Pertinence to the user's question        |

A benchmark of **12 questions** (Easy/Medium/Hard) across Charging, Maintenance, Dashboard, Operation, and Multimedia domains was used. Two out-of-domain trap questions test hallucination resistance (oil changes and fuel tank on an electric vehicle).

**Results:**

| System                         | Avg Score | Avg Latency |
|-------------------------------|-----------|-------------|
| **Approach 2 (Custom RAG)**   | **3.96**  | 5.0 s       |
| Approach 1 (ElevenLabs)       | 3.43      | **1.6 s**   |
| AI Technician (BYD App)       | 3.13      | 15.0 s      |

### Speech Synthesis Quality

Subjective evaluation with 20 volunteers (blind test, ITU-T P.800) and objective spectral fidelity (MCD):

<p align="center">
  <img width="450" src="./assets/mos_comparativo.png" />
  &nbsp;&nbsp;
  <img width="450" src="./assets/mcd_comparativo.png" />
</p>

| Metric | ElevenLabs TTS | Web Speech API |
|--------|---------------|----------------|
| MOS    | **4.60**      | 2.57           |
| MCD    | **9.43 dB**   | 15.24 dB       |

### Evaluation Notebooks

```bash
pip install -r docs/requirements-notebooks.txt
```

- `docs/evaluation_byd_llm_judge.ipynb` -- LLM-as-a-Judge scoring
- `docs/evaluation_tts_mos_mcd.ipynb` -- MOS and MCD analysis


## Main Documents and Datasets

| File | Description |
|------|-------------|
| `backend/assets/dolphin-mini-manual.pdf` | BYD Dolphin Mini Owner's Manual |
| `backend/assets/dolphin-mini-manutencao-garantia.pdf` | BYD Dolphin Mini Maintenance and Warranty Manual |
| `docs/evaluation_data_byd.json` | Evaluation benchmark (questions + responses) |
| `docs/evaluation_results_byd.json` | LLM-as-a-Judge results |
| `docs/tts_results_mos_mcd.json` | TTS quality results (MOS + MCD) |
| `docs/mos_responses.csv` | Raw MOS responses from 20 volunteers |
| `docs/audio/` | Audio samples for voice quality assessment |


## Acknowledgment

This research was supported by the Brazilian funding agency CNPq (National Council for Scientific and Technological Development), under grant No. 444677/2024-0.


## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.


## About Us

The **Conect2AI** research group is composed of undergraduate and graduate students from the **Federal University of Rio Grande do Norte (UFRN)**. The group focuses on applying Artificial Intelligence and Machine Learning to emerging areas such as **Embedded Intelligence, Internet of Things, and Intelligent Transportation Systems**, contributing to energy efficiency and sustainable mobility solutions.

Website: http://conect2ai.dca.ufrn.br
