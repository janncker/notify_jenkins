Name:           notify-jenkins
Version:        0.0.1
Release:        1
License:        GPLv2
Summary:        Plugin for OBS to trigger jenkins build
Url:            http://www.tizen.org
Group:          Development/Tools/Building
Source:         %{name}-%{version}.tar.gz
Requires:       obs-server
Requires:       perl-JSON-XS
Requires:       perl-common-sense
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

%description
Plugin for OBS, to trigger Jenkins job from URL. Depends on the plugin
Parameterized Trigger.

%prep
%setup -q -c

%build
true

%install
install -d %{buildroot}/usr/lib/obs/server/plugins/
install notify_jenkins.pm %{buildroot}/usr/lib/obs/server/plugins/

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%{_prefix}/lib/obs/server/plugins/notify_jenkins.pm

%changelog