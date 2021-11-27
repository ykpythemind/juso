class UserSerializer
  include Juso::Serializable

  def initialize(user)
    @user = user
  end

  attr_reader :user

  def juso(context)
    {
      id: user.id,
      name: user.name,
    }
  end
end

