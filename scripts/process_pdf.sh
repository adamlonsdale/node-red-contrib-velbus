#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $(basename "$0") <pdf-path> [density]
  pdf-path : Path to the PDF to process (required)
  density  : DPI for rasterising (optional, default 200)

Outputs per-page PNGs, OCR text files, and a combined OCR file alongside the PDF.
USAGE
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 ]]; then
  usage >&2
  exit 1
fi

pdf_path=$1
if [[ ! -f $pdf_path ]]; then
  echo "PDF not found: $pdf_path" >&2
  exit 1
fi

density=${2:-200}

pdf_dir=$(dirname "$pdf_path")
pdf_file=$(basename "$pdf_path")
base_name=${pdf_file%.pdf}

png_pattern="$pdf_dir/${base_name}_page_%02d.png"

echo "[process_pdf] Rendering pages from $pdf_file at ${density} DPI" >&2
magick -density "$density" "$pdf_path" "$png_pattern"

shopt -s nullglob
pages=("$pdf_dir"/${base_name}_page_*.png)
if (( ${#pages[@]} == 0 )); then
  echo "No PNG pages created for $pdf_path" >&2
  exit 1
fi

echo "[process_pdf] Running Tesseract on ${#pages[@]} pages" >&2
for png in "${pages[@]}"; do
  tesseract "$png" "${png%.png}" -l eng --psm 6 >/dev/null
done

combined="$pdf_dir/${base_name}_ocr.txt"
echo "[process_pdf] Combining OCR output into $(basename "$combined")" >&2
python3 - "$pdf_dir" "$base_name" <<'PY'
import pathlib
import sys

pdf_dir = pathlib.Path(sys.argv[1])
base = sys.argv[2]
output = pdf_dir / f"{base}_ocr.txt"
pages = sorted(pdf_dir.glob(f"{base}_page_*.txt"))
with output.open('w', encoding='utf-8') as out:
    for page in pages:
        out.write(f"===== {page.name} =====\n")
        out.write(page.read_text(encoding='utf-8'))
        out.write('\n')
PY

echo "[process_pdf] Completed processing for $pdf_file" >&2
