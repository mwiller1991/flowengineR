#!/bin/bash
#SBATCH --job-name=fairness_split
#SBATCH --output=logs/split_%A_%a.out
#SBATCH --error=logs/split_%A_%a.err
#SBATCH --cpus-per-task=1
#SBATCH --time=00:15:00
#SBATCH --mem=4G

# Dynamisch: Anzahl der Splits aus Datei lesen
N_SPLITS=$(cat slurm_inputs/n_splits.txt)

# Nur einmal: Array-Job starten mit sbatch, wenn das Skript direkt ausgeführt wird
if [ -z "$SLURM_ARRAY_TASK_ID" ]; then
  echo "[INFO] Submitting array job with $N_SPLITS splits..."
  sbatch --array=1-"$N_SPLITS" "$0"
  exit 0
fi

# Optional: R-Modul laden oder conda-Umgebung aktivieren
module load R

# Aktuellen Split starten
Rscript run_split.R "$SLURM_ARRAY_TASK_ID"
