#!/usr/bin/env python3
"""Submit and poll Aristotle jobs for this project.

Usage:
  .venv/bin/python aristotle/check-aristotle.py
  .venv/bin/python aristotle/check-aristotle.py submit aristotle/aristotle-in/name.lean [note]
  .venv/bin/python aristotle/check-aristotle.py submit-dir path/to/dir path/to/prompt.md [note]

This is a small local wrapper around Harmonic's `aristotlelib` 2.x API. It keeps
job metadata in `aristotle/aristotle-jobs.json`.
"""

from __future__ import annotations

import asyncio
import json
import shutil
import sys
import tarfile
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
JOBS_FILE = HERE / "aristotle-jobs.json"


def load_jobs() -> dict:
    if not JOBS_FILE.exists():
        return {"jobs": [], "completed": []}
    with JOBS_FILE.open() as f:
        return json.load(f)


def save_jobs(data: dict) -> None:
    with JOBS_FILE.open("w") as f:
        json.dump(data, f, indent=2)
        f.write("\n")
    print(f"Updated {JOBS_FILE}")


def extract_tar_safely(archive_path: Path, output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    output_root = output_dir.resolve()
    with tarfile.open(archive_path, "r:*") as archive:
        for member in archive.getmembers():
            target = (output_dir / member.name).resolve()
            try:
                target.relative_to(output_root)
            except ValueError as exc:
                raise RuntimeError(f"unsafe archive member path: {member.name}") from exc
        archive.extractall(output_dir)


def load_dotenv() -> None:
    """Load ARISTOTLE_API_KEY from a local .env file if it exists."""
    import os

    env_path = ROOT / ".env"
    if not env_path.exists():
        return
    for raw in env_path.read_text().splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key == "ARISTOTLE_API_KEY" and value and "ARISTOTLE_API_KEY" not in os.environ:
            os.environ["ARISTOTLE_API_KEY"] = value


def require_api_key() -> bool:
    import os

    load_dotenv()
    if not os.environ.get("ARISTOTLE_API_KEY"):
        print("ERROR: ARISTOTLE_API_KEY is not set.", file=sys.stderr)
        print("Create a key at https://aristotle.harmonic.fun/dashboard/keys", file=sys.stderr)
        print("then export it or put it in a local .env file.", file=sys.stderr)
        return False
    return True


async def check_all() -> None:
    if not require_api_key():
        return
    try:
        from aristotlelib import Project
    except ModuleNotFoundError:
        print("ERROR: Python package `aristotlelib` is not installed.", file=sys.stderr)
        print("Run `.venv/bin/python -m pip install aristotlelib`.", file=sys.stderr)
        return

    data = load_jobs()
    jobs = data.get("jobs", [])
    pending = [
        j for j in jobs
        if j.get("status") not in ("done", "downloaded", "expired", "failed", "negated")
    ]

    if not pending:
        print("No pending Aristotle jobs.")
        return

    for job in pending:
        job_id = job["id"]
        target = job.get("target", "?")
        short = job_id[:8]
        try:
            project = await Project.from_id(job_id)
            await project.refresh()
            raw_status = getattr(project, "status", "unknown")
            status = getattr(raw_status, "name", str(raw_status))
            status_lower = status.lower()
            print(f"[{short}] {target}: {status}")
            task_status = None
            try:
                tasks, _ = await project.get_tasks(limit=1)
                if tasks:
                    task = tasks[0]
                    task_status = task.status.name
                    percent = task.percent_complete
                    percent_text = f", {percent}%" if percent is not None else ""
                    print(f"  task {task.agent_task_id[:8]}: {task_status}{percent_text}")
                    if task.output_summary:
                        print(f"  summary: {task.output_summary}")
            except Exception as exc:
                print(f"  task status unavailable: {exc}")

            if "idle" in status_lower:
                if getattr(project, "has_files", False):
                    out_path = HERE / job["output"]
                    archive_path = out_path.with_suffix(".tar.gz")
                    archive_path.parent.mkdir(parents=True, exist_ok=True)
                    downloaded = await project.get_files(archive_path)
                    extract_tar_safely(downloaded, out_path)
                    job["status"] = "downloaded"
                    job["archive"] = str(downloaded)
                    job["solution"] = str(out_path)
                    print(f"  downloaded archive to {downloaded}")
                    print(f"  extracted project files to {out_path}")
                else:
                    job["status"] = (task_status or "idle-no-files").lower()
                    print("  project is idle but has no result files")
            elif "negat" in status_lower or "disprov" in status_lower:
                job["status"] = "negated"
                print("  Aristotle appears to have negated/disproved the statement.")
            elif "fail" in status_lower:
                job["status"] = "failed"
                print("  Aristotle failed on this job.")
            else:
                print("  still running")
        except Exception as exc:
            if "500" in str(exc):
                job["status"] = "expired"
                print(f"[{short}] {target}: expired (server 500)")
            else:
                print(f"[{short}] {target}: error: {exc}")

    save_jobs(data)


async def submit(file_path: str, note: str = "") -> None:
    if not require_api_key():
        return
    try:
        from aristotlelib import Project
    except ModuleNotFoundError:
        print("ERROR: Python package `aristotlelib` is not installed.", file=sys.stderr)
        print("Run `.venv/bin/python -m pip install aristotlelib`.", file=sys.stderr)
        return

    path = Path(file_path)
    if not path.exists():
        print(f"ERROR: submission file not found: {path}", file=sys.stderr)
        return

    output_path = HERE / "aristotle-out" / f"{path.stem}_aristotle"
    prompt = (
        f"Prove the Lean theorem in `{path.name}`. "
        "If the theorem is false or missing hypotheses, report the issue clearly. "
        "Keep the result as a Lean file suitable for integration into the source project."
    )

    with tempfile.TemporaryDirectory(prefix=f"aristotle-{path.stem}-") as tmp:
        tmp_path = Path(tmp)
        shutil.copy(path, tmp_path / path.name)
        project = await Project.create_from_directory(prompt, tmp_path)

    job_id = project.object_id
    data = load_jobs()
    path_abs = path.resolve()
    try:
        rel_submission = str(path_abs.relative_to(HERE.resolve()))
    except ValueError:
        rel_submission = str(path)
    rel_output = str(output_path.resolve().relative_to(HERE.resolve()))

    data["jobs"] = [j for j in data.get("jobs", []) if j.get("submission") != rel_submission]
    data.setdefault("completed", [])
    data["jobs"].append(
        {
            "id": job_id,
            "submission": rel_submission,
            "output": rel_output,
            "target": path.stem,
            "note": note,
            "status": "submitted",
        }
    )
    save_jobs(data)
    print(f"Submitted {path.name} as Aristotle job {job_id[:8]}")


async def submit_directory(dir_path: str, prompt_path: str, note: str = "") -> None:
    if not require_api_key():
        return
    try:
        from aristotlelib import Project
    except ModuleNotFoundError:
        print("ERROR: Python package `aristotlelib` is not installed.", file=sys.stderr)
        print("Run `.venv/bin/python -m pip install aristotlelib`.", file=sys.stderr)
        return

    directory = Path(dir_path)
    prompt_file = Path(prompt_path)
    if not directory.is_dir():
        print(f"ERROR: submission directory not found: {directory}", file=sys.stderr)
        return
    if not prompt_file.exists():
        print(f"ERROR: prompt file not found: {prompt_file}", file=sys.stderr)
        return

    prompt = prompt_file.read_text()
    output_path = HERE / "aristotle-out" / f"{directory.name}_aristotle"
    project = await Project.create_from_directory(prompt, directory)

    job_id = project.object_id
    data = load_jobs()
    dir_abs = directory.resolve()
    try:
        rel_submission = str(dir_abs.relative_to(HERE.resolve()))
    except ValueError:
        rel_submission = str(directory)
    rel_output = str(output_path.resolve().relative_to(HERE.resolve()))

    data["jobs"] = [j for j in data.get("jobs", []) if j.get("submission") != rel_submission]
    data.setdefault("completed", [])
    data["jobs"].append(
        {
            "id": job_id,
            "submission": rel_submission,
            "output": rel_output,
            "target": directory.name,
            "note": note,
            "status": "submitted",
        }
    )
    save_jobs(data)
    print(f"Submitted {directory.name} as Aristotle job {job_id[:8]}")


def main() -> None:
    if len(sys.argv) >= 2 and sys.argv[1] == "submit":
        if len(sys.argv) < 3:
            print("Usage: check-aristotle.py submit <file> [note]", file=sys.stderr)
            sys.exit(2)
        note = sys.argv[3] if len(sys.argv) >= 4 else ""
        asyncio.run(submit(sys.argv[2], note))
    elif len(sys.argv) >= 2 and sys.argv[1] == "submit-dir":
        if len(sys.argv) < 4:
            print("Usage: check-aristotle.py submit-dir <dir> <prompt-file> [note]", file=sys.stderr)
            sys.exit(2)
        note = sys.argv[4] if len(sys.argv) >= 5 else ""
        asyncio.run(submit_directory(sys.argv[2], sys.argv[3], note))
    else:
        asyncio.run(check_all())


if __name__ == "__main__":
    main()
