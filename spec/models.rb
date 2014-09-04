class Person < ActiveRecord::Base

  include WitnessProtection

  protected_identity :name

end


class Access < ActiveRecord::Base

  include WitnessProtection

  protected_identity :token

end
