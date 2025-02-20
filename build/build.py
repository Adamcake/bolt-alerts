#!/usr/bin/env python3

import glob
import json
import subprocess
import os
import sys

if len(sys.argv) != 2:
    print("Usage: {} <version>".format(sys.argv[0]))
    print("e.g.: {} \"1.2.3\"".format(sys.argv[0]))
    sys.exit(1)

version = sys.argv[1]
scriptdir = os.path.dirname(os.path.realpath(__file__))
basedir = subprocess.run(["git", "-C", scriptdir, "rev-parse", "--show-toplevel"], stdout=subprocess.PIPE).stdout.strip().decode(sys.stdout.encoding)
boltfile = "{}/bolt.json".format(basedir)
metafile = "{}/meta.json".format(basedir)
tempfilename = "bolt-alerts-v{}.tar.zst".format(version)
tempfile = "{}/{}".format(os.getenv("XDG_RUNTIME_DIR", "/tmp"), tempfilename)

with open(boltfile, "r+") as f:
    j = json.load(f)
    j["version"] = version
    f.seek(0)
    f.write(json.dumps(j, indent=2))
    f.truncate()

with open(tempfile, 'wb') as f:
    args = ["lua", "{}/archive.lua".format(scriptdir), "{}/".format(basedir), "{}/bolt.json".format(basedir)] \
        + glob.glob("{}/*.lua".format(basedir), recursive=False) \
        + [x for x in glob.iglob("{}/modules/**/*.lua".format(basedir), recursive=True) if os.path.isfile(x)] \
        + [x for x in glob.iglob("{}/app/dist/**/*".format(basedir), recursive=True) if os.path.isfile(x)] \
        + [x for x in glob.iglob("{}/app/images/**/*".format(basedir), recursive=True) if os.path.isfile(x)] \
        + [x for x in glob.iglob("{}/app/sounds/**/*".format(basedir), recursive=True) if os.path.isfile(x)]
    subprocess.run(args, stdout=f)

filehash = subprocess.run(["sha256sum", tempfile], stdout=subprocess.PIPE).stdout.strip().decode(sys.stdout.encoding).split()[0]

with open(metafile, "w") as f:
    f.write(json.dumps({"sha256": filehash, "version": version, "url": "https://github.com/Adamcake/bolt-alerts/releases/download/{}/{}".format(version, tempfilename)}))

subprocess.run(["git", "-C", basedir, "add", boltfile, metafile])
subprocess.run(["git", "-C", basedir, "commit", "-m", "publish v{}".format(version)])
subprocess.run(["git", "-C", basedir, "tag", "-a", version, "-m", "v{}".format(version)])

print("Done. Now run 'git push', then create a release for tag '{}' and attach this file to it: {}".format(version, tempfile))
print("Do not rename or edit the file.")
