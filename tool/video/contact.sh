#!/bin/bash
# contact.sh <project> [time]: one frame per scene → out/contact.png
S=/Users/sufyanthawry/.claude/skills/synced/45101991-1780-4674-81f1-16e2c1cef341_e58c3d25-40b8-4989-be32-ddecdfa498ab/motion-video
cd "$1" && T=${2:-2.6}
for s in $(seq 1 10); do node $S/scripts/video.mjs still --scene $s $T >/dev/null 2>&1; done
python3 - <<'PY'
from PIL import Image
import glob
fs = sorted(glob.glob('out/stills/*.png'))
fs = [f for f in fs if 'sheet' not in f][:10]
ims = [Image.open(f).resize((480, 270)) for f in fs]
o = Image.new('RGB', (5 * 490, 2 * 280), 'white')
for i, im in enumerate(ims): o.paste(im, ((i % 5) * 490, (i // 5) * 280))
o.save('out/contact.png'); print(len(ims), 'frames')
PY
