class Avrdude < Formula
  desc "Atmel AVR MCU programmer - Custom PrincePatel1025 version"
  homepage "https://github.com/PrincePatel1025/avrdude"
  url "https://github.com/PrincePatel1025/avrdude/archive/refs/heads/main.zip"
  sha256 "00aac68adc4496a7219ca4bbefc16c02748f507f0f760259d663e0a08f514a8f"

  license "GPL-2.0-or-later"

  depends_on "cmake" => :build
  depends_on "hidapi"
  depends_on "libftdi"
  depends_on "libusb"
  depends_on "libusb-compat"

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build

  on_macos do
    depends_on "libelf" => :build
  end

  on_linux do
    depends_on "elfutils"
    depends_on "readline"
  end

  def install
    args = std_cmake_args + ["-DCMAKE_INSTALL_SYSCONFDIR=#{etc}"]
    shared_args = ["-DBUILD_SHARED_LIBS=ON", "-DCMAKE_INSTALL_RPATH=#{rpath}"]
    shared_args << "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-undefined,dynamic_lookup" if OS.mac?

    system "cmake", "-S", ".", "-B", "build/shared", *args, *shared_args
    system "cmake", "--build", "build/shared"
    system "cmake", "--install", "build/shared"

    system "cmake", "-S", ".", "-B", "build/static", *args
    system "cmake", "--build", "build/static"
    lib.install "build/static/src/libavrdude.a"
  end

  test do
    output = shell_output("#{bin}/avrdude -c jtag2 -p x16a4 2>&1", 1).strip
    refute_match "avrdude was compiled without usb support", output
    assert_match "Avrdude done.  Thank you.", output
  end
end

