# Makes slides-standalone.html: same deck, screenshots embedded, so it is ONE file to share.
# Run again after editing slides.html:  python3 build-standalone.py
import base64, re, pathlib
here = pathlib.Path(__file__).parent
html = (here / "slides.html").read_text()
def inline(m):
    data = base64.b64encode((here / m.group(1)).read_bytes()).decode()
    return f'src="data:image/png;base64,{data}"'
out = re.sub(r'src="(screenshots/[^"]+\.png)"', inline, html)
(here / "slides-standalone.html").write_text(out)
print(f"slides-standalone.html: {len(out)/1e6:.1f} MB")
