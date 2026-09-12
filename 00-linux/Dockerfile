# =============================================================================
# NTI Session 1 - Linux Training Lab
# Base: Ubuntu 22.04 (chosen over Alpine so command output, man pages, and
# package behavior match what trainees will see on a "real" server distro)
# =============================================================================
FROM ubuntu:22.04

LABEL maintainer="NTI HCIA Big Data Program"
LABEL purpose="Linux Essentials training lab - realistic multi-user environment"

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color

# -----------------------------------------------------------------------------
# 1. Core packages
#    - sudo, passwd: user/permission management
#    - vim, nano: editors (nano for absolute beginners, vim introduced later)
#    - tree, less, man-db: navigation & documentation
#    - net-tools, iputils-ping, curl, wget: general CLI familiarity
#    - procps, htop: process management
#    - bash-completion: quality-of-life, shows tab-completion is a real feature
#    - cron: lets you demo scheduled jobs briefly if time allows (optional use)
# -----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    passwd \
    vim \
    nano \
    tree \
    less \
    man-db \
    net-tools \
    iputils-ping \
    curl \
    wget \
    procps \
    htop \
    bash-completion \
    cron \
    locales \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# 2. Locale (avoids "locale: Cannot set LC_ALL" warnings that confuse beginners)
# -----------------------------------------------------------------------------
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# -----------------------------------------------------------------------------
# 3. Groups - mirrors a real small-company server setup
#    sysadmins : full sudo access
#    developers: shared project access, no sudo
#    interns   : read-only-ish, very restricted
# -----------------------------------------------------------------------------
RUN groupadd sysadmins && \
    groupadd developers && \
    groupadd interns

# -----------------------------------------------------------------------------
# 4. Users - deliberately varied, so every permission concept has a live example
#    root        : exists by default (UID 0) - "the danger zone"
#    ahmed_admin : sysadmin, full sudo, password required for sudo (realistic)
#    sara_dev    : developer, member of 'developers' group, no sudo
#    omar_dev    : second developer -> lets you demo shared group permissions
#                  between two *different* people, not just user vs root
#    intern_user : minimal permissions, in 'interns' group only
# -----------------------------------------------------------------------------
RUN useradd -m -s /bin/bash -G sysadmins ahmed_admin && \
    useradd -m -s /bin/bash -G developers sara_dev && \
    useradd -m -s /bin/bash -G developers omar_dev && \
    useradd -m -s /bin/bash -G interns intern_user

# Simple, memorable passwords for a training lab (NOT for production use)
RUN echo "root:root123" | chpasswd && \
    echo "ahmed_admin:admin123" | chpasswd && \
    echo "sara_dev:dev123" | chpasswd && \
    echo "omar_dev:dev123" | chpasswd && \
    echo "intern_user:intern123" | chpasswd

# sysadmins group gets passworded sudo (realistic - not passwordless)
RUN echo "%sysadmins ALL=(ALL:ALL) ALL" >> /etc/sudoers

# -----------------------------------------------------------------------------
# 5. Pre-built directory structure for permission exercises
#    /opt/company-data   -> root-owned, restricted (chmod 700) - "the vault"
#    /srv/shared-dev     -> group-owned by 'developers', setgid bit demo
#    /srv/reports        -> owned by ahmed_admin, world-readable, group-writable
#    /var/log/lab-app    -> varied file permissions for chmod/find exercises
# -----------------------------------------------------------------------------
RUN mkdir -p /opt/company-data /srv/shared-dev /srv/reports /var/log/lab-app

# The vault: root only
RUN chown root:root /opt/company-data && chmod 700 /opt/company-data && \
    echo "TOP SECRET: quarterly salary figures" > /opt/company-data/confidential.txt

# Shared dev space: group-owned, setgid so new files inherit the group
RUN chgrp developers /srv/shared-dev && chmod 2775 /srv/shared-dev && \
    echo "# Shared Dev Notes" > /srv/shared-dev/notes.md

# Reports: admin-owned, group can write, others can only read
RUN chown ahmed_admin:sysadmins /srv/reports && chmod 664 /srv/reports 2>/dev/null; \
    chmod 775 /srv/reports && \
    echo "Q1 report draft" > /srv/reports/q1_draft.txt

# Log directory with intentionally mixed permissions for find/chmod practice
RUN echo "2024-01-01 app started" > /var/log/lab-app/app.log && \
    echo "2024-01-01 debug trace" > /var/log/lab-app/debug.log && \
    echo "root-only-secret-log" > /var/log/lab-app/audit.log && \
    chmod 644 /var/log/lab-app/app.log && \
    chmod 600 /var/log/lab-app/debug.log && \
    chmod 600 /var/log/lab-app/audit.log && \
    chown root:root /var/log/lab-app/audit.log

# -----------------------------------------------------------------------------
# 6. Working directory & entrypoint
#    Container stays alive with bash so `docker exec` sessions work per-user
# -----------------------------------------------------------------------------
WORKDIR /root
CMD ["/bin/bash", "-c", "echo 'Linux Lab container is up. Use: docker exec -it linux-lab su - <username>' && tail -f /dev/null"]
