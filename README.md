# Compress XLSX Image files

```shell
$ source comprezer.sh
$ IMGSIZE=800 comprezer demo.xlsx demo__compressed.xlsx
$ ls -alh
total 4.3M
-rw-rw-r-- 1 tzx tzx 2.0K 3月  28 20:41 comprezer.sh
-rw-rw-r-- 1 tzx tzx 1.3M 3月  28 19:24 demo1.jpg
-rw-rw-r-- 1 tzx tzx 511K 3月  28 19:24 demo2.jpg
-rw-rw-r-- 1 tzx tzx 178K 3月  28 19:24 demo3.jpg
-rw-rw-r-- 1 tzx tzx 218K 3月  28 23:27 demo__compressed.xlsx
-rw-rw-r-- 1 tzx tzx 2.1M 3月  28 19:24 demo.xlsx
-rw-rw-r-- 1 tzx tzx  154 3月  28 23:29 README.md
```

Before:

![](_before.png)

After:

![](_after.png)

还有点 bug, 但是 work 了.

# TODO

Better configs. 搞清楚为啥 log 打不出来, IMGSIZE 为啥失灵.
