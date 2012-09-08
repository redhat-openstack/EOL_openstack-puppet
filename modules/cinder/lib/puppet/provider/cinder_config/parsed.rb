require 'puppet/provider/parsedfile'

cinderconf = "/etc/cinder/cinder.conf"

Puppet::Type.type(:cinder_config).provide(
  :parsed,
  :parent => Puppet::Provider::ParsedFile,
  :default_target => cinderconf,
  :filetype => :flat
) do

  #confine :exists => cinderconf
  text_line :comment, :match => /#|\[.*/;
  text_line :blank, :match => /^\s*$/;

  record_line :parsed,
    :fields => %w{line},
    :match => /([^\[]*)/ ,
    :post_parse => proc { |hash|
      Puppet.debug("cinder config line:#{hash[:line]} has been parsed")
      if hash[:line] =~ /^\s*(\S+)\s*=\s*([\S ]+)\s*$/
        hash[:name]=$1
        hash[:value]=$2
      elsif hash[:line] =~ /^\s*(\S+)\s*$/
        hash[:name]=$1
        hash[:value]=false
      else
        raise Puppet::Error, "Invalid line: #{hash[:line]}"
      end
    }

  def self.to_line(hash)
    if hash[:name] and hash[:value]
      "#{hash[:name]}=#{hash[:value]}"
    end
  end

  def self.header
    "# Auto Genarated Cinder Config File\n[DEFAULT]\n"
  end

end
