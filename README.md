# OmniAuth Daylite

This is the unofficial [OmniAuth](https://github.com/intridea/omniauth) strategy for 
authenticating to [Daylite](https://www.marketcircle.com/) via OAuth.
To use it, you'll need to register your application by contacting the Daylite support.

## Installing

Add to your `Gemfile`:

```ruby
gem 'omniauth_daylite', github: "LinchSmyth/omniauth_daylite"
```

Then `bundle`

## Usage

Here's a quick example, adding the middleware to a Rails app in `config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :daylite, ENV['DAYLITE_APP_ID'], ENV['DAYLITE_APP_SECRET']
end
```

## Options

### Custom callback

The project for which this strategy was developed had a non-standard callback, and Daylite support was 
changing it really slowly. That's the reason why this strategy have `custom_callback` option so you can specify
callback manually:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :daylite, ENV['DAYLITE_APP_ID'], ENV['DAYLITE_APP_SECRET'], custom_callback: "https://example.com/daylite_custom_collback"
end
```

**IMPORTANT NOTE**

Sometimes you may need to pass additional params with callback or request phases, expecting that the API will 
return it back to you. But with Daylite API sending any additional parameter not included 
[in this description](https://developer.marketcircle.com/v1/docs/authentication-1#section-oauth-2-0-endpoints) causes 500 error on 
their side, so try to avoid additional parameters. For Rails apps you can use `params[:session]` instead to store any additional information. 

### User data

Since [Daylite API](https://developer.marketcircle.com/v1/reference) haven't classical OAuth endpoint like 
`https://developer.marketcircle.com/v1/me` to fetch user data, I'm decided to grab data in 3 steps and then merge it into one hash:

```
# get user id
GET https://api.marketcircle.net/v1/info
 
# get a contact id for this user
GET https://api.marketcircle.net/v1/users/#{user_id}

# get all user info
GET https://api.marketcircle.net/v1/contacts/#{contact_id}
```

The returned data inside the oauth-daylite will be looks like:

```ruby
{"application_identifier" => "com.example",
 "ip_address" => "213.111.81.231",
 "scopes" => ["daylite:read", "daylite:write"],
 "user" => "/v1/users/1000",
 "uid" => "1000",
 "self" => "/v1/contacts/1000",
 "login" => "daylite@example.com",
 "contact" => "/v1/contacts/1000",
 "hex_colour" => "#0080ffff",
 "first_name" => "Linch",
 "last_name" => "Smyth",
 "emails" => [{
   "label" => "Home",
   "address" => "daylite@example.com"
 }],
 "companies" => [{"company" => "/v1/companies/1000"}],
 "owner" => "/v1/users/1000",
 "creator" => "/v1/users/1000",
 "create_date" => "2017-04-28T13:50:49.028Z",
 "modify_date" => "2017-04-28T13:50:51.045Z"
}
```

You can disable fetching this data by adding `only_token: true` (if you need only auth token) or filter data with [filters](#filters) option.

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :daylite, ENV['DAYLITE_APP_ID'], ENV['DAYLITE_APP_SECRET'], only_token: true
end
```

### UID

Any resource on Daylite doesn't have unique ID, it's only have a `"self"` key which represents relative url 
like `"/v1/users/1000"`. So by default you will get UID like `"1000"` or `"2000"` **_which is not unique value per each user_**, but you can 
disable this behavior by adding `create_uid: false` and generate UID for user by yourself:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :daylite, ENV['DAYLITE_APP_ID'], ENV['DAYLITE_APP_SECRET'], create_uid: false
end
```

### Filters

Also, you can define filter for user data, which you don't want to be returned from OAuth (or leave empty array to get all available data):

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :daylite, ENV['DAYLITE_APP_ID'], ENV['DAYLITE_APP_SECRET'], filter: ["self", "owner", "creator"]
end
```

Default filter contains the following fields: `['self', 'owner', 'creator', 'contact', 'user']`


## Authentication Hash


Will be described soon...



## Contributing to omniauth-daylite


* Fork, fix, then send me a pull request.


## License


Copyright (c) 2011-2017 Linch Smyth

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

