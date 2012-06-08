#!/usr/bin/python

import urllib2
import re
import codecs
import os

response = urllib2.urlopen('https://entropia.de/wiki/index.php?title=Spezial:Beliebteste_Seiten&limit=2000&offset=0')
html = unicode(response.read(), 'utf8')

p = re.compile(r'title="GPN12:([^"]*)".*\((\d+) Abfragen\)')

txt = codecs.open('text.tmp',encoding='utf8',mode='w')

for line in html.splitlines():
    match = p.search(line)
    if match:
        title = match.group(1)
        count = int(match.group(2))
        txt.write("%d %s\n" % (count, title[:18]))

os.rename('text.tmp','text')
