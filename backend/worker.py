"""Vita background worker skeleton (Phase 1). Real jobs (alerts, digests) land in later phases."""
import time


def main():
    print("worker up; waiting for jobs (stub)", flush=True)
    while True:
        time.sleep(60)


if __name__ == "__main__":
    main()
