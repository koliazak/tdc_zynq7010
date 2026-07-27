import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

CSV_FILE = "tdc_data.csv"


def load_data(csv_file):
    df = pd.read_csv(csv_file)
    if "Phase_step_ps" not in df.columns or "PopCount" not in df.columns:
        raise ValueError("CSV must contain 'Phase_step_ps' and 'PopCount' columns")
    return df


def aggregate_by_phase(df: pd.DataFrame) -> pd.DataFrame :
    """
    Collapse multiple samples per phase step into a single PopCount value.
    """

    agg = grouped.apply(pick_mode, include_groups=False).reset_index(name="PopCount")

    return agg.sort_values("Phase_step_ps").reset_index(drop=True)


def extract_transitions(df: pd.DataFrame):
    """
    Extract transition points T[k] where PopCount first reaches k.
    transitions[k] is the phase at which the output changes to code k.
    Missing codes are filled with NaN.
    """
    max_code = int(df["PopCount"].max())
    transitions = [np.nan] * (max_code + 1)  # index k = transition to code k

    for k in range(1, max_code + 1):
        rows = df[df["PopCount"] >= k]
        if not rows.empty:
            transitions[k] = rows["Phase_step_ps"].iloc[0]

    return transitions


def compute_dnl_inl(transitions: list, dead_zone_end: float | None = None) -> dict:
    """
    Returns:
        dict with lsb_ps, dnl, inl, codes, dead_zone_ps, range_ps
    """
    valid = [(k, t) for k, t in enumerate(transitions) if k > 0 and not np.isnan(t)]
    if len(valid) < 2:
        raise ValueError("Need at least two valid transition points")

    codes = [k for k, _ in valid]
    times = np.array([t for _, t in valid], dtype=float)

    if dead_zone_end is None:
        dead_zone_end = times[0]

    n_steps = len(times) - 1
    lsb_ps = (times[-1] - times[0]) / n_steps

    dnl = [np.nan]
    inl = [0.0]
    for i in range(1, len(times)):
        step = times[i] - times[i - 1]
        dnl.append(step / lsb_ps - 1.0)
        inl.append((times[i] - times[0]) / lsb_ps - i)

    return {
        "codes": codes,
        "transitions_ps": times,
        "lsb_ps": lsb_ps,
        "dnl": np.array(dnl),
        "inl": np.array(inl),
        "dead_zone_ps": dead_zone_end,
        "range_ps": times[-1] - dead_zone_end,
    }


def compute_basic_metrics(df: pd.DataFrame) -> dict:
    """Compute basic TDC characteristics from the aggregated sweep data."""
    zero_rows = df[df["PopCount"] == 0]
    dead_zone_ps = zero_rows["Phase_step_ps"].iloc[-1] if not zero_rows.empty else 0.0

    max_pop = int(df["PopCount"].max())
    saturation_row = df[df["PopCount"] == max_pop].iloc[0]
    saturation_phase = saturation_row["Phase_step_ps"]

    active = df[df["PopCount"] > 0]
    min_phase = active["Phase_step_ps"].min() if not active.empty else dead_zone_ps

    avg_resolution = (saturation_phase - min_phase) / max_pop if max_pop > 0 else np.nan

    # Monotonicity check on aggregated data
    diff = df["PopCount"].diff().dropna()
    violations = diff[diff < 0]
    is_monotonic = violations.empty

    return {
        "dead_zone_ps": dead_zone_ps,
        "saturation_code": max_pop,
        "saturation_phase_ps": saturation_phase,
        "avg_resolution_ps": avg_resolution,
        "monotonic": bool(is_monotonic),
        "monotonic_violations": int(len(violations)),
        "total_steps": int(len(df) - 1),
    }


def plot_characteristics(metrics, save_path=None):
    """Plot transfer function, DNL and INL."""
    fig, axes = plt.subplots(3, 1, figsize=(10, 10), sharex=True)

    codes = metrics["codes"]
    times = metrics["transitions_ps"]

    # Transfer function
    ax = axes[0]
    ax.plot(times, codes, "-o", markersize=2)
    ax.axline(
        (times[0], codes[0]),
        slope=1.0 / metrics["lsb_ps"],
        color="r",
        linestyle="--",
        label=f"ideal (LSB={metrics['lsb_ps']:.2f} ps)",
    )
    ax.set_ylabel("Output code")
    ax.set_title("TDC Transfer Function")
    ax.legend()
    ax.grid(True)

    # DNL
    ax = axes[1]
    ax.bar(times, metrics["dnl"], width=metrics["lsb_ps"] * 0.8)
    ax.axhline(0, color="k", linewidth=0.5)
    ax.set_ylabel("DNL [LSB]")
    ax.set_title("Differential Non-Linearity")
    ax.grid(True)

    # INL
    ax = axes[2]
    ax.plot(times, metrics["inl"], "-o", markersize=2)
    ax.axhline(0, color="k", linewidth=0.5)
    ax.set_ylabel("INL [LSB]")
    ax.set_xlabel("Phase [ps]")
    ax.set_title("Integral Non-Linearity")
    ax.grid(True)

    plt.tight_layout()
    if save_path:
        plt.savefig(save_path, dpi=150)
    plt.show()


if __name__ == "__main__":
    df_raw = load_data(CSV_FILE)
    print(f"Loaded {len(df_raw)} raw samples")

    df = aggregate_by_phase(df_raw)
    print(f"Aggregated to {len(df)} unique phase steps (mode of PopCount)")

    basic = compute_basic_metrics(df)
    print("\n=== Basic Metrics ===")
    for k, v in basic.items():
        print(f"{k}: {v}")

    transitions = extract_transitions(df)
    metrics = compute_dnl_inl(transitions, dead_zone_end=basic["dead_zone_ps"])

    print("\n=== DNL/INL Metrics ===")
    print(f"LSB: {metrics['lsb_ps']:.3f} ps")
    print(f"Dead zone: {metrics['dead_zone_ps']:.2f} ps")
    print(f"Useful range: {metrics['range_ps']:.2f} ps")
    print(f"DNL min / max: {np.nanmin(metrics['dnl']):.3f} / {np.nanmax(metrics['dnl']):.3f} LSB")
    print(f"INL min / max: {np.nanmin(metrics['inl']):.3f} / {np.nanmax(metrics['inl']):.3f} LSB")
    print(f"RMS DNL: {np.nanstd(metrics['dnl']):.3f} LSB")
    print(f"RMS INL: {np.nanstd(metrics['inl']):.3f} LSB")

    plot_characteristics(metrics, save_path="tdc_characteristics.png")
