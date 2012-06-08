#!/usr/bin/python

import urllib2
import re
import codecs
import os

os.chdir(os.path.dirname(os.path.realpath(__file__)))

response = urllib2.urlopen('https://entropia.de/wiki/index.php?title=Spezial:Beliebteste_Seiten&limit=2000&offset=0')
html = unicode(response.read(), 'utf8')

p = re.compile(r'title="GPN12:([^"]*)".*\(([\d\.]+) Abfragen\)')
p2 = re.compile(r'(\d+) \d+ (.*)')

txt = codecs.open('text.tmp',encoding='utf8',mode='w')

oldCount = {}
try:
    old = codecs.open('text',encoding='utf8',mode='r')

    for line in old:
        match = p2.match(line)
        if match:
            oldCount[match.group(2)] = int(match.group(1))
        else:
            print("Warning: Could not parse old data line %s" % line)
except IOError:
   pass 


seen = set()
for line in html.splitlines():
    match = p.search(line)
    if match:
        title = match.group(1)
        count = int(match.group(2).replace('.',''))
        old = 0
        shorttitle = title
        if len(shorttitle) > 15:
            shorttitle = shorttitle[:10] + "..."
        if shorttitle in seen:
            continue
        seen.add(shorttitle)
        if shorttitle in oldCount:
            old = oldCount[shorttitle]
        txt.write("%d %d %s\n" % (count, old, shorttitle))

os.rename('text.tmp','text')
