"""
dj-hermes Plugin Backend API
Provides REST endpoints for the desktop plugin UI and skill orchestration.
"""

import os
import json
import shutil
import subprocess
import tempfile
import asyncio
from pathlib import Path
from typing import Optional, Dict, Any, List
from fastapi import FastAPI, HTTPException, BackgroundTasks
from pydantic import BaseModel, Field
import yaml

app = FastAPI(title="dj-hermes API", version="0.3.0")

# Load plugin config
PLUGIN_DIR = Path(__file__).parent.parent
CONFIG_PATH = PLUGIN_DIR / "plugin.yaml"
with open(CONFIG_PATH) as f:
    PLUGIN_CONFIG = yaml.safe_load(f)

DJ_CONFIG = PLUGIN_CONFIG.get("config", {}).get("dj_hermes", {})
OUTPUT_DIR = Path(os.path.expanduser(DJ_CONFIG.get("output_dir", "~/dj-hermes/output")))
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Request/Response models
class GenerateRequest(BaseModel):
    prompt: str = Field(..., description="Natural language groove description")
    tempo: Optional[int] = None
    genre: Optional[str] = None
    bars: int = 8
    temperature: float = 0.7

class GenerateResponse(BaseModel):
    pattern: str
    tempo: int
    genre: str
    bars: int
    source: str = "stub"  # "rhythmancer-gguf" when real inference ran

class RenderRequest(BaseModel):
    pattern: str
    output: Optional[str] = None
    bpm: int = 120
    bars: int = 8
    sample_rate: int = 44100
    normalize: bool = True

class RenderResponse(BaseModel):
    wav_path: str
    duration_seconds: float
    sample_rate: int

class ValidateRequest(BaseModel):
    pattern: str
    check_strudel: bool = True
    strict: bool = False

class ValidateResponse(BaseModel):
    valid: bool
    engine: str
    errors: List[str] = []
    warnings: List[str] = []

class ExportRequest(BaseModel):
    pattern: str
    include_tempo: bool = True
    include_swing: bool = True
    wrap_in_stack: bool = True
    create_session: bool = False

class ExportResponse(BaseModel):
    strudel_code: str
    session_url: Optional[str] = None

class ListenRequest(BaseModel):
    file: str
    player: Optional[str] = None
    volume: float = 1.0
    loop: bool = False


# Helper functions

STUB_PATTERN = 's("bd sd", "hh*2")  # stub: set RHYTHMANCER_GGUF for real generation'
GENERATION_SOURCE = {"source": "stub"}


def run_rhythmancer(prompt: str, tempo: int, bars: int, temperature: float) -> str:
    """Call Rhythmancer 3B (GGUF) via llama.cpp if a model is configured.

    Verified invocation (2026-10-27, see examples/rhythmancer-gguf/):
    the model writes Strudel-dialect code with tempo baked in as
    .cpm(BPM/4). Always pass output through dj-validate afterwards —
    sampled output can carry unbalanced parens / truncated bank names.
    Configure RHYTHMANCER_GGUF=/path/to/rhythmancer-Q4_K_M.gguf to enable.
    """
    GENERATION_SOURCE["source"] = "stub"
    gguf = os.getenv("RHYTHMANCER_GGUF", "")
    if gguf and shutil.which("llama-cli"):
        chatml = (
            "<|im_start|>user\n"
            f"Generate Strudel live-coding music code for: {prompt}\n"
            "<|im_start|>assistant\n"
        )
        with tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False) as f:
            f.write(chatml)
            prompt_file = f.name
        try:
            result = subprocess.run(
                [
                    "llama-cli", "-m", gguf, "-ngl", "99", "-no-cnv",
                    "-f", prompt_file, "-n", "400", "-c", "2048",
                    "--temp", str(temperature), "--top-p", "0.9",
                    "--repeat-penalty", "1.1",
                ],
                capture_output=True, text=True, timeout=300,
            )
        finally:
            os.unlink(prompt_file)
        text = result.stdout
        if "assistant\n" in text:
            text = text.split("assistant\n", 1)[1]
        pattern = text.replace("[end of text]", "").strip()
        if pattern:
            GENERATION_SOURCE["source"] = "rhythmancer-gguf"
            return pattern
    return STUB_PATTERN


def run_maelstrom_render(pattern: str, output: str, bpm: int, bars: int, 
                         sample_rate: int, normalize: bool) -> Dict[str, Any]:
    """Call maelstrom Rscript to render pattern to WAV."""
    rscript = DJ_CONFIG.get("maelstrom_rscript", "Rscript")
    
    r_code = f'''
library(maelstrom)
result <- maelstrom::render(
  pattern = {json.dumps(pattern)},
  output_file = {json.dumps(output)},
  bpm = {bpm},
  bars = {bars},
  sample_rate = {sample_rate},
  normalize = {str(normalize).lower()},
  fade_out_bars = 1
)
cat(jsonlite::toJSON(result, auto_unbox = TRUE))
'''
    
    result = subprocess.run([rscript, "-e", r_code], capture_output=True, text=True, timeout=60)
    if result.returncode != 0:
        raise RuntimeError(f"maelstrom render failed: {result.stderr}")
    
    return json.loads(result.stdout)


def validate_maelstrom(pattern: str) -> Dict[str, Any]:
    """Validate pattern with maelstrom parser."""
    rscript = DJ_CONFIG.get("maelstrom_rscript", "Rscript")
    
    r_code = f'''
library(maelstrom)
tryCatch({{
  ast <- maelstrom::parse_pattern({json.dumps(pattern)})
  cat(jsonlite::toJSON(list(valid = TRUE, ast = ast), auto_unbox = TRUE))
}}, error = function(e) {{
  cat(jsonlite::toJSON(list(valid = FALSE, error = e$message), auto_unbox = TRUE))
}})
'''
    
    result = subprocess.run([rscript, "-e", r_code], capture_output=True, text=True, timeout=30)
    return json.loads(result.stdout)


def validate_strudel(pattern: str) -> Dict[str, Any]:
    """Validate pattern with Strudel parser via Node.js."""
    try:
        node_code = f'''
const {{ parse }} = require('@strudel/parser');
try {{
  const ast = parse({json.dumps(pattern)});
  console.log(JSON.stringify({{ valid: true, ast }}));
}} catch (e) {{
  console.log(JSON.stringify({{ valid: false, error: e.message, position: e.index }}));
}}
'''
        result = subprocess.run(["node", "-e", node_code], capture_output=True, text=True, timeout=10)
        return json.loads(result.stdout.strip())
    except (subprocess.SubprocessError, json.JSONDecodeError, FileNotFoundError):
        return {"valid": False, "error": "Strudel parser not available (Node.js/@strudel/parser required)"}


def convert_to_strudel(pattern: str, include_tempo: bool, include_swing: bool,
                       wrap_in_stack: bool, tempo: int = 120, swing: float = 0.1) -> str:
    """Convert uzu pattern to Strudel code.
    API verified against @strudel 1.2.6 — the code strudel.cc ships.
    Full table: skills/dj-hermes/references/strudel-vs-maelstrom.md"""
    lines = []

    # Simple conversion - in reality would need proper AST transformation
    body = f"stack({pattern})" if wrap_in_stack and not pattern.strip().startswith("stack(") else pattern
    if include_swing:
        # swing is a pattern method (1 input); there is no verified setSwing global
        body = f"{body}.swing({swing})"
    if include_tempo:
        # 1 cycle = 1 bar (4/4): setcpm(bpm/4) is the docs idiom
        # (NOT bpm/60 — that made 4-second renders; setcps(bpm/240) equivalent)
        lines.append(f"setcpm({tempo}/4)")
    lines.append(body)
    return "\n".join(lines)


# API Endpoints
@app.get("/health")
async def health():
    return {"status": "ok", "plugin": "dj-hermes", "version": "0.3.0"}


@app.post("/generate", response_model=GenerateResponse)
async def generate(req: GenerateRequest):
    """Generate pattern from prompt via Rhythmancer."""
    # Load genre preset for defaults
    defaults_path = PLUGIN_DIR / "skills" / "dj-hermes" / "defaults.yaml"
    genre_presets = {}
    if defaults_path.exists():
        with open(defaults_path) as f:
            defaults = yaml.safe_load(f)
            genre_presets = defaults.get("genre_presets", {})
    
    genre = req.genre or "house"
    tempo = req.tempo or genre_presets.get(genre, {}).get("tempo", 120)
    bars = req.bars
    
    # Build full prompt for Rhythmancer
    full_prompt = f"{req.prompt} at {tempo}bpm {genre}"
    pattern = run_rhythmancer(full_prompt, tempo, bars, req.temperature)

    return GenerateResponse(pattern=pattern, tempo=tempo, genre=genre, bars=bars,
                            source=GENERATION_SOURCE["source"])


@app.post("/render", response_model=RenderResponse)
async def render(req: RenderRequest):
    """Render pattern to WAV via maelstrom."""
    output = req.output or str(OUTPUT_DIR / f"beat_{int(asyncio.get_event_loop().time())}.wav")
    
    result = run_maelstrom_render(
        pattern=req.pattern,
        output=output,
        bpm=req.bpm,
        bars=req.bars,
        sample_rate=req.sample_rate,
        normalize=req.normalize
    )
    
    return RenderResponse(
        wav_path=output,
        duration_seconds=req.bars * 60 / req.bpm * 4,  # 4/4 time
        sample_rate=req.sample_rate
    )


@app.post("/validate", response_model=ValidateResponse)
async def validate(req: ValidateRequest):
    """Validate pattern against maelstrom and/or Strudel."""
    errors = []
    warnings = []
    
    # Validate with maelstrom
    maelstrom_result = validate_maelstrom(req.pattern)
    if not maelstrom_result.get("valid", False):
        errors.append(f"maelstrom: {maelstrom_result.get('error', 'unknown error')}")
    
    # Validate with Strudel if requested
    if req.check_strudel:
        strudel_result = validate_strudel(req.pattern)
        if not strudel_result.get("valid", False):
            if req.strict:
                errors.append(f"strudel: {strudel_result.get('error', 'unknown error')}")
            else:
                warnings.append(f"strudel: {strudel_result.get('error', 'unknown error')}")
    
    valid = len(errors) == 0
    engine = "maelstrom" + (" + strudel" if req.check_strudel else "")
    
    return ValidateResponse(valid=valid, engine=engine, errors=errors, warnings=warnings)


@app.post("/export", response_model=ExportResponse)
async def export(req: ExportRequest):
    """Export pattern to Strudel code."""
    # For now, assume default tempo/swing - would come from pattern metadata
    strudel_code = convert_to_strudel(
        pattern=req.pattern,
        include_tempo=req.include_tempo,
        include_swing=req.include_swing,
        wrap_in_stack=req.wrap_in_stack,
        tempo=120,
        swing=0.1
    )
    
    session_url = None
    if req.create_session:
        # Would POST to Strudel API to create session
        # session_url = await create_strudel_session(strudel_code)
        pass
    
    return ExportResponse(strudel_code=strudel_code, session_url=session_url)


@app.post("/listen")
async def listen(req: ListenRequest, background_tasks: BackgroundTasks):
    """Play WAV file via system player."""
    file_path = Path(os.path.expanduser(req.file))
    if not file_path.exists():
        raise HTTPException(404, f"File not found: {file_path}")
    
    # Detect player
    player = req.player
    if not player:
        for p in ["ffplay", "aplay", "paplay", "afplay"]:
            if subprocess.run(["which", p], capture_output=True).returncode == 0:
                player = p
                break
        if not player and os.name == "nt":
            player = "start"
    
    if not player:
        raise HTTPException(500, "No audio player found. Install ffplay, aplay, paplay, or afplay.")
    
    # Build command
    if player == "ffplay":
        cmd = ["ffplay", "-nodisp", "-autoexit", f"-volume={int(req.volume*100)}", str(file_path)]
    elif player == "aplay":
        cmd = ["aplay", str(file_path)]
    elif player == "paplay":
        cmd = ["paplay", f"--volume={int(req.volume*65536)}", str(file_path)]
    elif player == "afplay":
        cmd = ["afplay", str(file_path)]
    elif player == "start" and os.name == "nt":
        cmd = ["start", "", str(file_path)]
    else:
        raise HTTPException(500, f"Unsupported player: {player}")
    
    # Run in background
    background_tasks.add_task(subprocess.run, cmd)
    
    return {"status": "playing", "player": player, "file": str(file_path)}


@app.get("/config")
async def get_config():
    """Get current plugin configuration."""
    return DJ_CONFIG


@app.post("/config")
async def update_config(config: Dict[str, Any]):
    """Update plugin configuration (merged into user config)."""
    # In practice, this would update the user's config.yaml
    # For now, just return the merged config
    DJ_CONFIG.update(config)
    return DJ_CONFIG


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8765)