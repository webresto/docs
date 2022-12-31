---
title: "Criteria language for Webresto server"
linkTitle: "CriteriaQL"
description: >
    Description and examples of criteria query language
---


# GraphQL criteria-filter helper (Criteria query language)

The syntax supported for GraphQL filter helper (criteria Query Language).  GraphQL filter helper (criteria knows how to interpret this syntax to retrieve or mutate records from any supported database.  

### Query language basics

Queries can be built using either a `where` key to specify attributes, or excluding it.


```
criteria: {
  where: { name: 'mary' },
  skip: 20,
  limit: 10,
  sort: 'createdAt DESC'
}
```
Constraints can be further joined together in a more complex example.

```
criteria: {
  where: { name: 'mary', state: 'me', occupation: { contains: 'teacher' } },
  sort: [{ firstName: 'ASC'}, { lastName: 'ASC'}]
}
```

If `where` is excluded, the entire object will be treated as a `where` criteria.

```
criteria: {
  name: 'mary'
}
```

#### Key pairs

A key pair can be used to search records for values matching exactly what is specified. This is the base of a criteria object where the key represents an attribute on a model and the value is a strict equality check of the records for matching values.

```
criteria: {
  name: 'lyra'
}
```

They can be used together to search multiple attributes.

```
criteria: {
  name: 'walter',
  state: 'new mexico'
}
```

#### Complex constraints

Complex constraints also have model attributes for keys but they also use any of the supported criteria modifiers to perform queries where a strict equality check wouldn't work.

```
criteria: {
  name : {
    'contains' : 'yra'
  }
}
```

#### In modifier

Provide an array to find records whose value for this attribute exactly matches _any_ of the specified search terms.

> This is more or less equivalent to "IN" queries in SQL, and the `$in` operator in MongoDB.

```
criteria: {
  name : ['walter', 'skyler']
}
```

#### Not-in modifier

Provide an array wrapped in a dictionary under a `!=` key (like `{ 'not': [...] }`) to find records whose value for this attribute _ARE NOT_ exact matches for any of the specified search terms.

> This is more or less equivalent to "NOT IN" queries in SQL, and the `$nin` operator in MongoDB.

```
criteria: {
  name: { 'not' : ['walter', 'skyler'] }
}
```

#### Or predicate

Use the `or` modifier to match _any_ of the nested rulesets you specify as an array of query pairs.  For records to match an `or` query, they must match at least one of the specified query modifiers in the `or` array.

```
criteria: {
  or : [
    { name: 'walter' },
    { occupation: 'teacher' }
  ]
}
```

### Criteria modifiers

The following modifiers are available to use when building queries.

* `'lessThan'`
* `'lessThanOrEqual'`
* `'greaterThan'`
* `'greaterThanOrEqual'`
* `'not'`
* `nin`
* `in`
* `contains`
* `startsWith`
* `endsWith`


#### 'lessThan'

Searches for records where the value is less than the value specified.

```
criteria: {
  age: { 'lessThan': 30 }
}
```

#### 'lessThanOrEqual'

Searches for records where the value is less or equal to the value specified.

```
criteria: {
  age: { 'lessThanOrEqual': 20 }
}
```

#### 'greaterThan'

Searches for records where the value is greater than the value specified.

```
criteria: ({
  age: { 'greaterThan': 18 }
}
```

#### 'greaterThanOrEqual'

Searches for records where the value is greater than or equal to the value specified.

```
criteria: {
  age: { 'greaterThanOrEqual': 21 }
}
```

#### 'not'

Searches for records where the value is not equal to the value specified.

```
criteria: {
  name: { 'not': 'foo' }
}
```

#### in

Searches for records where the value is in the list of values.

```
criteria: {
  name: { in: ['foo', 'bar'] }
}
```

#### nin

Searches for records where the value is NOT in the list of values.

```
criteria: {
  name: { nin: ['foo', 'bar'] }
}
```

#### contains

Searches for records where the value for this attribute _contains_ the given string.

```
criteria: {
  subject: { contains: 'music' }
}
```

_For performance reasons, case-sensitivity of `contains` depends on the database adapter._

#### startsWith

Searches for records where the value for this attribute _starts with_ the given string.

```
criteria: ({
  subject: { startsWith: 'american' }
}
```

_For performance reasons, case-sensitivity of `startsWith` depends on the database adapter._

#### endsWith

Searches for records where the value for this attribute _ends with_ the given string.

```
criteria: {
  subject: { endsWith: 'history' }
}
```

_For performance reasons, case-sensitivity of `endsWith` depends on the database adapter._


### Query options

Query options allow you refine the results that are returned from a query. They are used
in conjunction with a `where` key. The current options available are:

* `limit`
* `skip`
* `sort`

#### Limit

Limits the number of results returned from a query.

```
criteria: { where: { name: 'foo' }, limit: 20 }
```

> Note: if you set `limit` to 0, the query will always return an empty array.

#### Skip

Returns all the results excluding the number of items to skip.

```
criteria: { where: { name: 'foo' }, skip: 10 }
```

##### Pagination

`skip` and `limit` can be used together to build up a pagination system.

```
criteria: { where: { name: 'foo' }, limit: 10, skip: 10 }
```

#### Sort

Results can be sorted by attribute name. Simply specify an attribute name for natural (ascending)
sort, or specify an `ASC` or `DESC` flag for ascending or descending orders respectively.

```
// Sort by name in ascending order
criteria: { where: { name: 'foo' }, sort: 'name' }

// Sort by name in descending order
criteria: { where: { name: 'foo' }, sort: 'name DESC' }

// Sort by name in ascending order
criteria: { where: { name: 'foo' }, sort: 'name ASC' }

// Sort by object notation
criteria: { where: { name: 'foo' }, sort: [{ 'name': 'ASC' }] }

// Sort by multiple attributes
criteria: { where: { name: 'foo' }, sort: [{ name:  'ASC'}, { age: 'DESC' }] }
```

Thanks for Waterline & Sails developer
 Описание и примеры языка запросов