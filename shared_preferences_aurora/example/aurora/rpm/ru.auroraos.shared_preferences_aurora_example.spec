%global __provides_exclude_from ^%{_datadir}/%{name}/lib/.*$
%global __requires_exclude ^lib(dconf|flutter-embedder|maliit-glib|.+_platform_plugin)\\.so.*$

Name: ru.auroraos.shared_preferences_aurora_example
Summary: Demonstrates how to use the shared_preferences_aurora plugin.
Version: 0.1.0
Release: 1
License: BSD 3-Clause
Source0: %{name}-%{version}.tar.zst

BuildRequires: cmake
BuildRequires: ninja

%description
%{summary}.

%prep
%autosetup

%build
%cmake -GNinja -DCMAKE_BUILD_TYPE=%{_flutter_build_type} -DPSDK_VERSION=%{_flutter_psdk_version} -DPSDK_MAJOR=%{_flutter_psdk_major}
%ninja_build

%install
%ninja_install

%files
%{_bindir}/%{name}
%{_datadir}/%{name}/*
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
