{ lib, buildPythonPackage, fetchFromGitHub, setuptools, pyqt5 }:

buildPythonPackage {
  pname = "pyqt5-frameless-window";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "zhiyiYo";
    repo = "PyQt-Frameless-Window";
    rev = "v0.4.0";
    hash = "sha256-nX01Kh3po7Qyc0Kqo/SN2XJAmPyL0Ld45hGOsQeXhPY=";
  };

  pyproject = false;
  build-system = [ setuptools ];
  dependencies = [ pyqt5 ];

  meta = with lib; {
    description = "A cross-platform frameless window based on pyqt5";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
