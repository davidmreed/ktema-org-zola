+++
title="The Sneaky Way to Install a JWT Connected App"
+++

If you build backend services that integrate to Salesforce, you may have encountered this unusual scenario while setting up the JWT Flow.

You've built a service, Service A. You've created a Connected App in an org you control (Connected App Org). Meanwhile, you have one or more production orgs you plan to integrate with Service A (Orgs B-F). You're using the JWT Flow, because Service A is headless and needs to maintain persistent access. To set up the JWT Flow, you've attached your certificate to the Connected App and provided it to Service A (in a config var, right? Never commit credentials to source control).

But then, in each of Orgs B-F, you need to ensure that Service A's integration user is authorized to connect via that Connected App _without_ completing a UI-based flow. To do that, you set the Connected App's Permitted Users field to "Admin approved users are pre-authorized" and assign integration users to a Preapproved Profile or Permission Set. Then, you get that holy grail: fully headless authentication between your service and your org.

There's a catch, though. In order to manage the policies for your Connected App in Orgs B-F, you have to _install_ the Connected App in those orgs. And the usual way to do that is... completing an interactive OAuth flow, like the Web Server flow. Which you haven't implemented in Service A, because it doesn't have a front end.

There are multiple ways to solve this challenge. One that I've done before, but strongly dislike, is to use a separate OAuth client that can be configured to use your Connected App (Postman or CumulusCI works, for example). You can then have that client run the Web Server Flow while masquerading as Service A in order to get the Connected App installed in each org. That route's messy, though: you generally have to alter your Connected App to support the separate OAuth client's callback URL, and you may also have to remove security configuration like Login IP Ranges on your integration user Profiles.

The current way I'm approaching this is as follows. It's still a bit clunky, but is much faster and doesn't require you to change your security-related components or to implement the Web Server flow in your headless applications.

1. Locate the desired Connected App in the org that owns it, under Setup→App Manager.
1. Choose Edit from the dropdown menu on the right.
1. Look at the current page URL, all the way to the end. The URL should end in an `0Ci` id. This is the `AppManifest` id for the Connected App.
1. In the target org, construct the app install URL along this pattern:

        https://your-domain.my.salesforce.com/identity/app/AppInstallApprovalPage.apexp?app_id=<0Ci id>

    Make sure to use the domain for your target org and insert the `0Ci` id as the `app_id` parameter
1. Click the Install button on the page.
1. You'll be redirected to the installed Connected App.
1. Click Edit Policies
1. Set Permitted Users to "Admin approved users are pre-authorized"
1. Save
1. Make sure to add the relevant Preapproved Profiles or Permission Sets to allow your user(s) to connect.

Unfortunately, as far as I can tell, there's no way to query the `AppManifest` Id, so you do have to perform this dance to obtain it. I'd love to find that I'm wrong about that! But in the meantime, this procedure works nicely.