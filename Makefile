#
# Copyright (c) Members of the EGEE Collaboration. 2004-2010.
# See http://www.eu-egee.org/partners/ for details on the copyright holders. 
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
# RPM/ETICS
#
name = argus-pep-api-c
version = 2.2.0
release = 1

dist_url = https://github.com/downloads/argus-authz/argus-pep-api-c/$(name)-$(version).tar.gz
spec_file = fedora/$(name).spec
rpmbuild_dir = $(CURDIR)/rpmbuild
tmp_dir=$(CURDIR)/tmp
tgz_dir=$(CURDIR)/tgz
rpm_dir=$(CURDIR)/RPMS
deb_dir=$(CURDIR)/debs

all: srpm

clean:
	@echo "Cleaning..."
	rm -rf $(rpmbuild_dir) $(tmp_dir) *.tar.gz $(tgz_dir) $(rpm_dir) $(deb_dir) $(spec_file)


spec:
	@echo "Setting version and release in spec file: $(version)-$(release)"
	sed -e 's#@@SPEC_VERSION@@#$(version)#g' -e 's#@@SPEC_RELEASE@@#$(release)#g' $(spec_file).in > $(spec_file)


pre_rpmbuild: spec
	@echo "Preparing for rpmbuild in $(rpmbuild_dir)"
	mkdir -p $(rpmbuild_dir)/BUILD $(rpmbuild_dir)/RPMS $(rpmbuild_dir)/SOURCES $(rpmbuild_dir)/SPECS $(rpmbuild_dir)/SRPMS
	test -f $(rpmbuild_dir)/SOURCES/$(name)-$(version).tar.gz || wget -P $(rpmbuild_dir)/SOURCES $(dist_url)
	#mv $(name)-$(version).tar.gz $(name)-$(version).src.tar.gz
	#cp $(name)-$(version).tar.gz $(rpmbuild_dir)/SOURCES


srpm: pre_rpmbuild
	@echo "Building SRPM in $(rpmbuild_dir)"
	rpmbuild --nodeps -v -bs $(spec_file) --define "_topdir $(rpmbuild_dir)"


rpm: pre_rpmbuild
	@echo "Building RPM/SRPM in $(rpmbuild_dir)"
	rpmbuild --nodeps -v -ba $(spec_file) --define "_topdir $(rpmbuild_dir)"


etics:
	@echo "Publish SRPM/RPM/Debian/tarball"
	mkdir -p $(rpm_dir) $(tgz_dir) $(deb_dir)
	test ! -f $(name)-$(version).src.tar.gz || cp -v $(name)-$(version).src.tar.gz $(tgz_dir)
	test ! -f $(rpmbuild_dir)/SRPMS/$(name)-$(version)-*.src.rpm || cp -v $(rpmbuild_dir)/SRPMS/$(name)-$(version)-*.src.rpm $(rpm_dir)
	if [ -f $(rpmbuild_dir)/RPMS/*/$(name)-$(version)-*.rpm ] ; then \
		cp -v $(rpmbuild_dir)/RPMS/*/$(name)-$(version)-*.rpm $(rpm_dir) ; \
		test ! -d $(tmp_dir) || rm -fr $(tmp_dir) ; \
		mkdir -p $(tmp_dir) ; \
		cd $(tmp_dir) ; \
		rpm2cpio $(rpmbuild_dir)/RPMS/*/$(name)-$(version)-*.rpm | cpio -idm ; \
		tar -C $(tmp_dir) -czf $(name)-$(version).tar.gz * ; \
		mv -v $(name)-$(version).tar.gz $(tgz_dir) ; \
		rm -fr $(tmp_dir) ; \
	fi
	test ! -f $(debbuild_dir)/$(name)_$(version)-*.dsc || cp -v $(debbuild_dir)/$(name)_$(version)-*.dsc $(deb_dir)
	test ! -f $(debbuild_dir)/$(name)_$(version)-*.debian.tar.gz || cp -v $(debbuild_dir)/$(name)_$(version)-*.debian.tar.gz $(deb_dir)
	test ! -f $(debbuild_dir)/$(name)_$(version).orig.tar.gz || cp -v $(debbuild_dir)/$(name)_$(version).orig.tar.gz $(deb_dir)
	if [ -f $(debbuild_dir)/$(deb_name)_$(version)-*.deb ] ; then \
		cp -v $(debbuild_dir)/$(deb_name)_$(version)-*.deb $(deb_dir) ; \
		test ! -d $(tmp_dir) || rm -fr $(tmp_dir) ; \
		mkdir -p $(tmp_dir) ; \
		dpkg -x $(debbuild_dir)/$(deb_name)_$(version)-*.deb $(tmp_dir) ; \
		cd $(tmp_dir) ; \
		tar -C $(tmp_dir) -czf $(name)-$(version).tar.gz * ; \
		mv -v $(name)-$(version).tar.gz $(tgz_dir) ; \
		rm -fr $(tmp_dir) ; \
	fi

