---
title: "Тестовые данные"
linkTitle: "Тестовые данные"
description: >
 Тестовые случаи
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

## header
Ниже представлены возможные данные для примитива Хедер

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
        "active": true
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
        "link": "/stocks0"
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
        "visible": true
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
        "active": true,
        "visible": true
      },

  <i>server: dm_base_7</i>
  </pre>
</details>




## promotion


<details>
  <summary>Нет слайдов</summary> 
  <pre>
  На сервере нет записей о слайдере (раздел промоушен исчезает).
  
  <i>server: dm_base_5</i>
  </pre>
</details>

<details>
  <summary>Не установлен модуль промоушен</summary> 
  <pre>
  С сервера приходит ошибка (раздел промоушен исчезает).
  
  <i>server: dm_base_6</i>
  </pre>
</details>

<details>
  <summary>Битая картинка</summary> 
  <pre>
  Приходит одна битая картинка на первом слайде: <i>Суши от японсокого шефа </i> 
  Если приходит одна битая картинка то слайд на котором это происходит должен исчезнуть
  <i>server: dm_base_4</i>
  </pre>
</details>

<details>
  <summary>Все картинки у слайдера битые</summary> 
  <pre>
  Приходят все битые картинки на всех слайдах
  Если все картинки битые то весь слайдер должен исчезнуть
  <i>server: dm_base_8</i>
  </pre>
</details>

<details>
  <summary>Приходит один слайд</summary> 
  <pre>
  Исчезает навигация по слайдам
  <i>server: dm_base_2</i>
  </pre>
</details>

<details>
  <summary>Проверка всех размеров слайдов</summary> 
  <pre>
  Приходит на всех серверах на которых приходят картинки
  рекомендовано использовать dm_base_1  
  <i>server: dm_base_1</i>
  </pre>
</details>

<details>
  <summary>Переход по внешней ссылке</summary> 
  <pre>
  При нажатии на слайд переходит по внешней ссылке

  в первом слайде "Суши от японсокого шефа" при нажатии на слайд должно открыватся в новом окне сайт https://webresto.org

  <i>server: dm_base_1</i>
  </pre>
</details>

<details>
  <summary>Переход по внутренней ссылке</summary> 
  <pre>
  При нажатии на слайд переходит по ссылке на этом же сайта

  в слайде "Ягодное меню" при нажатии на слайд должно переходить по ссылку в этом же сайте /contacts

  <i>server: dm_base_1</i>
  </pre>
</details>


## dish-nav-bar

<details>
  <summary>NewPageBySlug</summary> 
  <pre>
  Построение через initSlug где каждый раздел создается на своей странице
  
  <i>server: dm_base_1</i>
  </pre>
</details>

<details>
  <summary>OnePageBySlug</summary> 
  <pre>
  Построение через initSlug где все подразделы на одной страницы с навигацией по # (переход реализуется прокруткой)
  
  <i>server: dm_base_2</i>
  </pre>
</details>

<details>
  <summary>NewPageByNavigationMenu</summary> 
  <pre>
  Построение из меню которое пришло в navigation_menu где каждый раздел создается на своей странице 
  <i>server: dm_base_3</i>
  </pre>
</details>

<details>
  <summary>OnePageByNavigationMenu</summary> 
  <pre>
  В текущем примере установленно значение NewPageByNavigationMenu это означает что при обработке меню фронтенд проигнорирует свойство initSlug

  <i>server: dm_base_4</i>
  </pre>
</details>


<details>
  <summary>Ссылка на которую нельзя нажать</summary> 
  <pre>
  Если флаги указаны видимый(visible: true)  и активный ( active: fallse)  то мы получаем ссылку на которую нельзя нажать
  
  Первый пункт приходит на который нельзя нажать. 
  
  <i>server: dm_base_3</i>
  </pre>
</details>


---


## dish-control

## dish-card

## dish-modal

<details>
  <summary>Моки для модификаторов</summary> 
  <pre>
  Все моки указаны на одном сервере
  те которые с будильником пока еще не готовы

  список:

  ✅ С фото и без в одной группе модификаторов 
  ✅ 2 мод.  в первой группе (max: 1, min: 1) img
  ✅ 3 мод.  в первой группе (max: 1, min: 1)
  ✅ 2 мод.  в первой группе (max: 0, min: 0)
  ✅ 5 мод во второй группе (max: 1, min: 0) [радиокнопка, при нажатии снимает с предыдущего]
  ✅ 5 мод во второй группе (max: 0, min: 0)
  ✅ 5 мод во второй группе (max: 3, min: 0)  
  ✅ 5 мод во второй группе (max: 6, min: 5)  
  ✅ 5 мод во второй группе (max: 5, min: 0)  у модификатора задан  max:1 min:0
  ✅ 5 мод во второй группе (max: 5, min: 0)  у модификатора задан  max:1 min:1 ()чекбоксы
  ✅ 5 мод во второй группе (max: 1, min: 2)  (обработка ошибки)
  ✅ 5 мод во второй группе (max: 0, min: 0)  у модификатора задан  max:3 min:0 default 1
  ✅ 5 мод во второй группе (max: 6, min: 5, выбраны дефолтные)  
  ✅ 5 мод во второй группе (У одного модификатора цена 0)
  ✅ 5 мод во второй группе (У всех модификаторов цена 0)
  ⏰ 1 мод в третьей группе (max: 5, min: 3)
  ✅ 7 мод во второй группе (max: 0, min: 0)
  ✅ 42 мод во второй группе (max: 0, min: 0)
  ⏰ у модификатора нет граммов
  ⏰ у модификатора нет имени
  ⏰ Длинное название у группы модификаторов
  ⏰ Длинное  описания модификаторов
  ⏰ Длинное название у описания модификаторов
  ⏰ цена модификатора ноль



  <i>server: dm_base_9</i>
  </pre>
</details>



---

## cart

## cart-panel (layout2)

## checkout

## order

## order-page

---

## footer

## review

## stocks

## basic-page