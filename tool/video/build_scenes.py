"""Generates the Dars 10–12 text-video projects (motion-video format).

    python3 build_scenes.py            # writes dars10/, dars11/, dars12/

Each video: title card → one scene per reading line (narrated by the app's
own clip, the line shown verbatim in the caption) → closing ayah/hadith card.
Text is read from lib/data/curriculum.dart so it can never drift from the
lesson. Illustrations show places, light and objects only — never the
Prophet ﷺ, the Companions, angels or al-Buraq.
"""
import json
import pathlib
import random
import re
import shutil
import subprocess

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[1]
CUR = (ROOT / "lib/data/curriculum.dart").read_text(encoding="utf-8")
EXTRA_AUDIO = HERE / "extra_audio"  # title / hadith narration + ayah recitation


def dart_list(cls, name):
    body = CUR[CUR.index(f"class {cls} "):]
    m = re.search(rf"static const {name} = \[(.*?)\n  \];", body, re.S)
    return re.findall(r"'((?:[^'\\]|\\.)*)'", m.group(1))


def dart_str(cls, name):
    body = CUR[CUR.index(f"class {cls} "):]
    m = re.search(rf"static const {name} =\s*((?:'(?:[^'\\]|\\.)*'\s*)+);", body, re.S)
    return "".join(re.findall(r"'((?:[^'\\]|\\.)*)'", m.group(1)))


def lesson_title(n):
    m = re.search(rf"LessonRef\({n}, '([^']+)'", CUR)
    return m.group(1)


def dur(path):
    out = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", str(path)],
                         capture_output=True, text=True, check=True).stdout
    return float(out.strip())


# ─────────────────────────────── SVG art kit ───────────────────────────────
W, H = 1600, 900
GB = H + 320  # ground layers run past the frame, so a lifted view never shows a gap
LIFT = 120  # line scenes: the view is lifted so the subject sits above the caption card

SKIES = {
    "dawn": ["#1c3547", "#8d5a4a", "#e39a55", "#f3d7a1"],
    "day": ["#6fa9c2", "#a9cbd2", "#eedcb2", "#f3e4c4"],
    "dusk": ["#1f1a36", "#5b2f45", "#b8574a", "#eaa25c"],
    "night": ["#01100b", "#052219", "#0b3528", "#17493a"],
    "deep": ["#010806", "#03140f", "#06241b", "#0b3b2e"],
}


def sky(kind):
    c = SKIES[kind]
    stops = "".join(f'<stop offset="{i / (len(c) - 1):.2f}" stop-color="{col}"/>' for i, col in enumerate(c))
    return (f'<defs><linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">{stops}</linearGradient>'
            f'<radialGradient id="sunglow"><stop offset="0" stop-color="#fff4d6"/><stop offset=".35" stop-color="#ffd98a" stop-opacity=".9"/>'
            f'<stop offset="1" stop-color="#ffb04a" stop-opacity="0"/></radialGradient>'
            f'<radialGradient id="warm"><stop offset="0" stop-color="#ffe6a8"/><stop offset=".4" stop-color="#f5b94f" stop-opacity=".75"/>'
            f'<stop offset="1" stop-color="#f5b94f" stop-opacity="0"/></radialGradient>'
            f'<linearGradient id="beam" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fff6da" stop-opacity=".95"/>'
            f'<stop offset="1" stop-color="#ffd98a" stop-opacity="0"/></linearGradient></defs>'
            f'<rect y="-200" width="{W}" height="{GB + 200}" fill="url(#sky)"/>')


def stars(n=90, seed=1, top=520):
    r = random.Random(seed)
    out = []
    for _ in range(n):
        x, y, s = r.uniform(0, W), r.uniform(0, top), r.uniform(0.8, 2.4)
        out.append(f'<circle class="twinkle" style="--d:-{r.uniform(0, 2.6):.2f}s" cx="{x:.0f}" cy="{y:.0f}" r="{s:.1f}" fill="#fff6da"/>')
    return "".join(out)


def crescent(x, y, r=46):
    if LIFTED["on"]:
        y += LIFT  # keep the moon inside a lifted view
    return (f'<g opacity=".95"><circle cx="{x}" cy="{y}" r="{r * 2.6}" fill="url(#warm)" opacity=".25"/>'
            f'<path d="M{x + r * .35},{y - r} A{r},{r} 0 1,0 {x + r * .35},{y + r} A{r * .78},{r * .78} 0 1,1 {x + r * .35},{y - r}Z" fill="#fbecc4"/></g>')


def sun(x, y, r=70, cls="sun-rise"):
    return (f'<g class="{cls}"><circle cx="{x}" cy="{y}" r="{r * 4}" fill="url(#sunglow)" opacity=".7"/>'
            f'<circle cx="{x}" cy="{y}" r="{r}" fill="#fff1c9"/></g>')


def mountains(colors=("#6b4a3a", "#4a3326", "#2e2019"), seed=3, base=(560, 640, 720)):
    r = random.Random(seed)
    out = []
    for col, b in zip(colors, base):
        pts, x = [f"0,{GB}", f"0,{b}"], 0
        while x < W:
            x += r.uniform(90, 220)
            pts.append(f"{x:.0f},{b - r.uniform(40, 170):.0f}")
            x += r.uniform(60, 160)
            pts.append(f"{x:.0f},{b + r.uniform(-10, 30):.0f}")
        pts += [f"{W},{GB}"]
        out.append(f'<polygon points="{" ".join(pts)}" fill="{col}"/>')
    return "".join(out)


def dunes(y=700, col1="#c8955a", col2="#a8763f"):
    return (f'<path d="M0,{y} C300,{y - 70} 520,{y + 40} 820,{y - 20} S1350,{y - 90} {W},{y - 30} V{GB} H0Z" fill="{col1}"/>'
            f'<path d="M0,{y + 90} C340,{y + 30} 700,{y + 130} 1000,{y + 70} S1450,{y + 20} {W},{y + 80} V{GB} H0Z" fill="{col2}"/>')


def house(x, y, w, h, col="#b98a5e", win="#f3c56b", lit=False):
    wy = y + h * 0.35
    glow = f'<rect class="flicker" style="--d:-{(x % 7) / 10:.1f}s" x="{x + w * .4}" y="{wy}" width="{w * .2}" height="{h * .22}" fill="{win}"/>' if lit \
        else f'<rect x="{x + w * .4}" y="{wy}" width="{w * .2}" height="{h * .22}" fill="#6d4c33"/>'
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{col}"/><rect x="{x - 4}" y="{y - 8}" width="{w + 8}" height="10" fill="#9c7048"/>{glow}'


def town(y=640, lit=False, seed=5, col="#b98a5e"):
    r = random.Random(seed)
    out, x = [], 40
    while x < W - 40:
        w, h = r.uniform(70, 140), r.uniform(60, 130)
        out.append(house(x, y - h, w, h, col=col, lit=lit and r.random() < .7))
        x += w + r.uniform(8, 40)
    return "".join(out)


def kaaba(x, y, s=1.0):
    w, h = 150 * s, 150 * s
    return (f'<g><rect x="{x - w / 2}" y="{y - h}" width="{w}" height="{h}" fill="#141414"/>'
            f'<polygon points="{x - w / 2},{y - h} {x - w / 2 + 38 * s},{y - h - 22 * s} {x + w / 2 + 38 * s},{y - h - 22 * s} {x + w / 2},{y - h}" fill="#2a2a2a"/>'
            f'<polygon points="{x + w / 2},{y - h} {x + w / 2 + 38 * s},{y - h - 22 * s} {x + w / 2 + 38 * s},{y - 22 * s} {x + w / 2},{y}" fill="#0a0a0a"/>'
            f'<rect x="{x - w / 2}" y="{y - h * .72}" width="{w}" height="{12 * s}" fill="#d4a53a"/>'
            f'<polygon points="{x + w / 2},{y - h * .72} {x + w / 2 + 38 * s},{y - h * .72 - 22 * s} {x + w / 2 + 38 * s},{y - h * .72 - 10 * s} {x + w / 2},{y - h * .72 + 12 * s}" fill="#a67f25"/></g>')


def palm(x, y, s=1.0, d=0.0):
    fr = "".join(
        f'<path d="M0,0 Q{dx * .5},{dy - 30} {dx},{dy}" stroke="#1f4a2f" stroke-width="{14 * s}" fill="none" stroke-linecap="round"/>'
        for dx, dy in [(-120, 30), (-90, -40), (-30, -70), (40, -65), (100, -30), (125, 35), (-60, 60), (70, 55)])
    return (f'<g class="sway" style="--d:-{d:.1f}s"><path d="M{x},{y} C{x + 10 * s},{y - 120 * s} {x - 8 * s},{y - 220 * s} {x + 6 * s},{y - 300 * s}" '
            f'stroke="#5b3f2a" stroke-width="{16 * s}" fill="none" stroke-linecap="round"/>'
            f'<g transform="translate({x + 6 * s},{y - 300 * s}) scale({s})">{fr}</g></g>')


def sheep(x, y, s=1.0, d=0.0):
    return (f'<g transform="translate({x},{y}) scale({s})"><g class="graze" style="--d:-{d:.1f}s">'
            f'<rect x="-30" y="0" width="8" height="34" rx="3" fill="#3b2a20"/><rect x="18" y="0" width="8" height="34" rx="3" fill="#3b2a20"/>'
            f'<ellipse cx="0" cy="-6" rx="52" ry="34" fill="#f1e6d0"/><ellipse cx="-20" cy="-24" rx="22" ry="18" fill="#f7efe0"/>'
            f'<ellipse cx="18" cy="-26" rx="24" ry="18" fill="#f7efe0"/><ellipse cx="-58" cy="4" rx="18" ry="13" fill="#3b2a20"/>'
            f'<ellipse cx="-56" cy="-8" rx="8" ry="5" fill="#3b2a20"/></g></g>')


def camel(x, y, s=1.0, d=0.0, col="#3a261b"):
    legs = "".join(f'<rect class="step" style="--d:-{d + i * .45:.2f}s" x="{lx}" y="-8" width="11" height="78" rx="4" fill="{col}"/>'
                   for i, lx in enumerate([-58, -38, 36, 56]))
    return (f'<g transform="translate({x},{y}) scale({s})">{legs}'
            f'<path d="M-80,-10 Q-78,-60 -40,-62 Q-24,-110 0,-66 Q20,-104 44,-64 Q70,-60 76,-30 L92,-70 Q98,-110 128,-104 L140,-96 Q118,-92 114,-68 L96,-10 Q60,8 0,4 Q-60,8 -80,-10Z" fill="{col}"/></g>')


def cave_mountain(glow=True):
    g = (f'<ellipse class="pulse" cx="860" cy="455" rx="120" ry="90" fill="url(#warm)"/>' if glow else "")
    return (f'<path d="M180,{GB} L520,520 L700,430 L840,300 L960,390 L1120,470 L1480,{GB}Z" fill="#3b2a21"/>'
            f'<path d="M840,300 L960,390 L1120,470 L1480,{GB} L1000,{GB} L900,520Z" fill="#2c1f18" opacity=".8"/>'
            f'{g}<path d="M825,470 Q860,420 895,470 L895,490 L825,490Z" fill="#120b07"/>')


def light_beam(x=860, top=-40, bottom=470, width=220):
    return (f'<polygon class="beam" points="{x - 30},{top} {x + 30},{top} {x + width / 2},{bottom} {x - width / 2},{bottom}" fill="url(#beam)" opacity=".85"/>'
            f'<ellipse class="glow-in" cx="{x}" cy="{bottom}" rx="{width * .9}" ry="60" fill="url(#warm)"/>')


def flight_path(d, t=0.3, dur=2.8):
    return (f'<path d="{d}" pathLength="1" class="stroke m" style="--in:draw; --t:{t}s; --in-dur:{dur}s" '
            f'stroke="#f3d7a1" stroke-width="5" opacity=".9"/>'
            f'<path d="{d}" pathLength="1" class="stroke m" style="--in:draw; --t:{t}s; --in-dur:{dur}s" '
            f'stroke="#ffe6a8" stroke-width="18" opacity=".18"/>')


def aqsa(x, y, s=1.0, lit=True):
    oct_w = 360 * s
    arches = "".join(
        f'<path d="M{x - oct_w / 2 + 28 * s + i * 62 * s},{y - 30 * s} v-60 a{22 * s},{26 * s} 0 0,1 {44 * s},0 v60Z" fill="{"#f3c56b" if lit else "#1e4f7a"}" opacity="{.9 if lit else 1}"/>'
        for i in range(5))
    return (f'<g><rect x="{x - oct_w / 2}" y="{y - 150 * s}" width="{oct_w}" height="{150 * s}" fill="#2f6f9e"/>'
            f'<rect x="{x - oct_w / 2}" y="{y - 150 * s}" width="{oct_w}" height="{18 * s}" fill="#e7eef3"/>{arches}'
            f'<rect x="{x - 95 * s}" y="{y - 205 * s}" width="{190 * s}" height="{58 * s}" fill="#2f6f9e"/>'
            f'<path d="M{x - 105 * s},{y - 205 * s} Q{x - 105 * s},{y - 330 * s} {x},{y - 345 * s} Q{x + 105 * s},{y - 330 * s} {x + 105 * s},{y - 205 * s}Z" fill="#e6b53c"/>'
            f'<path d="M{x - 40 * s},{y - 300 * s} Q{x - 10 * s},{y - 335 * s} {x + 20 * s},{y - 330 * s}" stroke="#fff1c9" stroke-width="{6 * s}" fill="none" opacity=".7"/>'
            f'<rect x="{x - 3 * s}" y="{y - 385 * s}" width="{6 * s}" height="{42 * s}" fill="#e6b53c"/></g>')


def lanterns(xs, y=120, seed=9):
    r = random.Random(seed)
    out = []
    for x in xs:
        L = r.uniform(80, 200)
        out.append(f'<g class="tilt" style="--d:-{r.uniform(0, 2):.1f}s"><line x1="{x}" y1="0" x2="{x}" y2="{y + L - 40}" stroke="#d4a53a" stroke-width="2"/>'
                   f'<circle class="flicker" style="--d:-{r.uniform(0, 1.3):.1f}s" cx="{x}" cy="{y + L}" r="48" fill="url(#warm)"/>'
                   f'<path d="M{x - 16},{y + L - 30} h32 l8,26 l-8,30 h-32 l-8,-30Z" fill="#d4a53a"/>'
                   f'<path d="M{x - 10},{y + L - 22} h20 l5,20 l-5,22 h-20 l-5,-22Z" fill="#ffe29a"/></g>')
    return "".join(out)


def mihrab():
    return (f'<rect y="-200" width="{W}" height="{GB + 200}" fill="#e9dcc0"/>' + star_pattern(.12, "#b58a3a")
            + f'<rect x="0" y="705" width="{W}" height="{GB - 705}" fill="#b77b4a"/>'
            f'<ellipse class="glow-in" cx="800" cy="470" rx="330" ry="280" fill="url(#warm)" opacity=".6"/>'
            f'<path d="M610,705 V430 Q610,250 800,215 Q990,250 990,430 V705Z" fill="#0b3b2e"/>'
            f'<path d="M645,705 V440 Q645,285 800,254 Q955,285 955,440 V705Z" fill="#12533f"/>'
            f'<path d="M610,705 V430 Q610,250 800,215 Q990,250 990,430 V705" stroke="#d4a53a" stroke-width="12" fill="none"/>'
            f'<g transform="translate(0,150)">{lanterns([800], y=120, seed=4)}</g>'
            f'<path d="M560,770 h480 l-40,-62 h-400Z" fill="#8a2b2b"/><path d="M596,760 h408 l-28,-44 h-352Z" fill="none" stroke="#d4a53a" stroke-width="4"/>'
            f'<path d="M772,738 q28,-24 56,0" stroke="#d4a53a" stroke-width="4" fill="none"/>')


def star_pattern(opacity=0.08, color="#d4a53a"):
    tiles = []
    for gx in range(0, W + 160, 160):
        for gy in range(0, H + 160, 160):
            tiles.append(f'<g transform="translate({gx},{gy})"><rect x="-44" y="-44" width="88" height="88" fill="none"/>'
                         f'<rect x="-44" y="-44" width="88" height="88" transform="rotate(45)" fill="none"/></g>')
    return (f'<g stroke="{color}" stroke-width="2" opacity="{opacity}">' + "".join(tiles).replace('fill="none"/>', 'fill="none" />')
            + '</g>')


def ring(cx=W / 2, cy=H / 2, r=300):
    return (f'<g class="spin-slow"><circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="#d4a53a" stroke-width="3" stroke-dasharray="4 14" opacity=".6"/></g>'
            f'<circle cx="{cx}" cy="{cy}" r="{r - 26}" pathLength="1" class="stroke m" style="--in:draw; --t:-0.5s; --in-dur:1.6s" stroke="#d4a53a" stroke-width="4"/>')


LIFTED = {"on": False}


def svg(body):
    lift = LIFT if LIFTED["on"] else 0
    return f'<svg viewBox="0 {lift} {W} {H}" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">{body}</svg>'


CORNER = ('<svg viewBox="0 0 100 100"><g fill="none" stroke="currentColor" stroke-width="5">'
          '<rect x="22" y="22" width="56" height="56"/><rect x="22" y="22" width="56" height="56" transform="rotate(45 50 50)"/>'
          '<circle cx="50" cy="50" r="10" fill="currentColor"/></g></svg>')

# ─────────────────────────────── Scene art per line ───────────────────────


def art_birth():  # born in Makkah, year of the Elephant — dawn over the valley and the Kaaba
    return svg(sky("dawn") + sun(1180, 470, 80) + mountains(("#8a5a45", "#5f3f30", "#3b281f"), 7, (520, 600, 680))
               + town(760, seed=2) + kaaba(800, 770, 1.0) + town(840, seed=8, col="#a57a52"))


def art_orphan():  # grew up an orphan — a lone palm and a lit window at dusk
    return svg(sky("dusk") + stars(30, 4, 300) + sun(420, 560, 60, "sun-set") + mountains(("#5a3a3f", "#3e2831", "#261a20"), 11)
               + dunes(740, "#7d5a45", "#5e4232") + palm(1060, 790, 1.15, .6) + house(1180, 700, 150, 110, "#8a6547", lit=True))


def art_shepherd():  # shepherded sheep in his youth — grazing flock on the hills (no shepherd shown)
    flock = "".join(sheep(x, y, s, d) for x, y, s, d in
                    [(420, 690, 1.0, .1), (620, 730, 1.15, .7), (860, 700, .95, 1.2), (1080, 745, 1.2, .4), (1290, 705, .9, 1.5), (720, 800, 1.3, .9)])
    return svg(sky("day") + f'<g class="drift-cloud"><ellipse cx="400" cy="160" rx="160" ry="36" fill="#fff" opacity=".7"/>'
               f'<ellipse cx="1150" cy="120" rx="200" ry="40" fill="#fff" opacity=".6"/></g>'
               + mountains(("#b48a64", "#9a7453", "#86643f"), 13, (480, 560, 640))
               + f'<path d="M0,640 C400,580 900,660 {W},600 V{GB} H0Z" fill="#b99456"/><g class="wander">{flock}</g>')


def art_caravan():  # married Khadijah — a trade caravan crossing the dunes (camels, no riders)
    return svg(sky("dusk") + sun(1250, 520, 70) + mountains(("#6e4a44", "#4c3232", "#33222a"), 17, (560, 620, 690))
               + dunes(700, "#b5824e", "#8f643a")
               + f'<g class="walk">{camel(700, 690, 1.0, .1)}{camel(930, 700, .95, .5)}{camel(1150, 695, .9, .9)}</g>')


def art_amin():  # called al-Amīn — the title in a roundel, light behind
    return bg_roundel(), roundel("الْأَمِينُ")


def art_hira():  # sent as a prophet in the cave of Ḥirāʾ, at forty — the mountain at night
    return svg(sky("night") + stars(120, 21) + crescent(1260, 150) + cave_mountain(glow=False)
               + f'<path d="M0,{GB} L0,760 Q400,720 800,780 T{W},760 V{GB}Z" fill="#1c140f"/>')


def art_wahy():  # revelation descended — light descends onto the cave
    return svg(sky("night") + stars(120, 22) + light_beam() + cave_mountain(glow=True)
               + f'<path d="M0,{GB} L0,760 Q400,720 800,780 T{W},760 V{GB}Z" fill="#1c140f"/>')


def art_dawn_message():  # the beginning of the message — full sunrise over the valley
    return svg(sky("dawn") + sun(800, 470, 110) + f'<g class="glow-in">'
               + "".join(f'<polygon points="800,470 {800 + 900 * __import__("math").cos(a)},{470 + 900 * __import__("math").sin(a)} '
                         f'{800 + 900 * __import__("math").cos(a + .06)},{470 + 900 * __import__("math").sin(a + .06)}" fill="#fff1c9" opacity=".12"/>'
                         for a in [i * .31 - 3.1 for i in range(11)])
               + '</g>' + mountains(("#8a5a45", "#5f3f30", "#3b281f"), 7, (560, 640, 720)))


def art_isra():  # night journey from Makkah to Bayt al-Maqdis — a path of light drawn across the sky
    return svg(sky("night") + stars(140, 31) + crescent(800, 130, 40)
               + f'<g transform="translate(-40,-70)">{kaaba(1330, 780, .75)}</g>' + town(760, seed=31, col="#3b2c22")
               + f'<g transform="translate(-980,110) scale(.8)">{aqsa(1500, 900, 1.0, lit=True)}</g>'
               + flight_path("M1310,600 C1150,200 600,160 330,520", .4, 3.2))


def art_journey_light():  # the wondrous journey — streaks of light racing across the night (al-Buraq itself not shown)
    r = random.Random(41)
    streaks = "".join(
        f'<line class="m" style="--in:wipe; --t:{r.uniform(-.4, 1.8):.2f}s; --in-dur:.9s" x1="{x}" y1="{y}" x2="{x - L}" y2="{y + L * .12}" '
        f'stroke="#fff1c9" stroke-width="{r.uniform(2, 6):.1f}" stroke-linecap="round" opacity="{r.uniform(.3, .9):.2f}"/>'
        for x, y, L in [(r.uniform(700, 1600), r.uniform(120, 560), r.uniform(200, 520)) for _ in range(22)])
    return svg(sky("deep") + stars(160, 42) + streaks + dunes(760, "#15261f", "#0c1a15"))


def art_aqsa():  # arrived at Bayt al-Maqdis and led the prophets in prayer — the Sanctuary at night
    return svg(sky("night") + stars(90, 51, 380) + crescent(1320, 150, 42)
               + f'<path d="M0,760 H{W} V{GB} H0Z" fill="#20352c"/>' + aqsa(800, 770, 1.35) + lanterns([180, 330, 1270, 1420], y=40, seed=52))


def art_miraj():  # ascended to the heavens up to Sidrat al-Muntahā — light rising through the layers of the sky
    layers = "".join(f'<ellipse cx="800" cy="{980 - i * 150}" rx="{1100 - i * 90}" ry="{150 - i * 8}" fill="none" stroke="#d4a53a" '
                     f'stroke-width="3" opacity="{.15 + i * .08:.2f}"/>' for i in range(7))
    return svg(sky("deep") + stars(160, 61) + f'<g class="ascend">{layers}'
               f'<ellipse cx="800" cy="-60" rx="360" ry="200" fill="url(#warm)" opacity=".8"/></g>'
               + f'<polygon class="beam" points="780,0 820,0 900,{H} 700,{H}" fill="url(#beam)" opacity=".7"/>')


def art_salah():  # prayer was made obligatory that night — a mihrab lit by a lantern
    return svg(mihrab())


def art_hijrah():  # migrated from Makkah to Madinah — a route drawn across the desert under the moon
    return svg(sky("night") + stars(110, 71, 420) + crescent(1250, 140)
               + mountains(("#23302a", "#1a241f", "#121a16"), 73, (560, 620, 690)) + dunes(720, "#2d3a2f", "#1f2a22")
               + f'<g transform="translate(1180,40) scale(.55)">{kaaba(300, 1180, 1)}</g>'
               + f'<g>{palm(330, 780, .6, .2)}{palm(410, 790, .5, .8)}{palm(250, 800, .5, 1.2)}</g>'
               + flight_path("M1320,700 C1100,610 980,760 760,690 S470,620 370,720", .3, 3.4))


def art_madinah():  # the Anṣār welcomed him with joy — Madinah's palms and lanterns at morning
    palms = "".join(palm(x, 780, s, d) for x, s, d in [(140, 1.0, .1), (360, .85, .7), (1250, .95, .4), (1460, 1.05, 1.1)])
    return svg(sky("dawn") + sun(800, 420, 70) + town(770, lit=True, seed=81, col="#c9a47a") + palms
               + f'<path d="M0,{GB} V790 H{W} V{GB}Z" fill="#a7824f"/>' + lanterns([520, 660, 940, 1080], y=10, seed=82))


def art_names():  # Muhājirūn and Anṣār — two roundels joined by a line
    return (svg(sky("deep") + star_pattern(.08)
                + '<path d="M540,340 C700,260 900,260 1060,340" pathLength="1" class="stroke m" style="--in:draw; --t:.6s; --in-dur:1.4s" '
                  'stroke="#d4a53a" stroke-width="4"/>'),
            '<div class="roundels"><div class="roundel-row">'
            '<div class="roundel m" style="--in:zoom; --t:-0.1s"><div class="name">الْمُهَاجِرُونَ</div></div>'
            '<div class="roundel m" style="--in:zoom; --t:0.35s"><div class="name">الْأَنْصَارُ</div></div>'
            '</div></div>')


def art_nabawi():  # the Companions — the early mosque of Madinah with palm-trunk pillars, at dawn
    pillars = "".join(f'<rect x="{x}" y="420" width="26" height="330" fill="#6b4a33"/>' for x in range(260, 1360, 140))
    return svg(sky("dawn") + sun(800, 360, 60) + f'<path d="M180,420 H1420 V440 H180Z" fill="#7a5a3c"/>'
               + '<path d="M180,405 H1420 L1400,420 H200Z" fill="#8e6a45"/>' + pillars
               + f'<path d="M0,{GB} V750 H{W} V{GB}Z" fill="#c9a26d"/>' + palm(90, 790, .9, .3) + palm(1510, 790, .95, .9))


def roundel(name, extra="", t=-0.1):
    tag_html = f'<div class="tags-wrap">{extra}</div>' if extra else ""
    return (f'<div class="roundel-wrap"><div class="roundel m" style="--in:zoom; --t:{t}s"><div class="name">{name}</div></div></div>'
            f'{tag_html}')


def tags(*items, t=0.6):
    return '<div class="tags">' + "".join(
        f'<span class="tag m" style="--in:rise; --t:{t + i * .25:.2f}s"><i data-icon="{ic}"></i>{txt}</span>' for i, (ic, txt) in enumerate(items)) + "</div>"


def bg_roundel():
    LIFTED["on"] = False
    return svg(sky("deep") + star_pattern(.09) + f'<ellipse class="glow-in" cx="800" cy="330" rx="520" ry="320" fill="url(#warm)" opacity=".3"/>' + ring(800, 330, 200))


def art_abubakr():
    return bg_roundel(), roundel("أَبُو بَكْرٍ<br>الصِّدِّيقُ")


def art_abubakr_traits():
    return bg_roundel(), roundel("أَبُو بَكْرٍ<br>الصِّدِّيقُ", tags(("badge-check", "الصِّدْقُ"), ("mountain", "الثَّبَاتُ")))


def art_umar():
    return bg_roundel(), roundel("عُمَرُ<br>الْفَارُوقُ", tags(("scale", "الْعَدْلُ")))


def art_uthman():  # gathered the Qur'an into one muṣḥaf — loose pages fly together into one book
    r = random.Random(91)
    pages = "".join(
        f'<rect class="page" style="--d:{.2 + i * .12:.2f}s; --fx:{r.uniform(-600, 600):.0f}px; --fy:{r.uniform(-380, 120):.0f}px; --fr:{r.uniform(-40, 40):.0f}deg" '
        f'x="{690 + i * 1.5}" y="{560 - i * 3}" width="220" height="150" rx="6" fill="#f8f1e1" stroke="#d4a53a" stroke-width="2"/>' for i in range(9))
    book = ('<g class="m" style="--in:fade; --t:1.4s"><rect x="660" y="505" width="290" height="210" rx="14" fill="#0b3b2e" stroke="#d4a53a" stroke-width="6"/>'
            '<rect x="690" y="530" width="230" height="160" rx="8" fill="none" stroke="#d4a53a" stroke-width="3"/>'
            '<circle cx="805" cy="610" r="34" fill="none" stroke="#d4a53a" stroke-width="4"/></g>')
    return (svg(sky("deep") + star_pattern(.07) + f'<ellipse class="glow-in" cx="805" cy="610" rx="420" ry="260" fill="url(#warm)" opacity=".35"/>' + pages + book),
            '<div class="roundels" style="place-items:start center; padding-top:9vh"><div class="roundel sm m" style="--in:zoom; --t:-0.1s">'
            '<div class="name">عُثْمَانُ<br>ذُو النُّورَيْنِ</div></div></div>')


def art_ali():
    return bg_roundel(), roundel("عَلِيٌّ", tags(("lamp", "الْحِكْمَةُ"), ("shield", "الشَّجَاعَةُ")))


def art_martyr():  # some were martyred in the path of Allah — a quiet sunset over the mountains
    return svg(sky("dusk") + sun(800, 500, 80, "sun-set") + mountains(("#5a3a3f", "#3e2831", "#221619"), 101, (560, 640, 720)))


def art_khulafa():  # the Rightly Guided Caliphs, our example — the four roundels together
    names = ["أَبُو بَكْرٍ", "عُمَرُ", "عُثْمَانُ", "عَلِيٌّ"]
    row = "".join(f'<div class="roundel sm m" style="--in:zoom; --t:{-0.1 + i * .3:.2f}s"><div class="name">{n}</div></div>' for i, n in enumerate(names))
    return (svg(sky("deep") + star_pattern(.09) + f'<ellipse class="glow-in" cx="800" cy="330" rx="700" ry="300" fill="url(#warm)" opacity=".25"/>'),
            f'<div class="roundels"><div class="roundel-row" style="gap:calc(var(--u)*3)">{row}</div></div>')


# ─────────────────────────────── Lessons ───────────────────────────────

LESSONS = {
    10: dict(cls="Dars1110", folder="tts_dars110", ordinal="الدرس العاشر", unit="الوحدة الرابعة: السيرة",
             arts=[(art_birth, "cam-pan-l"), (art_orphan, "cam-push"), (art_shepherd, "cam-pan-r"), (art_caravan, "cam-pull"),
                   (art_amin, None), (art_hira, "cam-push"), (art_wahy, "cam-up"), (art_dawn_message, "cam-pull")],
             close=dict(kind="حديث", narrator=("Dars1110", "hadithNarrator"), matn=("Dars1110", "hadithText"),
                        source=("Dars1110", "hadithSource"), audio="hadith10.mp3")),
    11: dict(cls="Dars1111", folder="tts_dars111", ordinal="الدرس الحادي عشر", unit="الوحدة الرابعة: السيرة",
             arts=[(art_isra, None), (art_journey_light, "cam-pan-r"), (art_aqsa, "cam-push"), (art_miraj, None),
                   (art_salah, None), (art_hijrah, None), (art_madinah, "cam-pan-l"), (art_names, None)],
             close=dict(kind="قال تعالى", ayah=("Dars1111", "ayahDisplay"), source=("Dars1111", "ayahRef"), audio="ayah11.mp3")),
    12: dict(cls="Dars1112", folder="tts_dars112", ordinal="الدرس الثاني عشر", unit="الوحدة الرابعة: السيرة",
             arts=[(art_nabawi, "cam-pan-l"), (art_abubakr, None), (art_abubakr_traits, None), (art_umar, None),
                   (art_uthman, None), (art_ali, None), (art_martyr, "cam-push"), (art_khulafa, None)],
             close=dict(kind="حديث", narrator=("Dars1112", "hadithNarrator"), matn=("Dars1112", "hadithText"),
                        source=("Dars1112", "hadithSource"), audio="hadith12.mp3")),
}

HEAD = """<!doctype html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="utf-8">
  <link rel="stylesheet" href="../base.css">
  <link rel="stylesheet" href="../lesson.css">
  <script src="../icons.js"></script>
  <script src="../motion.js"></script>
</head>
<body>
"""


def chip(label):
    return f'<div class="chip-lesson m" style="--in:fade; --t:-0.3s">{label}</div>'


def steps(i, n):
    return '<div class="steps">' + "".join(f'<b class="{"done" if k <= i else ""}"></b>' for k in range(n)) + "</div>"


def scene_line(label, text, art, cam, i, n):
    LIFTED["on"] = True
    res = art()
    LIFTED["on"] = False
    world, overlay = (res if isinstance(res, tuple) else (res, ""))
    cam_cls = f" {cam}" if cam else ""
    return (HEAD + f'<main class="stage"><div class="world{cam_cls}" data-world>{world}</div>{overlay}</main>\n'
            f'<div class="shade"></div>\n<header class="hud"><div class="safe">{chip(label)}{steps(i, n)}'
            f'<div class="caption m" style="--in:rise; --t:-0.15s"><p class="ar">{text}</p></div></div></header>\n</body>\n</html>\n')


def scene_title(ordinal, unit, title):
    world = svg(sky("deep") + star_pattern(.1) + f'<ellipse class="glow-in" cx="800" cy="450" rx="620" ry="380" fill="url(#warm)" opacity=".28"/>' + ring(800, 450, 360))
    return (HEAD + f'<main class="stage"><div class="world cam-pull" data-world>{world}</div></main>\n'
            f'<header class="hud"><div class="center"><div class="title-block">'
            f'<div class="unit-label m" style="--in:fade; --t:-0.2s">{unit}</div>'
            f'<div class="lesson-no m" style="--in:rise; --t:0.05s">{ordinal}</div>'
            f'<div class="rule m" style="--in:grow-x; --t:0.3s"></div>'
            f'<div class="lesson-title m" style="--in:blur; --t:0.45s">{title}</div>'
            f'</div></div></header>\n</body>\n</html>\n')


def scene_close(label, c):
    world = svg(sky("deep") + star_pattern(.12) + f'<ellipse cx="800" cy="450" rx="760" ry="440" fill="url(#warm)" opacity=".18"/>')
    corners = "".join(f'<div class="corner {p}">{CORNER}</div>' for p in ("tl", "tr", "bl", "br"))
    if "ayah" in c:
        body = (f'<div class="kind">{c["kind"]}</div>'
                f'<div class="quran">﴿{dart_str(*c["ayah"])}﴾</div>'
                f'<div class="source">{dart_str(*c["source"])}</div>')
    else:
        body = (f'<div class="kind">{c["kind"]}</div>'
                f'<div class="narrator">{dart_str(*c["narrator"])}</div>'
                f'<div class="matn">«{dart_str(*c["matn"])}»</div>'
                f'<div class="source">({dart_str(*c["source"])})</div>')
    return (HEAD + f'<main class="stage"><div class="world cam-push" data-world>{world}</div></main>\n'
            f'<header class="hud"><div class="safe">{chip(label)}</div><div class="center">'
            f'<div class="scroll-card m" style="--in:zoom; --t:-0.2s">{corners}{body}</div></div></header>\n</body>\n</html>\n')


def build(n, spec):
    proj = HERE / f"dars{n}"
    (proj / "scenes").mkdir(parents=True, exist_ok=True)
    (proj / "assets" / "audio").mkdir(parents=True, exist_ok=True)
    for f in (proj / "scenes").glob("*.html"):
        f.unlink()
    shutil.copy(HERE / "lesson.css", proj / "lesson.css")
    fonts = ROOT / "assets/fonts"
    for src in ["amiri/Amiri-Regular.ttf", "amiri/Amiri-Bold.ttf", "amiri_quran/AmiriQuran-Regular.ttf", "tajawal/Tajawal-Bold.ttf"]:
        shutil.copy(fonts / src, proj / "fonts" / pathlib.Path(src).name)

    lines = dart_list(spec["cls"], "readingLines")
    assert len(lines) == len(spec["arts"]), (n, len(lines))
    label = f'{spec["ordinal"]} · {re.sub(r"[ً-ْٰ]", "", lesson_title(n))}'
    scenes = []

    shutil.copy(EXTRA_AUDIO / f"title{n}.mp3", proj / "assets/audio/title.mp3")
    (proj / "scenes/00-title.html").write_text(scene_title(spec["ordinal"], spec["unit"], lesson_title(n)), encoding="utf-8")
    scenes.append({"file": "scenes/00-title.html", "audio": "assets/audio/title.mp3"})

    for i, (text, (art, cam)) in enumerate(zip(lines, spec["arts"])):
        src = ROOT / "assets/audio" / spec["folder"] / f"reading_{i}.mp3"
        shutil.copy(src, proj / f"assets/audio/reading_{i}.mp3")
        name = f"scenes/{i + 1:02d}-line.html"
        (proj / name).write_text(scene_line(label, text, art, cam, i, len(lines)), encoding="utf-8")
        scenes.append({"file": name, "audio": f"assets/audio/reading_{i}.mp3"})

    c = spec["close"]
    shutil.copy(EXTRA_AUDIO / c["audio"], proj / "assets/audio/close.mp3")
    (proj / "scenes/99-close.html").write_text(scene_close(label, c), encoding="utf-8")
    close_len = dur(proj / "assets/audio/close.mp3") + 2.2  # hold the card after the reading ends
    scenes.append({"file": "scenes/99-close.html", "audio": "assets/audio/close.mp3", "duration": round(close_len, 2)})

    manifest = {"width": 1280, "height": 720, "fps": 30, "output": f"out/topik{n}.mp4", "sfx": False,
                "sound": {"fadeIn": 0.3, "fadeOut": 1.2}, "scenes": scenes}
    (proj / "video.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"dars{n}: {len(scenes)} scenes")


if __name__ == "__main__":
    for n, spec in LESSONS.items():
        build(n, spec)
