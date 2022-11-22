+++
title="The Risks of Copying and Pasting Apex"
[taxonomies]
categories=["Articles"]
+++

It's a tricky position to be placed in: you're an admin, a declarative developer, or a junior developer, and your leadership comes to you with an ask that you know requires Apex that you haven't been trained to write.

What do you do? You're a problem-solver and you want to deliver value to the business, so you hit the Salesforce content sphere on your search engine of choice and turn up some blogs that seem like they hit the target, or at least are pretty close. And there's some Apex code ready for the copy-and-pasting. Jackpot!

This is my plea to _not_ do what you've got in mind to do. Let's explore a couple of the risks. To set context, I have worked as a Salesforce admin, developer, and architect, and I've reviewed a great deal of good and awful Apex code. I want to help you understand the risks of consuming Apex that you don't fully understand.


## The Code You Find is Terrible (Or At Least Buggy)

Take this example business requirement:

> When a user updates a Contact, if the Phone field is not blank, the Account's Phone field is updated to match.

Let's set aside for a moment the fact that this is a very silly requirement that makes little sense in most business contexts. It's not unrepresentative of real asks made by users that prioritize "seeing everything on one screen", and don't fully understand the Salesforce data model. As an admin or architect, one of the ways you can provide value is in digging to find the user need that underlies the ask and helping to design a more idiomatic, safer, and more maintainable solution. Faced with such an ask, that's the course I would recommend before even beginning to design a solution. 

But suppose your leadership stands firm, and you move forward with an implementation. You've fairly new to Salesforce and haven't mastered Flow yet, so you go a-searching for solutions and stumble upon some Apex that seems to hit the mark just right. Here's the Apex, and note that this is _real code recommended by a Salesforce blog_ that I've lightly modified and anonymized to protect the guilty.


```java
public class ContactHandler {
    public static void afterUpdate(List<Contact> newList) {
        Set<Id> accountIds = new Set<Id>();
        for(Contact con : newList){
            accountIds.add(con.AccountId);
        }

        List<Account> accountList = [
            SELECT Id, Name, Phone, 
                   (SELECT Id, FirstName, LastName, Phone, AccountId FROM Contacts)
            FROM Account
            WHERE Id IN :accountIds
        ];

        for (Account a1 : accountList) {
            for (Contact c1: a1.Contacts) {
                if (c1.Phone != null) {
                    a1.Phone = c1.Phone;
                    update accountList;
                }
            }
        }
    }
}
```

This code is presented as an off-the-shelf solution to your business problem. What do you think? As an admin or declarative developer, have you spotted the _two catastrophic problems in this code that will break your production org_? (There are quite a few other problems, but these two are catastrophic!)

+++

Here are the catastrophic problems. Fully code-reviewing the other issues with this trigger handler is left as an exercise for the reader.

### DML in a Loop Leading to Limits Exceptions

"No DML in a loop" is one of the first best-practices every Apex programmer learns. This code gets it wrong, and gets it wrong in an especially pernicious way. Because `update accountList` is located inside the nested `for` loops, it will execute once for every Contact on every Account for which a Contact was updated. If, for example, a user updates ten Contacts, and each of those Contacts has an Account with an average of sixteen other Contacts, the code will run 160 `update` DML operations. Since the limit is 150, the user's got a `LimitException`, and you've got a support case.

In practice, the code would likely fail quite a bit sooner due to causing lots more trigger invocations that themselves may consume DML. We just broke production! That means stopping workflows for every user who enters Contact data; it means potentially disrupting integrations that may require extensive work to fix.

### Incorrect Logic Leading to Data Loss or Corruption

The code does not actually implement the stated objective. To see how, suppose we update a Contact's Phone field. The Contact's Account has ten other Contacts with a mix of older Phone values. What happens?

The Account in fact gets updated eleven times (one per Contact returned by that SOQL query). The Phone value from whichever Contact happens to come last in the query result "wins". That's not necessarily the Contact that kicked off the trigger invocation; it might be some Contact last updated five years ago! If this code ends up producing the right result, it does so by accident. The ordering of a SOQL query without an explicit `ORDER BY` clause is [undefined](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_orderby.htm).

+++

This code is egregiously broken. I use it as an example because it's _real_, originating from an actual Salesforce blog. You may have been able to spot at least one of the catastrophic errors above. Perhaps you also spotted less-critical or subtler errors, like the fact that the class queries data it already has and doesn't need, or that it uses a poorly-designed trigger framework. If you're a declarative developer, you probably spotted a better solution using Flow. If you're a business analyst or architect, you probably have a response to redirect the user who wanted this feature to a better solution.

The critical point I'm asking you to take away, though, is this: evaluating Apex, like any code, can be subtle and tricky. As an admin, declarative developer, or junior developer — that is, as someone who does not have extensive experience writing code for a living —, you may not be prepared to spot all of the ways in which code can be _wrong_, and in which it could potentially damage your org and your users. Code-based solutions aren't puzzle pieces, ready to snap into place. They're complex machines that interact in complex ways with everything else in your org. Incorporating code into your org that you aren't equipped to write yourself places you, your org, and your users at risk.

Be cautious with code. Don't copy and paste it.

## The Code You Find Requires Modifications or Tests

Take a less cut-and-dried example. Here's a business requirement, again:

> When two Accounts are merged, the winning Account's Number of Employees field should have the Number of Employees from the merged Accounts added. 

And here's a code sample I ginned up that comes close to meeting it, but doesn't quite hit the mark. (Note that this code isn't using a trigger handler framework, for brevity's sake; this is _not_ best practice!)

```java
trigger AccountMergeTrigger on Account (after delete) {
    Map<Id, Account> winningAccounts = new Map<Id, Account>();
    for (Account acc: Trigger.old) {
        // Set the "Has_Merged_Accounts__c" field on the winning Account
        // for each Account deleted by a merge.
        if (acc.MasterRecordId != null) {
            winningAccounts.put(acc.MasterRecordId, new Account(Id = acc.MasterRecordId, Has_Merged_Accounts__c = true));
        }
    }

    update winningAccounts.values();
}
```

This code's not _that_ far from the business requirement. It responds to a merge event by updating a field on the winning record, just like we want. It's not terrible Apex (_pace_ the caveat above about using a framework). But there's two issues with trying to use this code to satisfy the requirement.

### Modifying the Logic

It might sound straightforward to change this code to make it match the business requirement: after all, we're just updating a different field! And it's true that it's not a huge lift. But it's also not a simple tweak of a parameter. Responding to the business requirement would require that we add a query to retrieve the current values of the Number of Employees field for the winning Accounts. Then, we'd write logic to add together the values of the field from the losing Accounts, taking care to handle the situation that multiple Accounts are being merged into the same winning Account (remember that we can merge [up to three records](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_dml_examples_merge.htm)).

In the end, we'd have written mostly new code, and have more than twice the number of lines. Here's what it might look like:

```java
trigger AccountMergeTrigger on Account (after delete) {
    Set<Id> winningAccountIds = new Set<Id>();

    for (Account acc: Trigger.old) {
        if (acc.MasterRecordId != null && acc.NumberOfEmployees != null) {
            winningAccountIds.add(acc.MasterRecordId);
        }
    }

    Map<Id, Account> winningAccounts = new Map<Id, Account>([
        SELECT Id, NumberOfEmployees
        FROM Account
        WHERE Id IN :winningAccountIds
    ]);

    for (Account acc: Trigger.old) {
        if (acc.MasterRecordId != null && acc.NumberOfEmployees != null) {
            Integer startingNumberOfEmployees = winningAccounts.get(acc.MasterRecordId).NumberOfEmployees;
            Integer newNumberOfEmployees = (startingNumberOfEmployees ? startingNumberOfEmployees : 0) + acc.NumberOfEmployees;
            winningAccounts.put(
                acc.MasterRecordId,
                new Account(Id = acc.MasterRecordId, NumberOfEmployees = newNumberOfEmployees)
            );
        }
    }

    update winningAccounts.values();
}
```

There's common lineage with the example solution, to be sure, but we mostly had to write new code here. That's the takeaway from this example: if you're fundamentally not comfortable writing code, attempting to modify a third-party example does not help a great deal. And, again, it leaves you at significant risk of negatively impacting your org if you aren't fully comfortable constructing the logic yourself. (As one illustration of that risk: I had to quickly revise this code example after publishing, because I found a bug that would've thrown exceptions!)

### Writing Apex Tests

On the Salesforce platform, you cannot deploy code to your production org without meeting _code coverage_ metrics. Code coverage is a measure of the extent to which the code is evaluated by Apex tests, which validate that it behaves the way you expect it to in different situations. Questions about [Apex testing](https://salesforce.stackexchange.com/questions/244788/how-do-i-write-an-apex-unit-test) and [code coverage](https://salesforce.stackexchange.com/questions/244794/how-do-i-increase-my-code-coverage-or-why-cant-i-cover-these-lines) are so common on Salesforce Stack Exchange that I wrote two standard articles about them. 

Many solutions you'll find written about on blogs don't come with tests that prove they do what they are supposed to do. I'm sure there are many reasons for this: some authors may feel tests are extraneous to the point they're trying to make; others, correctly, assess that they cannot provide tests that will work for every org. Testing highlights the fact we touched on above: all of the automation, including code, in your org is interconnected. Testing code in isolation without DML and applying dependency injection are software engineering strategies to limit this interconnection, but that's not something you'll usually spot in a code sample.

Tests aren't one-to-one with solutions. Again, these are not puzzle pieces to be snapped together. Tests in many cases need to take into account the org environment in which the code executes: what fields are required on what objects; what other triggers and flows exist. Constructing a good suite of tests (and it is almost always a suite, not just one test: you need to know how the code behaves with one record, with many records, with empty field values, with different input conditions simulating real user actions) requires an in-depth understanding of the code itself and the environment in which it executes.

The platform enforces testing as a quantitative rubric (you must meet a coverage threshold). It's also a great qualitative rubric: if you're not comfortable writing tests for a piece of code, you should on no account be deploying that code!

## What You Should Do Instead of Copying and Pasting Apex

You want the best outcome for your organization, and you want to deliver as much value as you can to support your users. Here's some routes you can pursue that honor that goal, without incurring code-based risk that you're not equipped to mitigate.

As an admin or declarative developer, part of the value that you bring to the organization is your risk-assessment capability and your ability to communicate with your stakeholders about technical solutions. Use those skills here. You might come to your stakeholders with a declarative proposal that gets 80% of the way to the goal. You might apply your knowledge of the platform to side-step the ask by delivering an idiomatic solution that nails the underlying user need. Or you might write a proposal to engage a local consultancy or a freelancer to build some code to get you that extra 20% of the way. Whichever way you go, you can clearly define the risk landscape for your org: how the solution will scale, what the maintenance story and costs will look like, and what the timeline to completion might be.

As a junior developer, or an aspiring developer, you might want to dive into the code, even if you're not completely comfortable with the shape of the solution. That's great! Don't just copy and paste, though: take solutions you find as opportunities to dig in and understand what makes Solution A strong, or Solution B risky. Be inspired by solutions you see as you write your own code. And make sure you do so in a context where you can get the review and guidance you need to ensure you deliver a safe, performant, best-practice solution. Your company should situate you in a team context where you can find review and resources from more senior developers. If they aren't doing that for you, you're in a situation that might put you at risk, both immediately in the context of completing high-risk assignments and in long-term risk to your career development. Take advantage of community resources like Trailblazer groups and online communities — but don't hesitate to consider if you might grow your career more effectively in a context where you have a supportive team to help you grow.

But please don't copy and paste code into your org.
