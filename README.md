# qBittorrent-Enhanced-Docker

### 感谢以下项目:
[https://github.com/qbittorrent/qBittorrent](https://github.com/qbittorrent/qBittorrent)   
[https://github.com/c0re100/qBittorrent-Enhanced-Edition](https://github.com/c0re100/qBittorrent-Enhanced-Edition)  
[https://github.com/XIU2/TrackersListCollection](https://github.com/XIU2/TrackersListCollection)  

## 变量

|参数|说明|
|-|:-|
| `--name=qbittorrent` |容器名|
| `-p 8989:8989` |web访问端口 [IP:8989](IP:8989);(默认用户名密码从运行日志获得);</br>此端口需与容器端口和环境变量保持一致，否则无法访问|
| `-p 6881:6881` |BT下载监听端口|
| `-p 6881:6881/udp` |BT下载DHT监听端口
| `-v /配置文件位置:/config` |qBittorrent配置文件位置|
| `-v /下载位置:/downloads` |qBittorrent下载位置|
| `-e PUID=1000` |PUID设置,默认为1000|
| `-e PGID=1000` |PGID设置,默认为1000|
| `-e UMASK=022` |umask设置,默认为022|
| `-e TZ=Asia/Shanghai` |系统时区设置,默认为Asia/Shanghai|
| `-e WEBUIPORT=8989` |web访问端口环境变量|
| `-e TRACKERSAUTO=true` |(true\|false)自动更新qBittorrent的trackers,默认开启|
| `-e TRACKERS_LIST_URL=` |trackers更新地址设置,仅支持ngosang格式,默认为 </br>https://jsd.cdn.zzko.cn/gh/XIU2/TrackersListCollection/best.txt |
