# Represents only User object
class User
  include ActiveModel::Model

  attr_accessor :id, :name, :email
end
