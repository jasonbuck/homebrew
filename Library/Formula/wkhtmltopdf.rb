require 'formula'

class Wkhtmltopdf < Formula
  homepage 'http://wkhtmltopdf.org/'
  url 'https://github.com/npinchot/wkhtmltopdf/archive/0.12.1.tar.gz'
  sha1 '0cadbeb348cca62680ca42d5249d5ffe38bea994'
  version '0.12.1'

  depends_on 'qt'

  def install
    # fix that missing TEMP= include.
    inreplace 'common.pri' do |s|
      s.gsub! 'TEMP = $$[QT_INSTALL_LIBS] libQtGui.prl', ''
      s.gsub! 'include($$join(TEMP, "/"))', ''
    end

    # It tries to build universally, but Qt is bottled as 64bit => build error.
    # If we are 64bit, do not compile with -arch i386.  This is a Homebrew
    # issue with our Qt4, not upstream, because wkhtmltopdf bundles a patched
    # Qt4 that Homebrew doesn't use.
    if MacOS.prefer_64_bit?
      inreplace 'src/pdf/pdf.pro', 'x86', Hardware::CPU.arch_64_bit
      inreplace 'src/image/image.pro', 'x86', Hardware::CPU.arch_64_bit
    end

    if MacOS.version >= :mavericks && ENV.compiler == :clang
      spec = 'unsupported/macx-clang-libc++'
    else
      spec = 'macx-g++'
    end

    system 'qmake', '-spec', spec
    system 'make'
    ENV['DYLD_LIBRARY_PATH'] = './bin'
    `bin/wkhtmltopdf --manpage > wkhtmltopdf.1`
    `bin/wkhtmltoimage --manpage > wkhtmltoimage.1`

    # install binaries, libs, and man pages
    bin.install Dir[ "bin/wkh*" ]
    lib.install Dir[ "bin/lib*" ]
    man1.install Dir[ "wkht*.1" ]
  end
end
