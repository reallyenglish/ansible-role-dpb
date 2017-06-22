require "spec_helper"
require "serverspec"

config_dir = "/etc/dpb"
config = "#{config_dir}/packages"
proot_config = "#{config_dir}/proot.conf"
build_user = "_pbuild"
fetch_user = "_pfetch"
fetch_group = fetch_user
packages_to_build = [
  "net/rsync",
  "sysutils/ansible",
  "net/curl"
]
chroot_dir = "/usr/local/build"
chroot_mount_point = "/usr/local"

describe file(config_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by "root" }
  it { should be_grouped_into "wheel" }
end

describe file(config) do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by "root" }
  it { should be_grouped_into "wheel" }
  packages_to_build.each do |p|
    its(:content) { should match(/^#{Regexp.escape(p)}$/) }
  end
end

describe file(proot_config) do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by "root" }
  it { should be_grouped_into "wheel" }
  its(:content) { should match(/^chroot=#{Regexp.escape(chroot_dir)}$/) }
  its(:content) { should match(/^BUILD_USER=#{build_user}$/) }
  its(:content) { should match(/^FETCH_USER=#{fetch_user}$/) }
  its(:content) { should match(/^chown_all=1$/) }
  its(:content) { should match(/^actions=\s*\n\s+unpopulate_light\n\s+resolve\n\s+copy_ports\n/) }
end

describe file("/usr/local/bin/dpb") do
  it { should exist }
  it { should be_symlink }
  it { should be_linked_to "/usr/ports/infrastructure/bin/dpb" }
end

describe file("/usr/local/bin/proot") do
  it { should exist }
  it { should be_symlink }
  it { should be_linked_to "/usr/ports/infrastructure/bin/proot" }
end

["", chroot_dir].each do |root|
  describe file("#{root}/usr/ports") do
    it { should exist }
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by "root" }
    it { should be_grouped_into "wheel" }
  end

  describe file("#{root}/usr/ports/Makefile") do
    it { should exist }
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by "root" }
    it { should be_grouped_into "wheel" }
  end
end

describe file("#{chroot_dir}/dev/zero") do
  it { should exist }
  it { should be_character_device }
end

describe file("/etc/ssh/ssh_known_hosts") do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by "root" }
  it { should be_grouped_into "wheel" }
  its(:content) { should match(/#{Regexp.escape("anoncvs.ca.openbsd.org")}\s+ssh-rsa\s+#{Regexp.escape("AAAAB3NzaC1yc2EAAAADAQABAAABAQCz6RLtgGksBp/0dH7M5vGCUxgD31+wX28tnLlij90+cYhjELDV3HX95DypEA7xfIN6W8Vg/GOJkX4Oot+zpQXNQx3VeOyMgcn4KXO83XYGsPVfJQijjzyI0r0/ztEsxYAE6JHEiEvY9floDnNRyoFLVETNE5oB9yBcDIt6W6BYjlpXqJNsEPy7ij+kBbEk7QT0FcyFidp7FmExsOQy23nhQ55A/6fB7ATsDQtz+snniF9ZJg5+b71SYzxfhUPkxJhmhBkx7NmPnRjy7eE0I7qrHODrHONIi1LWCo0joTIAfVgxhEn5SDbviTAINAecGgis5LQqXp0xSupfWuozZeXV")}/) }
end

[
  "/usr/X11R6/bin/xdm",
  "/usr/X11R6/lib/X11/fonts/TTF/DejaVuSansMono.ttf",
  "/usr/X11R6/bin/startx"
].each do |f|
  describe file(f) do
    # these are enough to test the chroot has been created
    it { should exist }
    it { should be_file }
    it { should be_owned_by "root" }
    it { should be_grouped_into "wheel" }
  end
end

describe file("#{chroot_dir}/usr/ports/distfiles") do
  it { should exist }
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by fetch_user }
  it { should be_grouped_into fetch_group }
end

describe command("mount") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/#{Regexp.escape("/dev/")}[ws]d0h\s+on\s+#{Regexp.escape(chroot_mount_point)}\s+type\s+ffs\s+\(local,\s+wxallowed\)$/) }
end

# build rsync only as the target of the test is dpb. any package should work
# but it should be a small one to save time and avoid troubles.
describe command("dpb -c -B '#{chroot_dir}' net/rsync") do
  # we do not care of stdout
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
end
