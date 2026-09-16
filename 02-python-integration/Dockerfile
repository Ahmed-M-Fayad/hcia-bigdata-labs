# =============================================================================
# NTI Session 2 Wrap-up - Python <-> MySQL Integration Demo
# Base: python:3.11-slim (small image, this container only needs a handful of
# libraries, not a full data-science stack)
# =============================================================================
FROM python:3.11-slim

LABEL maintainer="NTI HCIA Big Data Program"
LABEL purpose="Live demo bridging the Database Essentials & SQL lab with Python"

WORKDIR /app

# -----------------------------------------------------------------------------
# Only 3 libraries needed for the demo:
#   pandas    - DataFrames, the shape data takes for the rest of the program
#   sqlalchemy - clean connection/engine handling
#   pymysql   - the actual MySQL driver SQLAlchemy talks through
# -----------------------------------------------------------------------------
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY demo_query.py .

# Container just stays alive - the instructor runs the script on cue with:
#   docker exec -it pyint-lab-python python demo_query.py
# (mirrors the pattern used in 00-linux for the same reason: control the
# timing live in front of the class instead of it running on container start)
CMD ["/bin/bash", "-c", "echo 'Python integration lab is up. Run: docker exec -it pyint-lab-python python demo_query.py' && tail -f /dev/null"]
