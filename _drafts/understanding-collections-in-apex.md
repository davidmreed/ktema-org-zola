---
layout: post
title: Understanding Collections in Apex
---

## Introduction to Collections

## Object Identity

## Types and Generics

## Performance Concepts

Operating on data stored in collections can be very expensive in CPU time. In order to write code that is performant and reliable, it's critical to understand the performance characteristics of different collection operations.

The complexity of operations is often described in computer science using _Big-O notation_. We won't get into the details of Big-O notation here, but we'll start with a quick summary. When we think about performance, one of the key questions is this:

> If my data gets bigger, how much more work has to be done to process it?

If the work required to process the data stays the same regardless of the data's growth, the operation executes in _constant time_, in Big-O notation `O(1)`. That means that for 10 records and for 100 records, the work required is of the same complexity. (Note that this _doesn't_ mean the operations will take exactly the same time).

If the work grows at the same rate as the data, the operation executes in _linear time_, or `O(N)`. That means that 100 records would require 10 times as much work as 10 records.

If the work grows exponentially as the data grows, the operation executes in _exponential time_, such as `O(N^2)`. That means that 100 records would require _100_ times as much work as 10 records.

We always want to design our code in a way that keeps the computational complexity as low as possible for any given problem, to ensure that our code remains performant as data scales, to avoid governor limit exceptions, and to provide a good experience for our users. Not all problems can be reduced to constant time, or even linear time, but recognizing the three cases in our use of collections allows us to make informed decisions about the safeguards we need to protect our code, data, and users.

## Lists

> Also known as: arrays, vectors.

### Use Cases

### Antipatterns

Searching a `List` to determine if it contains a specific value is a _linear time_ operation, because code has to iterate over, potentially, all of the data in the `List`. If you need to check whether a value is a member of a collection, a `Set` or `Map` is often more appropriate.

A common antipattern with `List`s is the _matrix search_. Given two `List` values, the engineer scans them both in nested `for` loops:

```apex
for (Account a: someList) {
    for (Contact b: someOtherList) {
        if (a.Id == b.AccountId) {
            // Do something
        }
    }
}
```

This is not linear, but exponential time. This pattern should virtually always reduce to one `List` and one `Map`, where the `Map`'s keys are the values you want to use to connect the members of the two collections:

```apex
Map<Id, Account> accountMap = new Map<Id, Account>(...);
List<Contact> contactList = ...;

for (Contact c: contactList) {
    if (accountMap.containsKey(c.AccountId)) {
        // Do something
    }
}
```

This code is linear, because it only traverses one `List`, but still must traverse all of the values in that `List`. For more about this pattern, see [TODO].

### For Users of Other Languages

- Apex `List`s are always homogeneous (they contain only one type of value). That type can, however, be `Object` or `sObject`.
-

## Sets

> Also known as: hash sets.

### Use Cases

### Antipatterns

- `Set`s should not be used to store ordered data. While the iteration order of a `Set` is deterministic, the platform makes no guarantees as to _what that order is_, so you should not rely upon it.

## Creation and Conversion

A `Set` can be created from a `List` via the constructor:

```apex
List<String> externalIds = ...;
Set<String> uniqueExternalIds = new Set<Id>(externalIds);
```

and vice versa:

```apex
Set<String> uniqueExternalIds = ...;
List<String> externalIds = new List<String>(uniqueExternalIds);
```

A `Set` can be created from a `Map` via the `Map#keySet()` method:

```apex
Map<Id, sObject> recordMap = new Map<Id, sObject>([SELECT ...]);
Set<Id> recordIds = recordMap.keySet();
```

It's not possible to directly convert a `Map`'s values into a `Set`, because unlike keys they are not guaranteed by the collection to be unique. To obtain a `Set` of a `Map`'s values, first obtain them as a `List` via `Map#values()`.

### For Users of Other Languages

- Set identity semantics in Apex can be _very_ tricky. From the [Apex Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.228.0.apexcode.meta/apexcode/apex_methods_system_set.htm):

> Uniqueness of set elements of user-defined types is determined by the `equals` and `hashCode` methods, which you provide in your classes. Uniqueness of all other non-primitive types is determined by comparing the objects’ fields.
> If the set contains String elements, the elements are case-sensitive. Two set elements that differ only by case are considered distinct.

## Maps

> Also known as: hash maps, dicts, associative arrays.

### Use Cases

### Antipatterns

### For Users of Other Languages

- Apex `Map`s are always homogeneous (they contain only one type of value as keys and one type of value as values). Those types can, however, be `Object` or `sObject`.
