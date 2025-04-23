# pymongo-api

## Архитектурная схема

В формате draw.io - https://drive.google.com/file/d/1eQuR8rPTteEaDq0q1DcB_sHafrzBgVlq/view?usp=sharing

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

Теперь нам необходимо настроить шардирование и репликацию.

```shell  
.\scripts\init-cluster.sh
```

## Как проверить

Заполняем БД данными с помощью скрипта

```shell  
.\scripts\generate-data.sh
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