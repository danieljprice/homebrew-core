class Cython < Formula
  desc "Compiler for writing C extensions for the Python language"
  homepage "https://cython.org/"
  url "https://files.pythonhosted.org/packages/d3/38/adc49a5aca4f644e6322237089fdcf194084f5fe41445e6e632f28b32bf7/Cython-0.29.22.tar.gz"
  sha256 "df6b83c7a6d1d967ea89a2903e4a931377634a297459652e4551734c48195406"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "edd6535f8154608f559fc0898eec1babf966e768aa9be80e1ac05b103450356f"
    sha256 cellar: :any_skip_relocation, big_sur:       "fd74db80cbd06970855b2bd78d71593c919fad34d165c351663503f2429193c4"
    sha256 cellar: :any_skip_relocation, catalina:      "8642f6bff6de2c04fc5eea73b63af6a7029665a3fc053d5fa94043af0e9842ce"
    sha256 cellar: :any_skip_relocation, mojave:        "1b53458978d40017cb1b3be75aadfa9e99ecaffd73f6c3d4885d6a5d5b0ddaca"
    sha256 cellar: :any_skip_relocation, high_sierra:   "f6474509ad079919250de3f536e2d57e4230e72b1614603b5797c24a08e67391"
  end

  keg_only <<~EOS
    this formula is mainly used internally by other formulae.
    Users are advised to use `pip` to install cython
  EOS

  depends_on "python@3.9"

  def install
    xy = Language::Python.major_minor_version Formula["python@3.9"].opt_bin/"python3"
    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python#{xy}/site-packages"
    system Formula["python@3.9"].opt_bin/"python3", *Language::Python.setup_install_args(libexec)

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", PYTHONPATH: ENV["PYTHONPATH"])
  end

  test do
    xy = Language::Python.major_minor_version Formula["python@3.9"].opt_bin/"python3"
    ENV.prepend_path "PYTHONPATH", libexec/"lib/python#{xy}/site-packages"

    phrase = "You are using Homebrew"
    (testpath/"package_manager.pyx").write "print '#{phrase}'"
    (testpath/"setup.py").write <<~EOS
      from distutils.core import setup
      from Cython.Build import cythonize

      setup(
        ext_modules = cythonize("package_manager.pyx")
      )
    EOS
    system Formula["python@3.9"].opt_bin/"python3", "setup.py", "build_ext", "--inplace"
    assert_match phrase, shell_output("#{Formula["python@3.9"].opt_bin}/python3 -c 'import package_manager'")
  end
end
