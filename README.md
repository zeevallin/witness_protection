# Witness Protection
Rails library that lets you have an encrypted identities for your active record models.

## Setup

Add an an encryption salt through your `secrets.yml` or `application.yml` if you're using Figaro.
As long as you get the encryption salt in to your environment you'll be fine.

```yaml
development:
  encryption_salt: "$2a$10$pKIdnO.R6xIrnIr5T6k8GO"
```

You can generate an encryption salt using the bcrypt engine.

```
require "bcrypt"
BCrypt::Engine.generate_salt
# => "$2a$10$pKIdnO.R6xIrnIr5T6k8GO"
```

Create a model with an attribute you'd like to have encrypted.

```bash
$ rails generate model Person name:string
```

Include witness protection in your model and use the protected_identity macro to enable encryption.

```ruby
require "witness_protection"

class Person < ActiveRecord::Base

  include WitnessProtection

  protected_identity :name

end
```

```ruby
Person.create name: "Philip"
# => <Person id: 1, name: "$2a$10$8RdONCVhuLKmt0Fu5IxAo.vApyi0LISUJ6XxMNQjwJV...">

Person.identify_by_name "Philip"
# => <Person id: 1, name: "$2a$10$8RdONCVhuLKmt0Fu5IxAo.vApyi0LISUJ6XxMNQjwJV...">
```

## Generated values
You are also able to generate values for the protected identity field. This is useful for things like auth tokens.

```ruby
class User < ActiveRecord::Base

  include WitnessProtection

  protected_identity :auth_token

end
```

```ruby
user = User.create
# => <User id: nil, auth_token: nil>

token = user.generate_auth_token { SecureRandom.hex }
# => cb17f6573c5cb9bc86e90b66d1a441ef

user
# => <User id: nil, auth_token: "$2a$10$8RdONCVhuLKmt0Fu5IxAo.GlU.PXWR4nOeLfv2THxhC...">

user.save
# => true

User.identify_by_auth_token(token)
# => <User id: 1, auth_token: "$2a$10$8RdONCVhuLKmt0Fu5IxAo.GlU.PXWR4nOeLfv2THxhC...">
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem "witness_protection"
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```
$ gem install witness_protection
```


## Lisence

Copyright (c) 2014 Philip Vieira

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

