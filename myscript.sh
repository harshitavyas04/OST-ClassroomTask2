#!/bin/bash

# Define directories
DATA_DIR="/mnt/c/Users/harshita/ost/shell/data"
MODEL_DIR="/mnt/c/Users/harshita/ost/shell/models"
DEPLOY_DIR="/mnt/c/Users/harshita/ost/shell/deployment"
LOG_FILE="/mnt/c/Users/harshita/ost/shell/logs/training.log"
GIT_REPO="https://github.com/harshitavyas04/OST-ClassroomTask2.git"

# Function to log messages
echo_log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

# Step 1: Fetch latest data
echo_log "Fetching latest data..."
# Add data fetching logic if applicable

# Step 2: Train the model
echo_log "Training the model..."
python train_model.py --data $DATA_DIR --output $MODEL_DIR/latest_model.pkl || {
    echo_log "Model training failed!";
    exit 1;
}

# Step 3: Evaluate model performance
echo_log "Evaluating model performance..."
OLD_MODEL="$MODEL_DIR/best_model.pkl"
NEW_MODEL="$MODEL_DIR/latest_model.pkl"
python evaluate_model.py --old_model $OLD_MODEL --new_model $NEW_MODEL > performance.txt

if grep -q "New model is better" performance.txt; then
    echo_log "Deploying new model..."
    cp $NEW_MODEL $DEPLOY_DIR/model.pkl
    mv $NEW_MODEL $MODEL_DIR/best_model.pkl
else
    echo_log "New model did not improve performance. Skipping deployment."
fi

# Step 4: Archive previous models
echo_log "Archiving old models..."
mkdir -p $MODEL_DIR/archive
mv $MODEL_DIR/model_*.pkl $MODEL_DIR/archive/ 2>/dev/null || echo_log "No old models to archive."

# Step 5: Upload code and PDF to GitHub
echo_log "Uploading files to GitHub..."
cd /mnt/c/Users/harshita/ost/shell || exit 1
git add .
git commit -m "Automated model training and deployment update"
git push $GIT_REPO main || echo_log "Git push failed!"

# Step 6: Upload PDF file (if applicable)
if [ -f "$PDF_FILE" ]; then
    echo_log "Uploading report PDF..."
    git add report.pdf
    git commit -m "Adding report PDF"
    git push || echo_log "Git push for PDF failed!"
else
    echo_log "No report PDF found. Skipping upload."
fi

echo_log "Automation complete!"


