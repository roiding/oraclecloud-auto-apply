## [鸣谢]

本文基本就是复用了[n0thing2speak](https://github.com/n0thing2speak/oracle_arm)的申请脚本，并将一些参数进行了环境变量改造，构建成了docker镜像

## [使用]

1. 网上有教程的，把自己的`oci`的config文件构建出来，注意其中的`key_file`路径为镜像挂载后的路径(不用像`n0thing2speak`一样安装oci，只需要把oci文件手动填出来就行，网上有教程)
2. `n0thing2speak`有介绍如何生成`main.tf`,我就不赘述了
3. docker-compose文件参考如下:
```yaml
version: "3"

services:
oci-auto-apply:
        image: maodou38/oraclecloud-auto-apply
        volumes:
        - /home/opc/oraclecloud-auto-apply/oci:/.oci #/.oci和/main.tf是固定路径 我因为是保持着oci程序生成配置文件的格式，我只需要挂在文件夹，大家可能还有一个key.pub需要添加,只要知道默认读/.oci/config作为配置文件就行了
        - /home/opc/oraclecloud-auto-apply/main.tf:/main.tf
        restart: "no"
        container_name: oraclecloud-auto-apply
        environment:
        - USE_TG=True
        - TG_BOT_TOKEN=XXXXX
        - TG_USER_ID=XXXXX
        - TG_API_HOST=XXXXX
        logging:
        driver: "json-file"
        options:
            max-size: "10m"
            max-file: "2"
```
其中的`TG_BOT_TOKEN`，`TG_USER_ID`,作者`n0thing2speak`也有讲如何找到，但他没有提到的是，你必须创建完bot后，手动自己给自己的bot发一条消息，不然是无法收到消息的。