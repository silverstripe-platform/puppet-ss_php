require "spec_helper"

describe "ensure_php_packages" do
    it "creates a resource in the catalogue" do
      is_expected.to run.with_params(["mbstring", "gd"], ["5.6", "7.1"])
      expect(catalogue).to contain_package("php5.6-mbstring").with_ensure("present")
      expect(catalogue).to contain_package("php7.1-mbstring").with_ensure("present")
      expect(catalogue).to contain_package("php5.6-gd").with_ensure("present")
      expect(catalogue).to contain_package("php7.1-gd").with_ensure("present")
    end
    it "can ensure absent resource in the catalog" do
      is_expected.to run.with_params(["mbstring", "gd"], ["5.6", "7.1"], { "ensure" => "absent" })
      expect(catalogue).to contain_package("php5.6-mbstring").with_ensure("absent")
      expect(catalogue).to contain_package("php7.1-mbstring").with_ensure("absent")
      expect(catalogue).to contain_package("php5.6-gd").with_ensure("absent")
      expect(catalogue).to contain_package("php7.1-gd").with_ensure("absent")
    end
    it "skips dependencies that should not be installed" do
      is_expected.to run.with_params(["mcrypt", "json", "xmlrpc", "opcache"], ["7.1", "7.4", "8.0", "8.5"])
      # Mcrypt not provided in PHP 7.2+
      expect(catalogue).to contain_package("php7.1-mcrypt").with_ensure("present")
      expect(catalogue).to_not contain_package("php7.4-mcrypt")
      expect(catalogue).to_not contain_package("php8.0-mcrypt")

      # JSON not provided as a package in PHP 8+
      expect(catalogue).to contain_package("php7.1-json").with_ensure("present")
      expect(catalogue).to contain_package("php7.4-json").with_ensure("present")
      expect(catalogue).to_not contain_package("php8.0-json")

      # PECL extension not provided as a package in PHP 8+
      expect(catalogue).to contain_package("php7.1-xmlrpc").with_ensure("present")
      expect(catalogue).to contain_package("php7.4-xmlrpc").with_ensure("present")
      expect(catalogue).to_not contain_package("php8.0-xmlrpc")

      # Opcache not provided in PHP 8.5+
      expect(catalogue).to contain_package("php7.1-opcache").with_ensure("present")
      expect(catalogue).to contain_package("php8.0-opcache").with_ensure("present")
      expect(catalogue).to_not contain_package("php8.5-opcache")
    end
end
