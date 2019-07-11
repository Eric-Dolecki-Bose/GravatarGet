![badge](./ed-badge.png)

----

# GravatarGet
Getting a gravatar image and profile information from an email address that gets md5 hashed. The Gravatar APIs are difficult to use by any means, but it introduces the need to md5 hash an email address and use that in the API calls for both avatar image and also the profile data. 

I am using .json for the profile data. 

Because the root of the profile JSON is an array with a single item, it made parsing a little different. Using Codable structs to handle that which makes parsing so much easier than before.
