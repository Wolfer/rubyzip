#!/usr/bin/env ruby

require 'zip'
require 'filearchive'

module Zip
  module ZipFileSystem
    
    
    def dir
      @zipFsDir ||= Dir.new(self)
    end
    
    def file
      @zipFsDir ||= ZipFsFile.new(self)
    end
    
    class ZipFsFile
      def initialize(zipFile)
	@zipFile = zipFile
      end
      
      def exists?(fileName)
	@zipFile.findEntry(fileName) != nil
      end
      alias :exist? :exists?
      
      # Permissions not implemented, so if the file exists it is accessible
      alias readable? exists?
      alias readable_real? exists?
      alias writable? exists?
      alias writable_real? exists?
      alias executable? exists?
      alias executable_real? exists?

      def directory?(fileName)
	entry = @zipFile.findEntry(fileName)
	entry != nil && entry.directory?
      end
      
      def open(fileName, openMode = "r", &block)
	raise StandardError, "openmode '#{openMode} not supported" unless openMode == "r"
	@zipFile.getInputStream(fileName, &block)
      end

      def new(fileName, openMode = "r")
	open(fileName, openMode)
      end
      
      def size(fileName)
	@zipFile.getEntry(fileName).size
      end
      
      # nil for not found and nil for directories
      def size?(fileName)
	entry = @zipFile.findEntry(fileName)
	return (entry == nil || entry.directory?) ? nil : entry.size
      end
      
      def zero?(fileName)
	sz = size(fileName)
	sz == nil || sz == 0
      rescue Errno::ENOENT
	false
      end
      
      def file?(fileName)
	entry = @zipFile.findEntry(fileName)
	entry != nil && entry.file?
      end      
      
      def dirname(fileName)
	::File.dirname(fileName)
      end
      
      def basename(fileName)
	::File.basename(fileName)
      end
      
      def split(fileName)
	::File.split(fileName)
      end
      
      def join(*fragments)
	::File.join(*fragments)
      end
      
      def mtime(fileName)
	@zipFile.getEntry(fileName).mtime
      end
      
      def pipe?(filename)
	false
      end
      
      def blockdev?(filename)
	false
      end
      
      def chardev?(filename)
	false
      end
      
      def symlink?(fileName)
	false
      end
      
      def socket?(fileName)
	false
      end
      
      def ftype(fileName)
	@zipFile.getEntry(fileName).directory? ? "directory" : "file"
      end
      
      def readlink(fileName)
	raise NotImplementedError, "The readlink() function is not implemented to ZipFileSystem"
      end
      
      def symlink(fileName, symlinkName)
	raise NotImplementedError, "The symlink() function is not implemented to ZipFileSystem"
      end

      def link(fileName, symlinkName)
	raise NotImplementedError, "The link() function is not implemented to ZipFileSystem"
      end

      def pipe
	raise NotImplementedError, "The pipe() function is not implemented to ZipFileSystem"
      end

      def readlines(fileName)
	open(fileName) { |is| is.readlines }
      end

      def popen(*args, &aProc)
	File.popen(*args, &aProc)
      end

      def foreach(fileName, aSep = $/, &aProc)
	open(fileName) { |is| is.each_line(aSep, &aProc) }
      end

      def delete(*args)
	args.each { 
	  |fileName|
	  if directory?(fileName)
	    raise Errno::EISDIR, "Is a directory - \"#{fileName}\""
	  end
	  @zipFile.remove(fileName) 
	}
      end

      alias :unlink :delete

    end
  end

  class ZipFile
    include ZipFileSystem
  end
end

