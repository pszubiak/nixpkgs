{ stdenv, callPackage, fetchurl, makeWrapper, jre }:

let
# The version number here is whatever is reported by the RUBY_VERSION string
rubyVersion = callPackage ../ruby/ruby-version.nix {} "2" "3" "3" "";
jruby = stdenv.mkDerivation rec {
  name = "jruby-${version}";

  version = "9.2.8.0";

  src = fetchurl {
    url = "https://s3.amazonaws.com/jruby.org/downloads/${version}/jruby-bin-${version}.tar.gz";
    sha256 = "1fy717xy8csc89dnz3a8j96arq1s1vs8nakkkpcaqm1z1648didp";
  };

  buildInputs = [ makeWrapper ];

  installPhase = ''
     mkdir -pv $out/docs
     mv * $out
     rm $out/bin/*.{bat,dll,exe,sh}
     mv $out/COPYING $out/LICENSE* $out/docs

     for i in $out/bin/jruby{,.bash}; do
       wrapProgram $i \
         --set JAVA_HOME ${jre}
     done

     ln -s $out/bin/jruby $out/bin/ruby

     # Bundler tries to create this directory
     mkdir -pv $out/${passthru.gemPath}
     mkdir -p $out/nix-support
     cat > $out/nix-support/setup-hook <<EOF
       addGemPath() {
         addToSearchPath GEM_PATH \$1/${passthru.gemPath}
       }

       addEnvHooks "$hostOffset" addGemPath
     EOF
  '';

  passthru = rec {
    rubyEngine = "jruby";
    gemPath = "lib/${rubyEngine}/gems/${rubyVersion.libDir}";
    libPath = "lib/${rubyEngine}/${rubyVersion.libDir}";
  };

  meta = {
    description = "Ruby interpreter written in Java";
    homepage = http://jruby.org/;
    license = with stdenv.lib.licenses; [ cpl10 gpl2 lgpl21 ];
    platforms = stdenv.lib.platforms.unix;
  };
};
in jruby.overrideAttrs (oldAttrs: {
  passthru = oldAttrs.passthru // {
    devEnv = callPackage ../ruby/dev.nix {
      ruby = jruby;
    };
  };
})
