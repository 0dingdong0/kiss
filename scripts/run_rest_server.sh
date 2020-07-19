#!/bin/bash
source .venv/bin/activate
uvicorn rest.main:app --host 0.0.0.0 --reload

