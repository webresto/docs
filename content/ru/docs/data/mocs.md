---
title: "Тестовые данные"
linkTitle: "Тестовые данные"
description: >
 Список серверов с данными
---

# Список всех серверов:

> пример: 
> backendUrl: https://32001.fwr.m42.cx/graphql
> imagesUrl: https://32001.fwr.m42.cx

|№| Название|Сервер|
|-|:--------|:-----|
|1| dm_base_1   | 32001.fwr.m42.cx |
|2| dm_base_2   | 32002.fwr.m42.cx |
|3| dm_base_3   | 32003.fwr.m42.cx |
|4| dm_base_4   | 32004.fwr.m42.cx |
|5| dm_base_5   | 32005.fwr.m42.cx |
|6| dm_base_6   | 32006.fwr.m42.cx |
|7| dm_base_7   | 32007.fwr.m42.cx |
|8| dm_base_8   | 32008.fwr.m42.cx |

# Тестовые случаи

Header
<details>
  <summary>Нет пунктов меню навигаци хедера</summary> 
  <pre>
  В навигации хедера, в <b>navigation_menu</b> приходит пустой массив
  <i>server: dm_base_8</i>
  </pre>
</details>

<details>
  <summary>Нет меню навигаци хедера</summary> 
  <pre>
  Отсутвует инстанс навигации со слагом <b>header</b>
  <i>server: dm_base_5</i>
  </pre>
</details>

<details>
  <summary>Нет меню навигаци хедера</summary> 
  <pre>
  В меню <b>header</b> приодит 9 пунктов меню.
  <i>server: dm_base_7</i>
  </pre>
</details>

<details>
  <summary>Ссылка на внешний сайт</summary> 
  <pre>
  В меню <b>header</b> приходит пункт меню который содержит ссылку на внешний сайт

    {
        "label": "Сылка на внешний сайт",
        "link": "https://google.com",
        "slug": "stocks1",
        "active": true,
        "controller": "promotions"
    },

  <i>server: dm_base_7</i>
  </pre>
</details>

<details>
  <summary>Флаги дефолт неуказаны</summary> 
  <pre>
  Если флаг не указан должно ставится по дефолту, видимый(visible: true) и активный ( active: true)
  В меню <b>header</b> приходит пункт меню который не содержит флаги

      {
        "label": "Проверка флагов",
        "link": "/stocks0",
        "slug": "stocks0",
        "controller": "promotions"
      },

  <i>server: dm_base_7</i>
  </pre>
</details>

<details>
  <summary>Ссылка на которую нельзя нажать</summary> 
  <pre>
  Если флаги указаны видимый(visible: true)  и активный ( active: fallse)  то мы получаем ссылку на которую нельзя нажать

  В меню <b>header</b> приходит пункт меню который содержит такую запись

      {
        "label": "ссылка на которую нельзя нажать (дизебл) ",
        "link": "/stocks3",
        "slug": "stocks3",
        "active": false,
        "visible": true,
        "controller": "promotions"
      },

  <i>server: dm_base_6</i>
  </pre>
</details>

<details>
  <summary>Очень длинный текст для пункта меню</summary> 
  <pre>
  В меню <b>header</b> приходит пункт меню который содержит такую запись

      {
        "label": "Супер длинный текст в позиции меню который может написать пользователь",
        "link": "/stocks2",
        "slug": "stocks2",
        "active": true,
        "visible": true,
        "controller": "promotions"
      },

  <i>server: dm_base_7</i>
  </pre>
</details>
