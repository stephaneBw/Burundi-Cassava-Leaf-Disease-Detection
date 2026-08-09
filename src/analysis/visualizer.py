"""Render training and evaluation metrics into report-ready figures."""

import os

import keras
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from sklearn.manifold import TSNE
from sklearn.metrics import confusion_matrix, precision_recall_curve, roc_curve


class Visualizer:
    def __init__(self, output_dir: str, config: dict):
        # Keep all generated reports grouped under the selected model version.
        self.config = config
        self.fig_dir = os.path.join(output_dir, "figures")
        self.tab_dir = os.path.join(output_dir, "tables")
        os.makedirs(self.fig_dir, exist_ok=True)
        os.makedirs(self.tab_dir, exist_ok=True)

    def save_training_history(
        self, history: keras.callbacks.History, transition_epoch: int | None = None
    ) -> None:
        # Persist raw history before rendering plots so metrics remain machine-readable.
        df = pd.DataFrame(history.history)
        df.to_csv(os.path.join(self.tab_dir, "training_metrics.csv"), index_label="epoch")

        plt.figure(figsize=(15, 6))

        metrics = ["accuracy", "loss"]
        for i, metric in enumerate(metrics, 1):
            plt.subplot(1, 2, i)
            if metric in df.columns:
                plt.plot(df.index + 1, df[metric], label="Train", linewidth=2)
            if f"val_{metric}" in df.columns:
                plt.plot(df.index + 1, df[f"val_{metric}"], label="Val", linewidth=2)

            # Mark the fine-tuning boundary for two-stage training runs.
            if transition_epoch is not None and transition_epoch < len(df):
                plt.axvline(
                    x=transition_epoch,
                    color="red",
                    linestyle="--",
                    alpha=0.8,
                    label="Fine-Tuning Start",
                )
                y_limits = plt.ylim()
                y_pos = y_limits[0] + (y_limits[1] - y_limits[0]) * 0.1
                plt.text(transition_epoch, y_pos, " Stage 2", color="red", fontweight="bold")

            plt.title(f"Model {metric.title()}")
            plt.xlabel("Epochs")
            plt.ylabel(metric.title())
            plt.legend()
            plt.grid(True, alpha=0.3)

        plt.tight_layout()
        plt.savefig(os.path.join(self.fig_dir, "training_history.png"), dpi=300)
        plt.close()

    def plot_confusion_matrix(
        self, y_true: np.ndarray, y_pred: np.ndarray, classes: list[str]
    ) -> None:
        # Render the full matrix and a compact table of the most common mistakes.
        cm = confusion_matrix(y_true, y_pred)
        plt.figure(figsize=(20, 20))
        sns.heatmap(
            cm, annot=False, fmt="d", cmap="Blues", xticklabels=classes, yticklabels=classes
        )
        plt.xticks(rotation=90)
        plt.tight_layout()
        plt.savefig(os.path.join(self.fig_dir, "confusion_matrix.png"), dpi=300)
        plt.close()

        np.fill_diagonal(cm, 0)
        pairs = []
        for i in range(len(classes)):
            for j in range(len(classes)):
                if cm[i, j] > 0:
                    pairs.append((classes[i], classes[j], cm[i, j]))
        pairs.sort(key=lambda x: x[2], reverse=True)
        pd.DataFrame(pairs, columns=["True", "Predicted", "Count"]).head(20).to_csv(
            os.path.join(self.tab_dir, "top_confusions.csv"), index=False
        )

    def plot_class_f1_scores(self, report_path: str) -> None:
        # This plot is optional because older evaluation runs may not have the CSV.
        if not os.path.exists(report_path):
            return

        df = pd.read_csv(report_path, index_col=0)
        metrics_df = df.iloc[:-3]

        if "f1-score" not in metrics_df.columns:
            return

        metrics_df = metrics_df.sort_values(by="f1-score", ascending=True)

        plt.figure(figsize=(18, 12))
        bars = plt.barh(
            metrics_df.index,
            metrics_df["f1-score"],
            color="#3182bd",
            edgecolor="black",
            linewidth=0.5,
        )

        plt.xlabel("F1 Score")
        plt.title("Per-Class F1 Score Analysis", fontsize=16, fontweight="bold")
        plt.grid(axis="x", linestyle="--", alpha=0.3)
        plt.xlim(0, 1.05)

        # Annotate exact scores to make the exported figure useful without the CSV.
        for bar in bars:
            width = bar.get_width()
            plt.text(
                width + 0.005,
                bar.get_y() + bar.get_height() / 2,
                f"{width:.3f}",
                ha="left",
                va="center",
                fontsize=10,
                fontweight="bold",
                color="black",
            )

        plt.tight_layout()
        plt.savefig(os.path.join(self.fig_dir, "class_f1_scores.png"), dpi=300)
        plt.close()

    def plot_data_balance(
        self, class_counts: list[int], class_weights: list[float], classes: list[str]
    ) -> None:
        # Store both counts and weights so the imbalance strategy is auditable.
        data = {"Class": classes, "Count": class_counts, "Weight": class_weights}
        df = pd.DataFrame(data)
        df.to_csv(os.path.join(self.tab_dir, "class_metadata.csv"), index=False)

        _, (ax1, ax2) = plt.subplots(1, 2, figsize=(24, 16), sharey=True)

        sns.barplot(data=df, x="Count", y="Class", ax=ax1, color="#4e79a7", edgecolor="white")
        ax1.set_title(
            "Class Distribution (Number of Samples)", fontsize=15, fontweight="bold", pad=20
        )
        ax1.set_xlabel("Count", fontsize=12)
        ax1.grid(True, axis="x", linestyle="--", alpha=0.6)

        for i, count in enumerate(class_counts):
            ax1.text(
                count + 5,
                i,
                f" {count}",
                color="black",
                va="center",
                fontsize=9,
                fontweight="bold",
            )

        sns.barplot(data=df, x="Weight", y="Class", ax=ax2, color="#f28e2b", edgecolor="white")
        ax2.set_title(
            "Class Weight Strategy (Inverse Frequency)", fontsize=15, fontweight="bold", pad=20
        )
        ax2.set_xlabel("Weight Value", fontsize=12)
        ax2.set_ylabel("")
        ax2.grid(True, axis="x", linestyle="--", alpha=0.6)

        for i, weight in enumerate(class_weights):
            ax2.text(
                weight + 0.05,
                i,
                f" {weight:.2f}",
                color="black",
                va="center",
                fontsize=9,
                fontweight="bold",
            )

        plt.tight_layout()
        plt.savefig(os.path.join(self.fig_dir, "data_balance_analysis.png"), dpi=300)
        plt.close()

    def plot_pr_curve(
        self, y_true_onehot: np.ndarray, y_prob: np.ndarray, classes: list[str]
    ) -> None:
        # Plot one-vs-rest curves for every class on a shared axis.
        plt.figure(figsize=(12, 8))
        for i in range(len(classes)):
            precision, recall, _ = precision_recall_curve(y_true_onehot[:, i], y_prob[:, i])
            plt.plot(recall, precision, lw=1, alpha=0.5)
        plt.xlabel("Recall")
        plt.ylabel("Precision")
        plt.title("Precision-Recall Curve")
        plt.savefig(os.path.join(self.fig_dir, "pr_curve.png"), dpi=300)
        plt.close()

    def plot_roc_curve(
        self, y_true_onehot: np.ndarray, y_prob: np.ndarray, classes: list[str]
    ) -> None:
        # Plot one-vs-rest ROC curves for every class on a shared axis.
        plt.figure(figsize=(12, 8))
        for i in range(len(classes)):
            fpr, tpr, _ = roc_curve(y_true_onehot[:, i], y_prob[:, i])
            plt.plot(fpr, tpr, lw=1, alpha=0.3)
        plt.plot([0, 1], [0, 1], "k--")
        plt.title("ROC Curve")
        plt.xlabel("False Positive Rate")
        plt.ylabel("True Positive Rate")
        plt.savefig(os.path.join(self.fig_dir, "roc_curve.png"), dpi=300)
        plt.close()

    def plot_top_k_accuracy(
        self, y_true: np.ndarray, y_prob: np.ndarray, k_values: list[int] | None = None
    ) -> None:
        # Default to the common retrieval-style checkpoints used in model reports.
        if k_values is None:
            k_values = [1, 3, 5]
        y_prob = np.asarray(y_prob, dtype=np.float32)
        k_values = [k for k in k_values if k <= y_prob.shape[1]]
        if not k_values:
            return

        # Calculate top-k metrics from probabilities to catch near-miss behavior.
        accuracies = []
        y_true_cat = keras.utils.to_categorical(y_true, num_classes=y_prob.shape[1])
        for k in k_values:
            acc = keras.metrics.top_k_categorical_accuracy(y_true_cat, y_prob, k=k)
            accuracies.append(float(np.mean(acc)))

        plt.figure(figsize=(10, 6))
        labels = [f"Top-{k}" for k in k_values]
        sns.barplot(x=labels, y=accuracies, hue=labels, palette="viridis", legend=False)
        plt.ylim(0, 1.1)
        for i, val in enumerate(accuracies):
            plt.text(i, val + 0.02, f"{val:.4f}", ha="center")
        plt.title("Top-K Accuracy Metrics")
        plt.savefig(os.path.join(self.fig_dir, "top_k_accuracy.png"), dpi=300)
        plt.close()

    def plot_latency_histogram(self, latencies: list[float]) -> None:
        # Keep latency visible as a distribution, not only as an average.
        plt.figure(figsize=(12, 6))
        sns.histplot(latencies, bins=50, kde=True, color="purple")
        plt.xlabel("Inference Time (ms)")
        plt.title("Inference Latency Distribution")

        mean_val = float(np.mean(latencies))
        plt.axvline(
            x=mean_val, color="red", linestyle="--", alpha=0.8, label=f"Mean: {mean_val:.2f} ms"
        )
        plt.legend()
        plt.savefig(os.path.join(self.fig_dir, "latency_histogram.png"), dpi=300)
        plt.close()

    def plot_confidence_calibration(
        self, y_true: np.ndarray, y_pred: np.ndarray, y_prob_max: np.ndarray
    ) -> None:
        # Compare confidence distributions for correct and incorrect predictions.
        correct = y_true == y_pred
        plt.figure(figsize=(12, 6))
        sns.histplot(
            y_prob_max[correct], color="green", alpha=0.5, label="Correct", bins=30, kde=True
        )
        sns.histplot(y_prob_max[~correct], color="red", alpha=0.5, label="Wrong", bins=30, kde=True)
        plt.xlabel("Confidence Score")
        plt.ylabel("Frequency")
        plt.legend()
        plt.title("Model Confidence vs Prediction Correctness")
        plt.savefig(os.path.join(self.fig_dir, "confidence_calibration.png"), dpi=300)
        plt.close()

    def plot_tsne(
        self, features: np.ndarray, y_true: np.ndarray, classes: list[str], n_samples: int = 2000
    ) -> None:
        # Bound t-SNE cost while preserving a representative class spread.
        if len(features) < 2:
            return

        if len(features) > n_samples:
            seed = self.config.get("data", {}).get("seed", 42)
            rng = np.random.default_rng(seed)
            idx = rng.choice(len(features), n_samples, replace=False)
            features = features[idx]
            y_true = y_true[idx]

        perplexity = min(30, max(1, len(features) - 1))
        tsne = TSNE(
            n_components=2,
            random_state=42,
            init="pca",
            learning_rate="auto",
            perplexity=perplexity,
        )
        embedded = tsne.fit_transform(features)

        plt.figure(figsize=(28, 20))
        sns.scatterplot(
            x=embedded[:, 0],
            y=embedded[:, 1],
            hue=[classes[i] for i in y_true],
            palette="tab20",
            s=120,
            alpha=0.8,
            legend="full",
        )
        plt.legend(
            bbox_to_anchor=(1.01, 1),
            loc="upper left",
            ncol=1,
            fontsize=14,
            markerscale=2,
            labelspacing=1.2,
            borderaxespad=0.0,
            frameon=True,
            shadow=True,
        )
        plt.title("t-SNE Projection of High-Level Features", fontsize=20, pad=20)
        plt.xticks(fontsize=12)
        plt.yticks(fontsize=12)
        plt.tight_layout()
        plt.savefig(os.path.join(self.fig_dir, "tsne_clusters.png"), dpi=300)
        plt.close()
