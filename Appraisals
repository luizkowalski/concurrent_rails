# frozen_string_literal: true

appraise "rails-7.2" do
  gem "rails", "~> 7.2.0"
  gem "sqlite3", "~> 1.7"
end

appraise "rails-8.0" do
  gem "rails", "~> 8.0.0"
  gem "sqlite3"
end

appraise "rails-8.1" do
  gem "rails", "~> 8.1"
  gem "sqlite3"
end

appraise "rails-main" do
  gem "rails", github: "rails/rails", branch: "main"
  gem "activerecord", github: "rails/rails", glob: "activerecord/*.gemspec"
  gem "sqlite3"
end
