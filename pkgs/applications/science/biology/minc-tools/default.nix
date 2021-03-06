{ stdenv, fetchFromGitHub, cmake, makeWrapper, flex, bison, perl, TextFormat,
  libminc, libjpeg, nifticlib, zlib }:

stdenv.mkDerivation rec {
  pname   = "minc-tools";
  version = "unstable-2019-12-04";

  src = fetchFromGitHub {
    owner  = "BIC-MNI";
    repo   = pname;
    rev    = "d4dddfdb4e4fa0cea389b8fdce51cfc076565d94";
    sha256 = "1wwdss59qq4hz1jp35qylfswzzv0d37if23al0srnxkkgc5f8zng";
  };

  patches = [ ./fix-netcdf-header.patch ];

  # add missing CMake module to build NIFTI support
  # (the maintainers normally build libminc and minc-tools in a meta-project)
  postPatch = ''
    cp ${libminc.src}/cmake-modules/FindNIFTI.cmake cmake-modules
  '';

  nativeBuildInputs = [ cmake flex bison makeWrapper ];
  buildInputs = [ libminc libjpeg nifticlib zlib ];
  propagatedBuildInputs = [ perl TextFormat ];

  cmakeFlags = [ "-DLIBMINC_DIR=${libminc}/lib/"
                 "-DZNZ_INCLUDE_DIR=${nifticlib}/include/nifti"
                 "-DNIFTI_INCLUDE_DIR=${nifticlib}/include/nifti" ];

  postFixup = ''
    for prog in minccomplete minchistory mincpik; do
      wrapProgram $out/bin/$prog --prefix PERL5LIB : $PERL5LIB
    done
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = "https://github.com/BIC-MNI/minc-tools";
    description = "Command-line utilities for working with MINC files";
    maintainers = with maintainers; [ bcdarwin ];
    platforms = platforms.unix;
    license   = licenses.free;
  };
}
