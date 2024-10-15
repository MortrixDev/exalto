{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
	buildInputs = with pkgs; [
		glfw
		xorg.libX11
		xorg.libX11.dev
		xorg.libXcursor
		xorg.libXrandr
		xorg.libXi
		xorg.libXinerama
		emscripten
	];
}
