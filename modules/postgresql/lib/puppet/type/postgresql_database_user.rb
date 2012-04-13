Puppet::Type.newtype(:postgresql_database_user) do
  desc 'Type for managing postgres database and user creation'

  ensurable do
    defaultto(:present)
    newvalue(:present) do
      provider.create
    end
    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:db_name, :namevar => true) do
    desc 'Name of user'
    newvalues(/^\S+$/)
  end

  newparam(:db_password) do
    desc 'Database password.'
    newvalues(/^\S+$/)
  end

  newparam(:db_user) do
    desc 'Database username.'
    newvalues(/^\S+$/)
  end

  validate do
    if self[:ensure] == :present and ! self[:db_name]
      raise ArgumentError, 'must set db_name when creating database' unless self[:db_name]
    end
    if self[:ensure] == :present and ! self[:db_password]
      raise ArgumentError, 'must set db_password when creating database' unless self[:db_password]
    end
    if self[:ensure] == :present and ! self[:db_user]
      raise ArgumentError, 'must set db_user when creating database' unless self[:db_user]
    end
  end

end
