class Libbpf < Formula
  desc "Berkeley Packet Filter library"
  homepage "https://github.com/libbpf/libbpf"
  url "https://github.com/libbpf/libbpf/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "3d6afde67682c909e341bf194678a8969f17628705af25f900d5f68bd299cb03"
  license "BSD-2-Clause"

  bottle do
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c746fb954a10b136e5bb2f88fd5d58cb9c60cd3948539381f12d4bc0c1c06ecb"
  end

  depends_on "pkg-config" => :build
  depends_on "linux-headers@5.16" => :test
  depends_on "elfutils"
  depends_on :linux

  uses_from_macos "zlib"

  def install
    chdir "src" do
      system "make"
      system "make", "install", "PREFIX=#{prefix}", "LIBDIR=#{lib}"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include "bpf/libbpf.h"
      #include <stdio.h>

      int main() {
        printf("%s", libbpf_version_string());
        return(0);
      }
    EOS
    system ENV.cc, "test.c", "-I#{Formula["linux-headers@5.16"].opt_include}", "-I#{include}", "-L#{lib}",
                   "-lbpf", "-o", "test"
    system "./test"
  end
end
