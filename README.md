# Decidim::Dataspace

Decidim Data space is an API that allows decidim applications to communicate with each other.

## Usage

Data space will be available as a module.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-dataspace"
```

And then execute:

```bash
bundle install
# For versions >= 0.27
bundle exec rake railties:install:migrations
bundle exec rake db:migrate
```

## API endpoints
+ Retrieve all data from the data space\
GET "api/v1/data"
+ Retrieve all containers from the data space\
GET "api/v1/data/containers"
+ Retrieve a container using its reference\
GET "api/v1/data/containers/:reference"
+ Retrieve all contributions from the data space\
GET "api/v1/data/contributions"
+ Retrieve a contribution using its reference\
GET "api/v1/data/contributions/:reference"
+ Retrieve all authors from the data space\
GET "api/v1/data/authors"
+ Retrieve an author using its reference\
GET "api/v1/data/authors/:reference"

Please note that for the data and the contributions endpoints, you can add a container query params
+ "container=JD-PROP-2025-09-1" to get only the contributions from the specified container

Please note that for the 2 endpoints related to contribution, you can also add 2 query params
+ "preferred_locale=fr" to get the data with your favorite language (default is "en")
+ "with_comments=true" (default is false)
  + for contributions endpoint, it will give you proposals and comments (the default is only proposals)
  + for contribution endpoint, it will give you a proposal with detailed comments as children

Please note that the reference is the last part of the URL and **needs to be URL encoded**

## Contributing

Contributions are welcome !

We expect the contributions to follow the [Decidim's contribution guide](https://github.com/decidim/decidim/blob/develop/CONTRIBUTING.adoc).

## Security

Security is very important to us. If you have any issue regarding security, please disclose the information responsibly by sending an email to __security [at] opensourcepolitics [dot] eu__ and not by creating a GitHub issue.

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.
