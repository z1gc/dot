#!/usr/bin/env python3

import os
import logging
import subprocess
import shutil
from dataclasses import dataclass, field
from typing import Optional, List


@dataclass
class NongitMeta:
    source: str = ""
    branch: str = ""
    rev: Optional[str] = None
    include: List[str] = field(default_factory=list)
    dry_run: bool = True


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

    # A dumb way to update, as git-r3 in gentoo:
    def check_call_git(*args: str):
        # Throws exception:
        if meta.dry_run:
            logging.info("Run: 'git %s' in %s", " ".join(args), workdir)
        else:
            subprocess.check_call(["git"] + list(args), cwd=workdir)

    check_call_git("init")
    check_call_git("fetch", "--depth=1", meta.source, rev)
    if len(meta.include) != 0:
        args = ["--", *meta.include]
    else:
        args = []
    check_call_git("checkout", "FETCH_HEAD", *args)

    # Clear the '.git' directory we don't want:
    if not meta.dry_run:
        shutil.rmtree(os.path.join(workdir, ".git"))

    return rev
