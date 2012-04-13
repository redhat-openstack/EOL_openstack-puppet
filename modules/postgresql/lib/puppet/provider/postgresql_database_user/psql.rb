Puppet::Type.type(:postgresql_database_user).provide(:psql) do

  commands :psql => 'psql'
  defaultfor :feature => :posix

  def self.instances
out=%x{
echo "SELECT datname FROM pg_database;" | su - postgres -c psql
}
    header_found=false
    for line in out.lines
      break if line =~ /\(\d+ rows\)/
      if header_found then
        new(:db_name => line.chomp)
      end
      if line =~ /-----------/ then
        header_found = true
      end
    end
  end

  def create
    out=%x{
echo "CREATE DATABASE #{resource[:db_name]};" | su - postgres -c psql
echo "CREATE USER #{resource[:db_user]} WITH PASSWORD '#{resource[:db_password]}';" | su - postgres -c psql
echo "GRANT ALL ON DATABASE #{resource[:db_name]} TO #{resource[:db_user]};" | su - postgres -c psql
    }
    retval=$?
    if not retval.success?
      raise Puppet::Error, "Failed to create postgres DB and user: #{out}."
    end
  end

  def destroy
    #Not implemented for safety.
    return
  end

  def exists?
out=%x{
echo "SELECT datname FROM pg_database;" | su - postgres -c psql
}
    for line in out.lines
      break if line =~ /\(\d+ rows\)/
      return true if line =~ /#{resource[:db_name].downcase}/
    end
    return false
  end

end
