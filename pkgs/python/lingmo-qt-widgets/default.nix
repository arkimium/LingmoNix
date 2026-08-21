{ lib, buildPythonPackage, fetchFromGitHub, setuptools, pyqt5, pyqt5-frameless-window, darkdetect }:

buildPythonPackage {
  pname = "lingmo-qt-widgets";
  version = "1.5.5";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-qt-widgets";
    rev = "master";
    hash = "sha256-JSf0jBfKbnBx5rNifPIMZAsAwf+XYaE/aqor+aczVR0=";
  };

  pyproject = false;
  build-system = [ setuptools ];
  dependencies = [ pyqt5 pyqt5-frameless-window darkdetect ];

  meta = with lib; {
    description = "Fluent design widgets library for LingmoOS (PyQt5)";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
