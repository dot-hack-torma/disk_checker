# disk_checker
BASH Based Disk Checker

This was made to make it easier to check disk usage in a breakdown fashion (the look is kind of inspired as to how reddit comments on a mobile device looks).

###### Some samples of the script output
```
[root@host3 torma_scripts]# disk_checker.v62

Location: /home
Search size: 200m

1.07 GB /home/mentor/
| 1.06 GB /home/mentor/public_html/
| | 1.00 GB /home/mentor/public_html/virtfs.img

0.77 GB /home/mamlaz/
| 0.77 GB /home/mamlaz/public_html/
| | 0.55 GB /home/mamlaz/public_html/magento2/
| | | 0.39 GB /home/mamlaz/public_html/magento2/vendor/
| | | | 0.31 GB /home/mamlaz/public_html/magento2/vendor/magento/

0.63 GB /home/unixdev/
| 0.21 GB /home/unixdev/public_html/

0.56 GB /home/ivanso/
| 0.54 GB /home/ivanso/public_html/
| | 0.24 GB /home/ivanso/public_html/bla/

0.54 GB /home/urazumi/
| 0.53 GB /home/urazumi/public_html/

0.38 GB /home/pandas4ever/

0.27 GB /home/vnex/
```
```
[root@host3 torma_scripts]# !!
disk_checker.v62

Location: /
Search size: 1.5g

12.77 GB /usr/
| 8.42 GB /usr/local/
| | 4.24 GB /usr/local/src/
| | | 3.99 GB /usr/local/src/plBake/
| | 3.03 GB /usr/local/cpanel/

5.88 GB /home/

5.23 GB /var/
| 2.19 GB /var/lib/
| 1.56 GB /var/log/

2.55 GB /root/

2.33 GB /backup/
| 2.29 GB /backup/weekly/
```
