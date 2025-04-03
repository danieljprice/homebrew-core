class Libadwaita < Formula
  desc "Building blocks for modern adaptive GNOME applications"
  homepage "https://gnome.pages.gitlab.gnome.org/libadwaita/"
  url "https://download.gnome.org/sources/libadwaita/1.7/libadwaita-1.7.0.tar.xz"
  sha256 "58bf99b8a9f8b0171964de0ae741d01d5a09db3662134fa67541c99a8ed7dec0"
  license "LGPL-2.1-or-later"

  # libadwaita doesn't use GNOME's "even-numbered minor is stable" version
  # scheme. This regex is the same as the one generated by the `Gnome` strategy
  # but it's necessary to avoid the related version scheme logic.
  livecheck do
    url :stable
    regex(/libadwaita-(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 arm64_sequoia: "d683e698701527e6447b0be7cb6cd4fd367fad68219163ac782a6a1a119ce657"
    sha256 arm64_sonoma:  "20d880f75a9c9d4019cf12790aba9515f00b7eb6c28d09878f6e26349208b6e2"
    sha256 arm64_ventura: "a4bfddb77bfea3f8df44c79357bda5e07ed7e6739ca1a77f2eddb24807bb674a"
    sha256 sonoma:        "9af7bfc351744084149321ce2f0a7a570bed4ed3f19b75a643e988ed9b349207"
    sha256 ventura:       "bff7ec010d04ada9aeaac78e8464507176c922078dbe51efdfe486da4bd0ff4c"
    sha256 arm64_linux:   "942f7efab94cc28955491e797246adba00e241c4a8b16d1ff624bd8e734c66d9"
    sha256 x86_64_linux:  "965753c9de047a186668cd1fabeb18bb95a97497b04c5fb14ae0b42a9024e8ea"
  end

  depends_on "gettext" => :build
  depends_on "gobject-introspection" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => [:build, :test]
  depends_on "sassc" => :build
  depends_on "vala" => :build

  depends_on "appstream"
  depends_on "fribidi"
  depends_on "glib"
  depends_on "graphene"
  depends_on "gtk4"
  depends_on "libsass"
  depends_on "pango"

  uses_from_macos "python" => :build

  on_macos do
    depends_on "gettext"
  end

  def install
    system "meson", "setup", "build", "-Dtests=false", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <adwaita.h>

      int main(int argc, char *argv[]) {
        g_autoptr (AdwApplication) app = NULL;
        app = adw_application_new ("org.example.Hello", G_APPLICATION_DEFAULT_FLAGS);
        return g_application_run (G_APPLICATION (app), argc, argv);
      }
    C
    flags = shell_output("#{Formula["pkgconf"].opt_bin}/pkgconf --cflags --libs libadwaita-1").strip.split
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test", "--help"

    # include a version check for the pkg-config files
    assert_match version.to_s, (lib/"pkgconfig/libadwaita-1.pc").read
  end
end
