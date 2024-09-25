#!/usr/bin/env python3

import os
import logging
import subprocess
import shutil
from dataclasses import dataclass
from typing import Optional, List


@dataclass
class NongitMeta:
    source: str = ""
    branch: str = ""
    rev: Optional[str] = None
    include: List[str] = []


def update(workdir: str, meta: NongitMeta) -> Optional[str]:
    # Fetch latest commit of the branch:
    heads: bytes = subprocess.check_output(
        ["git", "ls-remote", meta.source, f"refs/heads/{meta.branch}"]
    )
    heads = heads.splitlines()
    if len(heads) != 1:
        logging.error("Cannot match the exact branch!")
        return None

    head = heads[0].split()[0].decode("ascii")
    if meta.rev is not None and meta.rev == head:
        logging.info("Already up-to-date, skipped.")
        return head
    else:
        rev = head

    # Before we move ahead, remove all files to keep the repository clean:
    shutil.rmtree(workdir)
    os.mkdir(workdir)

    # A dumb way to update, as git-r3 in gentoo:
    subprocess.check_call(["git", "init"], cwd=workdir)
    subprocess.check_call(["git", "fetch", "--depth=1", meta.source, rev], cwd=workdir)
    if len(meta.include) != 0:
        args = ["--", *meta.include]
    else:
        args = []
    subprocess.check_call(["git", "checkout", "FETCH_HEAD", *args], cwd=workdir)

    # Clear the '.git' directory we don't want:
    shutil.rmtree(os.path.join(workdir, ".git"))

    return rev
