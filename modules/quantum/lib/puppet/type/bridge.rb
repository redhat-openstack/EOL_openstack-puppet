require "puppet"

module Puppet
  Puppet::Type.newtype(:bridge) do
    @doc = "Add a linux bridge via brctl"

    ensurable

    newparam(:name) do
      isnamevar
      desc "Name of bridge."
    end

  end
end
