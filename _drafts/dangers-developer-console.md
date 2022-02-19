---
layout: post
title: On the Dangers of the Developer Console
---

*The Developer Console is a trap for early-career Salesforce developers*. Here's why, and the tools you can use to achieve the same objectives in a safer way.

## Execute Anonymous

### User Mode and the Tooling API

It's easy to imagine that the Developer Console's "Execute Anonymous" feature just ... runs your code, in some straightforward fashion analogous to how your other triggers and classes are run. The reality is slightly more complicated, and the comes with subtle consequences for the behavior of your code.

Under the hood, the Developer Console is making a Tooling API call to [run Anonymous Apex](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_anonymous_block.htm). And that has a critical environmental difference from almost everywhere else you'll run Apex:

> Unlike classes and triggers, anonymous blocks execute as the current user and can fail to compile if the code violates the user's object- and field-level permissions.

The API enforces CRUD, FLS, and record-level sharing against the code you're running - it runs in user mode, not the system mode you're used to for triggers and other Apex automation. If you attempt to run code that references a field or object to which you do not have FLS or CRUD, you obtain an error that can be very confusing:

```lang-java
for (Account a: [SELECT Id, Star_Helix_Liaison__c FROM Account]) {
    // Do some work.
}
```

> SELECT Id, Star\_Helix\_Liaison\_\_c FROM Account ^ ERROR at Row:1:Column:12 No such column 'Star\_Helix\_Liaison\_\_c' on entity 'Account'. If you are attempting to use a custom field, be sure to append the '\_\_c' after the custom field name. Please reference your WSDL or the describe call for the appropriate names.

It's easy to end up tearing your hair out as you stare at Object Manager in another tab, the field `Star_Helix_Liaison__c` _manifestly_ existing on the `Account` object. But it's FLS: you can't read that field, and that results in a compile-time error in Anonymous Apex.

Anonymous Apex always runs `with sharing`, enforcing record-level access. This behavior can also be quite surprising

### The Magic Outer Class

Suppose you're testing a class structure like this, perhaps as a data-transfer object for deserializing a JSON message:

```lang-java
class Foo {
    class Bar {
        
    }
}
```

If you include this code in an Anonymous Apex body, you'll get a compile-time error:

> Inner types are not allowed to have inner types.

But we only have one inner type here! That's perfectly legal in Apex... except when we're in the Execute Anonymous context. Here, the entire code block is wrapped in an anonymous outer class by the system, _of which `Foo` is an inner class_. That means that in Execute Anonymous, but _not_ anywhere else we use this code, `Bar` is an illegal inner class of an inner class.

(You could move `Bar` out of the context of `Foo` to allow it compile in Anonymous Apex, but it's a better plan to switch to different tools for testing an exploration, such as writing Apex unit tests).

For the same underlying reason, you cannot use the `static` keyword on a method defined in a class in your Anonymous Apex: [inner classes cannot use the `static` keyword](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_static.htm), and every class in Anonymous Apex is an inner class.

### Persistence of User Context

"Why is Miller showing up as the Last Modified By on thousands of records every day?" an admin might wonder. "And the time stamps are all in the middle of the night!"

Miller likely forgot something critical: if one uses Anonymous Apex in the Developer Console to schedule an Apex class, including a batch class, the class retains the original user context indefinitely. That batch class you set up to run every night at midnight? It runs _as you_, because it was scheduled with you as the context user via Anonymous Apex. (In that sense, it's not _anonymous_ at all!)

This feature doesn't apply only to Anonymous Apex, of course: anywhere you schedule Apex, you'll find the same behavior. But it's easy to let that knowledge slip, especially when you're trying to fix a problem quickly.

## The Quirks of the Query Editor

Query Editor can be very useful for doing quick checks, but it's got its share of quirks.

Try running 

```lang-sql
SELECT VersionData FROM ContentVersion
```

You'll see a list of URLs, not the content you might have expected (especially if your Cont is mostly text rather than binary).

That's an API artifact. The Query Editor is running your queries over the API, where field data of type `Blob`, like `VersionData`, is not included in the response. Instead, the API returns a URL the client can hit to download the potentially-large, potentially-binary content. That's what you see in Query Editor.

## When `System.debug()` Tricks You

It seems like the most natural thing in the world to fire up the Developer Console and run `System.debug()` in Anonymous Apex while you explore the system. But there's a trick - well, several tricks.

```lang-java
Account a = new Account(Name = 'Transport Union');
insert a;
Contact c = new Contact(FirstName = 'Camina', LastName = 'Drummer', AccountId = a.Id);
insert c;

System.debug([
    SELECT LastName, Account.Name, Email FROM Contact WHERE Id = :c.Id
]);
```

Look what you get back:

> 22:41:15:000 USER\_DEBUG [6]|DEBUG|(Contact:{LastName=Drummer, AccountId=0011R00002pCh07QAC, Id=0031R00002fBlWOQA0})

We queried `Email`, but it's not here at all - not even as `null`. And where's the `Account.Name` value? Is it `null`? Did we do something incorrect in the data setup?

No, it's not `null`; the value's just what you think it is. But `System.debug()` does not represent fields across relationships in its output, and it does not represent `null` values, even if they're queried on an sObject.

This behavior can be insidious. If you're trying to track down a problem, you might look at your `System.debug()` output, see values that are not what you expected, and go on a wild-goose chase after a bug that's not real - while missing the real bug that caused the problem with which you started!

sObject output behavior is not the only place that `System.debug()` can be deceptive to the unwary. Take this example:

```lang-java
List<String> stations = new List<String>{
    'Ceres', 'Pallas', 'Tycho', 'Ganymede',
    'Vesta', 'Medina', 'Eros', 'Phoebe',
    'Iapetus', 'Laconia', 'Callisto', 'Draper'
};

System.debug(stations);
```

You'd expect to see twelve items in your debug output, right? No such luck:

> 22:47:53:004 USER\_DEBUG [8]|DEBUG|(Ceres, Pallas, Tycho, Ganymede, Vesta, Medina, Eros, Phoebe, Iapetus, Laconia, ...)

`System.debug()` truncates collection output (note the ellipsis, `...`), and does not by default output the collection size. You'll find the same behavior with `Map` and with `List`.

It's also important to know what it is you're seeing. It's not JSON, or any other parseable format. Rather, it's the result of `String.valueOf(yourCollection)`. (You can demonstrate this for yourself in, where else, the Developer Console!) You shouldn't ever migrate this representation elsewhere, or store it in your database. It's not useful.

If you want a clearer representation that you can both store safely *and* inspect within the debug logs, use `JSON.serialize()` or `JSON.serializePretty()` to turn the collection into JSON first, or iterate over the collection to inspect its items.

Using JSON doesn't mean you can log arbitrary amounts of data: the system will still truncate the string in your logs to the first 501 characters. However, it's generally a more readable representation, and likely gives you *more* to look at in the debug log.

