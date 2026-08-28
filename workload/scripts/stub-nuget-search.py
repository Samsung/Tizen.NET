#!/usr/bin/env python3
#
# Copyright (c) Samsung Electronics. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#
"""Serve a stub NuGet search + flatcontainer feed and run next-workload-version.py against it.

Used by test-release-workflow.sh to exercise the search pagination path offline. The stub
deliberately puts the HIGHEST build counter on the LAST page: a reader that takes only the
first page returns a version that is already published.

Usage: stub-nuget-search.py <ok|truncated|nototal|badtotal>
Prints "rc=<exit> out=<stdout>" for the caller to assert on.
"""
import http.server, json, threading, subprocess, os, sys, urllib.parse
# 3 pages of 2 entries; the HIGHEST build counter lives on page 3 (previously invisible).
IDS = ["samsung.net.sdk.tizen.manifest-%d" % i for i in range(6)]
VERS = {i: ["10.0.%d" % (100+i)] for i in range(6)}
MODE = sys.argv[1]
class H(http.server.BaseHTTPRequestHandler):
    def log_message(self,*a): pass
    def do_GET(self):
        u = urllib.parse.urlparse(self.path); q = urllib.parse.parse_qs(u.query)
        if u.path == "/query":
            skip=int(q.get("skip",[0])[0]); take=2
            page = IDS[skip:skip+take]
            body = {"totalHits": len(IDS), "data": [{"id": i} for i in page]}
            if MODE == "truncated" and skip == 0:
                body = {"totalHits": len(IDS), "data": [{"id": i} for i in IDS[:2]]}
                # then serve nothing further
            if MODE == "truncated" and skip > 0:
                body = {"totalHits": len(IDS), "data": []}
            if MODE == "nototal": body.pop("totalHits")
            if MODE == "badtotal": body["totalHits"] = "six"
        else:
            pid = u.path.strip("/").split("/")[0]
            idx = IDS.index(pid) if pid in IDS else None
            body = {"versions": VERS[idx]} if idx is not None else {"versions": []}
        b = json.dumps(body).encode()
        self.send_response(200); self.send_header("Content-Type","application/json")
        self.send_header("Content-Length",str(len(b))); self.end_headers(); self.wfile.write(b)
srv = http.server.HTTPServer(("127.0.0.1",0), H)
threading.Thread(target=srv.serve_forever, daemon=True).start()
port = srv.server_address[1]
env = dict(os.environ, TIZEN_NUGET_SEARCH_BASE="http://127.0.0.1:%d/query"%port,
           TIZEN_NUGET_FEED_BASE="http://127.0.0.1:%d"%port)
here = os.path.dirname(os.path.abspath(__file__))
r = subprocess.run([sys.executable, os.path.join(here, "next-workload-version.py")],env=env,
                   capture_output=True,text=True)
print("rc=%d out=%s" % (r.returncode, r.stdout.strip()))
