require_relative 'app'

Time.zone = "Tokyo"
ActiveRecord::Base.default_timezone = :local

run TodoApp
