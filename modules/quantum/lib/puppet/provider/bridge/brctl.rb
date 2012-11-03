require "puppet"

Puppet::Type.type(:bridge).provide(:brctl) do
  commands :brctl => "/sbin/brctl"

  def exists?
    results = brctl("show")
    count=0
    results.each_line do |line|
      count += 1
      next if count == 1
      brname = line.scan(/^\w*/)[0]
      return true if brname == @resource[:name]
    end
    return false
  end

  def create
    brctl("addbr", @resource[:name])
  end

  def destroy
    brctl("delbr", @resource[:name])
  end

end
