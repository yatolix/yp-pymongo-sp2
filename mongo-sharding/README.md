# pymongo-api

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

Теперь нам необходимо настроить шардирование на сервере конфигурации, на роутере и на самих шардах MongoDB.

Для этого выполняем следующие шаги:

Подключаемся к серверу конфигурации шардирования MongoDB выполнив в терминале команду

```shell
docker exec -it mongo-config-srv mongosh --port 27017
```

На сервере конфигурации выполняем команду

```shell
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "mongo-config-srv:27017" }
    ]
  }
);
```

Для выхода обратно в терминал вызываем команду. Впредь не забываем выполнять эту команду при выходе из любого сервиса.

```shell
exit();
```

Теперь подключаемся к первому шарду чтоб зарегистрировать его

```shell
docker exec -it shard-1 mongosh --port 27018
```

Выполняем на шарде команду:

```shell
rs.initiate(
    {
      _id : "shard-1",
      members: [
        { _id : 0, host : "shard-1:27018" }
      ]
    }
);
```

Выходим

```shell
exit();
```

Также подключаемся ко второму шарду и выполняем аналогичную команду на нём

```shell
docker exec -it shard-2 mongosh --port 27019
```

Выполняем команду

```shell
rs.initiate(
    {
      _id : "shard-2",
      members: [
        { _id : 1, host : "shard-2:27019" }
      ]
    }
  );
```

Выходим

```shell
exit();
```

Подключаемся к Роутеру, который будет получать запросы из нашего приложения и перенаправлять их на шарды. Нам необходимо добавть в ротуер шарды чтоб он о них знал.

```shell  
docker exec -it mongo-router mongosh --port 27020
```

Добавляем шарды

```shell
sh.addShard( "shard-1/shard-1:27018");
sh.addShard( "shard-2/shard-2:27019");
```

Прописываем БД для которой будет применяться шардирование.

```shell
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
```

## Как проверить

Заполняем БД данными с помощью скрипта

```shell  
.\scripts\mongo-init.sh
```

Подключаемся к каждому из шардов чтобы проверить как по ним распределились данные.
Сначала на первом шарде.

```shell 
docker exec -it shard-1 mongosh --port 27018
```

```shell 
use somedb;
db.helloDoc.countDocuments();
```

Теперь на втором шарде

```shell
docker exec -it shard-2 mongosh --port 27019
```

```shell
use somedb;
db.helloDoc.countDocuments();
```

### Если вы запускаете проект на локальной машине

Откройте в браузере http://localhost:8080

### Если вы запускаете проект на предоставленной виртуальной машине

Узнать белый ip виртуальной машины

```shell
curl --silent http://ifconfig.me
```

Откройте в браузере http://<ip виртуальной машины>:8080

## Доступные эндпоинты

Список доступных эндпоинтов, swagger http://<ip виртуальной машины>:8080/docs