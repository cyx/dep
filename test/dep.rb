require "cutest"

load File.expand_path("../../bin/dep", __FILE__)

# Dep::Lib
scope do
  test "parsing" do
    lib = Dep::Lib["ohm-contrib -v 1.0.rc1"]

    assert_equal "ohm-contrib", lib.name
    assert_equal "1.0.rc1", lib.version

    lib = Dep::Lib["dep --git git://github.com/cyx/dep.git"]

    assert_equal "dep", lib.name
    assert_equal "git://github.com/cyx/dep.git", lib.uri
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

# Dep::GitLib
scope do
  test "parsing" do
    lib = Dep::Lib["dep --git git://github.com/cyx/dep.git"]

    assert_equal "dep", lib.name
    assert_equal "git://github.com/cyx/dep.git", lib.uri
    assert_equal nil, lib.gemspec_path

    lib = Dep::Lib["dep --git 'git://github.com/cyx/dep.git path/to/gemspec'"]

    assert_equal "dep", lib.name
    assert_equal "git://github.com/cyx/dep.git", lib.uri
    assert_equal "path/to/gemspec", lib.gemspec_path
  end

  test "to_s" do
    lib = Dep::GitLib.new("dep", "git://github.com/cyx/dep.git")
    assert_equal "dep --git git://github.com/cyx/dep.git", lib.to_s

    lib = Dep::GitLib.new("dep", "git://github.com/cyx/dep.git path/to/gemspec")
    assert_equal "dep --git 'git://github.com/cyx/dep.git path/to/gemspec'", lib.to_s
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
    lib3 = Dep::GitLib.new("padrino-performance", "git://github.com/padrino/padrino-framework.git padrino-performance")

    assert list.libraries.include?(lib1)
    assert list.libraries.include?(lib2)
    assert list.libraries.include?(lib3)

    assert_equal 2, list.missing_libraries.size
    assert list.missing_libraries.include?(lib1)
    assert list.missing_libraries.include?(lib3)
  end

  test do |list|
    list.add(Dep::Lib.new("cutest", "2.0"))

    assert ! list.libraries.include?(Dep::Lib.new("cutest", "1.1.3"))
    assert list.libraries.include?(Dep::Lib.new("cutest", "2.0"))
  end
end
