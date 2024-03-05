---
title: "Data mock webresto server"
linkTitle: "Mock servers"
description: >
  Development servers data mocks
---


## Lyrics
This section publishes test cases for data received from the server. Test cases will be divided into logical partitions or data entities. We will follow the logic that the **first server: [next.dev.restoapp.org](https://next.dev.restoapp.org/graphql)** contains the base default dataset. That is, those that people receive after the default setting

> The data and section exist only for the development of webresto clients. Admin panel is disabled.

> For all servers default OTP: `999999`

## List of all servers:

> Example: 
> backendUrl: https://next.dev.restoapp.org/graphql
> imagesUrl: https://next.dev.restoapp.org

|#| name | URL |
|-|:--------|:-----|
|1| 32001 *[default]*   | next.dev.restoapp.org |
|2| 32002   | 32002.fwr.m42.cx |
|3| 32003   | 32003.fwr.m42.cx |
|4| dm_base_4   | 32004.fwr.m42.cx |
|5| dm_base_5   | 32005.fwr.m42.cx |
|6| dm_base_6   | 32006.fwr.m42.cx |
|7| dm_base_7   | 32007.fwr.m42.cx |
|8| dm_base_8   | 32008.fwr.m42.cx |
|8| dm_base_9   | 32009.fwr.m42.cx |


## Login & User data

To determine the login method, the client must request user [restrictions](./authorization.md). Among which there are flags Whether the OTP is required `loginOTPRequired` when logging in or not. And a password policy. `passwordPolicy` is possible 3 variants `['required', 'from_otp', 'disabled']` by default: `from_otp` it means what need only  one OTP, for next logins  passwordRequired, disabled is means password forbidden and you need all time get OTP password. 

Also, one of two options for the login field is possible, it can be an `email` or `phone`, for both cases you must recive OTP.

> Base login case if get OTP and login by OTP

* If `loginOTPRequired: true`, and you pass password in login mutation, you also should pass OTP
* In case `loginOTPRequired: true` and `passwordPolicy: 'disabled'` password will be ignored, and so this just login By OTP

**Custom fields** - These are important fields through which modules or settings for a specific business model can be passed to be filled `allRequiredCustomFieldsAreFilled` in by the user. Whether or not these fields are filled can be seen in the user model at the [getMe](./user.md) request. To get a list of required fields use user restrictions


| Host  | Password policy | Login field | Login OTP required | Allowed phone countries | Custom fields |
|-------|----------------|------------|------------------|-----------------------|--------------|
| 32001 | from_otp       | phone      | No               | 1                     | No           |
| 32002 | required       | email      | Yes              | 3                     | Not required |
| 32003 | disabled       | phone      | No               | All                   | Yes          |


## Mock data for components (testing data for factory)

### header
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




### promotion


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


### dish-nav-bar

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


### dish-line

### dish-card

### dish-modal

<details>
  <summary>Моки для модификаторов</summary> 
  <pre>
  Все моки указаны на одном сервере
  те которые с будильником пока еще не готовы

  список:

✅ 2 мод.  в первой группе (max: 1, min: 1) - обязательный выбор. Свитч
✅ 3 мод.  в первой группе (max: 1, min: 1) - обязательный выбор чекбоксы
✅ 2 мод.  в первой группе (max: 0, min: 0) нет ограничений (+-)
✅ data: 5 мод во первой группе (max: 5, min: 0)  у модификатора задан  max:1 min:0 (5 чекбоксов)
✅ data: контролы вместо свича +++ 5 мод во второй группе (max: 1, min: 2)  (обработка ошибки)
✅ data: первая группа: выбраны дефолтные (у первого мод: дефолт 3)
✅ data: 5 мод во первой группе (max: 6, min: 5, выбраны дефолтные)т оесть если снять выбор с когото можно переставить на другой
✅ data: 5 мод во первой группе (У одного модификатора цена 0) Не должен влиять на финальную цену
✅ data: 5 мод во первой группе (У всех модификаторов цена 0)
✅ Много модификаторов (проверить плейсхолдер в попапе, должен прятатся)
✅ 2 мод.  в первой группе цена у блюда 0
✅ Цена у блюда 0 (Без модификаторов)
✅ Баланс у блюда 3
✅ Баланс у блюда 0
✅ Баланс у блюда 1
✅ 2 мод.  в первой группе (max: 1, min: 1) - обязательный выбор. Свитч
✅ 3 мод.  в первой группе (max: 1, min: 1) - обязательный выбор чекбоксы
✅ 2 мод.  в первой группе (max: 0, min: 0) нет ограничений (+-)
✅ data: 5 мод во первой группе (max: 5, min: 0)  у модификатора задан  max:1 min:0 (5 чекбоксов)
✅ data: контролы вместо свича +++ 5 мод во второй группе (max: 1, min: 2)  (обработка ошибки)
✅ data: первая группа: выбраны дефолтные (у первого мод: дефолт 3)
✅ data: 5 мод во первой группе (max: 6, min: 5, выбраны дефолтные)т оесть если снять выбор с когото можно переставить на другой
✅ data: 5 мод во первой группе (У одного модификатора цена 0) Не должен влиять на финальную цену
✅ data: 5 мод во первой группе (У всех модификаторов цена 0)
✅ Много модификаторов (проверить плейсхолдер в попапе, должен прятатся)
✅ 2 мод.  в первой группе цена у блюда 0
✅ Баланс у блюда 3
✅ Баланс у блюда 0
✅ Баланс у блюда 1
  <i>server: dm_base_9</i>
  </pre>
</details>



---

### cart

<details>
  <summary>Стоимость доставки</summary> 
  <pre>
  Каждый раз приходит разная стоимость доставки.
  Возможные варианты: 
  [150, 1000, 100000, 12345.12 ]
 

  <i>server:  Все сервера</i>
  </pre>
</details>

### cart-panel (layout2)

### checkout
<details>
  <summary>Платежные методы</summary> 
  <pre>
  На первых 4 (32001..32004) серверах есть платежные методы
  На 32003 изменена сортировка в обратном порядке
  на 32005..32015 нет платежных методов(в таком случе нужно непоказывать поле выбора платежного метода, и делать запрос не указывая платежный метод)


  Для платжного метода по "Онлайн на сайте" в ответ от сервера приходит ссылка для редиректа, 
  тестовые карты для оплаты тут: https://securepayments.sberbank.ru/wiki/doku.php/test_cards
  </pre>
</details>


### order

### order-page

---

### footer
<details>
  <summary>Навигация соц-сети</summary> 
  <pre>
  1. Сервера с 32001 по 32004 имеют ссылки социальных сетей и должны отображать их
  2. Сервер 32005 не имеет данных в моделе и должен прятать соцсети
  3. 32006 имеет пустое меню социальных сетей
  </pre>
</details>

### review

### stocks

<details>
  <summary>Акций</summary> 
  c dm_base_1 по dm_base_4 присутвуют различные моки  
</details>


### basic-page