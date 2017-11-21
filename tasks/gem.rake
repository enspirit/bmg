require 'rubygems/package_task'

# Dynamically load the gem spec
gemspec_file = File.expand_path('../../bmg.gemspec', __FILE__)
gemspec      = Kernel.eval(File.read(gemspec_file))

Gem::PackageTask.new(gemspec) do |t|

  # Name of the package
  t.name = gemspec.name

  # Version of the package
  t.version = gemspec.version

  # Directory used to store the package files
  t.package_dir = "pkg"

  # True if a gzipped tar file (tgz) should be produced
  t.need_tar = false

  # True if a gzipped tar file (tar.gz) should be produced
  t.need_tar_gz = false

  # True if a bzip2'd tar file (tar.bz2) should be produced
  t.need_tar_bz2 = false

  # True if a zip file should be produced (default is false)
  t.need_zip = false

  # List of files to be included in the package.
  t.package_files = gemspec.files

  # Tar command for gzipped or bzip2ed archives.
  t.tar_command = "tar"

  # Zip command for zipped archives.
  t.zip_command = "zip"

end
