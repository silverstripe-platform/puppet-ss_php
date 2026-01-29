module Puppet::Parser::Functions
  newfunction(:ensure_php_packages, :type => :statement, :doc => <<-EOS
    Takes an array of php extension names, and another array of php versions and installs all
    extension packages for the versions specified. Example:

    ensure_php_packages(["mcrypt", "gd"], ["5.6", "7.1"])

    This will install php5.6-mcrypt, php7.1-mcrypt, php5.6-gd, and php7.1-gd
EOS
  ) do |arguments|
    if arguments.size > 3 || arguments.size == 0
      raise(Puppet::ParseError, "ensure_php_packages(): Wrong number of arguments given (#{arguments.size} for 2 or 3)")
    elsif arguments.size == 3 && !arguments[2].is_a?(Hash)
      raise(Puppet::ParseError, 'ensure_php_packages(): Requires third argument to be a Hash')
    end

    packages = arguments[0]
    versions = arguments[1]

    unless packages.is_a?(Array) && versions.is_a?(Array)
      raise(Puppet::ParseError, "ensure_php_packages(): Requires 2 arrays")
    end

    if arguments[2]
      defaults = { "ensure" => "present" }.merge(arguments[2])
    else
      defaults = { "ensure" => "present" }
    end

    versions.each do |version|
      packages.each do |package|
        if version.to_s >= "7.2" && package === "mcrypt"
          next
        end
        if version.to_s >= "8.0" && (package === "xmlrpc" || package === "json" || package === 'apcu-bc')
          next
        end
        if version.to_s <= "5.6" && package === "apcu-bc"
          next
        end
        if version.to_s >= "8.5" && package === "opcache"
          next
        end
        function_ensure_resource(["package", "php#{version.to_s}-#{package}", defaults])
      end
    end
  end
end
