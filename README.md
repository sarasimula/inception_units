# inception_units
Analysis pipeline for studying how single-unit activity is modulated by internal physiological rhythms (heartbeat, breathing, gastric/EGG) across brain states, using chronic Neuropixels recordings.

## Project overview
Characterize neurons modulated by cardiac, respiratory, and gastric signals, and whether this coupling depends on brain state (wake, quiet wakefulness, REM, slow-wave sleep).

Current approach:
- Compute PSTHs / raster plots locked to physiological events (heartbeats, breaths, gastric cycle minima) over full recordings, activity/inactivity, then within specific brain states (sws/rem).
- Compare activity vs. inactivity as a first pass, before splitting into finer-grained states (quiet wakefulness / REM / SWS) once the sleep-state pipeline is validated.
- Use surrogate/shuffle controls (randomized event timestamps or fake spikes) to assess significance of any observed coupling (tbd).

## Repo structure
```
inception_units/
├── main_*.m          # Main analysis script(s) — entry point for running the pipeline end-to-end
├── utils          # Dependencies for plotting etc
├── ...  
└── README.md
```
