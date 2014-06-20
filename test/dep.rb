require "cutest"
require "override"

load File.expand_path("../../bin/dep", __FILE__)

class Cutest::Scope
  include Override
end

# Dep::Lib
scope do
  test "parsing" do
    lib = Dep::Lib["ohm-contrib -v 1.0.rc1"]

    assert_equal "ohm-contrib", lib.name
    assert_equal "1.0.rc1", lib.version
  end

  test "availability of existing gem" do
    lib = Dep::Lib.new("cutest", "1.2.0")
    assert lib.available?
  end

  test "non-availability of missing gem" do
    lib = Dep::Lib.new("rails", "3.0")
    assert ! lib.available?
  end

  test "to_s" do
    lib = Dep::Lib.new("cutest", "1.1.3")
    assert_equal "cutest -v 1.1.3", lib.to_s
  end
end

# Dep::List
scope do
  setup do
    Dep::List.new(File.expand_path(".gems", File.dirname(__FILE__)))
  end

  test do |list|
    lib1 = Dep::Lib.new("ohm-contrib", "1.0.rc1")
    lib2 = Dep::Lib.new("cutest", "1.2.0")

    assert list.libraries.include?(lib1)
    assert list.libraries.include?(lib2)

    assert_equal 1, list.missing_libraries.size
    assert list.missing_libraries.include?(lib1)
  end

  test do |list|
    list.add(Dep::Lib.new("cutest", "2.0"))

    assert ! list.libraries.include?(Dep::Lib.new("cutest", "1.1.3"))
    assert list.libraries.include?(Dep::Lib.new("cutest", "2.0"))
  end
end

# Dep::CLI
scope do
  setup do
    list = Dep::List.new("/dev/null")

    list.add(Dep::Lib.new("foo", "2.0"))
    list.add(Dep::Lib.new("bar", "1.1"))

    commands = []

    cli = Dep::CLI.new
    cli.list = list

    override(cli, run: -> args { commands << args })

    [cli, commands]
  end

  test "install" do |cli, commands|
    cli.install

    assert_equal ["gem install foo:2.0 bar:1.1"], commands
  end
end
