source "https://rubygems.org"

# Rails
gem "rails", "~> 8.0.3"

# Database
gem "pg", "~> 1.1"

# Web server
gem "puma", ">= 5.0"

# JSON API helpers (optional, uncomment if you want jbuilder views)
# gem "jbuilder"

# Authentication / security
gem "bcrypt", "~> 3.1.7"    # has_secure_password
gem "jwt"                   # JSON Web Tokens for API auth

# Authorization
gem "pundit"                # policies for business rules (creator/assignee checks)

# CORS (allow Retool / Node / browser to call the API)
gem "rack-cors"

# Timezone data on Windows
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Rails performance / dev tools
gem "bootsnap", require: false

# Optional: monitoring, background adapters included in your Rails template
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Useful if you deploy as Docker
gem "kamal", require: false

# Optional HTTP asset caching/compression helper for Puma
gem "thruster", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end
