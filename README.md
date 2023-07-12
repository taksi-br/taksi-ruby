# Taksi [![Gem Version](https://badge.fury.io/rb/taksi.svg)](https://badge.fury.io/rb/taksi) [![CI](https://github.com/taksi-br/taksi-ruby/actions/workflows/ci.yml/badge.svg)](https://github.com/taksi-br/taksi-ruby/actions/workflows/ci.yml) [![Codacy Badge](https://app.codacy.com/project/badge/Coverage/c3b7b1b64129408a946ce2c99a5b2706)](https://app.codacy.com/gh/taksi-br/taksi-ruby/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_coverage)

Application framework to build a backend driven UI in ruby.

## Considerations

This repository are in its **very early days** and **not ready for production** yet. If you want to help or understand what it is, get a look over our inspirations on the links below:
  - https://medium.com/movile-tech/backend-driven-development-ios-d1c726f2913b
  - https://engineering.q42.nl/server-driven-ui-at-primephonic/
  - https://www.youtube.com/watch?v=vuCfKjOwZdU

Also, we're working in create a protocol documentation to explain the comunication details between frontend and backend.

## Usage

In Taksi, every interface are composed by 1 to many components, those components are feed by data provided from the interface definition.

Defining a new component:

```ruby
class Components::Users::ProfileResume
  include Taksi::Component.new('users/profile_resume')

  content do
    static :profile_kind, 'resume' # same as `field :profile_kind, Taksi::Static`

    dynamic :name

    field :details do
      field :age Taksi::Dynamic # same as `dynamic :age`
      field :email Taksi::Dynamic
    end
  end
end
```

Defining a new interface (in this example a interface interface):

```ruby
class Interfaces::UserProfile
  include Taksi::Interface.new('user_profile')

  add Components::Users::ProfileResume, with: :profile_data

  attr_accessor :user

  def profile_data
    {
      name: user.name,
      details: {
        age: user.age,
        email: user.email,
      }
    }
  end
end
```

From those definitions you can set up the skeleton or strip the data:

```ruby
user_profile = Interfaces::UserProfile.new
user_profile.skeleton.as_json
```

Which provide us:

```json
{
  "components": [
    {
      "name": "users/profile_resume",
      "identifier": "component$0",
      "requires_data": true,
      "content": {
        "name": null,
        "profile_kind": "resume",
        "details": {
          "age": null,
          "email": null
        }
      }
    }
  ]
}
```

Then, you can strip the data off:

```ruby
user_profile.user = User.find(logged_user_id)
user_profile.data.as_json
```

```json
{
  "interface_data": [
    {
      "identifier": "component$0",
      "content": {
        "name": "Israel Trindade",
        "details": {
          "age": 29,
          "email": "irto@outlook.com",
        }
      }
    }
  ]
}
```

## Supported Ruby versions

This library officially supports the following Ruby versions:

  * MRI `>= 2.7`
