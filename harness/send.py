#!/usr/bin/env python3
"""Sends the scenarios' notifications the way their apps do, over the session bus."""
import json, os, subprocess, sys, time

def gv(v):
    if isinstance(v, bool): return "true" if v else "false"
    if isinstance(v, int): return str(v)
    return "'" + v.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n") + "'"

def image_data(path, w, h):
    data = open(path, "rb").read()
    return "<(%d, %d, %d, true, 8, 4, [byte %s])>" % (w, h, w * 4, ", ".join("0x%02x" % b for b in data))

def notify(app, icon, summary, body, hints):
    parts = []
    for k, v in hints.items():
        if k == "image-data": parts.append("'image-data': " + image_data(*v))
        elif isinstance(v, int) and not isinstance(v, bool): parts.append("'%s': <byte %d>" % (k, v) if k == "urgency" else "'%s': <%d>" % (k, v))
        else: parts.append("'%s': <%s>" % (k, gv(v)))
    cmd = ["gdbus", "call", "--session", "--dest", "org.freedesktop.Notifications", "--object-path", "/org/freedesktop/Notifications",
           "--method", "org.freedesktop.Notifications.Notify", app, "0", icon, summary, body, "[]", "{" + ", ".join(parts) + "}", "0"]
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)

env = json.loads(os.environ.get("SCENARIO_ENV", "{}"))
for s in json.load(open(sys.argv[1])):
    need = s.get("needs")
    if need and not env.get(need): continue
    if s.get("cmd"):
        subprocess.run([a.format(**env) for a in s["cmd"]], check=True)
    else:
        hints = {k: (v.format(**env) if isinstance(v, str) else v) for k, v in s.get("hints", {}).items()}
        notify(s["app"].format(**env), s.get("icon", "").format(**env), s["summary"], s.get("body", "").format(**env), hints)
    time.sleep(0.4)
