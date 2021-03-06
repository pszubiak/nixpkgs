{ stdenv, fetchFromGitHub, autoconf, automake, pkgconfig, gtk2
, libjack2, libsndfile
}:

stdenv.mkDerivation rec {
  pname = "timemachine";
  version = "0.3.3";
  src = fetchFromGitHub {
    owner = "swh";
    repo = "timemachine";
    rev = "v${version}";
    sha256 = "1jsvd29wiqigxyqxl2xjklla11fwyjy68vqivcnlr9f2af4ylym8";
  };

  nativeBuildInputs = [ pkgconfig ];
    buildInputs = [ autoconf automake gtk2 libjack2
      libsndfile
    ];

  preConfigure = "./autogen.sh";

  NIX_LDFLAGS =  [
    "-lm"
  ];

  meta = {
    description = "JACK audio recorder";
    homepage = http://plugin.org.uk/timemachine/;
    license = stdenv.lib.licenses.lgpl2;
    platforms = stdenv.lib.platforms.linux;
    maintainers = [ stdenv.lib.maintainers.nico202 ];
  };
}

