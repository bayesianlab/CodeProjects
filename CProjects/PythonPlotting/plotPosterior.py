#!/usr/bin/env python3
import argparse
import sys
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

def main():
    parser = argparse.ArgumentParser(description="Plot histograms of posterior samples with true values from a file.")
    
    parser.add_argument("csv_file", type=str, help="Path to the CSV with posterior samples")
    
    # New argument to take a separate file for true values
    parser.add_argument(
        "--true-file", 
        type=str, 
        help="CSV file containing true values. Must have headers matching the main CSV."
    )
    
    parser.add_argument("-o", "--output", type=str, default="posteriors_histograms.png")
    parser.add_argument("--bins", type=int, default=50)
    parser.add_argument("--title", type=str, default="Posterior Distributions")
    parser.add_argument("--no-show", action="store_true")
    parser.add_argument("--dpi", type=int, default=150)
    parser.add_argument("--no-kde", action="store_true")
    
    args = parser.parse_args()


    # Load True Values from file (No Header)
    true_vals_list = []
    if args.true_file:
        try:
            # header=None tells pandas the first line is data, not column names
            true_df = pd.read_csv(args.true_file, header=None)
            # Flatten the first row into a list
            true_vals_list = true_df.iloc[0].tolist()
        except Exception as e:
            print(f"Error reading true values CSV: {e}", file=sys.stderr)
            sys.exit(1)

    # Load Posterior Samples
    try:
        df = pd.read_csv(args.csv_file)
        numeric_cols = df.select_dtypes(include="number").columns.tolist()
    except Exception as e:
        print(f"Error reading sample CSV: {e}", file=sys.stderr)
        sys.exit(1)

    n = len(numeric_cols)
    ncols = min(3, n)
    nrows = (n + ncols - 1) // ncols

    fig, axes = plt.subplots(
        nrows=nrows, ncols=ncols,
        figsize=(5 * ncols, 4 * nrows),
        squeeze=False
    )
    axes = axes.flatten()

    colmeans = df.mean()

    for i, col in enumerate(numeric_cols):
        ax = axes[i]
        sns.histplot(
            data=df[col].dropna(), bins=args.bins, kde=not args.no_kde,
            stat="density", ax=ax, color="cornflowerblue", alpha=0.7
        )
        
        # Match by index (position) instead of column name
        if i < len(true_vals_list):
            true_val = true_vals_list[i]
            ax.axvline(true_val, color="red", linestyle="--", linewidth=2)
            
            ax.text(
                true_val, 1.02, f'True: {true_val:.4f}', 
                color='red', ha='center', va='bottom', fontweight='bold',
                transform=ax.get_xaxis_transform()
            )
        
        ax.set_title(f"Estimated mean value: {colmeans[col]:.4f}", fontsize=12, pad=25)
        ax.set_xlabel("Value")
        ax.set_ylabel("Density")
        ax.grid(True, alpha=0.3, linestyle="--")

    for j in range(i + 1, len(axes)):
        axes[j].set_visible(False)

    fig.suptitle(args.title, fontsize=16, y=1.05)
    fig.tight_layout()

    plt.savefig(args.output, dpi=args.dpi, bbox_inches="tight")
    if not args.no_show:
        plt.show()

if __name__ == "__main__":
    main()